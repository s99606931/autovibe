#!/usr/bin/env bash
# OpenClaw 설치 스크립트 (LMStudio + gemma-4-e4b-it)
# 사용법: bash install.sh [--daemon]
# 환경: WSL2 / Linux / macOS

set -euo pipefail

# ────────────────────────────────────────────────────────────────
# 상수
# ────────────────────────────────────────────────────────────────
LMSTUDIO_BASE_URL="http://192.168.0.104:1234"
LMSTUDIO_MODEL="gemma-4-e4b-it"
OPENCLAW_CONFIG_DIR="$HOME/.openclaw"
OPENCLAW_CONFIG_FILE="$OPENCLAW_CONFIG_DIR/openclaw.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DAEMON=false

# ────────────────────────────────────────────────────────────────
# 색상 출력
# ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ────────────────────────────────────────────────────────────────
# 인수 파싱
# ────────────────────────────────────────────────────────────────
for arg in "$@"; do
  [[ "$arg" == "--daemon" ]] && INSTALL_DAEMON=true
done

# ────────────────────────────────────────────────────────────────
# 1. Node.js 버전 확인
# ────────────────────────────────────────────────────────────────
check_node() {
  info "Node.js 버전 확인 중..."
  if ! command -v node &>/dev/null; then
    error "Node.js가 설치되지 않았습니다. Node 24 이상을 설치해 주세요.\n  https://nodejs.org 또는 nvm 사용 권장"
  fi

  local node_major
  node_major=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
  if (( node_major < 22 )); then
    error "Node.js $node_major 감지. OpenClaw는 Node 22.16+ (권장: 24) 가 필요합니다."
  fi
  success "Node.js v$(node -v | tr -d 'v') — 요구사항 충족"
}

# ────────────────────────────────────────────────────────────────
# 2. 패키지 매니저 선택
# ────────────────────────────────────────────────────────────────
detect_pkg_manager() {
  if command -v pnpm &>/dev/null; then
    PKG_MGR="pnpm"
    INSTALL_CMD="pnpm add -g"
  elif command -v npm &>/dev/null; then
    PKG_MGR="npm"
    INSTALL_CMD="npm install -g"
  else
    error "npm 또는 pnpm이 필요합니다."
  fi
  info "패키지 매니저: $PKG_MGR"
}

# ────────────────────────────────────────────────────────────────
# 3. OpenClaw 설치
# ────────────────────────────────────────────────────────────────
install_openclaw() {
  info "OpenClaw 최신 버전 설치 중..."
  $INSTALL_CMD openclaw@latest
  success "OpenClaw 설치 완료 — $(openclaw --version 2>/dev/null || echo 'version check failed')"
}

# ────────────────────────────────────────────────────────────────
# 4. LMStudio 연결 테스트
# ────────────────────────────────────────────────────────────────
check_lmstudio() {
  info "LMStudio 서버 연결 확인 중 ($LMSTUDIO_BASE_URL)..."
  if curl -sf "${LMSTUDIO_BASE_URL}/v1/models" -o /dev/null --max-time 5; then
    success "LMStudio 연결 성공"
    # 모델 목록 출력
    local models
    models=$(curl -sf "${LMSTUDIO_BASE_URL}/v1/models" | grep -o '"id":"[^"]*"' | sed 's/"id":"//;s/"//')
    if [ -n "$models" ]; then
      info "로드된 모델:\n$models"
    fi
  else
    warn "LMStudio에 연결할 수 없습니다. LMStudio를 실행하고 서버를 활성화한 후 다시 확인하세요."
    warn "계속 진행하지만 OpenClaw 실행 전 LMStudio를 시작해야 합니다."
  fi
}

# ────────────────────────────────────────────────────────────────
# 5. OpenClaw 설정 파일 생성
# ────────────────────────────────────────────────────────────────
write_config() {
  info "OpenClaw 설정 파일 생성 중: $OPENCLAW_CONFIG_FILE"
  mkdir -p "$OPENCLAW_CONFIG_DIR"

  # 기존 설정 백업
  if [ -f "$OPENCLAW_CONFIG_FILE" ]; then
    local backup="${OPENCLAW_CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$OPENCLAW_CONFIG_FILE" "$backup"
    warn "기존 설정을 백업했습니다: $backup"
  fi

  cat > "$OPENCLAW_CONFIG_FILE" << EOF
{
  "agent": {
    "model": "lmstudio/${LMSTUDIO_MODEL}"
  },
  "providers": {
    "lmstudio": {
      "baseUrl": "${LMSTUDIO_BASE_URL}/v1",
      "apiKey": "lm-studio"
    }
  },
  "gateway": {
    "port": 18789
  }
}
EOF
  success "설정 파일 작성 완료"
}

# ────────────────────────────────────────────────────────────────
# 6. 환경 변수 파일 복사
# ────────────────────────────────────────────────────────────────
setup_env() {
  if [ -f "$SCRIPT_DIR/.env.example" ] && [ ! -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    success ".env 파일 생성 완료 (필요시 편집: $SCRIPT_DIR/.env)"
  fi
}

# ────────────────────────────────────────────────────────────────
# 7. 데몬 설치 (선택)
# ────────────────────────────────────────────────────────────────
install_daemon_if_requested() {
  if [ "$INSTALL_DAEMON" = true ]; then
    info "OpenClaw Gateway 데몬 설치 중..."
    openclaw onboard --install-daemon --non-interactive \
      --custom-base-url "${LMSTUDIO_BASE_URL}/v1" \
      --custom-model-id "${LMSTUDIO_MODEL}" \
      --custom-api-key "lm-studio" || \
    warn "데몬 자동 설치 실패. 수동으로 'openclaw onboard --install-daemon' 을 실행하세요."
    success "데몬 설치 완료"
  else
    info "--daemon 플래그 없이 실행됨. 데몬 설치를 원하면: bash install.sh --daemon"
  fi
}

# ────────────────────────────────────────────────────────────────
# 8. 진단
# ────────────────────────────────────────────────────────────────
run_doctor() {
  info "OpenClaw 진단 실행 중..."
  openclaw doctor 2>/dev/null || warn "진단 도구를 실행할 수 없습니다. 설치 후 'openclaw doctor' 를 직접 실행하세요."
}

# ────────────────────────────────────────────────────────────────
# 메인 실행
# ────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  OpenClaw × LMStudio 설치 스크립트"
  echo "  모델: ${LMSTUDIO_MODEL}"
  echo "  엔드포인트: ${LMSTUDIO_BASE_URL}"
  echo "═══════════════════════════════════════════════════════"
  echo ""

  check_node
  detect_pkg_manager
  install_openclaw
  check_lmstudio
  write_config
  setup_env
  install_daemon_if_requested
  run_doctor

  echo ""
  echo "═══════════════════════════════════════════════════════"
  success "설치 완료!"
  echo ""
  echo "  다음 명령으로 게이트웨이를 시작하세요:"
  echo "    openclaw gateway --port 18789 --verbose"
  echo ""
  echo "  상태 확인:"
  echo "    openclaw gateway status"
  echo ""
  echo "  자세한 내용은 SETUP.md 를 참조하세요."
  echo "═══════════════════════════════════════════════════════"
}

main "$@"
