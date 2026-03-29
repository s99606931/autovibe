# PDCA: av-ecosystem-pdca-driven — bkit PDCA 기반 av 생태계 점진적 구축

> **에이전트**: av-pm-coordinator | **PL**: av-do-orchestrator | **PM**: av-pm-coordinator
> **생성**: 2026-03-28 | **개정**: 2026-03-29 | **상태**: DRAFT

---

## Plan (계획)

### 목표
bkit PDCA 사이클을 활용하여 신규 프로젝트에서 사용자와 대화하면서
av(AutoVibe) 생태계를 7개 Phase로 점진적으로 구축한다.
사용자가 자연어로 요청하면 av 조직(PM→PL→Agent Team)이 gstack(실행·테스트)과
bkit(문서 작성)을 활용하여 최고 품질의 결과를 보장한다.

### 핵심 원칙
- **자연어 인터페이스**: 사용자는 `/av {자연어}` 하나만 사용
- **조직 구조**: PM↔사용자 대화 → PL 계획 → Agent Team 구현 → PL/PM 검토·승인
- **gstack**: 생각→계획→구축→검토→테스트→출시→성찰 전 생명주기
- **bkit**: 모든 PDCA 문서(PRD, Plan, Design, Report) 관리 전담
- **프로젝트 기억**: 전문 에이전트(av-base-memory-keeper)가 학습 이력 관리

### 범위
`.claude/` 디렉토리 전체 생태계:
- Base Rules 5종, 조직 에이전트 3종, Base Agents 8종
- Meta Skills(Forge) 6종, Core Skills 10종, Hooks 8종
- `components.json` 레지스트리, `settings.json` 훅/Agent Teams 등록, `CLAUDE.md` AutoVibe 섹션

### Phase별 계획

---

#### Phase 0: 기반 인프라 구축 (Bootstrap)

**목표**: `.claude/` 디렉토리 구조 생성 + 빈 Registry + CLAUDE.md 스캐폴딩 + Agent Teams 활성화

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p0-bootstrap
/pdca design av-ecosystem-p0-bootstrap
```

**사용자-Claude 대화 포인트:**
- Q: "프로젝트 이름은 무엇인가요?" → `{{PROJECT_NAME}}`
- Q: "사용하는 기술 스택은?" → `{{TECH_STACK}}`
- Q: "주요 도메인 그룹은?" → `{{DOMAIN_GROUPS}}`
- Q: "소스 루트 경로는?" → `{{SRC_ROOT}}` (기본: `src`)

**생성 파일:**
```
.claude/
├── skills/           # 스킬 SKILL.md 파일 위치
├── agents/           # 에이전트 AGENT.md 파일 위치
├── rules/            # 규칙 파일 위치
├── hooks/            # 훅 셸 스크립트 위치
├── registry/
│   └── components.json   # 빈 레지스트리
├── agent-memory/     # 에이전트 메모리 (memory: project 자동 관리)
└── docs/             # av-claude-code-spec 등 문서
    └── av-claude-code-spec/
        └── topics/   # frontmatter-spec.md 등
```

**settings.json 초기 설정 (Agent Teams 활성화):**
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**완료 기준:**
- [ ] `.claude/` 모든 서브디렉토리 생성
- [ ] `components.json` 기본 구조 생성 (빈 레지스트리)
- [ ] `CLAUDE.md` AutoVibe 섹션 추가
- [ ] `settings.json` Agent Teams 환경변수 설정

---

#### Phase 1: Base Rules 생성

**목표**: av 생태계의 핵심 규칙 5종 생성 (gstack/bkit 플러그인 라우팅 규칙 포함)

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p1-rules
/pdca design av-ecosystem-p1-rules
```

**사용자-Claude 대화 포인트:**
- Q: "조직 승인 프로세스가 필요한가요? (PM→PL→Agent 3단계)" → av-org-protocol 커스터마이즈
- Q: "멀티테넌트 지원이 필요한가요?" → tenantId 관련 규칙 포함/제외

