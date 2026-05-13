#!/bin/bash
#===============================================================================
# GitNexus 설치 & 가동 스크립트 (standalone)
#
# 역할:
#   - GitNexus 컴포즈 스택을 ~/.gitnexus 에 배치하고 docker compose 로 가동
#   - Claude Code 에 user-scope MCP 등록 (모든 프로젝트 공용)
#   - 인덱싱 대상 WORKSPACE_DIR 준비
#
# 단독 실행:
#   ./wsl-setup/install-gitnexus.sh
#
# setup.sh 에서 호출:
#   bash "$SCRIPT_DIR/install-gitnexus.sh"
#
# 옵션:
#   --workspace <path>  인덱싱 대상 디렉토리 (기본: /data/projects)
#   --server-port <n>   서버 포트 (기본: 4747)
#   --web-port <n>      Web UI 포트 (기본: 4173)
#   --no-mcp            MCP 등록 건너뜀
#   --uninstall         compose down + MCP 제거
#
# 참고:
#   https://github.com/abhigyanpatwari/GitNexus
#   https://docs.docker.com/compose/
#===============================================================================

set -e

# 색상 정의 (setup.sh 호출 시 이미 정의되어 있을 수 있음 — 안전하게 재정의)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $1"; }

# 기본값
WORKSPACE_DIR="${WORKSPACE_DIR:-/data/projects}"
GITNEXUS_SERVER_PORT="${GITNEXUS_SERVER_PORT:-4747}"
GITNEXUS_WEB_PORT="${GITNEXUS_WEB_PORT:-4173}"
REGISTER_MCP=1
MODE=install

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace)   WORKSPACE_DIR="$2"; shift 2 ;;
        --server-port) GITNEXUS_SERVER_PORT="$2"; shift 2 ;;
        --web-port)    GITNEXUS_WEB_PORT="$2"; shift 2 ;;
        --no-mcp)      REGISTER_MCP=0; shift ;;
        --uninstall)   MODE=uninstall; shift ;;
        -h|--help)
            # 파일 상단의 도움말 블록만 출력 (첫 #===... 사이)
            awk '/^#={3,}/{c++; next} c==1{print} c>=2{exit}' "$0" \
                | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) log_error "알 수 없는 옵션: $1"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITNEXUS_HOME="$HOME/.gitnexus"
COMPOSE_SRC="$SCRIPT_DIR/gitnexus/docker-compose.yml"
COMPOSE_DST="$GITNEXUS_HOME/docker-compose.yml"
ENV_FILE="$GITNEXUS_HOME/.env"

#───────────────────────────────────────────────────────────────────────────────
# Uninstall 경로
#───────────────────────────────────────────────────────────────────────────────
if [[ "$MODE" == "uninstall" ]]; then
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                GitNexus 제거                                       ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"

    if [[ -f "$COMPOSE_DST" ]]; then
        log_info "docker compose down 실행 중..."
        (cd "$GITNEXUS_HOME" && docker compose down -v) || log_warn "compose down 실패"
    else
        log_warn "compose 파일 없음: $COMPOSE_DST"
    fi

    if command -v claude &>/dev/null; then
        log_info "MCP 등록 제거 중..."
        claude mcp remove gitnexus --scope user 2>/dev/null || \
            claude mcp remove gitnexus 2>/dev/null || \
            log_warn "MCP 제거 건너뜀 (등록되어 있지 않음)"
    fi

    log_success "GitNexus 제거 완료. ~/.gitnexus 디렉토리는 보존됩니다."
    exit 0
fi

#───────────────────────────────────────────────────────────────────────────────
# 사전 요구사항 확인
#───────────────────────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          GitNexus 설치 — 코드베이스 지식 그래프 (공용 서비스)     ║"
echo "║          https://github.com/abhigyanpatwari/GitNexus              ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

if ! command -v docker &>/dev/null; then
    log_error "Docker 가 설치되어 있지 않습니다. setup.sh 의 setup_docker() 를 먼저 실행하세요."
    exit 1
fi

if ! docker compose version &>/dev/null; then
    log_error "Docker Compose v2 (docker compose) 가 필요합니다."
    exit 1
fi

# Docker 그룹 권한 확인 (현재 셸에서 docker 명령 동작 여부)
if ! docker info &>/dev/null; then
    log_warn "Docker 데몬에 접근할 수 없습니다. 다음 중 하나가 필요합니다:"
    echo "    1) 현재 셸이 docker 그룹에 적용되지 않음 → newgrp docker"
    echo "    2) Docker 서비스 미시작 → sudo service docker start"
    echo "    3) 이후 다시 실행 → bash $0"
    exit 1
