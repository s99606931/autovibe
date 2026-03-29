# WSL 바이브코딩 환경 설정 가이드

> **대상**: Windows 11 사용자 (WSL 미설치 포함)
> **배포판**: Ubuntu 24.04 LTS (Noble Numbat)
> **결과**: WSL Ubuntu 24.04 + Claude Code + Gemini CLI + bkit 개발환경 완성
> **소요 시간**: 약 20~30분 (네트워크 속도에 따라 다름)

---

## 목차

1. [시작 전 확인사항](#1-시작-전-확인사항)
2. [WSL + Ubuntu 24.04 설치](#2-wsl--ubuntu-2404-설치)
3. [WSL 환경 자동 설정 (setup.sh)](#3-wsl-환경-자동-설정-setupsh)
4. [Claude Code 로그인](#4-claude-code-로그인)
5. [bkit 플러그인 설치](#5-bkit-플러그인-설치)
6. [바이브코딩 시작](#6-바이브코딩-시작)
7. [문제 해결](#7-문제-해결)

---

## 1. 시작 전 확인사항

### 시스템 요구사항

| 항목 | 요구사항 |
|------|----------|
| **Windows** | Windows 11 (Build 22000+) |
| **RAM** | 32GB 이상 권장 |
| **저장공간** | 500GB 이상 여유 |
| **WSL** | WSL 2 (버전 0.67.6 이상, systemd 지원) |
| **배포판** | Ubuntu 24.04 LTS (Noble Numbat) |
| **계정** | Claude Pro / Max / Teams / Enterprise (무료 플랜 미지원) |
| **인터넷** | 필수 |

> Claude 구독 안내: https://claude.com/pricing

### WSL 버전 확인 (이미 설치된 경우)

PowerShell에서:

```powershell
wsl --version
```

`WSL 버전: 2.x.x` 형태로 출력되어야 합니다. 구버전이면 업데이트:

```powershell
wsl --update
```

---

## 2. WSL + Ubuntu 24.04 설치

**Windows PowerShell을 관리자 권한으로 실행** 후 입력:

```powershell
# Ubuntu 24.04 LTS 지정 설치
wsl --install -d Ubuntu-24.04
```

설치 완료 후 Ubuntu 24.04 앱이 열리면 사용자 이름과 비밀번호를 설정합니다.

### setup.sh 실행

Ubuntu 터미널에서:

```bash
cd /data/autovibe/wsl-setup
chmod +x setup.sh
./setup.sh
```

---

## 3. WSL 환경 자동 설정 (setup.sh)

`setup.sh`는 아래 항목을 순서대로 자동 설치·설정합니다.

| 단계 | 내용 |
|------|------|
| 0 | 환경 확인 (WSL + Ubuntu 24.04 + systemd) |
| 1 | 시스템 패키지 업데이트 |
| 2 | sudo 비밀번호 생략 설정 |
| 3 | 한국어 로케일 + 서울 시간대 설정 |
| 4 | 필수 패키지 설치 (build-essential, curl, git, jq, wslu, Python 3.12 + pip/venv, Ruff, uv) |
| 5 | Node.js 24.x + pnpm |
| 6 | Docker Engine + Docker Compose (공식 저장소) |
| 7 | `/data` 디렉토리 생성 및 소유권 설정 |
| 8-1 | Claude Code (Native Install) + WSL 브라우저 연동 (`BROWSER=wslview`) |
| 8-2 | Gemini CLI (`@google/gemini-cli`) |
| 8-3 | bkit 플러그인 설치 안내 + `~/.claude/settings.json` 자동 생성 + Agent Teams 활성화 |
| 9 | Git 전역 설정 (user.name, email, autocrlf, rebase, prune, credential) |

### 설치 완료 후 — Docker 그룹 즉시 적용

```bash
newgrp docker
# 또는 Ubuntu 24.04 앱을 닫고 재시작
```

---

## 4. Claude Code 로그인

### 4-1. 첫 실행

```bash
source ~/.bashrc   # PATH 반영
cd ~/              # 또는 작업할 프로젝트 디렉토리
claude
```

첫 실행 시 브라우저가 열리며 Claude 계정으로 인증합니다.

> **WSL에서 브라우저가 자동으로 열리지 않는 경우:**
> 터미널에 출력된 URL을 복사하여 **Windows 브라우저**에 직접 붙여넣으세요.
> `setup.sh` 실행 시 `wslu`와 `BROWSER=wslview`가 자동 설정됩니다.

### 4-2. 로그인 확인

```bash
claude --version   # 버전 확인
claude doctor      # 환경 진단
```

### 4-3. 계정 전환이 필요한 경우

Claude Code 실행 중:
```
/login
```

---

## 5. bkit 플러그인 설치

bkit은 Claude Code 내부 슬래시 명령으로만 설치 가능합니다 (쉘 자동화 불가).

> `setup.sh` 실행 시 아래 항목이 **자동으로** 설정됩니다:
> - `~/.claude/settings.json` — `autoUpdate: true`
> - `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (멀티 에이전트 팀 활성화)

### 5-1. 사전 요구사항 확인

```bash
claude --version   # v2.1.78 이상 확인
node --version     # v18 이상 확인
```

버전이 낮으면:
```bash
claude update      # Claude Code 업데이트
```

### 5-2. Claude Code에서 설치

```bash
cd ~/your-project
claude
```

**Claude Code 프롬프트에서 순서대로 입력:**

**Step 1** - Marketplace 등록:
```
/plugin marketplace add popup-studio-ai/bkit-claude-code
```

**Step 2** - bkit 설치:
```
/plugin install bkit
```

### 5-3. 설치 확인

Claude Code에서:
```
/bkit
```

bkit 메뉴가 표시되면 설치 성공입니다.

---

## 6. 바이브코딩 시작

```bash
cd /data/your-project
claude
```

AutoVibe 프레임워크로 시작하려면 [getting-started.md](getting-started.md)를 참고하세요.

---

## 7. 문제 해결

### Ubuntu 버전이 24.04가 아님

```powershell
# PowerShell: 기존 배포판 삭제 후 재설치
wsl --unregister Ubuntu
wsl --install -d Ubuntu-24.04
```

### WSL에서 브라우저가 열리지 않음

```bash
# universe 저장소 활성화 후 wslu 설치
sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y wslu

# BROWSER 환경변수 설정
echo 'export BROWSER="wslview"' >> ~/.bashrc
source ~/.bashrc
```

### Claude Code 설치/업데이트 실패

```bash
claude doctor
claude update
curl -fsSL https://claude.ai/install.sh | bash
```

### bkit 설치 후 "Failed to load hooks" 오류

Claude Code 버전이 v2.1.78 미만입니다.

```bash
claude --version
claude update
```

### Docker 권한 오류

```bash
newgrp docker
# 또는 Ubuntu 24.04 앱 재시작 후 확인
docker ps
```

### Docker 서비스가 시작되지 않음 (WSL systemd)

Ubuntu 24.04 WSL에서 systemd 활성화 확인:

```bash
cat /etc/wsl.conf
```

아래 내용이 없으면 추가:

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

### Node.js 버전 문제 (bkit 요구: v18+)

```bash
node --version

# NodeSource로 재설치 (Node.js 24.x)
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs
```

### Git 서브모듈 초기화 실패

```bash
cd /data/your-project
git submodule update --init --recursive
```

---

## 참고 링크

| 리소스 | URL |
|--------|-----|
| Claude Code 공식 문서 | https://code.claude.com/docs/en/overview |
| Claude Code 설치 가이드 | https://code.claude.com/docs/en/setup |
| Claude 구독 안내 | https://claude.com/pricing |
| Gemini CLI GitHub | https://github.com/google-gemini/gemini-cli |
| bkit 플러그인 GitHub | https://github.com/popup-studio-ai/bkit-claude-code |
| Ubuntu 24.04 릴리스 노트 | https://ubuntu.com/blog/tag/ubuntu-24-04 |
| Microsoft WSL 공식 문서 | https://learn.microsoft.com/ko-kr/windows/wsl/ |
