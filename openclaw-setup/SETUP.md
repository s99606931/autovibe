# OpenClaw × LMStudio 설치 및 설정 가이드

> LMStudio(http://127.0.0.1:1234) + **qwen/qwen3.5-9b** 모델로 OpenClaw를 설치하는 가이드입니다.
> 
> **검증된 구성 (2026-05-14)**: qwen3.5-9b + smart-proxy v3.1 (non-streaming 어댑터)

---

## 목차

1. [사전 요구사항](#1-사전-요구사항)
2. [LMStudio 준비](#2-lmstudio-준비)
3. [OpenClaw 설치](#3-openclaw-설치)
4. [설정 파일 구성](#4-설정-파일-구성)
5. [게이트웨이 실행](#5-게이트웨이-실행)
6. [채널 연동 (선택)](#6-채널-연동-선택)
7. [문제 해결](#7-문제-해결)

---

## 1. 사전 요구사항

| 항목 | 버전 | 확인 명령 |
|------|------|-----------|
| Node.js | 22.16+ (권장: 24) | `node -v` |
| npm / pnpm | 최신 | `npm -v` / `pnpm -v` |
| LMStudio | 최신 | LMStudio 앱 실행 후 확인 |
| Git | 모든 버전 | `git --version` |

### Node.js 설치 (없는 경우)

```bash
# nvm 사용 권장
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
```

---

## 2. LMStudio 준비

### 2-1. LMStudio 다운로드 및 설치

1. https://lmstudio.ai 에서 운영체제에 맞는 LMStudio를 다운로드
2. 설치 후 실행

### 2-2. 권장 모델 로드

**OpenClaw와 검증된 모델**: `qwen/qwen3.5-9b` (tool-calling + 한국어 지원 확인)

1. LMStudio 왼쪽 패널 → **"Search"** 탭 클릭
2. 검색창에 `qwen3.5-9b` 입력
3. **Download** 클릭 (용량: 약 6GB)
4. 다운로드 완료 후 왼쪽 패널 → **"My Models"** 에서 확인

> **주의**: `qwen3.6-27b`은 기본 컨텍스트(4096 토큰)로 로드 시 OpenClaw 시스템 프롬프트(7265 토큰)를 처리 못함. 사용하려면 LMStudio에서 Context Length를 16384 이상으로 변경 후 재로드 필요.

### 2-3. LMStudio 로컬 서버 활성화

1. LMStudio 상단 탭 → **"Developer"** (또는 `</>` 아이콘)
2. **"Local Server"** 선택
3. **qwen/qwen3.5-9b** 모델 선택
4. **"Start Server"** 버튼 클릭
5. `http://127.0.0.1:1234` 로 서버 가동 확인

### 2-4. 서버 연결 테스트

```bash
# 모델 목록 조회
curl http://127.0.0.1:1234/v1/models

# tool-calling 테스트
curl http://127.0.0.1:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen/qwen3.5-9b",
    "stream": false,
    "tools": [{"type":"function","function":{"name":"greet","description":"greet user","parameters":{"type":"object","properties":{"msg":{"type":"string"}},"required":["msg"]}}}],
    "messages": [{"role": "user", "content": "Say hello using the greet tool"}],
    "max_tokens": 200
  }' | python3 -c "import sys,json; d=json.load(sys.stdin); print('finish:', d['\''choices'\''][0]['\''finish_reason'\''], '| tool_calls:', bool(d['\''choices'\''][0].get('\''message'\'',{}).get('\''tool_calls'\'')))"
```

---

## 3. OpenClaw 설치

### 방법 A: 자동 설치 스크립트 (권장)

```bash
cd /path/to/autovibe/openclaw-setup

# 실행 권한 부여
chmod +x install.sh

# 설치 (데몬 없이)
bash install.sh

# 설치 + 시스템 데몬 등록 (백그라운드 자동 실행)
bash install.sh --daemon
```

### 방법 B: 수동 설치

```bash
# npm 사용
npm install -g openclaw@latest

# 또는 pnpm 사용
pnpm add -g openclaw@latest

# 설치 확인
openclaw --version
```

---

## 4. 설정 파일 구성

### 4-1. 설정 파일 복사

```bash
# OpenClaw 설정 디렉토리 생성
mkdir -p ~/.openclaw

# 이 폴더의 설정 파일 복사
cp openclaw-setup/openclaw.json ~/.openclaw/openclaw.json
```

### 4-2. 설정 파일 내용 (`~/.openclaw/openclaw.json`)

```json
{
  "agent": {
    "model": "lmstudio/gemma-4-e4b-it"
  },
  "providers": {
    "lmstudio": {
      "baseUrl": "http://127.0.0.1:1234/v1",
      "apiKey": "lm-studio"
    }
  },
  "gateway": {
    "port": 18789
  }
}
```

> **모델 교체**: `model` 값을 `"lmstudio/다른모델명"` 으로 변경하면 다른 LMStudio 모델을 사용할 수 있습니다.

### 4-3. 환경 변수 설정 (선택)

```bash
# .env.example 복사
cp openclaw-setup/.env.example openclaw-setup/.env

# 편집 (필요한 항목만)
nano openclaw-setup/.env
```

---

## 5. 스마트 프록시 실행 (필수)

Qwen3 계열 모델은 `reasoning_content` 토큰을 출력하여 OpenClaw와 호환 문제가 발생합니다.  
`smart-proxy.js`가 이를 자동으로 처리합니다.

### 5-1. 프록시 시작

```bash
# 포트 11435에서 프록시 실행 (LMStudio 1234 → 프록시 11435)
node openclaw-setup/smart-proxy.js &

# 정상 기동 메시지:
# [smart-proxy v3.1] :11435 → 127.0.0.1:1234
# [smart-proxy] non-streaming adapter + /v1/ 보정 + reasoning_content 제거
```

> OpenClaw provider가 `http://127.0.0.1:11435`를 가리키고 있어야 합니다.

## 6. 게이트웨이 실행

### 6-1. 게이트웨이 시작

```bash
# 프록시 먼저 실행 후 게이트웨이 시작
openclaw gateway --port 18789

# 상세 로그와 함께
openclaw gateway --port 18789 --verbose

# 한 번에 실행 (백그라운드)
node openclaw-setup/smart-proxy.js > /tmp/proxy.log 2>&1 &
openclaw gateway --port 18789 > /tmp/gateway.log 2>&1 &
```

### 6-2. 상태 확인

```bash
openclaw gateway status
openclaw doctor
```

### 6-3. 에이전트 테스트

```bash
# 세션 초기화 후 테스트
rm -f ~/.openclaw/agents/main/sessions/*.json 2>/dev/null

# 메시지 전송
openclaw agent --agent main --message "안녕하세요! LMStudio 연결 테스트입니다."
```

---

## 6. 채널 연동 (선택)

### Telegram 봇 연동

1. Telegram에서 `@BotFather` 에게 `/newbot` 명령으로 봇 생성
2. 발급된 토큰을 `.env` 에 설정:
   ```
   TELEGRAM_BOT_TOKEN=123456:ABCDEF...
   ```
3. `openclaw.json` 에 채널 추가:
   ```json
   {
     "channels": {
       "telegram": {
         "enabled": true
       }
     }
   }
   ```
4. 게이트웨이 재시작 후 봇에게 메시지 전송

### Discord 봇 연동

1. https://discord.com/developers/applications 에서 봇 생성
2. `DISCORD_BOT_TOKEN` 을 `.env` 에 설정
3. 봇을 서버에 초대 후 게이트웨이 재시작

---

## 7. 문제 해결

### LMStudio 연결 실패

```bash
# 포트 사용 확인
ss -tlnp | grep 1234

# LMStudio 서버 재시작 후 재연결
curl -sf http://127.0.0.1:1234/v1/models
```

**원인 및 해결:**
- LMStudio 서버가 시작되지 않은 경우 → Developer 탭 → Start Server 클릭
- 방화벽이 포트를 막는 경우 → `sudo ufw allow 1234` (Linux)
- WSL2에서 Windows LMStudio 접근 시 → 127.0.0.1 대신 Windows 호스트 IP 사용

### WSL2에서 Windows LMStudio 접근

LMStudio가 Windows에서 실행 중이고 OpenClaw가 WSL2에서 실행 중인 경우:

```bash
# Windows 호스트 IP 확인
cat /etc/resolv.conf | grep nameserver | awk '{print $2}'

# openclaw.json의 baseUrl을 해당 IP로 변경
# 예: "baseUrl": "http://172.28.0.1:1234/v1"
```

LMStudio에서 네트워크 바인딩 주소를 `0.0.0.0` 으로 변경해야 할 수 있습니다.

### `incomplete terminal response` 오류

```
FailoverError: custom-xxx/qwen/qwen3.6-27b ended with an incomplete terminal response
```

**원인 1: 컨텍스트 오버플로우** (n_keep >= n_ctx)
- OpenClaw 시스템 프롬프트가 7265 토큰인데 모델이 4096 컨텍스트로 로드됨
- **해결**: `qwen/qwen3.5-9b` 사용 (기본 컨텍스트 충분) 또는 LMStudio에서 Context Length를 16384 이상으로 변경

**원인 2: 프록시 미실행**
- smart-proxy.js가 실행되지 않은 상태에서 Qwen3 모델 사용 시 `seq gap` 또는 `payloads=0` 오류
- **해결**: `node openclaw-setup/smart-proxy.js &` 먼저 실행

**원인 3: 세션 토큰 누적**
- 오래된 세션에 메시지가 쌓여 컨텍스트 초과
- **해결**: `rm -f ~/.openclaw/agents/main/sessions/*.json`

### 모델 이름 불일치

```bash
# LMStudio에 로드된 실제 모델 ID 확인
curl http://127.0.0.1:1234/v1/models | python3 -m json.tool

# openclaw.json의 model 값을 실제 ID와 맞추기
```

### OpenClaw 진단

```bash
openclaw doctor
openclaw gateway status
```

### 설정 초기화

```bash
# 설정 백업
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak

# 재설정
cp openclaw-setup/openclaw.json ~/.openclaw/openclaw.json
openclaw gateway restart
```

---

## 참고 링크

- OpenClaw GitHub: https://github.com/openclaw/openclaw
- OpenClaw 공식 문서: https://docs.openclaw.ai
- LMStudio 공식 사이트: https://lmstudio.ai
- 커뮤니티: OpenClaw GitHub Discussions