**생성 컴포넌트:**
```
.claude/rules/
├── av-base-spec.md             # AutoVibe 중앙 규칙 인덱스
├── av-org-protocol.md          # PM→PL→Agent 승인 프로토콜
├── av-base-memory-first.md     # 메모리 우선 읽기 원칙
├── av-util-mermaid-std.md      # Mermaid 다이어그램 표준
└── av-base-plugin-routing.md   # gstack/bkit 플러그인 라우팅 규칙
```

**av-base-plugin-routing.md 핵심 내용:**
```markdown
# gstack/bkit 플러그인 라우팅 규칙
- 실행·테스트·배포·브라우저 작업 → gstack
- 문서 작성(PRD/Plan/Design/Report) → bkit:pdca
- 코드 품질 분석 → bkit:code-analyzer
- 설계-구현 갭 검증 → bkit:gap-detector
- 에이전트는 직접 플러그인을 호출하되, ROUTING_TABLE을 통해 최적 경로 선택
```

**완료 기준:**
- [ ] 5개 Rule 파일 생성 + `autovibe: true` frontmatter 포함
- [ ] `av-base-plugin-routing.md`에 gstack/bkit 라우팅 규칙 명시
- [ ] Rule의 `paths:` 필드로 지연 로딩 설정 (공식 스펙)
- [ ] `components.json` rules 섹션에 5개 등록

---

#### Phase 2: 조직 에이전트 생성 (PM / PL / Memory Keeper)

**목표**: av 조직의 핵심 3종 에이전트 최우선 생성 — 이후 모든 Phase는 이 조직을 통해 진행

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p2-org-agents
/pdca design av-ecosystem-p2-org-agents
```

**사용자-Claude 대화 포인트:**
- Q: "PM이 사용자에게 질문할 때 최대 질문 수는?" (기본: 6개)
- Q: "PL이 Agent Team 스폰 시 최대 인원은?" (기본: 5명)
- Q: "프로젝트 기억에 어떤 내용을 저장할까요?" (기본: 의사결정, 패턴, 아키텍처)

**생성 컴포넌트:**

```
.claude/agents/
├── av-pm-coordinator.md        # PM — opus, memory: project
├── av-do-orchestrator.md       # PL — opus, memory: project
└── av-base-memory-keeper.md    # 기억 전문가 — sonnet, memory: project
```

**av-pm-coordinator.md 핵심 (공식 Agent Frontmatter):**
```yaml
---
name: av-pm-coordinator
description: |
  AutoVibe PM 에이전트. 사용자와 대화하여 요구사항을 도출하고 PRD를 작성한다.
  사용자가 생각하지 못한 요구사항을 질문으로 심화한다.
  bkit:pdca 스킬로 PDCA 문서를 관리한다.
  트리거: /av-pm start {feature} 또는 /av run {자연어}에서 PM 라우팅
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Glob, Grep, Write, Edit, AskUserQuestion, Skill, Agent]
disallowedTools: [Bash]
model: opus
permissionMode: plan
maxTurns: 30
memory: project
effort: max
---
```

**av-do-orchestrator.md 핵심 (공식 Agent Frontmatter):**
```yaml
---
name: av-do-orchestrator
description: |
  AutoVibe PL 에이전트. PM으로부터 PRD를 받아 Plan/Design을 작성하고
  Agent Team을 스폰하여 구현·테스트를 조율한다.
  gstack으로 실행·테스트·배포를 오케스트레이션한다.
  bkit:pdca 스킬로 문서를 관리하고 bkit:gap-detector로 구현을 검증한다.
  트리거: PM이 PRD 전달 시 또는 /av run {자연어}에서 PL 라우팅
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Write, Edit, Glob, Grep, Bash, Agent, Skill, Task]
model: opus
permissionMode: default
maxTurns: 100
memory: project
effort: max
---
```

**av-base-memory-keeper.md 핵심 (공식 Agent Frontmatter):**
```yaml
---
name: av-base-memory-keeper
description: |
  프로젝트 기억 전문 에이전트. 프로젝트 의사결정 이력, 학습된 패턴,
  아키텍처 결정사항, 에이전트 간 공유 지식을 관리한다.
  모든 PDCA 사이클 완료 시 학습 내용을 메모리에 저장한다.
  트리거: PDCA Archive 시 또는 PL/PM 요청
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Write, Edit, Glob, Grep]
disallowedTools: [Bash, Agent]
model: sonnet
memory: project
maxTurns: 20
effort: high
---
```

**완료 기준:**
- [ ] 3개 조직 에이전트 파일 생성 (공식 frontmatter 필드 포함)
- [ ] `memory: project` 필드로 `.claude/agent-memory/{name}/` 자동 관리
- [ ] PM이 `AskUserQuestion`으로 사용자와 대화 가능
- [ ] PL이 `Agent` 도구로 Agent Team 스폰 가능
- [ ] `components.json` agents 섹션에 3개 등록

---

#### Phase 3: Base Agents 생성

**목표**: 모든 프로젝트에 필요한 범용 에이전트 8종 생성 — 공식 frontmatter 스펙 준수

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p3-base-agents
/pdca design av-ecosystem-p3-base-agents
```

