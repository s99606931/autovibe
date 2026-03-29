#!/bin/bash
# name: av-content-scanner
# autovibe: true
# version: 1.0
# created: 2026-03-29
# hook-type: PreToolUse
# trigger-tools: Write, Edit
# description: Write/Edit 전 내용 검사 — 민감 정보 유출 방지

set -euo pipefail
INPUT=$(cat)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""' 2>/dev/null || echo "")

SENSITIVE_PATTERNS=(
  "AKIA[A-Z0-9]{16}"
  "sk-[a-zA-Z0-9]{48}"
  "ghp_[a-zA-Z0-9]{36}"
  "password\s*=\s*['\"][^'\"]+['\"]"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE "$pattern"; then
    echo "[av-content-scanner] 민감 정보 감지 — 작성 차단" >&2
    exit 2
  fi
done

exit 0
