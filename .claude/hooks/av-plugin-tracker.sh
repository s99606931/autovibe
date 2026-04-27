#!/bin/bash
# name: av-plugin-tracker
# autovibe: true
# version: 1.0
# created: 2026-04-27
# hook-type: SessionStart
# matcher: startup
# description: 외부 플러그인(bkit/gstack/ECC) 버전 자동 감지 + drift 알림

set -euo pipefail

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="${CLAUDE_PROJECT_DIR}/.claude/state/plugin-versions.json"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/plugin-tracker.log"
mkdir -p "$(dirname "$STATE_FILE")" "$(dirname "$LOG_FILE")"

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

# 현재 버전 감지
detect_bkit() {
  local v=""
  if command -v bkit >/dev/null 2>&1; then
    v=$(bkit --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  fi
  # CLAUDE.md에 기록된 버전도 확인
  if [ -z "$v" ] && [ -f "${CLAUDE_PROJECT_DIR}/CLAUDE.md" ]; then
    v=$(grep -oP 'bkit v?\K[0-9]+\.[0-9]+\.[0-9]+' "${CLAUDE_PROJECT_DIR}/CLAUDE.md" | head -1)
  fi
  echo "${v:-unknown}"
}

detect_gstack() {
  local v=""
  if command -v gstack >/dev/null 2>&1; then
    v=$(gstack --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  fi
  if [ -z "$v" ] && [ -f "${CLAUDE_PROJECT_DIR}/CLAUDE.md" ]; then
    v=$(grep -oP 'gstack v?\K[0-9]+\.[0-9]+(\.[0-9]+)?' "${CLAUDE_PROJECT_DIR}/CLAUDE.md" | head -1)
  fi
  echo "${v:-unknown}"
}

detect_ecc() {
  local count=0
  local ecc_dir="${HOME}/.claude/plugins/everything-claude-code"
  if [ -d "$ecc_dir/skills" ]; then
    count=$(find "$ecc_dir/skills" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l)
  fi
  echo "${count}"
}

CURRENT_BKIT=$(detect_bkit)
CURRENT_GSTACK=$(detect_gstack)
CURRENT_ECC=$(detect_ecc)

# 이전 상태와 비교
DRIFT_DETECTED=0
DRIFT_MSG=""

if [ -f "$STATE_FILE" ] && command -v jq >/dev/null 2>&1; then
  PREV_BKIT=$(jq -r '.bkit // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  PREV_GSTACK=$(jq -r '.gstack // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  PREV_ECC=$(jq -r '.ecc_skill_count // 0' "$STATE_FILE" 2>/dev/null || echo "0")

  if [ "$PREV_BKIT" != "$CURRENT_BKIT" ] && [ "$CURRENT_BKIT" != "unknown" ]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+=" bkit:${PREV_BKIT}→${CURRENT_BKIT}"
  fi
  if [ "$PREV_GSTACK" != "$CURRENT_GSTACK" ] && [ "$CURRENT_GSTACK" != "unknown" ]; then
    DRIFT_DETECTED=1
    DRIFT_MSG+=" gstack:${PREV_GSTACK}→${CURRENT_GSTACK}"
  fi
  if [ "$PREV_ECC" != "$CURRENT_ECC" ]; then
    DIFF=$((CURRENT_ECC - PREV_ECC))
    if [ "$DIFF" != "0" ]; then
      DRIFT_DETECTED=1
      DRIFT_MSG+=" ecc:${PREV_ECC}→${CURRENT_ECC}(${DIFF})"
    fi
  fi
fi

# 상태 파일 업데이트
cat > "$STATE_FILE" <<EOF
{
  "_meta": {
    "updated": "${TIMESTAMP}",
    "tracked_by": "av-plugin-tracker"
  },
  "bkit": "${CURRENT_BKIT}",
  "gstack": "${CURRENT_GSTACK}",
  "ecc_skill_count": ${CURRENT_ECC}
}
EOF

# 로그 기록
echo "${TIMESTAMP} | TRACK | bkit=${CURRENT_BKIT} gstack=${CURRENT_GSTACK} ecc=${CURRENT_ECC} drift=${DRIFT_DETECTED}" >> "$LOG_FILE"

# Drift 감지 시 사용자에게 알림
if [ "$DRIFT_DETECTED" = "1" ]; then
  echo "[av-plugin-tracker] 🔄 Plugin drift detected:${DRIFT_MSG}" >&2
  echo "[av-plugin-tracker] Run /av-vibe-forge sync to update CLAUDE.md & registry" >&2
fi

exit 0
