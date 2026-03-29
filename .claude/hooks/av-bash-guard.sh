#!/bin/bash
# name: av-bash-guard
# autovibe: true
# version: 2.0
# created: 2026-03-29
# hook-type: PreToolUse
# trigger-tools: Bash
# description: 위험 Bash 명령어 차단 — settings.json if 조건과 연동

set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

BLOCKED_PATTERNS=(
  "rm -rf /"
  "sudo rm"
  "DROP TABLE"
  "DELETE FROM.*WHERE 1=1"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "[av-bash-guard] 차단: $pattern" >&2
    exit 2
  fi
done

exit 0
