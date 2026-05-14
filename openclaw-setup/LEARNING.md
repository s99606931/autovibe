# OpenClaw × LMStudio 학습 가이드

> 로컬 AI 어시스턴트 OpenClaw를 완전히 활용하기 위한 단계별 학습 가이드입니다.
> 모델: **gemma-4-e4b-it** | 엔드포인트: **http://127.0.0.1:1234**

---

## 학습 경로 개요

```
Level 1: 기초 — 설치 및 첫 번째 대화
Level 2: 채널 연동 — 메신저와 OpenClaw 연결
Level 3: 에이전트 활용 — 고급 기능 사용
Level 4: 커스터마이징 — 나만의 OpenClaw 구성
Level 5: 심화 — 멀티 모달 · 플러그인 · 자동화
```

---

## Level 1: 기초

### 1-1. OpenClaw 아키텍처 이해

```
┌─────────────────────────────────────────┐
│           사용자 인터페이스              │
│   (Telegram / Discord / Slack / CLI)    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         OpenClaw Gateway                │
│     (포트 18789, 로컬 실행)              │
│  - 세션 관리  - 채널 라우팅             │
│  - 인증      - 에이전트 조율            │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           OpenClaw Agent                │
│  - 도구 사용  - 메모리 관리             │
│  - 멀티 에이전트 라우팅                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         LMStudio (로컬 LLM)             │
│  모델: gemma-4-e4b-it                  │
│  주소: http://127.0.0.1:1234           │
└─────────────────────────────────────────┘
```

**핵심 개념:**
- **Gateway**: 메신저 채널과 AI 에이전트 사이의 중개자
- **Agent**: 실제 AI 추론과 도구 사용을 담당
- **LMStudio**: 로컬에서 실행되는 LLM 서버 (gemma 모델 제공)
- **채널**: Telegram, Discord 등 실제 대화 인터페이스

### 1-2. 첫 번째 대화

```bash
# 1. LMStudio 서버 시작 (LMStudio 앱 → Developer → Start Server)

# 2. OpenClaw 게이트웨이 시작
openclaw gateway --port 18789 --verbose

# 3. 다른 터미널에서 에이전트 테스트
openclaw agent --message "안녕하세요! 자기소개를 해주세요."

# 4. 한국어 능력 테스트
openclaw agent --message "오늘의 날씨를 묻는 영어 표현 5가지를 알려주세요."
```

### 1-3. 기본 CLI 명령어

| 명령어 | 설명 |
|--------|------|
| `openclaw gateway --port 18789 --verbose` | 게이트웨이 시작 (상세 로그) |
| `openclaw gateway status` | 게이트웨이 상태 확인 |
| `openclaw gateway stop` | 게이트웨이 중지 |
| `openclaw agent --message "질문"` | 에이전트에 직접 질문 |
| `openclaw doctor` | 전체 시스템 진단 |
| `openclaw --version` | 버전 확인 |

### 1-4. 실습 과제

```
[과제 1] 게이트웨이를 시작하고 상태를 확인하세요.
[과제 2] 에이전트에게 "파이썬으로 피보나치 수열 생성하는 코드를 작성해줘"라고 요청하세요.
[과제 3] openclaw doctor 결과를 분석하고 모든 항목이 정상인지 확인하세요.
```

---

## Level 2: 채널 연동

### 2-1. Telegram 봇 설정 (권장 시작점)

**왜 Telegram인가?** 설정이 가장 간단하고, 모바일에서 바로 AI와 대화할 수 있습니다.

```
Step 1: 봇 생성
  1. Telegram에서 @BotFather 검색 및 시작
  2. /newbot 명령 입력
  3. 봇 이름 입력 (예: "MyLocalAI")
  4. 봇 사용자명 입력 (예: "mylocal_ai_bot" — _bot으로 끝나야 함)
  5. 토큰 발급: "1234567890:AABBCCDDEEFFaabbccddeeff" 형태

Step 2: 환경 변수 설정
  TELEGRAM_BOT_TOKEN=발급받은토큰
  (openclaw-setup/.env 파일에 설정)

Step 3: openclaw.json에 채널 추가
  {
    "agent": { "model": "lmstudio/gemma-4-e4b-it" },
    "providers": { ... },
    "channels": {
      "telegram": { "enabled": true }
    }
  }

Step 4: 게이트웨이 재시작 후 봇에게 메시지 전송
```