**사용자-Claude 대화 포인트:**
- Q: "코드 품질 체크 도구는?" (Biome/ESLint/Ruff 등) → av-base-auditor 커스터마이즈
- Q: "감사 레벨을 몇 단계로 설정할까요?" (1~3단계) → 감사 계층 설정

**생성 컴포넌트:**
```
.claude/agents/
├── av-base-auditor.md          # 코드 품질·로직 검증 — bkit:code-analyzer 활용
├── av-base-optimizer.md        # 토큰·컴포넌트·설정 최적화
├── av-base-template.md         # 템플릿 레지스트리·스캐폴딩
├── av-base-git-committer.md    # Conventional Commits 메시지 생성
├── av-base-refactor-advisor.md # 리팩토링 기회 탐지·제안
├── av-base-qa-reviewer.md      # QA 검수 — gstack E2E + bkit:qa-monitor
├── av-base-sync-auditor.md     # CLAUDE.md 정합성 검증
└── av-vibe-vibecoder.md        # 생태계 갭 분석·컴포넌트 추천
```

**모든 Base Agent 공통 frontmatter (공식 스펙):**
```yaml
---
name: av-base-{name}
description: |
  {역할 설명}
  트리거: {언제 호출되는지}
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Glob, Grep, Write, Edit]    # 에이전트별 커스터마이즈
model: sonnet
memory: project                             # 공식 필드 — 영구 메모리
maxTurns: 30                                # 공식 필드 — 최대 턴
permissionMode: default                     # 공식 필드 — 권한 모드
---
```

**gstack/bkit 통합 에이전트 상세:**

| 에이전트 | gstack 활용 | bkit 활용 |
|---------|-------------|-----------|
| `av-base-auditor` | — | `Task("bkit:code-analyzer", ...)` |
| `av-base-qa-reviewer` | `Skill("gstack", "check-errors")` | `Task("bkit:qa-monitor", ...)` |
| `av-vibe-vibecoder` | — | `Task("bkit:gap-detector", ...)` |

**완료 기준:**
- [ ] 8개 Agent 파일 생성 + 공식 필수 frontmatter 포함
  (`name`, `description`, `tools`, `model`, `memory`, `maxTurns`, `permissionMode`)
- [ ] `memory: project`로 메모리 자동 관리 (수동 MEMORY.md 초기화 불필요)
- [ ] QA 에이전트: gstack + bkit 통합 확인
- [ ] `components.json` agents 섹션에 8개 등록

---

#### Phase 4: Meta Skills / Forge 생성

