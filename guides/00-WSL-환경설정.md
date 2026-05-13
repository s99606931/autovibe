# 00. WSL 바이브코딩 환경 설정 가이드

> **대상**: Windows 11 사용자 (WSL 미설치 포함) · 이미 WSL이 있다면 Step 1을 건너뛰세요.
> **결과**: WSL Ubuntu 24.04 + Claude Code(Opus 4.7) + gstack + bkit + GitNexus — **4축 생태계 완성**
> **소요 시간**: 20~30분 (네트워크 속도 의존)

> AutoVibe는 4축으로 동작합니다.
> | 축 | 정체성 | 본 가이드 설치 위치 |
> |----|--------|------|
> | **Claude Code** | AI 런타임 (Opus 4.7, 1M context) | Step 4 (setup.sh) |
> | **gstack** | Fast Headless Browser (29개 명령) | Step 4 (setup.sh) |
> | **bkit** | Vibecoding Kit PDCA 플러그인 | Step 5 (Claude Code 내) |
> | **GitNexus** | 공유 코드 그래프 MCP | Step 4 (setup.sh) |

---

## 전체 설정 흐름

```mermaid
flowchart LR
    A["1. WSL 설치<br/>Ubuntu 24.04"] --> B["2. autovibe clone<br/>git clone"]
    B --> C["3. setup.sh 실행<br/>4축 자동 설치"]
    C --> D["4. Claude Code 로그인<br/>계정 인증"]
    D --> E["5. bkit 설치<br/>/plugin install bkit"]
    E --> F["6. /av 사용 시작<br/>자연어 명령"]

    style A fill:#2d6a4f,color:#fff
    style F fill:#1d3557,color:#fff
```

---

## 1. 시작 전 확인

| 항목 | 요구사항 | 확인 방법 |
|------|----------|----------|
| Windows | 11 (Build 22000+) | `winver` |
| RAM | 32GB 이상 권장 | 작업관리자 |
| 저장공간 | 500GB 이상 여유 | 파일탐색기 |
| 계정 | Claude Pro / Max / Teams / Enterprise | https://claude.com/pricing |

> 무료 플랜은 Claude Code를 사용할 수 없습니다.

### WSL 버전 확인 (이미 설치된 경우)

PowerShell에서:
```powershell
wsl --version
# WSL 버전: 2.x.x 필요. 구버전이면:
wsl --update
```

---

## 2. WSL + Ubuntu 24.04 설치

**Windows PowerShell을 관리자 권한으로 실행** 후:

```powershell
wsl --install -d Ubuntu-24.04
```

```mermaid
sequenceDiagram
    participant PS as PowerShell (관리자)
    participant WSL as WSL 시스템
    participant UB as Ubuntu 24.04

    PS->>WSL: wsl --install -d Ubuntu-24.04
    WSL->>WSL: WSL 2 커널 설치
    WSL->>UB: Ubuntu 24.04 다운로드 및 설치
    UB->>UB: 사용자 이름/비밀번호 설정 요청
    Note over UB: 여기서 사용자 정보를 입력하세요
```

설치 완료 후 Ubuntu 24.04 앱이 열리면 **사용자 이름과 비밀번호**를 설정합니다.

---

## 3. autovibe 저장소 clone

```bash
sudo mkdir -p /data && sudo chown $USER:$USER /data
cd /data
git clone https://github.com/s99606931/autovibe.git
cd autovibe
```

> 다른 경로에 clone 해도 OK. setup.sh는 자기 디렉토리 기준으로 동작합니다.

---

## 4. 자동 환경 설정 (setup.sh)

```bash
cd /data/autovibe/wsl-setup
chmod +x setup.sh
./setup.sh
```

### setup.sh가 자동으로 설치하는 항목

```mermaid
flowchart TD
    S0["0. 환경 확인<br/>WSL + Ubuntu 24.04 + systemd"]
    S1["1. 시스템 업데이트"]
    S2["2. sudo 무비번"]
    S3["3. 한국어 + 서울 시간대"]
    S4["4. 필수 패키지<br/>git/jq/Python/Ruff/uv/bubblewrap"]
    S5["5. Node.js 24.x + pnpm"]
    S6["6. Docker Engine + Compose"]
    S7["7. /data 디렉토리"]
    S81["8-1. Claude Code<br/>(Native install, Opus 4.7)"]
    S82["8-2. Gemini CLI (선택)"]
    S83["8-3. bkit 설치 안내"]
    S84["8-4. gstack<br/>29개 슬래시 명령 + Chromium"]
    S85["8-5. GitNexus<br/>compose + user-scope MCP 등록"]
    S9["9. Git 전역 설정"]

    S0 --> S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7
    S7 --> S81 --> S82 --> S83 --> S84 --> S85 --> S9
```