### 2-2. 페어링 코드 승인

보안상 최초 연결 시 페어링 코드가 필요합니다:

```bash
# 봇에게 메시지를 보내면 콘솔에 페어링 코드가 표시됨
# 아래 명령으로 승인
openclaw pairing approve telegram <페어링코드>
```

### 2-3. 채팅 오퍼레이터 명령어

Telegram/Discord 등 채팅창에서 직접 입력:

| 명령어 | 설명 |
|--------|------|
| `/status` | 현재 연결 상태 및 모델 정보 |
| `/new` | 새 대화 세션 시작 |
| `/reset` | 대화 컨텍스트 초기화 |
| `/compact` | 메모리 압축 (긴 대화 후) |
| `/think` | 고급 추론 모드 활성화 |
| `/verbose` | 상세 로그 출력 모드 |
| `/usage` | 토큰 사용량 확인 |
| `/restart` | 에이전트 재시작 |

### 2-4. 실습 과제

```
[과제 1] Telegram 봇을 생성하고 OpenClaw와 연결하세요.
[과제 2] 봇에게 /status 명령을 보내고 응답을 확인하세요.
[과제 3] 봇과 5번 이상 대화하고 /compact 명령으로 메모리를 압축하세요.
```

---

## Level 3: 에이전트 활용

### 3-1. 에이전트 도구 이해

OpenClaw 에이전트는 다양한 도구를 사용할 수 있습니다:

```
내장 도구:
├── 브라우저 (Playwright 기반)
│   - 웹 페이지 방문 및 정보 추출
│   - 스크린샷 캡처
├── 파일 시스템
│   - 파일 읽기/쓰기 (설정된 범위 내)
├── 코드 실행
│   - 코드 스니펫 실행 및 결과 반환
├── 세션 관리
│   - sessions_list: 활성 세션 목록
│   - sessions_history: 대화 이력
│   - sessions_send: 세션 간 메시지 전송
└── 스케줄러 (크론)
    - 반복 작업 등록
```

### 3-2. 고급 추론 모드

```bash
# 기본 모드 (빠른 응답)
openclaw agent --message "질문"

# 고급 추론 모드 (더 깊은 분석)
openclaw agent --message "복잡한 질문" --thinking high

# 채팅 내 활성화
/think
이제 복잡한 질문을 입력하세요.
```

**언제 고급 추론을 사용하나요?**
- 복잡한 코드 설계 및 리뷰
- 다단계 논리적 추론이 필요한 문제
- 장문 문서 분석
- 전략 수립 및 의사결정 지원

### 3-3. 멀티 에이전트 라우팅

OpenClaw는 여러 에이전트를 동시에 조율할 수 있습니다:

```json
// openclaw.json 예시 — 도메인별 에이전트 분리
{
  "agent": {
    "model": "lmstudio/gemma-4-e4b-it",
    "routing": {
      "code": "lmstudio/gemma-4-e4b-it",
      "creative": "lmstudio/gemma-4-e4b-it",
      "default": "lmstudio/gemma-4-e4b-it"
    }
  }
}
```

### 3-4. 세션 관리

```bash
# 활성 세션 목록
openclaw agent --message "sessions_list 도구를 사용해서 활성 세션을 알려줘"

# 대화 이력 조회
openclaw agent --message "sessions_history 도구로 최근 대화 이력을 보여줘"
```

### 3-5. 실습 과제

```
[과제 1] --thinking high 옵션으로 "파이썬의 GIL을 우회하는 방법들을 분석해줘"라고 요청하세요.
[과제 2] 채팅에서 /think 모드를 활성화하고 수학 문제를 풀어달라고 요청하세요.
[과제 3] 대화 이력을 조회하고 /compact 명령으로 최적화하세요.
```

---

## Level 4: 커스터마이징

### 4-1. 모델 전환

LMStudio에서 다른 모델로 전환하는 방법:

```bash
# 1. LMStudio에서 새 모델 로드
#    Models 탭 → 원하는 모델 선택 → Load

# 2. openclaw.json 업데이트
# 모델 ID 확인: curl http://127.0.0.1:1234/v1/models
{
  "agent": {
    "model": "lmstudio/새모델ID"
  }
}

# 3. 게이트웨이 재시작
openclaw gateway restart
```

### 4-2. 로컬 + 클라우드 혼합 사용

비용 효율적인 하이브리드 전략:

```json
{
  "agent": {
    "model": "lmstudio/gemma-4-e4b-it"
  },
  "providers": {
    "lmstudio": {
      "baseUrl": "http://127.0.0.1:1234/v1",
      "apiKey": "lm-studio"
    },
    "anthropic": {
      "apiKey": "sk-ant-..."
    }
  }
}
```

**전략:**
- 일반 대화 → gemma-4-e4b-it (무료, 로컬)
- 복잡한 코딩 → Claude Sonnet (클라우드, 유료)
- 문서 요약 → gemma-4-e4b-it (무료, 로컬)

### 4-3. 보안 설정 강화

```json
{
  "gateway": {
    "port": 18789,
    "auth": {
      "token": "your-secure-token-here"
    }
  },
  "security": {
    "allowedOrigins": ["http://localhost:*"],
    "requirePairing": true
  }
}
```

```bash
# 토큰 생성
openssl rand -hex 32
```

### 4-4. 응답 스타일 커스터마이징

```json
{
  "agent": {
    "model": "lmstudio/gemma-4-e4b-it",
    "systemPrompt": "당신은 한국어를 주로 사용하는 친절한 AI 어시스턴트입니다. 항상 명확하고 구조화된 답변을 제공하세요.",
    "temperature": 0.7,
    "maxTokens": 2048
  }
}
```

### 4-5. 실습 과제

```
[과제 1] LMStudio에서 다른 모델을 로드하고 openclaw.json을 업데이트하세요.
[과제 2] 한국어 전용 시스템 프롬프트를 작성하고 에이전트에 적용하세요.
[과제 3] 보안 토큰을 생성하고 게이트웨이에 적용하세요.
```

---

## Level 5: 심화

### 5-1. gemma-4-e4b-it 모델 특성 이해

**모델 정보:**
- **풀네임**: Gemma 4 Enhanced 4B Instruction-tuned
- **파라미터**: 약 4B (40억)
- **특성**: 경량 고효율, 명령어 수행(instruction-following)에 최적화
- **강점**: 코드 생성, 논리적 추론, 다국어 지원
- **제한**: 최대 컨텍스트 길이에 주의 (모델 버전마다 상이)

**최적 프롬프트 패턴:**

```
# 효과적인 프롬프트 구조
역할 지정: "당신은 시니어 파이썬 개발자입니다."
맥락 제공: "현재 FastAPI 프로젝트에서..."
명확한 요청: "다음 기능을 구현해주세요:"
출력 형식: "코드와 함께 설명을 제공해주세요."
```

**Gemma 모델에 효과적인 프롬프트:**
```
# 코드 작업
"다음 파이썬 코드를 리뷰하고 버그를 찾아 수정해주세요:\n[코드]"

# 분석 작업
"다음 텍스트를 분석하고 핵심 포인트 3가지를 추출해주세요:\n[텍스트]"

# 창작 작업
"다음 주제로 블로그 포스트 개요를 작성해주세요: [주제]"
```

### 5-2. LMStudio 서버 최적화

```bash
# GPU 가속 활성화 (LMStudio Settings → GPU 설정)
# - Metal (macOS): 자동 활성화
# - CUDA (NVIDIA): 드라이버 설치 후 자동
# - ROCm (AMD): 지원 버전 확인

# 컨텍스트 크기 조정 (LMStudio Model Settings)
# - 기본: 4096 토큰
# - 확장: 8192~32768 토큰 (메모리에 따라)
# - 더 많은 컨텍스트 = 더 긴 대화 유지 가능

# 동시 요청 처리 (Advanced Settings)
# n_parallel: 1~4 (CPU/GPU 성능에 따라)
```

### 5-3. 자동화 스크립트 작성

```bash
# daily-briefing.sh — 매일 아침 브리핑 요청
#!/bin/bash
DATE=$(date '+%Y년 %m월 %d일')
openclaw agent --message "오늘은 ${DATE}입니다. 오늘 해야 할 일을 정리하고 집중해야 할 항목을 알려주세요."

# 크론 등록
# crontab -e
# 0 9 * * * /path/to/daily-briefing.sh
```

```bash
# code-review.sh — 코드 파일을 에이전트에게 리뷰 요청
#!/bin/bash
FILE=$1
CONTENT=$(cat "$FILE")
openclaw agent --message "다음 파일을 리뷰해주세요:\n파일: $FILE\n\n\`\`\`\n${CONTENT}\n\`\`\`"
```

