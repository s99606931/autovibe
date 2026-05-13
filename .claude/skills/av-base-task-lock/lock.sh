#!/usr/bin/env bash
# av-base-task-lock — 멀티 세션 작업 락 (flock atomic)
#
# 사용:
#   lock.sh acquire <key> [ttl_seconds]     # 기본 TTL 300초 (5분)
#   lock.sh release <key>
#   lock.sh status <key>
#   lock.sh list
#   lock.sh heartbeat <key>
#   lock.sh prune                           # 만료 락 일괄 정리
#
# 출력: JSON ({ ok, op, key, owner, expires_at, ... })
# 종료 코드: 0 = 성공/이미 보유, 10 = 충돌(다른 세션 점유), 1 = 사용자 오류

set -euo pipefail

# ───── 환경 ─────
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOCKS_DIR="${CLAUDE_PROJECT_DIR}/.claude/state/locks"
SESSION_FILE="${CLAUDE_PROJECT_DIR}/.claude/state/session.id"
FLOCK_FD="${FLOCK_FD:-9}"
DEFAULT_TTL=300

mkdir -p "$LOCKS_DIR"

# ───── 세션 식별자 (idempotent — 처음 호출 시 자동 생성하여 영구 보존) ─────
session_id() {
  if [ ! -f "$SESSION_FILE" ]; then
    mkdir -p "$(dirname "$SESSION_FILE")"
    if command -v uuidgen >/dev/null 2>&1; then
      uuidgen > "$SESSION_FILE"
    elif [ -r /proc/sys/kernel/random/uuid ]; then
      cat /proc/sys/kernel/random/uuid > "$SESSION_FILE"
    else
      echo "auto-$$@$(hostname -s 2>/dev/null || echo unknown)-$(date +%s)" > "$SESSION_FILE"
    fi
  fi
  cat "$SESSION_FILE"
}

# ───── 키 유효성 ─────
validate_key() {
  local k="$1"
  if [[ ! "$k" =~ ^[a-zA-Z0-9_:.-]+$ ]]; then
    echo '{"ok":false,"error":"invalid key (allowed: A-Z a-z 0-9 _ : . -)"}'
    exit 1
  fi
}

# ───── 시간 ─────
now() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
epoch() { date -u +%s; }

# ───── JSON 헬퍼 (jq 없을 때도 동작) ─────
emit() {
  if command -v jq >/dev/null 2>&1; then
    jq -nc "$@"
  else
    # 매우 단순한 fallback — jq가 없을 가능성 거의 없으나 안전망
    printf '%s\n' "$1"
  fi
}

# ───── flock으로 lock 파일 보호 ─────
with_flock() {
  local lockfile="$1"; shift
  exec 9>"$lockfile.flock"
  flock -x 9
  "$@"
  local rc=$?
  flock -u 9
  return $rc
}

# ───── acquire ─────
op_acquire() {
  local key="$1"
  local ttl="${2:-$DEFAULT_TTL}"
  validate_key "$key"
  local lockfile="$LOCKS_DIR/$key.lock.json"
  local sid; sid=$(session_id)
  local now_ts; now_ts=$(epoch)
  local exp=$((now_ts + ttl))

  with_flock "$lockfile" _acquire_inner "$lockfile" "$key" "$sid" "$now_ts" "$exp" "$ttl"
}

_acquire_inner() {
  local lockfile="$1" key="$2" sid="$3" now_ts="$4" exp="$5" ttl="$6"

  if [ -f "$lockfile" ] && command -v jq >/dev/null 2>&1; then
    local cur_owner cur_exp
    cur_owner=$(jq -r '.owner // ""' "$lockfile" 2>/dev/null || echo "")
    cur_exp=$(jq -r '.expires_at_epoch // 0' "$lockfile" 2>/dev/null || echo "0")

    # 같은 세션이면 이미 보유 — heartbeat 효과
    if [ "$cur_owner" = "$sid" ]; then
      _write_lock "$lockfile" "$key" "$sid" "$exp" "$ttl"
      jq -nc --arg key "$key" --arg owner "$sid" --argjson exp "$exp" \
        '{ok:true,op:"acquire",key:$key,owner:$owner,expires_at_epoch:$exp,note:"renewed (same session)"}'
      return 0
    fi

    # 다른 세션이 보유 중이고 아직 만료 전 → 충돌
    if [ -n "$cur_owner" ] && [ "$cur_exp" -gt "$now_ts" ] 2>/dev/null; then
      jq -nc --arg key "$key" --arg cur "$cur_owner" --argjson cur_exp "$cur_exp" \
        '{ok:false,op:"acquire",key:$key,conflict:true,current_owner:$cur,current_expires_at_epoch:$cur_exp}'
      return 10
    fi
    # 만료됨 → 우리가 인수
  fi

  _write_lock "$lockfile" "$key" "$sid" "$exp" "$ttl"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg key "$key" --arg owner "$sid" --argjson exp "$exp" \
      '{ok:true,op:"acquire",key:$key,owner:$owner,expires_at_epoch:$exp}'
  else
    echo "{\"ok\":true,\"op\":\"acquire\",\"key\":\"$key\",\"owner\":\"$sid\",\"expires_at_epoch\":$exp}"
  fi
}

_write_lock() {
  local lockfile="$1" key="$2" sid="$3" exp="$4" ttl="$5"
  local now_iso; now_iso=$(now)
  cat > "$lockfile" <<EOF
{
  "key": "$key",
  "owner": "$sid",
  "acquired_at": "$now_iso",
  "expires_at_epoch": $exp,
  "ttl_seconds": $ttl
}
EOF
}

