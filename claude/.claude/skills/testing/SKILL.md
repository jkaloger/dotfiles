---
name: testing
description: Use when designing, structuring, or reviewing tests — deciding what to test, choosing test doubles/fakes, organizing suites, or driving implementation test-first (red-green-refactor TDD). Trigger this whenever you are about to write or change tests, add a feature that needs coverage, or are asked "how should I test this?", even if the user does not say the word "test".
---

# Testing

## Core stance

A test is a claim about behaviour: "given this input or state, the system produces this output or effect." Good tests pin down the contract a caller depends on. Bad tests pin down how the code happens to be written today, so they break the moment you refactor and tell you nothing when behaviour regresses.

Three failure modes account for most bad tests. This skill exists to prevent them:

1. **Written after the fact**, so they restate the code instead of specifying behaviour.
2. **Coupled to structure**, so a behaviour-preserving refactor breaks them.
3. **Asserting the recipe, not the result**, so they pass even when the result is wrong.

The fixes are connected. Write the test first and you can't restate code that doesn't exist yet. Assert observable outcomes and a refactor can't break you. Most of this skill is those two ideas applied.

## Default loop: red → green → refactor (Kent Beck TDD)

Write tests first, by default. Not as ceremony — because it changes *what* you test.

- **Red.** Write one small failing test that names a behaviour you want. Run it. Watch it fail for the reason you expect (a wrong assertion failure, not a typo or missing import). A test you never saw fail is a test you can't trust.
- **Green.** Write the least code that makes it pass. Resist building ahead of the test.
- **Refactor.** With the test green, improve the code's structure. The test holds the behaviour still while you move the parts.

Then repeat for the next behaviour. Stop when "fear has turned to boredom" (Beck) — when remaining cases are variations you're confident in, not risks.

**Why first, not after.** A test written against code that already exists tends to mirror that code: same branches, same intermediate values, same shape. A test written against a behaviour you want describes the *contract* — you're forced to pick an interface and a concrete expected result before any implementation exists to copy. That single ordering change is the cheapest cure for "tests that just replicate the code."

```rust
// RED — the function does not exist yet. You specify behaviour, not implementation.
#[test]
fn rounds_half_to_even() {
    assert_eq!(round_banker(2.5), 2.0);
    assert_eq!(round_banker(3.5), 4.0);
}
// `cargo test` fails to compile → write the minimal `round_banker`, run again → green.
```