### 5-4. MCP (Model Context Protocol) 연동

OpenClaw는 MCP를 지원하여 외부 데이터 소스와 연동 가능합니다:

```json
{
  "mcp": {
    "servers": {
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"]
      },
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token"
        }
      }
    }
  }
}
```

### 5-5. 플러그인 SDK 활용

```javascript
// 커스텀 플러그인 기본 구조 (openclaw-plugin-example/index.js)
export default {
  name: 'my-plugin',
  version: '1.0.0',
  tools: {
    greet: {
      description: '사용자에게 인사합니다',
      parameters: {
        name: { type: 'string', description: '이름' }
      },
      execute: async ({ name }) => {
        return `안녕하세요, ${name}님!`;
      }
    }
  }
};
```

### 5-6. 성능 모니터링

```bash
# 토큰 사용량 모니터링
# 채팅에서: /usage

# 응답 시간 측정
time openclaw agent --message "안녕하세요"

# 게이트웨이 상세 로그
openclaw gateway --verbose 2>&1 | grep -E "tokens|latency|model"
```

---

## 학습 체크리스트

### Level 1 체크리스트
- [ ] Node.js 24 설치 완료
- [ ] LMStudio에서 gemma-4-e4b-it 모델 로드
- [ ] LMStudio 서버 시작 및 연결 테스트
- [ ] OpenClaw 설치 (`openclaw --version` 확인)
- [ ] 설정 파일 배포 (`~/.openclaw/openclaw.json`)
- [ ] 게이트웨이 시작 및 첫 번째 에이전트 대화

### Level 2 체크리스트
- [ ] Telegram 봇 생성 및 토큰 발급
- [ ] 채널 연동 및 페어링 승인
- [ ] 오퍼레이터 명령어 5개 이상 테스트
- [ ] 모바일에서 봇과 대화 성공

### Level 3 체크리스트
- [ ] `--thinking high` 모드로 복잡한 질문 해결
- [ ] 세션 목록 및 이력 조회
- [ ] `/compact` 명령으로 메모리 최적화 경험

### Level 4 체크리스트
- [ ] 다른 LMStudio 모델로 전환 경험
- [ ] 커스텀 시스템 프롬프트 적용
- [ ] 보안 토큰 설정

### Level 5 체크리스트
- [ ] 자동화 스크립트 1개 이상 작성
- [ ] gemma 모델 최적 프롬프트 패턴 습득
- [ ] LMStudio GPU 가속 설정
- [ ] MCP 서버 1개 이상 연동

---

## 자주 묻는 질문 (FAQ)

**Q: gemma-4-e4b-it가 다른 모델보다 느린데 어떻게 개선하나요?**
> A: LMStudio Settings → GPU Layers를 높이세요. GPU가 없다면 n_threads를 CPU 코어 수에 맞게 설정하세요. Context 크기를 줄이면 속도가 향상됩니다.

**Q: 한국어 응답 품질을 높이려면?**
> A: 시스템 프롬프트에 "반드시 한국어로 답변하세요"를 추가하고, 프롬프트도 한국어로 작성하세요. gemma-4 시리즈는 한국어를 지원하지만 영어 대비 품질이 낮을 수 있습니다.

**Q: 대화 내역이 초기화되는 이유는?**
> A: 모델의 컨텍스트 윈도우 초과 시 자동 초기화됩니다. `/compact` 명령으로 주기적으로 압축하거나 LMStudio에서 Context Size를 늘리세요.

**Q: 여러 채널(Telegram + Discord)을 동시에 사용할 수 있나요?**
> A: 네, `openclaw.json`의 `channels` 섹션에 여러 채널을 동시에 등록할 수 있습니다.

**Q: LMStudio 없이 클라우드 모델만 사용할 수 있나요?**
> A: 네, `model`을 `"anthropic/claude-sonnet-4-6"` 등으로 변경하고 해당 API 키를 설정하면 됩니다.

---

## 추가 학습 자료

- **OpenClaw 공식 문서**: https://docs.openclaw.ai
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **LMStudio 문서**: https://lmstudio.ai/docs
- **Gemma 모델 카드**: https://ai.google.dev/gemma
- **MCP 프로토콜**: https://modelcontextprotocol.io
- **OpenAI API 호환 스펙**: https://platform.openai.com/docs/api-reference
