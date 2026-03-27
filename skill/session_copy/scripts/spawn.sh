#!/bin/bash
# spawn.sh — Open iTerm2 tabs via AppleScript
# Usage: spawn.sh <claude_tabs> <plain_tabs> <target_dir>

CLAUDE_TABS="${1:-0}"
PLAIN_TABS="${2:-0}"
TARGET_DIR="${3:-$(pwd)}"

# Validate
if ! [[ "$CLAUDE_TABS" =~ ^[0-9]+$ ]] || ! [[ "$PLAIN_TABS" =~ ^[0-9]+$ ]]; then
  echo "Error: arguments must be integers" >&2
  exit 1
fi

if [ "$CLAUDE_TABS" -gt 5 ]; then
  CLAUDE_TABS=5
fi

TOTAL=$((CLAUDE_TABS + PLAIN_TABS))
if [ "$TOTAL" -eq 0 ]; then
  echo "Nothing to open." >&2
  exit 0
fi

# Build AppleScript
SCRIPT='tell application "iTerm2"
  tell current window'

for ((i = 1; i <= CLAUDE_TABS; i++)); do
  SCRIPT+='
    create tab with default profile
    tell current session of current tab
      write text "cd '"'$TARGET_DIR'"' && claude --dangerously-skip-permissions"
    end tell'
done

for ((i = 1; i <= PLAIN_TABS; i++)); do
  SCRIPT+='
    create tab with default profile
    tell current session of current tab
      write text "cd '"'$TARGET_DIR'"'"
    end tell'
done

SCRIPT+='
  end tell
end tell'

osascript -e "$SCRIPT"

echo "Opened ${CLAUDE_TABS} Claude tab(s) + ${PLAIN_TABS} plain tab(s) in ${TARGET_DIR}"
