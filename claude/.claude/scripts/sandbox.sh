#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Walk settings in precedence order (first hit wins)
sandbox=false
for f in \
    "$CWD/.claude/settings.local.json" \
    "$CWD/.claude/settings.json" \
    "$HOME/.claude/settings.json"; do
    [ -f "$f" ] || continue
    val=$(jq -r '.sandbox.enabled // empty' "$f" 2>/dev/null)
    if [ -n "$val" ]; then sandbox="$val"; break; fi
done

GREEN='\033[32m'; DIM='\033[2m'; RESET='\033[0m'
if [ "$sandbox" = "true" ]; then
    tag="${GREEN}🛡 sandbox${RESET}"
else
    tag="${DIM}no sandbox${RESET}"
fi

printf '%b\n' "[$MODEL] $tag"