**목표**: av 생태계의 핵심 오케스트레이터 및 생성 도구(Forge) 6종 생성

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p4-forge-skills
/pdca design av-ecosystem-p4-forge-skills
```

**사용자-Claude 대화 포인트:**
- Q: "컴포넌트 그룹 체계를 어떻게 설정할까요?" (예: [core] user, product [extended] analytics)
- Q: "기본 ROUTING_TABLE 전략은?" (도메인별 위임 규칙)

**생성 컴포넌트:**
```
.claude/skills/
├── av-vibe-forge/
│   └── SKILL.md        # 마스터 오케스트레이터 (14 서브커맨드)
├── av-vibe-skill-forge/
│   └── SKILL.md        # 스킬 생성 전담
├── av-vibe-agent-forge/
│   └── SKILL.md        # 에이전트 생성 전담 (공식 frontmatter 필드 포함)
├── av-vibe-hook-forge/
│   └── SKILL.md        # 훅 생성 전담 (공식 이벤트 타입 포함)
├── av-vibe-rule-forge/
│   └── SKILL.md        # 룰 생성 전담
└── av-vibe-portable-init/
    └── SKILL.md        # 신규 프로젝트 초기화
```

**Forge가 생성하는 Agent/Skill의 공식 필드 보장:**
```
av-vibe-agent-forge 생성 시 반드시 포함:
  - memory: project|user|local
  - maxTurns: {N}
  - permissionMode: default|plan|dontAsk
  - disallowedTools: [] (필요 시)

av-vibe-skill-forge 생성 시 반드시 포함:
  - context: fork (격리 실행이 필요한 경우)
  - paths: [] (지연 로딩 경로)
  - $ARGUMENTS, ${CLAUDE_SKILL_DIR} 등 문자열 치환 활용
```

**완료 기준:**
- [ ] 6개 Skill 파일 생성
- [ ] `av-vibe-forge` 14개 서브커맨드 동작 확인
- [ ] Forge가 공식 frontmatter 필드를 포함하여 Agent/Skill 생성
- [ ] `components.json` skills 섹션에 6개 등록

---

#### Phase 5: Core Skills 생성 (gstack / bkit 통합)

**목표**: 일상 워크플로우를 자동화하는 핵심 스킬 10종 생성 — gstack/bkit 플러그인 완전 통합

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p5-core-skills
/pdca design av-ecosystem-p5-core-skills
```

**사용자-Claude 대화 포인트:**
- Q: "ROUTING_TABLE에 어떤 도메인별 위임 규칙이 필요한가요?" → av/SKILL.md 커스터마이즈
- Q: "PM 워크플로우 팀 구성 기준은?" → av-pm/SKILL.md 도메인 감지 규칙
- Q: "UI가 있는 프로젝트인가요?" → gstack 브라우저 QA 통합 여부 결정
- Q: "bkit PDCA 품질 게이트 수준은?" → bkit:gap-detector 임계값 설정

**생성 컴포넌트:**
```
.claude/skills/
├── av/
│   └── SKILL.md                # 마스터 게이트웨이 (ROUTING_TABLE)
│                               #   PM 라우팅 → av-pm-coordinator
│                               #   PL 라우팅 → av-do-orchestrator
│                               #   testing + browser → Skill("gstack", ...)
│                               #   analyze + gap → Task("bkit:gap-detector", ...)
│                               #   document + write → Skill("bkit:pdca", ...)
├── av-pm/
│   └── SKILL.md                # PM 대화형 인터페이스 (context: fork)
├── av-base-code-quality/
│   └── SKILL.md                # 코드 품질 게이트 — bkit:code-analyzer 통합
├── av-base-git-commit/
│   └── SKILL.md                # git 커밋 자동화
├── av-base-sync/
│   └── SKILL.md                # CLAUDE.md 자동 최신화
├── av-base-refactor/
│   └── SKILL.md                # 리팩토링 스킬
├── av-base-post-qa/
│   └── SKILL.md                # QA 오케스트레이션 — gstack E2E + bkit:qa-monitor
├── av-ecosystem-optimizer/
│   └── SKILL.md                # 생태계 최적화
├── av-agent-chat/
│   └── SKILL.md                # 에이전트 자연어 대화 인터페이스
└── av-docs-guard/
    └── SKILL.md                # 문서 디렉토리 감시 — bkit:design-validator
```