# ───── release ─────
op_release() {
  local key="$1"
  validate_key "$key"
  local lockfile="$LOCKS_DIR/$key.lock.json"
  local sid; sid=$(session_id)

  with_flock "$lockfile" _release_inner "$lockfile" "$key" "$sid"
}

_release_inner() {
  local lockfile="$1" key="$2" sid="$3"
  if [ ! -f "$lockfile" ]; then
    echo "{\"ok\":true,\"op\":\"release\",\"key\":\"$key\",\"note\":\"no lock found\"}"
    return 0
  fi

  local cur_owner=""
  if command -v jq >/dev/null 2>&1; then
    cur_owner=$(jq -r '.owner // ""' "$lockfile" 2>/dev/null || echo "")
  fi

  if [ -n "$cur_owner" ] && [ "$cur_owner" != "$sid" ]; then
    echo "{\"ok\":false,\"op\":\"release\",\"key\":\"$key\",\"error\":\"not owner\",\"current_owner\":\"$cur_owner\"}"
    return 10
  fi

  rm -f "$lockfile" "$lockfile.flock"
  echo "{\"ok\":true,\"op\":\"release\",\"key\":\"$key\"}"
}

# ───── status ─────
op_status() {
  local key="$1"
  validate_key "$key"
  local lockfile="$LOCKS_DIR/$key.lock.json"
  if [ ! -f "$lockfile" ]; then
    echo "{\"ok\":true,\"op\":\"status\",\"key\":\"$key\",\"held\":false}"
    return 0
  fi
  if command -v jq >/dev/null 2>&1; then
    local now_ts; now_ts=$(epoch)
    jq -c --argjson now "$now_ts" \
      '. + {ok:true,op:"status",held:(.expires_at_epoch > $now),expired:(.expires_at_epoch <= $now)}' \
      "$lockfile"
  else
    cat "$lockfile"
  fi
}

# ───── list ─────
op_list() {
  local now_ts; now_ts=$(epoch)
  shopt -s nullglob
  local files=("$LOCKS_DIR"/*.lock.json)
  shopt -u nullglob
  if [ ${#files[@]} -eq 0 ]; then
    echo '{"ok":true,"op":"list","count":0,"locks":[]}'
    return 0
  fi
  if command -v jq >/dev/null 2>&1; then
    jq -sc --argjson now "$now_ts" \
      'map(. + {held:(.expires_at_epoch > $now),expired:(.expires_at_epoch <= $now)})
       | {ok:true,op:"list",count:length,locks:.}' \
      "${files[@]}"
  else
    echo '{"ok":true,"op":"list","raw":true,"files":['"${files[*]}"']}'
  fi
}

# ───── heartbeat ─────
op_heartbeat() {
  local key="$1"
  validate_key "$key"
  local lockfile="$LOCKS_DIR/$key.lock.json"
  local sid; sid=$(session_id)

  if [ ! -f "$lockfile" ]; then
    echo "{\"ok\":false,\"op\":\"heartbeat\",\"key\":\"$key\",\"error\":\"no lock\"}"
    return 1
  fi

  if command -v jq >/dev/null 2>&1; then
    local cur_owner ttl
    cur_owner=$(jq -r '.owner // ""' "$lockfile")
    ttl=$(jq -r '.ttl_seconds // 300' "$lockfile")
    if [ "$cur_owner" != "$sid" ]; then
      echo "{\"ok\":false,\"op\":\"heartbeat\",\"key\":\"$key\",\"error\":\"not owner\",\"current_owner\":\"$cur_owner\"}"
      return 10
    fi
    op_acquire "$key" "$ttl"
  else
    op_acquire "$key" "$DEFAULT_TTL"
  fi
}

# ───── prune ─────
op_prune() {
  local now_ts; now_ts=$(epoch)
  local removed=0
  shopt -s nullglob
  for f in "$LOCKS_DIR"/*.lock.json; do
    local exp=0
    if command -v jq >/dev/null 2>&1; then
      exp=$(jq -r '.expires_at_epoch // 0' "$f" 2>/dev/null || echo 0)
    fi
    if [ "$exp" -le "$now_ts" ] 2>/dev/null; then
      rm -f "$f" "$f.flock"
      removed=$((removed + 1))
    fi
  done
  shopt -u nullglob
  echo "{\"ok\":true,\"op\":\"prune\",\"removed\":$removed}"
}

# ───── usage ─────
usage() {
  cat <<EOF
av-base-task-lock — 멀티 세션 작업 락

사용:
  $0 acquire <key> [ttl_seconds]
  $0 release <key>
  $0 status <key>
  $0 list
  $0 heartbeat <key>
  $0 prune

키 규칙: ^[a-zA-Z0-9_:.-]+\$ (예: order-refund, user.auth, sprint:m1)
종료 코드: 0=성공, 10=충돌/소유권 없음, 1=사용자 오류
EOF
  exit 1
}

# ───── 디스패치 ─────
[ $# -lt 1 ] && usage
op="$1"; shift || true
case "$op" in
  acquire)   [ $# -ge 1 ] || usage; op_acquire "$@" ;;
  release)   [ $# -ge 1 ] || usage; op_release "$@" ;;
  status)    [ $# -ge 1 ] || usage; op_status "$@" ;;
  heartbeat) [ $# -ge 1 ] || usage; op_heartbeat "$@" ;;
  list)      op_list ;;
  prune)     op_prune ;;
  -h|--help|help) usage ;;
  *) usage ;;
esac
