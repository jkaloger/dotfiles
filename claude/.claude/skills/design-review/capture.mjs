#!/usr/bin/env node
// Sandboxed browser capture for design review.
// Drives Playwright but ABORTS every request whose origin is not on the
// allowlist, so a compromised/injected page cannot exfiltrate or reach the
// wider network from inside the sandbox. Refuses non-loopback targets unless
// --allow-remote is passed AND the host is explicitly listed in allowOrigins.
//
// Usage: node capture.mjs <manifest.json> [--allow-remote]
// Requires: npm i -D playwright && npx playwright install chromium
//
// Reads the manifest, captures one PNG per (set x viewport), and writes the
// resulting paths back into each set's `actual` map. Leaves `intended`,
// `findings`, and `manual` untouched.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { chromium } from "playwright";

const LOOPBACK = new Set(["localhost", "127.0.0.1", "0.0.0.0", "::1", "[::1]"]);

const manifestPath = process.argv[2];
const allowRemote = process.argv.includes("--allow-remote");
const tag = (process.argv.find((a) => a.startsWith("--tag=")) ?? "").slice(6);
if (!manifestPath) {
  console.error("usage: node capture.mjs <manifest.json> [--allow-remote]");
  process.exit(2);
}

const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const root = dirname(resolve(manifestPath));
const outDir = resolve(root, manifest.outDir ?? "review");
const baseUrl = new URL(manifest.baseUrl);

// Allowlist = configured origins + the base origin. Loopback is the default
// contract; anything else must be opted into explicitly.
const allow = new Set([baseUrl.origin, ...(manifest.allowOrigins ?? [])]);
if (!LOOPBACK.has(baseUrl.hostname) && !allowRemote) {
  console.error(
    `refusing non-loopback target ${baseUrl.origin}. Pass --allow-remote and ` +
      `list it in manifest.allowOrigins if this is intentional.`,
  );
  process.exit(2);
}

const viewports = manifest.viewports ?? [
  { name: "desktop", width: 1440, height: 900, scale: 2 },
];

let aborted = 0;
const abortedHosts = new Set();

const browser = await chromium.launch({ headless: true });
try {
  for (const vp of viewports) {
    const context = await browser.newContext({
      viewport: { width: vp.width, height: vp.height },
      deviceScaleFactor: vp.scale ?? 2,
      reducedMotion: "reduce",
    });

    // Origin allowlist enforcement. Non-allowlisted requests never leave.
    await context.route("**/*", (route) => {
      const url = new URL(route.request().url());
      if (url.protocol === "data:" || allow.has(url.origin)) return route.continue();
      aborted++;
      abortedHosts.add(url.origin);
      return route.abort();
    });

    const page = await context.newPage();
    // Kill popups; a review capture never needs a second window.
    context.on("page", (p) => {
      if (p !== page) p.close().catch(() => {});
    });

    for (const set of manifest.sets) {
      // --tag isolates a run under its own subdir so re-runs don't overwrite
      // the previous capture (before/after for the fix loop).
      const dir = join(outDir, "shots", "app", tag);
      mkdirSync(dir, { recursive: true });
      const file = join(dir, `${set.id}__${vp.name}.png`);

      await page.goto(new URL(set.route ?? "/", baseUrl).href, {
        waitUntil: "networkidle",
        timeout: 30_000,
      });
      await runSteps(page, set.steps ?? []);
      if (set.waitFor) await page.waitForSelector(set.waitFor, { timeout: 15_000 });
      await page.evaluate(() => document.fonts.ready);

      // Mask nondeterministic regions (dates, avatars, random data) so re-runs
      // don't produce phantom diffs.
      const mask = (set.mask ?? []).map((s) => page.locator(s));
      if (set.clip) {
        const el = await page.waitForSelector(set.clip, { timeout: 15_000 });
        await el.screenshot({ path: file, mask });
      } else {
        // fullPage defaults on for plain page shots, off once steps run (the
        // post-interaction state is usually above the fold). Override per set.
        const fullPage = set.fullPage ?? !set.steps?.length;
        await page.screenshot({ path: file, fullPage, mask });
      }

      set.actual ??= {};
      set.actual[vp.name] = relative(outDir, file, root);
      console.log(`captured ${set.id} @ ${vp.name}`);
    }
    await context.close();
  }
} finally {
  await browser.close();
}

writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n");
console.log(
  `\nwrote actual paths to ${manifestPath}. ` +
    `blocked ${aborted} off-allowlist request(s)` +
    (abortedHosts.size ? ` to: ${[...abortedHosts].join(", ")}` : ""),
);

async function runSteps(page, steps) {
  for (const s of steps) {
    if (s.goto) await page.goto(new URL(s.goto, baseUrl).href, { waitUntil: "networkidle" });
    if (s.hover) await page.hover(s.hover);
    if (s.click) await page.click(s.click);
    if (s.fill) await page.fill(s.fill, s.value ?? "");
    if (s.press) await page.keyboard.press(s.press);
    if (s.waitFor) await page.waitForSelector(s.waitFor, { timeout: 15_000 });
  }
}

function relative(_outDir, file, from) {
  // manifest-relative path so report.html (opened from repo root) resolves images
  return file.slice(resolve(from).length + 1);
}