**av/SKILL.md ROUTING_TABLE 핵심 (gstack/bkit 통합):**
```
# 조직 라우팅
pm + feature/requirement/prd
  → Agent("av-pm-coordinator")
  → PM이 사용자와 대화 → PRD (bkit:pdca)

plan + design/implement/build
  → Agent("av-do-orchestrator")
  → PL이 Plan/Design (bkit) → Agent Team 스폰

# gstack 라우팅 (7단계 생명주기)
think + research/reference
  → Skill("gstack", "navigate {url}")

build + check/preview
  → Skill("gstack", "navigate localhost:{port}")

test + browser/e2e/ui
  → Skill("gstack", "check-errors {url}")
  → Skill("gstack", "screenshot {page}")

ship + deploy/canary
  → Skill("canary", ...)

reflect + benchmark/performance
  → Skill("benchmark", ...)

# bkit 라우팅 (문서 관리)
document + plan/design/report
  → Skill("bkit:pdca", "{type} {feature}")

analyze + gap/verify
  → Task("bkit:gap-detector", ...)

analyze + code/security/quality
  → Task("bkit:code-analyzer", ...)

# 기존 라우팅
optimization + refactor → Skill("av-base-refactor", ...)
configuration + commit/git → Skill("av-base-git-commit", ...)
configuration + sync → Skill("av-base-sync", ...)
meta-management + create → Skill("av-vibe-forge", ...)
```

**av-pm/SKILL.md 핵심 (context: fork — 공식 스펙):**
```yaml
---
name: av-pm
description: |
  PM 대화형 인터페이스. 사용자와 대화하여 요구사항을 도출하고
  bkit:pdca 스킬로 PRD를 작성한다.
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
argument-hint: "start {feature}"
user-invocable: true
allowed-tools: [Read, Write, Edit, AskUserQuestion, Skill, Agent]
context: fork
agent: general-purpose
---
```

**gstack 통합 상세 (av-base-post-qa):**
```
사용자: "QA 실행해줘"
  → av-base-post-qa 실행
    1. Skill("gstack", "navigate {url}") — 페이지 로드 확인
    2. Skill("gstack", "check-errors {url}") — 콘솔 오류 탐지
    3. Skill("gstack", "screenshot {pages}") — 시각적 회귀 탐지
    4. Task("bkit:qa-monitor", ...) — 서버 로그 오류 감지
    5. QA 결과 통합 리포트 출력
```

**bkit 통합 상세 (av-base-code-quality):**
```
사용자: "코드 품질 검사 해줘"
  → av-base-code-quality 실행
    1. Bash: lint + typecheck (프로젝트 스택별)
    2. Task("bkit:code-analyzer", ...) — 품질·보안·아키텍처 분석
    3. 결과 통합 → G1 품질 게이트 PASS/FAIL 판정
```

**완료 기준:**
- [ ] 10개 Skill 파일 생성
- [ ] `/av run {자연어}` → ROUTING_TABLE 라우팅 정상 동작
- [ ] PM 라우팅: `/av-pm start {feature}` → 사용자 대화 → PRD (bkit)
- [ ] PL 라우팅: Agent Team 스폰 → 구현 → 검토
- [ ] gstack: `av-base-post-qa`에서 브라우저 E2E 정상 동작
- [ ] bkit: `av-base-code-quality`에서 code-analyzer 통합 동작
- [ ] `av-pm/SKILL.md`: `context: fork` 격리 실행 정상 동작
- [ ] `components.json` skills 섹션에 10개 추가 등록 (누적 16개)

---

#### Phase 6: Hooks & Settings 등록