fi

if [[ ! -f "$COMPOSE_SRC" ]]; then
    log_error "docker-compose.yml 원본 파일을 찾을 수 없습니다: $COMPOSE_SRC"
    exit 1
fi

# bubblewrap — Claude Code v2.1.140+ 의 subprocess sandbox 의존성
# (없으면 `claude mcp add` 호출 시 'bubblewrap is required' 에러로 실패)
if ! command -v bwrap &>/dev/null; then
    log_info "bubblewrap 미설치 → 자동 설치 시도 (Claude Code subprocess sandbox 요구)..."
    if sudo apt-get install -y bubblewrap >/dev/null 2>&1; then
        log_success "bubblewrap 설치 완료"
    else
        log_warn "bubblewrap 자동 설치 실패. 수동 설치 필요:"
        echo "    sudo apt-get install -y bubblewrap"
        echo "    또는 (보안 약화): export CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0"
    fi
fi

#───────────────────────────────────────────────────────────────────────────────
# 1. 작업 디렉토리 + WORKSPACE_DIR 준비
#───────────────────────────────────────────────────────────────────────────────
log_info "GitNexus 홈 디렉토리 준비: $GITNEXUS_HOME"
mkdir -p "$GITNEXUS_HOME"

# WORKSPACE_DIR 생성 (sudo 필요할 수 있음)
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    log_info "작업 디렉토리 생성: $WORKSPACE_DIR"
    if [[ "$WORKSPACE_DIR" == /data* || "$WORKSPACE_DIR" == /opt* ]]; then
        sudo mkdir -p "$WORKSPACE_DIR"
        sudo chown "$USER:$USER" "$WORKSPACE_DIR"
    else
        mkdir -p "$WORKSPACE_DIR"
    fi
else
    log_warn "작업 디렉토리 이미 존재: $WORKSPACE_DIR"
fi

#───────────────────────────────────────────────────────────────────────────────
# 2. compose 파일 + .env 배치
#───────────────────────────────────────────────────────────────────────────────
log_info "docker-compose.yml 배치 중..."
cp "$COMPOSE_SRC" "$COMPOSE_DST"

cat > "$ENV_FILE" <<EOF
# GitNexus 환경변수 — install-gitnexus.sh 가 생성
WORKSPACE_DIR=$WORKSPACE_DIR
GITNEXUS_SERVER_PORT=$GITNEXUS_SERVER_PORT
GITNEXUS_WEB_PORT=$GITNEXUS_WEB_PORT
EOF

log_success ".env 생성: $ENV_FILE"
echo "    WORKSPACE_DIR=$WORKSPACE_DIR"
echo "    SERVER_PORT=$GITNEXUS_SERVER_PORT  WEB_PORT=$GITNEXUS_WEB_PORT"

#───────────────────────────────────────────────────────────────────────────────
# 3. docker compose 가동
#───────────────────────────────────────────────────────────────────────────────
log_info "이미지 풀 + 컨테이너 기동 중 (수 분 소요)..."
(
    cd "$GITNEXUS_HOME"
    docker compose pull
    docker compose up -d
)

# 헬스체크 대기 (최대 60초). 엔드포인트는 GitNexus 1.6.x 기준 /api/health
log_info "GitNexus 서버 헬스체크 대기 중..."
for i in $(seq 1 30); do
    if curl -sf "http://localhost:$GITNEXUS_SERVER_PORT/api/health" &>/dev/null; then
        log_success "서버 응답 확인 (http://localhost:$GITNEXUS_SERVER_PORT/api/health)"
        break
    fi
    if [[ $i -eq 30 ]]; then
        log_warn "헬스체크 타임아웃 — docker compose logs 로 확인하세요."
        echo "    cd $GITNEXUS_HOME && docker compose logs -f"
    fi
    sleep 2
done

