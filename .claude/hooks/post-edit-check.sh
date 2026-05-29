#!/usr/bin/env bash
# PostToolUse hook: fires on Edit/Write to any beagle source file.
# Runs the structural delimiter check first (cheap, catches paren-balance
# errors immediately) and, when delimiters pass, the schema validator.
# Output goes to stderr so the agent sees actionable repair hints
# without polluting tool output.
set -euo pipefail

BEAGLE_PATH="${BEAGLE_PATH:-$(cd "$(dirname "$0")/../../../beagle" && pwd)}"
SYNTAX="$BEAGLE_PATH/bin/beagle-syntax"
VALIDATE="$BEAGLE_PATH/bin/beagle-validate"

# Claude Code passes the modified file paths via $CLAUDE_FILE_PATHS
# (newline-separated). Older versions used $TOOL_INPUT — try both.
PATHS="${CLAUDE_FILE_PATHS:-${TOOL_INPUT:-}}"

# Filter to beagle source files only.
BNIX=()
while IFS= read -r p; do
  case "$p" in
    *.bnix|*.bgl|*.bclj|*.bjs|*.bsql|*.bpy) BNIX+=("$p") ;;
  esac
done <<< "$PATHS"

if [[ ${#BNIX[@]} -eq 0 ]]; then exit 0; fi

# Structural delimiter check — fix these before anything else.
for f in "${BNIX[@]}"; do
  [[ -f "$f" ]] || continue
  if ! "$SYNTAX" "$f" 2>/dev/null; then
    echo "✗ syntax error in $f" >&2
    "$SYNTAX" --ledger "$f" 2>&1 | tail -10 >&2 || true
    echo "  → try: $SYNTAX --repair --emit-patch $f" >&2
    exit 1
  fi
done

# Validator — schema-driven option-path and type check.
# Run with the edited files as scope, not the whole tree (faster on edit).
if [[ -x "$VALIDATE" ]]; then
  cd "$(dirname "$(realpath "${BNIX[0]}")")" 2>/dev/null || true
  "$VALIDATE" "${BNIX[@]}" 2>&1 | head -20 >&2 || true
fi
exit 0