When code already exists (you're adding coverage to legacy code), you can't write it first. Recover the intent instead: write the test against the behaviour you believe is *required*, from the caller's point of view — never by reading the implementation and echoing its arithmetic back as the expected value.

## Test behaviour, not structure

**The litmus test, applied before every assertion:** *If I rewrote the implementation but kept the contract, would this assertion still hold?* If no, you're testing structure, and the test will break on refactors while missing real bugs.

Two structural smells dominate.

### Smell 1: re-deriving the implementation as the expected value

```ts
class PriceCalculator {
  constructor(private taxRate: number) {}
  total(subtotal: number) { return subtotal + subtotal * this.taxRate; }
}

// BAD — the expected value recomputes the implementation's formula.
test("total", () => {
  const calc = new PriceCalculator(0.1);
  const subtotal = 100;
  const tax = subtotal * 0.1;                  // same arithmetic as the code
  expect(calc.total(subtotal)).toBe(subtotal + tax);
});
```

If the formula is wrong, the test is wrong in exactly the same way, so it passes. It also breaks whenever the formula is refactored. It asserts nothing a reader didn't already see in the code.

```ts
// GOOD — a concrete result the reader can verify by hand, independent of the code.
test("adds 10% tax to the subtotal", () => {
  expect(new PriceCalculator(0.1).total(100)).toBe(110);
});
```

Pick expected values you computed independently (by hand, from a spec, from a known-good fixture), never by running the formula the code uses.

### Smell 2: asserting *how* instead of *what* (over-mocking)

```ts
// BAD — asserts the call sequence to collaborators: pure structure.
test("checkout", () => {
  const repo = { save: vi.fn() };
  const logger = { info: vi.fn() };
  new Checkout(repo, logger).run(cart);
  expect(repo.save).toHaveBeenCalledWith(/* exact shape */);  // welds to internals
  expect(logger.info).toHaveBeenCalledTimes(2);               // breaks on an added log line
});
```

Asserting call counts and argument shapes on mocked collaborators ties the test to the implementation's wiring. Rename a method, reorder two calls, add a log statement — behaviour identical, test red.

```ts
// GOOD — assert the resulting state through the same interface a real caller would observe.
test("persists a paid order for the cart", () => {
  const repo = new InMemoryOrderRepo();          // a fake, not a call-spy
  new Checkout(repo, noopLogger).run(cart);
  expect(repo.findById(cart.id)).toMatchObject({ status: "paid", total: 110 });
});
```

Reserve "verify the call happened" assertions for cases where the call *is* the observable behaviour — e.g. that an email was actually sent — and even then assert against a fake's recorded state ("one email queued to X"), not a mock's invocation log.

## Test doubles: prefer real, fake at the boundary

Default to the real collaborator when it's deterministic and cheap. Each double you introduce is a place the test can diverge from reality.

Replace a collaborator only when it is **slow, non-deterministic, has side effects, or isn't built yet** — typically the system's edges: network, database, filesystem, clock, randomness, third-party services.

When you must substitute, prefer a **fake** (a working in-memory implementation of the real interface) over a **mock** (an object programmed with call expectations). Fakes let you assert on resulting state, which is behavioural and structure-insensitive; mocks pull you toward asserting calls, which is structural. Stubs (canned return values) are fine for feeding inputs; the trap is the *assertion side*.

Rough vocabulary: a **stub** answers queries with fixed data; a **fake** is a lightweight real implementation (in-memory repo, fake clock); a **mock** records and asserts interactions. Reach for them in that order of preference.

## Choosing the level: unit, integration, e2e

Define the levels by scope and what gets faked:

- **Unit** — one module/function; collaborators real if cheap, faked only at external edges. Milliseconds. You write many.
- **Integration** — several units wired with one real boundary (a real DB, a real HTTP server). Tens to hundreds of ms. Fewer.
- **e2e** — the whole system through its outermost interface (HTTP API, CLI, UI). Seconds. Fewest.

**Guiding rule: test each behaviour at the highest level that gives you confidence at acceptable cost, then push it as low as it will go without losing meaning.** Cost, flakiness, and poor failure-localization all rise with scope — an e2e failure tells you *something* broke, rarely *where*.

Default to a pyramid (many unit, fewer integration, fewest e2e) because that minimizes total cost for a given confidence. But the interesting behaviour decides the level, not dogma:

- A pure pricing rule or parser → unit. Mocking its inputs would just restate it.
- A CRUD endpoint whose real logic *is* the query + serialization + validation wiring → integration against a real database. A unit test that mocks the DB asserts only that you called the mock you wrote; it proves nothing about the behaviour users get.
- A critical multi-service flow (login, checkout) → one or two e2e tests for the happy path and top failure, not exhaustive branch coverage (that belongs lower, where it's cheap).

Frontend note: UI behaviour often lives in the integration band (render a component, interact, assert on what the user sees) rather than in unit tests of internals — weight accordingly.

## Beck's test desiderata (review checklist)

Kent Beck's properties of a good test, as a quick screen. The ones tied to the user's recurring pains are first:

- **Behavioral** — sensitive to behaviour changes (a bug must fail a test).
- **Structure-insensitive** — *not* sensitive to behaviour-preserving refactors. (This is smells 1 and 2 above.)
- **Specific** — a failure points at one cause, not "something, somewhere."
- **Deterministic** — same result every run; no reliance on clock, ordering, network, or shared mutable state.
- **Fast** — fast enough that you run them constantly.
- **Readable** — the test names the behaviour and reads as a small example; a reader learns the contract from it.
- **Isolated** — order-independent, no leaked state between tests.

If a test fails Behavioral or Structure-insensitive, it is actively harmful — rewrite it, don't patch it.

## Red flags

- Expected value is computed by the same expression the code under test uses.
- Assertions are mostly `toHaveBeenCalled` / call-count / argument-shape on mocks.
- The test imports or reaches into private members, internal modules, or implementation files.
- A behaviour-preserving refactor required editing tests (the defining symptom of structural coupling).
- One test asserts many unrelated things, so a failure doesn't localize.
- Tests share mutable fixtures and pass only in a particular order.
- Coverage of trivial code (plain getters, framework glue) while branch logic goes untested.
- Snapshot tests used as the primary assertion for logic — they detect *change*, not *correctness*, and get blindly re-blessed.

## What not to test

Don't test the language, the framework, or third-party libraries — assume they work. Don't chase 100% coverage; cover behaviour and risk. Stop when added tests only restate cases already covered (Beck's "fear into boredom"). A test that can never fail for a real bug is cost without value — delete it.