#───────────────────────────────────────────────────────────────────────────────
# 4. gitnexus CLI 글로벌 설치 (npx 콜드 스타트 제거 → MCP 헬스체크 통과)
#───────────────────────────────────────────────────────────────────────────────
GITNEXUS_BIN=""
if command -v npm &>/dev/null; then
    if ! command -v gitnexus &>/dev/null; then
        log_info "gitnexus CLI 글로벌 설치 중 (npx 콜드 스타트로 인한 MCP 연결 실패 방지)..."
        if npm install -g gitnexus >/dev/null 2>&1; then
            log_success "gitnexus 글로벌 설치 완료 ($(gitnexus --version 2>/dev/null))"
        else
            log_warn "글로벌 설치 실패 — npx 폴백 사용 (첫 MCP 호출 시 느릴 수 있음)"
        fi
    else
        log_warn "gitnexus 이미 설치됨 ($(gitnexus --version 2>/dev/null))"
    fi
    GITNEXUS_BIN="$(command -v gitnexus 2>/dev/null || true)"
else
    log_warn "npm 이 없습니다. setup.sh 의 Node.js 단계 후 다시 실행하세요."
fi

#───────────────────────────────────────────────────────────────────────────────
# 5. Claude Code MCP 등록 (user-scope, 공용)
#───────────────────────────────────────────────────────────────────────────────
if [[ "$REGISTER_MCP" -eq 1 ]]; then
    if command -v claude &>/dev/null; then
        log_info "Claude Code MCP 등록 중 (scope=user, 모든 프로젝트 공용)..."

        # 기존 등록 제거 (재실행 대비)
        claude mcp remove gitnexus --scope user 2>/dev/null || true

        # 글로벌 설치된 경우 절대 경로 사용 (npx 콜드 스타트 회피 → ✓ Connected)
        if [[ -n "$GITNEXUS_BIN" ]]; then
            MCP_CMD=("$GITNEXUS_BIN" "mcp")
        else
            MCP_CMD=("npx" "-y" "gitnexus@latest" "mcp")
        fi

        if claude mcp add --scope user gitnexus -- "${MCP_CMD[@]}"; then
            log_success "MCP 등록 완료 (command: ${MCP_CMD[*]})"

            # 즉시 헬스체크 (✓ Connected 확인)
            if claude mcp list 2>&1 | grep -E "^gitnexus:.*✓ Connected" &>/dev/null; then
                log_success "MCP 헬스체크 통과 (✓ Connected)"
            else
                log_warn "MCP 등록은 되었으나 헬스체크가 미통과 — Claude Code 재시작 후 재확인:"
                echo "    claude mcp list"
            fi
            echo "    Claude Code 재시작 후 모든 프로젝트에서 gitnexus MCP 도구 사용 가능"
        else
            log_warn "MCP 자동 등록 실패. 수동 등록:"
            echo "    claude mcp add --scope user gitnexus -- ${MCP_CMD[*]}"
        fi
    else
        log_warn "claude CLI 가 PATH 에 없습니다. setup.sh 의 Claude Code 단계 후 다시 실행하거나:"
        echo "    source ~/.bashrc"
        echo "    bash $0 --no-mcp   # 또는 다시 실행"
    fi
else
    log_info "MCP 등록 건너뜀 (--no-mcp)"
fi

#───────────────────────────────────────────────────────────────────────────────
# 5. 요약
#───────────────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                     GitNexus 설치 요약                            ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "  서비스:"
echo "    Server (MCP API):  http://localhost:$GITNEXUS_SERVER_PORT"
echo "    Web UI:            http://localhost:$GITNEXUS_WEB_PORT"
echo "    Workspace:         $WORKSPACE_DIR  (컨테이너 내부 /workspace, read-only)"
echo "    홈 디렉토리:        $GITNEXUS_HOME"
echo ""
echo "  관리 명령:"
echo "    상태 확인:   cd $GITNEXUS_HOME && docker compose ps"
echo "    로그 확인:   cd $GITNEXUS_HOME && docker compose logs -f"
echo "    재시작:      cd $GITNEXUS_HOME && docker compose restart"
echo "    중지:        cd $GITNEXUS_HOME && docker compose down"
echo "    제거:        bash $0 --uninstall"
echo ""
echo "  Claude Code MCP:"
echo "    /mcp                                 # 등록된 MCP 목록"
echo "    claude mcp list                      # CLI 에서 확인"
echo ""
echo "  인덱싱 예시 (호스트에서):"
echo "    cd $WORKSPACE_DIR && git clone <repo>"
echo "    Claude Code 에서 자연어로: \"<repo> 를 gitnexus 로 인덱싱해줘\""
echo ""
log_success "완료. Claude Code 를 재시작하면 gitnexus MCP 도구가 활성화됩니다."
