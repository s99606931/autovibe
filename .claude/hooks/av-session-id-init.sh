#!/usr/bin/env bash
# name: av-session-id-init
# autovibe: true
# version: 1.0
# created: 2026-05-13
# hook-type: SessionStart (startup|resume)
# description: 세션 식별자 UUID를 .claude/state/session.id 에 생성/확인하여
#              av-base-task-lock 이 일관된 owner로 동작하게 한다.

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="${CLAUDE_PROJECT_DIR}/.claude/state"
SESSION_FILE="${STATE_DIR}/session.id"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/session-id.log"

mkdir -p "$STATE_DIR" "$(dirname "$LOG_FILE")"

now() { date +"%Y-%m-%dT%H:%M:%S"; }

if [ ! -f "$SESSION_FILE" ]; then
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen > "$SESSION_FILE"
  elif [ -r /proc/sys/kernel/random/uuid ]; then
    cat /proc/sys/kernel/random/uuid > "$SESSION_FILE"
  else
    echo "auto-$$@$(hostname -s 2>/dev/null || echo unknown)-$(date +%s)" > "$SESSION_FILE"
  fi
  echo "[$(now)] created session.id=$(cat "$SESSION_FILE")" >> "$LOG_FILE"
else
  echo "[$(now)] reuse session.id=$(cat "$SESSION_FILE")" >> "$LOG_FILE"
fi

# 만료 락 일괄 정리 (best-effort)
LOCK_SH="${CLAUDE_PROJECT_DIR}/.claude/skills/av-base-task-lock/lock.sh"
if [ -x "$LOCK_SH" ]; then
  "$LOCK_SH" prune >/dev/null 2>&1 || true
fi

exit 0
