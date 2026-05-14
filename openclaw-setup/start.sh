#!/usr/bin/env bash
# OpenClaw 시작 스크립트 — 프록시 + 게이트웨이 한 번에 실행
set -e

PROXY_PORT=11435
GW_PORT=18789
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROXY_LOG=/tmp/openclaw-proxy.log
GW_LOG=/tmp/openclaw-gateway.log

stop_all() {
  echo "[stop] 프록시/게이트웨이 종료 중..."
  fuser -k ${PROXY_PORT}/tcp 2>/dev/null || true
  fuser -k ${GW_PORT}/tcp   2>/dev/null || true
  echo "[stop] 완료"
}

# --stop 옵션
if [[ "$1" == "--stop" ]]; then
  stop_all
  exit 0
fi

# --restart 옵션
if [[ "$1" == "--restart" ]]; then
  stop_all
  sleep 1
fi

echo "=============================="
echo " OpenClaw 시작"
echo "=============================="

# 1. LMStudio 연결 확인
echo "[1/3] LMStudio 연결 확인 (127.0.0.1:1234)..."
if ! curl -sf http://127.0.0.1:1234/v1/models > /dev/null 2>&1; then
  echo "  ✗ LMStudio가 응답하지 않습니다."
  echo "  → LMStudio 앱에서 qwen/qwen3.5-9b 로드 후 Start Server 클릭하세요."
  exit 1
fi
echo "  ✓ LMStudio 연결 OK"

# 2. 기존 프로세스 정리
fuser -k ${PROXY_PORT}/tcp 2>/dev/null || true
fuser -k ${GW_PORT}/tcp   2>/dev/null || true
sleep 0.5

# 3. 스마트 프록시 시작
echo "[2/3] 스마트 프록시 시작 (포트 ${PROXY_PORT})..."
node "${SCRIPT_DIR}/smart-proxy.js" > "${PROXY_LOG}" 2>&1 &
PROXY_PID=$!
sleep 1

if ! kill -0 "${PROXY_PID}" 2>/dev/null; then
  echo "  ✗ 프록시 시작 실패. 로그: ${PROXY_LOG}"
  cat "${PROXY_LOG}"
  exit 1
fi
echo "  ✓ 프록시 실행 중 (PID: ${PROXY_PID})"

# 4. OpenClaw 게이트웨이 시작
echo "[3/3] OpenClaw 게이트웨이 시작 (포트 ${GW_PORT})..."
openclaw gateway --port "${GW_PORT}" > "${GW_LOG}" 2>&1 &
GW_PID=$!

# ready 대기 (최대 15초)
for i in $(seq 1 15); do
  sleep 1
  if grep -q "ready" "${GW_LOG}" 2>/dev/null; then
    break
  fi
  if ! kill -0 "${GW_PID}" 2>/dev/null; then
    echo "  ✗ 게이트웨이 시작 실패. 로그: ${GW_LOG}"
    tail -10 "${GW_LOG}"
    stop_all
    exit 1
  fi
done

if ! grep -q "ready" "${GW_LOG}" 2>/dev/null; then
  echo "  ✗ 게이트웨이 타임아웃. 로그: ${GW_LOG}"
  tail -5 "${GW_LOG}"
  stop_all
  exit 1
fi

MODEL=$(grep "agent model:" "${GW_LOG}" 2>/dev/null | sed 's/.*agent model: //' | sed 's/ (.*//')
echo "  ✓ 게이트웨이 실행 중 (PID: ${GW_PID})"
echo "  ✓ 모델: ${MODEL}"

echo ""
echo "=============================="
echo " 준비 완료!"
echo "=============================="
echo " 채팅: openclaw agent --agent main --message \"안녕!\""
echo " 로그: tail -f ${PROXY_LOG}"
echo "       tail -f ${GW_LOG}"
echo " 종료: bash ${SCRIPT_DIR}/start.sh --stop"
echo "=============================="