**목표**: Claude Code 이벤트 기반 자동화 훅 8종 + settings.json 등록 — 공식 최신 이벤트 포함

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p6-hooks
/pdca design av-ecosystem-p6-hooks
```

**사용자-Claude 대화 포인트:**
- Q: "Write 이벤트 후 어떤 자동 검사가 필요한가요?" → write-monitor 커스터마이즈
- Q: "세션 시작 시 자동으로 로드할 컨텍스트가 있나요?" → session-discovery 커스터마이즈
- Q: "금지할 Bash 명령어 패턴이 있나요?" → bash-guard 커스터마이즈
- Q: "에이전트 스폰/종료 시 로깅이 필요한가요?" → SubagentStart/Stop 훅

**생성 컴포넌트:**
```
.claude/hooks/
├── av-post-write-monitor.sh        # PostToolUse (Write, Edit)
├── av-session-discovery.sh         # SessionStart (startup, resume)
├── av-content-scanner.sh           # PreToolUse (Write, Edit)
├── av-bash-guard.sh                # PreToolUse (Bash)
├── av-base-precompact.sh           # SessionStart (compact)
├── av-agent-spawn-logger.sh        # SubagentStart — 에이전트 스폰 기록
├── av-agent-complete-logger.sh     # SubagentStop — 에이전트 완료 기록 + 메모리 업데이트
└── av-config-watcher.sh            # ConfigChange (skills, project_settings)
```

**settings.json 완전 형식 (공식 최신 스펙):**
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-post-write-monitor.sh" }]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-session-discovery.sh" }]
      },
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-base-precompact.sh" }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-content-scanner.sh" }]
      },
      {
        "matcher": "Bash",
        "if": "Bash(rm *)|Bash(sudo *)|Bash(DROP *)",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-bash-guard.sh" }]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-agent-spawn-logger.sh" }]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-agent-complete-logger.sh" }]
      }
    ],
    "ConfigChange": [
      {
        "matcher": "skills|project_settings",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-config-watcher.sh" }]
      }
    ]
  },
  "permissions": {
    "allow": [
      "Bash(chmod +x .claude/hooks/*.sh)",
      "Bash(jq *)",
      "Bash(git log*)",
      "Bash(git status*)",
      "Bash(git diff*)",
      "Skill(gstack*)",
      "Skill(bkit:*)",
      "Skill(canary*)",
      "Skill(benchmark*)"
    ]
  }
}
```

**완료 기준:**
- [ ] 8개 훅 셸 스크립트 생성 + 실행 권한 부여 (`chmod +x`)
- [ ] `SubagentStart/Stop` 훅: 에이전트 스폰/완료 로깅 정상 동작
- [ ] `ConfigChange` 훅: 스킬/설정 변경 감지 정상 동작
- [ ] `if` 조건: Bash Guard에서 위험 명령만 선택적 차단
- [ ] `.claude/settings.json` 훅 + Agent Teams + 권한 등록 완료
- [ ] `components.json` hooks 섹션에 8개 등록

---

#### Phase 7: 도메인 확장 (반복 사이클)

**목표**: 프로젝트 특화 도메인 에이전트·스킬을 PM/PL 조직 기반으로 지속 확장

**워크플로우 (PM → PL → Agent Team):**
```
사용자: "이커머스 주문 관리 기능이 필요해"
        ↓
PM (av-pm-coordinator):
  AskUserQuestion 대화:
    1. "주문 유형은? (일반/정기/선물)"
    2. "결제 후 배송 상태 추적이 필요한가요?"
    3. "환불/취소 정책은?"
    4. "주문 내역 대시보드가 필요한가요?"
    5. "재고 관리 연동이 필요한가요?"
  → 요구사항 확정 → PRD 작성 (bkit:pdca)
  → PRD를 PL에게 전달
        ↓
PL (av-do-orchestrator):
  1. PRD 기반 Plan 작성 (bkit:pdca)
  2. Design 작성 (bkit:pdca)
  3. Agent Team 스폰:
     /av-vibe-forge agent ecom-order-lead --group ecom
     /av-vibe-forge agent ecom-order-backend --group ecom
     /av-vibe-forge agent ecom-order-frontend --group ecom
     /av-vibe-forge agent ecom-order-qa --group ecom
  4. Task 할당 → 병렬 구현
        ↓
Agent Team:
  - ecom-order-backend: API 구현
  - ecom-order-frontend: UI 구현
  - ecom-order-qa: gstack E2E 테스트 + bkit:qa-monitor
        ↓
PL 검토:
  1. Task("bkit:gap-detector", ...) → Match Rate ≥ 90% 확인
  2. Skill("gstack", "check-errors {url}") → 브라우저 오류 없음
  3. Match Rate < 90% → Task("bkit:pdca-iterator", ...) 자동 개선
        ↓
PM 최종 승인:
  1. Report 작성 (bkit:pdca report)
  2. Archive → av-base-memory-keeper에 학습 이력 저장
  3. ROUTING_TABLE에 ecom 도메인 경로 추가
```