> **재실행 안전**: 이미 설치된 항목은 자동 감지하여 건너뜁니다. 일부 실패 시 해당 단계만 수동 재실행 가능 (`bash wsl-setup/install-gitnexus.sh` 등).

설치 완료 후 Docker 그룹 적용:
```bash
newgrp docker
# 또는 Ubuntu 24.04 앱을 닫고 재시작
```

---

## 5. Claude Code 로그인

```bash
source ~/.bashrc   # PATH 반영
cd ~/              # 작업 디렉토리
claude             # 첫 실행
```

```mermaid
sequenceDiagram
    participant T as 터미널
    participant CC as Claude Code
    participant B as 브라우저 (Windows)

    T->>CC: claude (첫 실행)
    CC->>B: 인증 URL 열기 (wslview)
    Note over B: Claude 계정으로 로그인
    B->>CC: 인증 토큰 전달
    CC->>T: ✅ 로그인 성공
```

> **WSL에서 브라우저가 안 열리면**: 터미널에 출력된 URL을 Windows 브라우저에 직접 붙여넣으세요.

```bash
claude --version   # 버전 확인 (v2.2+ 권장 — Opus 4.7 / 1M context / deferred tools)
claude doctor      # 환경 진단
claude mcp list    # gitnexus ✓ Connected 확인
```

---

## 6. bkit 플러그인 설치

bkit은 Claude Code 내부 명령어로만 설치 가능합니다.

```bash
cd ~/your-project
claude
```

**Claude Code 프롬프트에서 순서대로 입력:**

```
# Step 1: Marketplace 등록
/plugin marketplace add popup-studio-ai/bkit-claude-code

# Step 2: bkit 설치
/plugin install bkit

# Step 3: 설치 확인
/bkit
```

bkit 메뉴가 표시되면 설치 성공입니다.

### 4축 설치 검증 (한 번에 확인)

```bash
claude doctor                            # Claude Code 환경 OK
claude mcp list | grep gitnexus          # gitnexus ✓ Connected
ls ~/.claude/skills/gstack/SKILL.md      # gstack 설치 확인
# Claude Code 안에서:
#   /bkit       → bkit 메뉴
#   /gstack     → gstack 메뉴
#   /av         → AutoVibe 마스터 게이트웨이
```

---

## 7. 바이브코딩 시작

기존 프로젝트에 AutoVibe를 적용하려면:

```bash
cd /data/my-project        # 내 프로젝트
claude
```

Claude Code 안에서 자연어 한 줄:

```
/av-vibe-portable-init     # 원클릭 자동 구축 (추천)
```

또는:

```
/av AutoVibe 생태계 구축해줘. Phase 0부터 시작.
```

상세 단계별 가이드: [01-퀵스타트-30분.md](01-퀵스타트-30분.md) · [08-프로젝트-이전.md](08-프로젝트-이전.md)

---

## 문제 해결

### Ubuntu 버전이 24.04가 아님

```powershell
# PowerShell: 기존 배포판 삭제 후 재설치
wsl --unregister Ubuntu
wsl --install -d Ubuntu-24.04
```

### 브라우저가 열리지 않음

```bash
sudo add-apt-repository universe -y
sudo apt update && sudo apt install -y wslu
echo 'export BROWSER="wslview"' >> ~/.bashrc
source ~/.bashrc
```

### Claude Code 설치/업데이트 실패

```bash
claude doctor
claude update
curl -fsSL https://claude.ai/install.sh | bash
```

### Docker 서비스 미시작

```bash
# /etc/wsl.conf 확인
cat /etc/wsl.conf
```

아래 내용 없으면 추가:
```bash
sudo tee /etc/wsl.conf << 'EOF'
[boot]
systemd=true
EOF
```

PowerShell에서 WSL 재시작:
```powershell
wsl --shutdown
wsl -d Ubuntu-24.04
```

---

## 참고 링크

| 리소스 | URL |
|--------|-----|
| Claude Code 공식 문서 | https://code.claude.com/docs/en/overview |
| Claude 구독 | https://claude.com/pricing |
| bkit 플러그인 | https://github.com/popup-studio-ai/bkit-claude-code |
| Microsoft WSL 문서 | https://learn.microsoft.com/ko-kr/windows/wsl/ |

---

**다음**: [01-퀵스타트-30분.md](01-퀵스타트-30분.md) -- 30분 안에 AutoVibe Phase 0 완료
