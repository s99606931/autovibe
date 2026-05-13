#!/usr/bin/env bash
# name: av-pm-team-lock-check
# autovibe: true
# version: 1.0
# created: 2026-05-13
# hook-type: UserPromptSubmit
# description: /av pm, /av-pm, "pm team" 패턴 감지 시 현재 활성 락을
#              컨텍스트로 주입하여 PM/PL이 충돌을 사전 인지하게 한다.

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROMPT="${CLAUDE_USER_PROMPT:-}"
LOCK_SH="${CLAUDE_PROJECT_DIR}/.claude/skills/av-base-task-lock/lock.sh"

# 트리거 패턴: /av pm, /av-pm, pm team, av-pm-coordinator
if ! echo "$PROMPT" | grep -qiE '(/av[ -]?pm|av-pm-coordinator|pm[ -]?team|av-do-orchestrator)'; then
  exit 0
fi

[ -x "$LOCK_SH" ] || exit 0

# 활성 락 조회 (best-effort)
LIST_JSON=$("$LOCK_SH" list 2>/dev/null || echo '{"count":0}')

if command -v jq >/dev/null 2>&1; then
  COUNT=$(echo "$LIST_JSON" | jq -r '.count // 0')
  if [ "$COUNT" -gt 0 ]; then
    ACTIVE=$(echo "$LIST_JSON" | jq -r '.locks[] | select(.held==true) | "  - \(.key) (owner: \(.owner[0:8]), 만료: \(.expires_at_epoch))"')
    if [ -n "$ACTIVE" ]; then
      echo "[av-task-lock] 현재 활성 락 — PM/PL은 acquire 전에 충돌 여부 확인:"
      echo "$ACTIVE"
      echo "[av-task-lock] 사용법: Skill(\"av-base-task-lock\", \"acquire feature:{key}\")"
    fi
  fi
fi

exit 0