**완료 기준:**
- [ ] 도메인별 Lead + Backend + Frontend + QA 에이전트 생성
- [ ] PM↔사용자 대화로 요구사항 도출 → PRD 작성 (bkit)
- [ ] PL이 Plan/Design (bkit) → Agent Team 스폰
- [ ] Agent Team 구현 → gstack 테스트 → PL 검토
- [ ] `bkit:gap-detector` Match Rate ≥ 90%
- [ ] PM 승인 → Report (bkit) → Archive
- [ ] 기억 에이전트(av-base-memory-keeper)에 학습 이력 저장
- [ ] `av/SKILL.md` ROUTING_TABLE에 도메인 경로 추가
- [ ] `/av run {domain} {task}` 정상 라우팅

---

### 완료 기준 (전체)

| 항목 | 기준 |
|------|------|
| **건강도** | `/av-vibe-forge health` ≥ 90/100 |
| **게이트웨이** | `/av run {자연어}` 신뢰도 ≥ 8/10 |
| **PM 워크플로우** | PM↔사용자 대화 → PRD (bkit) → PL 전달 |
| **PL 워크플로우** | Plan/Design (bkit) → Agent Team 스폰 → 구현 → 검토 |
| **Agent Team** | 도메인 에이전트 3~5명 병렬 구현 → 결과 수집 |
| **gstack 통합** | 7단계 생명주기(생각~성찰) 전 과정 정상 동작 |
| **bkit 통합** | 모든 PDCA 문서(PRD/Plan/Design/Report) bkit 관리 |
| **Registry** | `components.json` 전체 컴포넌트 등록 |
| **프로젝트 기억** | av-base-memory-keeper가 학습 이력 관리 |
| **품질 게이트** | G1~G5 자동 동작 확인 |

---

## Do (실행)

> 이 섹션은 각 Phase 실행 시 작성됩니다.

- **시작**: 미정 | **완료**: 미정
- **Phase 진행 현황**: Phase 0 대기 중

---

## Check (검증)

| Gate | 결과 | 담당 | 비고 |
|------|------|------|------|
| G1 코드 품질 | 대기 | Agent (셀프) | Biome/ESLint + TypeCheck + bkit:code-analyzer |
| G2 Match Rate | 대기 | PL (자동) | bkit:gap-detector ≥90% |
| G3 보안 | 대기 | Agent (셀프) | OWASP + bkit:code-analyzer security scan |
| G4 PL 검토 | 대기 | av-do-orchestrator | Agent Team 결과 검토 + gstack 확인 |
| G5 PM 승인 | 대기 | av-pm-coordinator | 요구사항 충족 여부 최종 확인 |

---

## Act (개선)

> PM APPROVED 후 작성 예정

- **학습 내용**: TBD → av-base-memory-keeper에 저장
- **개선 제안**: TBD
- **Archive 일시**: TBD
- **Archive 경로**: `docs/pdca/archived/archive/2026-03/av-ecosystem-pdca-driven/`

---

## 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **Design Spec**: `docs/design/av-ecosystem-design-spec.md`
- **Claude Code 공식 문서**: Agent, Skill, Hook, Rule, Memory, Agent Teams 스펙 기준
- **av-org-protocol**: `.claude/rules/av-org-protocol.md`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
