# Design Spec: av-ecosystem-pdca-driven — AutoVibe 생태계 구축 설계 명세

> **Claude Code 실행용 완전 명세 문서**
> 이 문서만으로 신규 프로젝트에서 bkit PDCA를 통해 av 생태계를 재현 가능.
> 생성일: 2026-03-28 | 버전: 2.0 (2026-03-29 개정)
> **연관 PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
> **PDCA Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`
> **Claude Code 공식 문서 기반**: Agent, Skill, Hook, Rule, Memory, Agent Teams 최신 스펙 준수

---

## 1. 디렉토리 구조 명세

### 1.1 `.claude/` 전체 구조

```
{project-root}/
├── .claude/
│   ├── skills/                  # 스킬 SKILL.md (사용자 직접 호출)
│   │   ├── av/                  # 마스터 게이트웨이
│   │   │   ├── SKILL.md
│   │   │   └── reference.md     # 공식: Supporting Files
│   │   ├── av-vibe-forge/       # 마스터 오케스트레이터
│   │   │   ├── SKILL.md
│   │   │   └── reference.md
│   │   └── {other-skills}/
│   ├── agents/                  # 에이전트 AGENT.md (Claude Code SubAgent)
│   │   ├── av-pm-coordinator.md     # PM — opus
│   │   ├── av-do-orchestrator.md    # PL — opus
│   │   ├── av-base-memory-keeper.md # 기억 전문가 — sonnet
│   │   ├── av-base-auditor.md
│   │   └── {other-agents.md}
│   ├── rules/                   # 규칙 파일 (paths: 지연 로딩 지원)
│   │   ├── av-base-spec.md
│   │   ├── av-org-protocol.md
│   │   ├── av-base-plugin-routing.md  # gstack/bkit 플러그인 라우팅 규칙
│   │   └── {other-rules}.md
│   ├── hooks/                   # 훅 셸 스크립트
│   │   ├── av-post-write-monitor.sh
│   │   ├── av-session-discovery.sh
│   │   ├── av-agent-spawn-logger.sh      # SubagentStart 훅
│   │   ├── av-agent-complete-logger.sh   # SubagentStop 훅
│   │   ├── av-config-watcher.sh          # ConfigChange 훅
│   │   └── {other-hooks}.sh
│   ├── registry/
│   │   └── components.json      # 전체 컴포넌트 레지스트리
│   ├── agent-memory/            # 에이전트별 메모리 (memory: project 자동 관리)
│   │   └── {agent-name}/
│   │       └── MEMORY.md
│   └── docs/
│       └── av-claude-code-spec/
│           └── topics/
│               ├── frontmatter-spec.md
│               ├── naming-rules.md
│               ├── protocols.md
│               └── audit-rules.md
├── CLAUDE.md                    # 프로젝트 가이드 (AutoVibe 섹션 포함)
└── .claude/settings.json        # 훅·Agent Teams·권한 설정
```

### 1.2 Claude Code 생성 명령어 (Phase 0)

```bash
# Phase 0: 기반 디렉토리 구조 생성
mkdir -p .claude/{skills,agents,rules,hooks,registry,agent-memory,docs/av-claude-code-spec/topics}
```

---

## 2. components.json 레지스트리 형식

### 2.1 초기 빈 레지스트리 (Phase 0)

```json
{
  "_meta": {
    "version": "2.0",
    "created": "{{YYYY-MM-DD}}",
    "updated": "{{YYYY-MM-DD}}",
    "description": "{{PROJECT_NAME}} AutoVibe registry",
    "total": {
      "agents": 0,
      "skills": 0,
      "hooks": 0,
      "rules": 0
    }
  },
  "rules": {},
  "agents": {},
  "skills": {},
  "hooks": {}
}
```

### 2.2 Rule 등록 형식

```json
"av-base-spec": {
  "group": "base",
  "tier": null,
  "version": "1.0",
  "inherits": null,
  "children": [],
  "file": ".claude/rules/av-base-spec.md",
  "topics": [
    ".claude/docs/av-claude-code-spec/topics/frontmatter-spec.md",
    ".claude/docs/av-claude-code-spec/topics/naming-rules.md"
  ],
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "base",
  "portable": true
}
```

### 2.3 Agent 등록 형식

```json
"av-pm-coordinator": {
  "group": "base",
  "tier": null,
  "version": "1.0",
  "inherits": null,
  "children": [],
  "file": ".claude/agents/av-pm-coordinator.md",
  "scope": ".claude/**",
  "model": "opus",
  "memory": "project",
  "maxTurns": 30,
  "permissionMode": "plan",
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "base",
  "portable": true,
  "description": "PM — 사용자 대화로 요구사항 도출, PRD 작성(bkit), 최종 승인"
}
```

### 2.4 Skill 등록 형식

```json
"av-vibe-forge": {
  "group": "vibe",
  "tier": "meta",
  "version": "1.0",
  "inherits": null,
  "children": [],
  "file": ".claude/skills/av-vibe-forge/SKILL.md",
  "argument-hint": "<subcommand> [args] [--options]",
  "user-invocable": true,
  "context": null,
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "vibe",
  "portable": true,
  "description": "AutoVibe 마스터 오케스트레이터 — skill/agent/hook/rule 생성·검증·관리 (14 서브커맨드)"
}
```

### 2.5 Hook 등록 형식

```json
"av-agent-spawn-logger": {
  "group": "base",
  "tier": null,
  "version": "1.0",
  "hook-type": "SubagentStart",
  "trigger-tools": [],
  "file": ".claude/hooks/av-agent-spawn-logger.sh",
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "base",
  "portable": true
}
```

---

## 3. Rule 파일 형식 명세 (Phase 1)

### 3.1 Rule Frontmatter 공통 형식 (공식 스펙)

```markdown
---
name: av-{rule-name}
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|util|{domain}}
paths:
  - "{glob-pattern}"   # 공식: 이 패턴 매칭 파일 열 때만 로드 (지연 로딩)
---

# {Rule 제목} — {한줄 설명}

> {Rule의 목적과 적용 범위 설명}

## 1. 핵심 원칙
...

## 2. 상세 규칙
...
```

**공식 스펙 참고사항:**
- `paths` 없는 Rule → 세션 시작 시 항상 로드 (CLAUDE.md처럼)
- `paths` 있는 Rule → 매칭 파일 열 때만 로드 (지연 로딩, 컨텍스트 절약)
- 심볼릭 링크 지원 → 프로젝트 간 공유 가능

### 3.2 av-base-spec.md 최소 내용 템플릿

```markdown
---
name: av-base-spec
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
paths:
  - ".claude/agents/**"
  - ".claude/skills/**"
  - ".claude/rules/**"
---

# AutoVibe Claude Code Spec (av-base-spec)

> 모든 av- 컴포넌트 중앙 규칙 인덱스.

## Quick Reference

- `av-` = AutoVibe 생태계 산출물 (Rule/Agent/Skill/Hook에만 적용)
- `autovibe: true` frontmatter 필수
- 네이밍: `av-{domain}-{name}` (kebab-case, 최대 4단어, 도메인 필수)
- 도메인: `vibe` (메타) | `base` (범용 필수) | `util` (범용 선택) | `{project}` (프로젝트 전용)
- 모든 생성은 `/av-vibe-forge`를 통해서만 (레지스트리 자동 등록)
- Agent는 `memory: project` 필드로 영구 메모리 자동 관리 (공식 스펙)
- Skill은 `context: fork` 필드로 격리 실행 가능 (공식 스펙)

## 조직 구조

| 역할 | 에이전트 | 모델 | 책임 |
|------|---------|------|------|
| **PM** | av-pm-coordinator | opus | 사용자 대화, PRD(bkit), 최종 승인 |
| **PL** | av-do-orchestrator | opus | Plan/Design(bkit), Agent Team 스폰, gstack 검증 |
| **Memory** | av-base-memory-keeper | sonnet | 프로젝트 기억 관리 |

## 플러그인 라우팅

| 요청 유형 | 플러그인 | 호출 |
|-----------|---------|------|
| 실행·테스트·배포·브라우저 | gstack | `Skill("gstack", ...)` |
| 문서 작성(PRD/Plan/Design/Report) | bkit | `Skill("bkit:pdca", ...)` |
| 코드 품질 분석 | bkit | `Task("bkit:code-analyzer", ...)` |
| 설계-구현 검증 | bkit | `Task("bkit:gap-detector", ...)` |

## Topic Index

| Topic | 파일 | 내용 |
|-------|------|------|
| Frontmatter | `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` | 유형별 필수 필드 (공식 스펙 기반) |
| Naming | `.claude/docs/av-claude-code-spec/topics/naming-rules.md` | av- 접두사, 도메인 |
| Protocols | `.claude/docs/av-claude-code-spec/topics/protocols.md` | PM/PL/Agent 프로토콜 |
| Audit | `.claude/docs/av-claude-code-spec/topics/audit-rules.md` | 감사 계층 |
```

### 3.3 av-base-plugin-routing.md 템플릿 (신규)

```markdown
---
name: av-base-plugin-routing
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
---

# av-base-plugin-routing — gstack/bkit 플러그인 라우팅 규칙

> av 생태계 에이전트/스킬이 gstack과 bkit 플러그인을 호출하는 규칙.

## gstack (실행·테스트·배포)

| 요청 의도 | gstack 호출 | 담당 |
|-----------|------------|------|
| 레퍼런스 탐색 | `Skill("gstack", "navigate {url}")` | PM |
| UI 레퍼런스 수집 | `Skill("gstack", "screenshot {ref}")` | PL |
| 실시간 구현 확인 | `Skill("gstack", "navigate localhost:{port}")` | Agent Team |
| 시각적 회귀 탐지 | `Skill("gstack", "screenshot {pages}")` | PL |
| 브라우저 E2E 테스트 | `Skill("gstack", "check-errors {url}")` | QA Agent |
| 인터랙션 테스트 | `Skill("gstack", "interact {selector}")` | QA Agent |
| 카나리 배포 모니터링 | `Skill("canary", ...)` | PL |
| 성능 기준선 비교 | `Skill("benchmark", ...)` | Memory Keeper |

## bkit (문서 작성)

| 요청 의도 | bkit 호출 | 담당 |
|-----------|----------|------|
| PRD/Plan 작성 | `Skill("bkit:pdca", "plan {feature}")` | PM → PL |
| Design 작성 | `Skill("bkit:pdca", "design {feature}")` | PL |
| Report 작성 | `Skill("bkit:pdca", "report {feature}")` | PL |
| 코드 품질 분석 | `Task("bkit:code-analyzer", ...)` | Auditor |
| 설계-구현 갭 검증 | `Task("bkit:gap-detector", ...)` | PL |
| 런타임 QA | `Task("bkit:qa-monitor", ...)` | QA Agent |
| 자동 개선 | `Task("bkit:pdca-iterator", ...)` | PL |
| Design 검증 | `Task("bkit:design-validator", ...)` | PL |
```

### 3.4 av-base-memory-first.md 최소 내용 템플릿

```markdown
---
name: av-base-memory-first
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
paths:
  - ".claude/**"
---

# av-base-memory-first — 메모리 우선 읽기 원칙

> 모든 av- 에이전트는 작업 시작 전 반드시 자신의 메모리를 확인해야 한다.
> 공식 스펙: Agent frontmatter의 `memory: project` 필드로 자동 관리.

## 원칙

1. **에이전트**: `memory: project` → `.claude/agent-memory/{name}/MEMORY.md` 자동 로드
2. **스킬**: `Read .claude/skills/{name}/MEMORY.md` (수동)
3. **글로벌**: `~/.claude/projects/{project-slug}/memory/MEMORY.md` (Claude Code auto-memory)

## 메모리 계층

| 계층 | 경로 | 범위 | 관리 |
|------|------|------|------|
| L1 에이전트 | `.claude/agent-memory/{name}/MEMORY.md` | 해당 에이전트 전용 | `memory: project` 자동 |
| L2 스킬 | `.claude/skills/{name}/MEMORY.md` | 해당 스킬 전용 | 수동 Read/Write |
| L4 글로벌 | `~/.claude/projects/{slug}/memory/MEMORY.md` | 전체 공유 | Claude Code auto-memory |
```

---

## 4. Agent 파일 형식 명세 (Phase 2~3)

### 4.1 Agent Frontmatter 공식 완전 형식

```yaml
---
# === 공식 필수 필드 ===
name: av-{agent-name}
description: |
  {에이전트 역할 설명 — 1~3줄}
  트리거: {언제 호출되는지}

# === 공식 권장 필드 ===
tools: [Read, Glob, Grep, Write, Edit]      # 도구 허용 목록
disallowedTools: []                          # 도구 금지 목록
model: sonnet|opus|haiku|inherit             # 모델 선택
permissionMode: default|plan|dontAsk         # 권한 처리 모드
maxTurns: 50                                 # 최대 에이전틱 턴 수
memory: project|user|local                   # 영구 메모리 디렉토리
background: false                            # 백그라운드 실행 여부
effort: medium|high|max                      # 추론 노력 수준
isolation: worktree                          # Git 워크트리 격리 (선택)
skills: [skill-name]                         # 시작 시 주입할 스킬 (선택)
initialPrompt: ""                            # 자동 제출 첫 턴 (선택)

# === av 커스텀 필드 ===
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|{domain}}
tier: null
inherits: null
---

# {에이전트 이름} — {한줄 설명}

> {에이전트의 목적과 책임 설명}

## 역할 및 책임
...

## 실행 프로토콜

### 시작 프로토콜
1. memory: project → MEMORY.md 자동 로드 (공식 스펙)
2. {작업별 초기화}

### 종료 프로토콜
1. 결과 요약 출력
2. MEMORY.md 자동 업데이트 (공식 스펙)
3. av-base-auditor Level 1 Self-Check
```

### 4.2 av-pm-coordinator.md 완전 템플릿

```markdown
---
name: av-pm-coordinator
description: |
  AutoVibe PM 에이전트. 사용자와 대화하여 요구사항을 도출하고 PRD를 작성한다.
  사용자가 생각하지 못한 요구사항을 질문으로 심화한다.
  bkit:pdca 스킬로 PDCA 문서를 관리한다.
  gstack으로 경쟁사·레퍼런스를 탐색한다.
  트리거: /av-pm start {feature} 또는 /av run에서 PM 라우팅
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

# av-pm-coordinator — PM 에이전트

> 사용자와 대화하여 요구사항을 도출하고 PRD를 작성하는 PM 에이전트.

## 핵심 역할

1. **요구사항 도출**: 사용자가 생각하지 못한 질문으로 요구사항 심화
2. **PRD 작성**: bkit:pdca 스킬로 PDCA 문서 관리
3. **레퍼런스 탐색**: gstack으로 경쟁사·레퍼런스 UI 수집
4. **최종 승인**: PL 구현 완료 후 요구사항 충족 여부 확인

## PM 대화 프로토콜

### 질문 전략 (AskUserQuestion)
1. **범위 질문**: "이 기능의 핵심 사용자는 누구인가요?"
2. **기능 질문**: "어떤 기능이 필수이고 어떤 것이 선택인가요?"
3. **예외 질문**: "에러 상황이나 예외 케이스는 어떻게 처리할까요?"
4. **UX 질문**: "사용자 경험에서 가장 중요한 것은 무엇인가요?"
5. **기술 질문**: "기존 시스템과의 연동이 필요한가요?"
6. **비기능 질문**: "성능/보안/확장성 요구사항이 있나요?"

### 최대 질문 수: 6개 (과도한 질문 방지)

## 플러그인 활용

| 단계 | 플러그인 | 호출 |
|------|---------|------|
| 레퍼런스 탐색 | gstack | `Skill("gstack", "navigate {ref-url}")` |
| PRD 작성 | bkit | `Skill("bkit:pdca", "plan {feature}")` |
| PRD → PL 전달 | — | `Agent("av-do-orchestrator")` |

## 실행 프로토콜

### 시작 프로토콜
1. memory: project → MEMORY.md 자동 로드
2. 기존 PRD/대화 이력 확인
3. 사용자와 AskUserQuestion 대화 시작

### 종료 프로토콜
1. PRD 작성 완료 → bkit:pdca 스킬
2. PL에게 PRD 전달
3. MEMORY.md 업데이트 (요구사항 패턴, 도메인 지식)
```

### 4.3 av-do-orchestrator.md 완전 템플릿

```markdown
---
name: av-do-orchestrator
description: |
  AutoVibe PL 에이전트. PM으로부터 PRD를 받아 Plan/Design을 작성하고
  Agent Team을 스폰하여 구현·테스트를 조율한다.
  gstack으로 실행·테스트·배포를 오케스트레이션한다.
  bkit으로 문서를 관리하고 bkit:gap-detector로 구현을 검증한다.
  트리거: PM이 PRD 전달 시 또는 /av run에서 PL 라우팅
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

# av-do-orchestrator — PL 에이전트

> PM으로부터 PRD를 받아 기술적 계획·설계를 수행하고 Agent Team을 조율하는 PL 에이전트.

## 핵심 역할

1. **Plan 작성**: PRD 기반 + 프로젝트 학습 내용 → bkit:pdca plan
2. **Design 작성**: Plan 기반 상세 설계 → bkit:pdca design
3. **Agent Team 스폰**: Claude Code Agent Teams로 도메인 에이전트 생성
4. **구현 조율**: Task 할당 → 병렬 구현 → 결과 수집
5. **gstack 검증**: 실시간 구현 확인, 시각적 회귀 탐지, E2E 테스트
6. **검토**: bkit:gap-detector Match Rate ≥ 90% 확인
7. **Report**: bkit:pdca report → Archive → 기억 에이전트에 학습 이력

## gstack 생명주기 관리 (7단계)

| 단계 | gstack 호출 |
|------|------------|
| Think | `Skill("gstack", "navigate {ref}")` — 레퍼런스 탐색 |
| Plan | `Skill("gstack", "screenshot {ref}")` — UI 레퍼런스 수집 |
| Build | `Skill("gstack", "navigate localhost")` — 실시간 확인 |
| Review | `Skill("gstack", "screenshot {pages}")` — 시각적 회귀 |
| Test | `Skill("gstack", "check-errors {url}")` — E2E 테스트 |
| Ship | `Skill("canary", ...)` — 카나리 모니터링 |
| Reflect | `Skill("benchmark", ...)` — 성능 기준선 |

## Agent Team 스폰 프로토콜

```
1. /av-vibe-forge agent {domain}-lead --group {domain}
2. /av-vibe-forge agent {domain}-backend --group {domain}
3. /av-vibe-forge agent {domain}-frontend --group {domain}
4. /av-vibe-forge agent {domain}-qa --group {domain}
5. Task 할당 → 병렬 구현 시작
6. 구현 완료 → 결과 수집 → 검증
```

## 검증 프로토콜

```
1. Task("bkit:gap-detector", ...) → Match Rate 확인
2. Skill("gstack", "check-errors {url}") → 브라우저 오류 확인
3. Task("bkit:code-analyzer", ...) → 코드 품질 확인
4. Match Rate < 90% → Task("bkit:pdca-iterator", ...) 자동 개선
5. Match Rate ≥ 90% → PM 승인 요청
```

## 실행 프로토콜

### 시작 프로토콜
1. memory: project → MEMORY.md 자동 로드
2. PRD 수신 확인 → 프로젝트 기존 아키텍처 참조
3. Plan/Design 작성 시작 (bkit)

### 종료 프로토콜
1. Report 작성 (bkit:pdca report)
2. Archive → av-base-memory-keeper에 학습 이력 전달
3. MEMORY.md 업데이트 (아키텍처 결정, 기술 패턴)
```

### 4.4 av-base-memory-keeper.md 완전 템플릿 (신규)

```markdown
---
name: av-base-memory-keeper
description: |
  프로젝트 기억 전문 에이전트. 프로젝트 의사결정 이력, 학습된 패턴,
  아키텍처 결정사항, 에이전트 간 공유 지식을 관리한다.
  모든 PDCA 사이클 완료 시 학습 내용을 메모리에 저장한다.
  gstack benchmark 결과, bkit 분석 결과를 축적한다.
  트리거: PDCA Archive 시, PL/PM 요청 시, SubagentStop 훅
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

# av-base-memory-keeper — 프로젝트 기억 전문가

> 프로젝트의 장기 기억을 관리하는 전문 에이전트.

## 기억 영역

| 영역 | 저장 내용 | 소스 |
|------|---------|------|
| 의사결정 이력 | 왜 이 아키텍처를 선택했는지 | PL Report |
| 학습된 패턴 | 성공/실패한 구현 패턴 | Agent 작업 결과 |
| 도메인 지식 | 프로젝트 특화 비즈니스 규칙 | PM PRD |
| 기술 부채 | 알려진 제약사항과 해결 과제 | Auditor 검수 |
| 성능 기준선 | gstack benchmark 결과 이력 | PL 검증 |
| 품질 이력 | bkit:gap-detector Match Rate 이력 | PL 검증 |

## 기억 저장 프로토콜

1. PDCA 사이클 완료 시 → PL이 Report 전달 → 핵심 학습 추출
2. 성능 테스트 완료 시 → gstack benchmark 결과 저장
3. 코드 리뷰 완료 시 → 반복 패턴/안티패턴 기록
4. 에이전트 종료 시(SubagentStop) → 작업 결과 요약 저장

## MEMORY.md 구조

```markdown
# av-base-memory-keeper Memory

## 아키텍처 결정 (최근 10건)
| 날짜 | 결정 | 이유 | 결과 |

## 학습된 패턴 (누적)
| 패턴 | 컨텍스트 | 성공률 |

## 성능 기준선
| 페이지 | LCP | FID | CLS | 측정일 |

## 품질 이력
| 기능 | Match Rate | 날짜 |
```
```

### 4.5 av-base-auditor.md 최소 내용 템플릿

```markdown
---
name: av-base-auditor
description: |
  코드 품질·로직·메모리 검증 에이전트.
  bkit:code-analyzer를 활용하여 품질·보안·아키텍처를 분석한다.
  모든 av- 에이전트 작업 완료 후 Level 1~3 감사 수행.
  트리거: 모든 av- 스킬/에이전트 종료 프로토콜 (Level에 따라)
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Glob, Grep, Write, Edit, Task]
model: sonnet
memory: project
maxTurns: 30
permissionMode: default
---

# av-base-auditor — 코드 품질·로직·메모리 검증

## 감사 레벨

| Level | 범위 | 트리거 |
|-------|------|--------|
| **Level 1** Self-Check | 자신의 출력물만 검토 | 모든 av- 에이전트 종료 시 |
| **Level 2** 표준 감사 | 변경 파일 전체 + bkit:code-analyzer | PL/PM 요청 시 |
| **Level 3** 종합 감사 | 전체 코드베이스 + bkit:gap-detector | 릴리즈 전 |

## bkit 통합

- Level 2: `Task("bkit:code-analyzer", ...)` — 품질·보안 분석
- Level 3: `Task("bkit:gap-detector", ...)` — 설계-구현 갭 분석
```

### 4.6 MEMORY.md 초기 형식 (공식 `memory: project` 자동 생성)

```markdown
---
name: {에이전트명} Memory
type: agent
created: {{YYYY-MM-DD}}
---

# {에이전트명} MEMORY

> 마지막 업데이트: {{YYYY-MM-DD}}

## 라우팅/실행 이력 (최근 5건)

(없음 — 첫 실행 후 누적)

## 학습된 패턴

(없음 — 작업 완료 후 누적)

## 주의 사항

(없음)
```

---

## 5. Skill 파일 형식 명세 (Phase 4~5)

### 5.1 Skill Frontmatter 공식 완전 형식

```yaml
---
# === 공식 필수 필드 ===
name: av-{skill-name}
description: |
  {스킬 역할 설명 — 1~3줄}

# === 공식 권장 필드 ===
argument-hint: "{서브커맨드 힌트}"
user-invocable: true                         # 사용자 직접 호출 가능
disable-model-invocation: false              # Claude 자동 호출 차단
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent, Skill]
context: fork                                # 격리된 서브에이전트에서 실행
agent: general-purpose|Explore|Plan          # fork 시 에이전트 타입
model: sonnet|opus|inherit                   # 모델 선택
effort: medium|high|max                      # 추론 노력
paths: ["src/**/*.ts"]                       # 지연 로딩 경로 (매칭 파일 열 때만 로드)
hooks: {}                                    # 스킬 스코프 훅
shell: bash|powershell                       # 명령어 주입 셸

# === av 커스텀 필드 ===
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|{domain}}
tier: {meta|null}
inherits: null
---

# {스킬 이름} — {한줄 설명}

> {스킬 목적}

## 서브커맨드

| 커맨드 | 설명 |
|--------|------|
| `{cmd}` | {설명} |

## 문자열 치환 (공식 지원)

- `$ARGUMENTS` — 전체 인자
- `$ARGUMENTS[0]`, `$1` — 첫 번째 인자
- `${CLAUDE_SESSION_ID}` — 세션 ID
- `${CLAUDE_SKILL_DIR}` — 스킬 디렉토리 경로
- `` !`command` `` — 전처리 명령어 실행

## 실행 프로토콜
...
```

### 5.2 av/SKILL.md ROUTING_TABLE 완전 형식

```markdown
---
name: av
description: |
  AutoVibe 마스터 게이트웨이. 자연어 요청 → 최적 컴포넌트 자동 선정 → 위임 실행.
  PM/PL 조직 라우팅 + gstack(실행·테스트) + bkit(문서) 통합.
autovibe: true
version: "2.0"
created: "{{YYYY-MM-DD}}"
group: base
argument-hint: "run|find|optimize|health|stats [args]"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent, Skill]
# Skill 포함: gstack(브라우저), bkit(문서), canary(배포), benchmark(성능) 호출
---

# av — AutoVibe 마스터 게이트웨이

## ROUTING_TABLE (커스터마이즈 필수)

> 사용자의 자연어 요청을 분석하여 최적 컴포넌트로 라우팅한다.
> gstack은 실행·테스트·배포, bkit은 문서 작성을 전담한다.

```
# === 조직 라우팅 (PM / PL) ===
pm + feature/requirement/prd/요구사항/기능정의
  → Agent("av-pm-coordinator")
  → PM이 사용자와 대화 → 요구사항 도출 → PRD (bkit)

plan + design/implement/build/구현/설계
  → Agent("av-do-orchestrator")
  → PL이 Plan/Design (bkit) → Agent Team 스폰 → gstack 검증

# === gstack 라우팅 (7단계 생명주기) ===
think + research/reference/탐색/조사
  → Skill("gstack", "navigate {url}")

build + check/preview/확인/미리보기
  → Skill("gstack", "navigate localhost:{port}")

review + visual/screenshot/스크린샷/시각적
  → Skill("gstack", "screenshot {page}")

test + browser/e2e/ui/테스트/브라우저
  → Skill("gstack", "check-errors {url}")
  → Skill("gstack", "screenshot {page}")

test + interaction/click/form/인터랙션
  → Skill("gstack", "interact {selector}")

ship + deploy/canary/배포/카나리
  → Skill("canary", ...)

reflect + benchmark/performance/성능/기준선
  → Skill("benchmark", ...)

# === bkit 라우팅 (문서 관리) ===
document + plan/design/report/문서/보고서
  → Skill("bkit:pdca", "{type} {feature}")

analyze + gap/verify/검증/갭
  → Task("bkit:gap-detector", ...)

analyze + code/security/quality/품질/보안
  → Task("bkit:code-analyzer", ...)
  → Task("av-base-auditor", "Level 2")

analyze + runtime/logs/로그/런타임
  → Task("bkit:qa-monitor", ...)

# === 기존 라우팅 ===
creation + any
  → Skill("av-vibe-forge", "skill {name}")

optimization + refactor
  → Skill("av-base-refactor", "analyze {target}")

optimization + token/component/config
  → Task("av-base-optimizer", "{mode} {target}")

configuration + commit/git
  → Skill("av-base-git-commit", "commit {message}")

configuration + sync/claude-md
  → Skill("av-base-sync", "update")

meta-management + create + skill
  → Skill("av-vibe-forge", "skill {name}")

meta-management + create + agent
  → Skill("av-vibe-forge", "agent {name}")

meta-management + health/validate
  → Skill("av-vibe-forge", "health")

testing + quality/lint/build
  → Skill("av-base-code-quality", "{target}")

memory + recall/search/기억/이력
  → Agent("av-base-memory-keeper")

[fallback]
  → AskUserQuestion으로 선택지 제시

# Phase 7 이후 도메인 확장:
# {domain} + backend/api/frontend
#   → Agent("av-{domain}-lead")
#   → Agent Team 스폰 → PL 조율
```
```

### 5.3 av-pm/SKILL.md 핵심 형식 (context: fork)

```markdown
---
name: av-pm
description: |
  PM 대화형 인터페이스. 사용자와 대화하여 요구사항을 도출하고
  bkit:pdca 스킬로 PRD를 작성한다. gstack으로 레퍼런스를 탐색한다.
autovibe: true
version: "2.0"
created: "{{YYYY-MM-DD}}"
group: base
argument-hint: "start {feature}"
user-invocable: true
allowed-tools: [Read, Write, Edit, AskUserQuestion, Skill, Agent]
context: fork
agent: general-purpose
model: opus
effort: max
---

# av-pm — PM 대화형 인터페이스

> `/av-pm start {feature}` — 사용자와 대화하여 요구사항 도출 → PRD 작성

## 인자: $ARGUMENTS

`$1` = feature 이름

## 실행 프로토콜

1. Agent("av-pm-coordinator") 스폰 — PM 에이전트 활성화
2. PM이 사용자와 AskUserQuestion 대화 (최대 6개 질문)
3. 요구사항 확정 → `Skill("bkit:pdca", "plan $1")` PRD 작성
4. PRD를 PL에게 전달 → `Agent("av-do-orchestrator")`
```

### 5.4 av-base-post-qa/SKILL.md 핵심 형식 (gstack + bkit 통합)

```markdown
---
name: av-base-post-qa
description: |
  대량 작업 후 QA 오케스트레이션.
  gstack 브라우저 E2E 테스트 + bkit:qa-monitor 런타임 QA.
autovibe: true
version: "2.0"
created: "{{YYYY-MM-DD}}"
group: base
argument-hint: "[url] [--full]"
user-invocable: true
allowed-tools: [Read, Glob, Grep, Bash, Skill, Task]
context: fork
agent: general-purpose
---

# av-base-post-qa — QA 오케스트레이션

> gstack + bkit:qa-monitor 통합 QA

## 실행 시퀀스

1. `Skill("gstack", "navigate $1")` — 페이지 로드 확인
2. `Skill("gstack", "check-errors $1")` — 콘솔 오류 탐지
3. `Skill("gstack", "screenshot $1")` — 시각적 스냅샷
4. `Task("bkit:qa-monitor", ...)` — 서버 로그 오류 감지
5. QA 결과 통합 리포트 출력

## --full 모드 (전체 페이지)

1. 모든 주요 페이지에 대해 위 시퀀스 반복
2. `Skill("gstack", "interact {forms}")` — 인터랙션 테스트
3. `Skill("benchmark", "$1")` — 성능 기준선 측정
```

---

## 6. Hook 파일 형식 명세 (Phase 6)

### 6.1 Hook 셸 스크립트 공통 헤더

```bash
#!/bin/bash
# name: av-{hook-name}
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: PreToolUse|PostToolUse|SessionStart|SubagentStart|SubagentStop|ConfigChange
# trigger-tools: Write, Edit  (해당하는 경우)
# description: 훅 동작 설명

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$LOG_DIR"
```

### 6.2 av-agent-spawn-logger.sh 템플릿 (신규 — SubagentStart)

```bash
#!/bin/bash
# name: av-agent-spawn-logger
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: SubagentStart
# description: 에이전트 스폰 시 로깅 — 조직 구조 추적

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/agent-lifecycle.log"
mkdir -p "$(dirname "$LOG_FILE")"

# stdin에서 JSON 읽기 (공식 스펙)
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

echo "${TIMESTAMP} | SPAWN | ${AGENT_TYPE}" >> "$LOG_FILE"

# av- 에이전트 스폰 시 알림
if [[ "$AGENT_TYPE" == av-* ]]; then
  echo "[av-lifecycle] Agent 스폰: ${AGENT_TYPE}" >&2
fi

exit 0
```

### 6.3 av-agent-complete-logger.sh 템플릿 (신규 — SubagentStop)

```bash
#!/bin/bash
# name: av-agent-complete-logger
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: SubagentStop
# description: 에이전트 완료 시 로깅 + 기억 에이전트에 결과 전달 트리거

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/agent-lifecycle.log"
mkdir -p "$(dirname "$LOG_FILE")"

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

echo "${TIMESTAMP} | COMPLETE | ${AGENT_TYPE}" >> "$LOG_FILE"

exit 0
```

### 6.4 av-config-watcher.sh 템플릿 (신규 — ConfigChange)

```bash
#!/bin/bash
# name: av-config-watcher
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: ConfigChange
# matcher: skills|project_settings
# description: 스킬/설정 변경 감지 시 레지스트리 동기화 알림

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/config-changes.log"
mkdir -p "$(dirname "$LOG_FILE")"

INPUT=$(cat)
CHANGE_TYPE=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

echo "${TIMESTAMP} | CONFIG_CHANGE | ${CHANGE_TYPE}" >> "$LOG_FILE"
echo "[av-config] 설정 변경 감지 — components.json 동기화 필요" >&2

exit 0
```

### 6.5 기존 훅 템플릿 (개선된 if 조건)

**av-bash-guard.sh (if 조건 추가):**
```bash
#!/bin/bash
# name: av-bash-guard
# autovibe: true
# version: 2.0
# created: {{YYYY-MM-DD}}
# hook-type: PreToolUse
# trigger-tools: Bash
# description: 위험 Bash 명령어 차단 — settings.json if 조건과 연동

set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# 공식 스펙: exit 2 = 차단, stderr 메시지가 Claude에 전달
BLOCKED_PATTERNS=(
  "rm -rf /"
  "sudo rm"
  "DROP TABLE"
  "DELETE FROM.*WHERE 1=1"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "[av-bash-guard] 차단: $pattern" >&2
    exit 2
  fi
done

exit 0
```

---

## 7. CLAUDE.md AutoVibe 섹션 형식 (Phase 0)

```markdown
## AutoVibe 생태계

자기 성장 AI 개발 생태계. 스펙: `.claude/rules/av-base-spec.md`
레지스트리: `.claude/registry/components.json`

### 조직 구조

| 역할 | 에이전트 | 모델 | 책임 |
|------|---------|------|------|
| PM | av-pm-coordinator | opus | 사용자 대화 → PRD(bkit) → 최종 승인 |
| PL | av-do-orchestrator | opus | Plan/Design(bkit) → Agent Team → gstack 검증 |
| Memory | av-base-memory-keeper | sonnet | 프로젝트 기억 관리 |

### 핵심 스킬

| 스킬 | 역할 |
|------|------|
| `/av {자연어}` | 마스터 게이트웨이 — 자연어 → 최적 컴포넌트 + PM/PL 라우팅 |
| `/av-vibe-forge` | 마스터 오케스트레이터 — skill/agent/hook/rule 관리 |
| `/av-pm start {feature}` | PM 인터페이스 — 사용자 대화 → PRD (bkit) |
| `/av-base-code-quality` | 코드 품질 게이트 (bkit:code-analyzer 통합) |
| `/av-base-post-qa` | QA (gstack E2E + bkit:qa-monitor) |
| `/av-base-git-commit` | git 커밋 자동화 |

### 플러그인 통합

| 플러그인 | 역할 | 호출 |
|---------|------|------|
| **gstack** | 실행·테스트·배포 (7단계 생명주기) | `Skill("gstack", ...)` |
| **bkit** | 문서 작성·코드 분석·갭 검증 | `Skill("bkit:pdca", ...)` / `Task("bkit:*", ...)` |
| **canary** | 카나리 배포 모니터링 | `Skill("canary", ...)` |
| **benchmark** | 성능 기준선 비교 | `Skill("benchmark", ...)` |

### 워크플로우

```
사용자 → /av {자연어}
  → PM 대화 (AskUserQuestion) → PRD (bkit)
  → PL Plan/Design (bkit) → Agent Team 스폰
  → 구현 → gstack 테스트 → PL 검토 (bkit:gap-detector)
  → PM 승인 → Report (bkit) → Archive → 기억 저장
```

### 컴포넌트

| 유형 | 수량 | 경로 |
|------|------|------|
| Agents | {{N}} | `.claude/agents/` |
| Skills | {{N}} | `.claude/skills/` |
| Hooks | {{N}} | `.claude/hooks/` |
| Rules | {{N}} | `.claude/rules/` |
```

---

## 8. settings.json 완전 형식 (Phase 6)

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-post-write-monitor.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-session-discovery.sh"
          }
        ]
      },
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-base-precompact.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-content-scanner.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "if": "Bash(rm *)|Bash(sudo *)|Bash(DROP *)",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-bash-guard.sh"
          }
        ]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-agent-spawn-logger.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-agent-complete-logger.sh"
          }
        ]
      }
    ],
    "ConfigChange": [
      {
        "matcher": "skills|project_settings",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-config-watcher.sh"
          }
        ]
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

---

## 9. Frontmatter Spec 문서 형식 (Phase 0 — 필수 참조 문서)

이 파일은 `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`에 생성한다.

```markdown
# Frontmatter Spec — av- 컴포넌트 유형별 필수/선택 필드 (공식 스펙 기반)

## Agent (`.claude/agents/av-*.md`)

**공식 필수**: name, description
**공식 권장**: tools, disallowedTools, model, permissionMode, maxTurns, memory, background, effort, isolation, skills, initialPrompt
**av 필수**: autovibe, version, created, group

## Skill (`.claude/skills/av-*/SKILL.md`)

**공식 필수**: name, description
**공식 권장**: argument-hint, user-invocable, disable-model-invocation, allowed-tools, context, agent, model, effort, paths, hooks, shell
**문자열 치환**: $ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}, !`command`
**Supporting Files**: reference.md, examples.md (SKILL.md와 같은 디렉토리)
**av 필수**: autovibe, version, created, group

## Hook (`.claude/hooks/av-*.sh`)

**공식 이벤트**: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStart, SubagentStop, ConfigChange, FileChanged, CwdChanged
**공식 핸들러 타입**: command, http, prompt, agent
**공식 매처**: 도구명, startup|resume|clear|compact, 에이전트타입명 등
**공식 조건**: if (permission rule syntax)
**종료코드**: 0=허용, 2=차단(stderr→Claude), 기타=허용
셸 스크립트 주석으로 메타데이터: # name, autovibe, version, created, hook-type, trigger-tools, description

## Rule (`.claude/rules/av-*.md`)

**공식 필수**: (없음 — 마크다운 파일만 있으면 됨)
**공식 권장**: paths (배열 — 지연 로딩 경로 패턴)
**av 필수**: name, autovibe, version, created, group, paths
```

---

## 10. Phase별 Claude Code 실행 시나리오

### Phase 0 실행 시나리오

```
1. AskUserQuestion: 프로젝트 정보 수집
   - 프로젝트 이름: {{PROJECT_NAME}}
   - 기술 스택: {{TECH_STACK}}
   - 소스 루트: {{SRC_ROOT}}
   - 도메인 그룹: {{DOMAIN_GROUPS}}

2. Bash: mkdir -p .claude/{skills,agents,rules,hooks,registry,agent-memory,docs/av-claude-code-spec/topics}

3. Write: .claude/registry/components.json (빈 레지스트리)

4. Write: .claude/docs/av-claude-code-spec/topics/frontmatter-spec.md (공식 스펙 기반)

5. Write|Edit: .claude/settings.json (Agent Teams env 설정)

6. Edit CLAUDE.md: AutoVibe 섹션 추가 (CLAUDE.md 없으면 Write)
```

### Phase 1 실행 시나리오

```
1. Write: .claude/rules/av-base-spec.md (§3.2 — paths: 지연 로딩)
2. Write: .claude/rules/av-org-protocol.md (PM→PL→Agent 조직 커스터마이즈)
3. Write: .claude/rules/av-base-memory-first.md (§3.4 — memory: project)
4. Write: .claude/rules/av-util-mermaid-std.md
5. Write: .claude/rules/av-base-plugin-routing.md (§3.3 — gstack/bkit 라우팅 규칙)
6. Edit: .claude/registry/components.json → rules 5개 추가
```

### Phase 2 실행 시나리오 (조직 에이전트 — 최우선)

```
1. Write: .claude/agents/av-pm-coordinator.md (§4.2 — opus, memory: project)
2. Write: .claude/agents/av-do-orchestrator.md (§4.3 — opus, memory: project)
3. Write: .claude/agents/av-base-memory-keeper.md (§4.4 — sonnet, memory: project)
4. Edit: .claude/registry/components.json → agents 3개 추가
   (memory: project → .claude/agent-memory/ 자동 관리)
```

### Phase 3 실행 시나리오 (Base Agents)

```
각 에이전트별 실행:
1. Write: .claude/agents/{agent-name}.md (§4.1 공식 frontmatter 완전 형식)
   필수 포함: memory: project, maxTurns, permissionMode
2. Edit: .claude/registry/components.json → agents 섹션에 추가

8개 에이전트:
  av-base-auditor, av-base-optimizer, av-base-template,
  av-base-git-committer, av-base-refactor-advisor, av-base-qa-reviewer,
  av-base-sync-auditor, av-vibe-vibecoder
```

### Phase 4 실행 시나리오 (Forge)

```
각 Forge 스킬별 실행:
1. Bash: mkdir -p .claude/skills/{skill-name}
2. Write: .claude/skills/{skill-name}/SKILL.md
3. Write: .claude/skills/{skill-name}/reference.md (공식 Supporting Files)
4. Edit: .claude/registry/components.json → skills 섹션에 추가

6개 스킬:
  1. av-vibe-skill-forge  (스킬 생성 — $ARGUMENTS 치환 포함)
  2. av-vibe-agent-forge  (에이전트 생성 — 공식 frontmatter 필드 보장)
  3. av-vibe-hook-forge   (훅 생성 — 공식 이벤트 타입 보장)
  4. av-vibe-rule-forge   (룰 생성 — paths 지연 로딩 포함)
  5. av-vibe-forge        (마스터 오케스트레이터)
  6. av-vibe-portable-init (이식 초기화)
```

### Phase 5 실행 시나리오 (Core Skills)

```
1. av/SKILL.md 생성 (ROUTING_TABLE — §5.2, gstack/bkit 통합 라우팅)
2. av-pm/SKILL.md 생성 (context: fork, agent: general-purpose — §5.3)
3. av-base-post-qa/SKILL.md 생성 (gstack E2E + bkit:qa-monitor — §5.4)
4. av-base-code-quality/SKILL.md 생성 (bkit:code-analyzer 통합)
5. 나머지 6개 스킬 생성:
   av-base-git-commit, av-base-sync, av-base-refactor,
   av-ecosystem-optimizer, av-agent-chat, av-docs-guard
```

### Phase 6 실행 시나리오 (Hooks)

```
1. Write: .claude/hooks/av-post-write-monitor.sh
2. Write: .claude/hooks/av-session-discovery.sh (matcher: startup|resume)
3. Write: .claude/hooks/av-content-scanner.sh
4. Write: .claude/hooks/av-bash-guard.sh (if 조건 연동)
5. Write: .claude/hooks/av-base-precompact.sh (matcher: compact)
6. Write: .claude/hooks/av-agent-spawn-logger.sh (SubagentStart — §6.2)
7. Write: .claude/hooks/av-agent-complete-logger.sh (SubagentStop — §6.3)
8. Write: .claude/hooks/av-config-watcher.sh (ConfigChange — §6.4)
9. Bash: chmod +x .claude/hooks/*.sh
10. Write|Edit: .claude/settings.json (§8 — Agent Teams + 훅 + 권한)
11. Edit: registry → hooks 섹션 8개 추가
```

### Phase 7 확장 시나리오 (PM → PL → Agent Team)

```
사용자: "{{domain}} 기능이 필요해"

1. /av-pm start {{domain}}
   → PM(av-pm-coordinator)이 사용자와 대화
   → AskUserQuestion: 도메인 범위, 기능 상세, 완료 기준
   → 요구사항 확정 → PRD 작성 (bkit:pdca)
   → PRD를 PL에게 전달

2. PL(av-do-orchestrator) 실행:
   → Plan 작성 (bkit:pdca plan)
   → Design 작성 (bkit:pdca design)

3. Agent Team 스폰:
   /av-vibe-forge agent {{domain}}-lead --group {{domain}}
   /av-vibe-forge agent {{domain}}-backend --group {{domain}}
   /av-vibe-forge agent {{domain}}-frontend --group {{domain}}
   /av-vibe-forge agent {{domain}}-qa --group {{domain}}

4. Task 할당 → 병렬 구현

5. gstack 검증 (PL):
   Skill("gstack", "navigate localhost:{port}")  → 실시간 확인
   Skill("gstack", "check-errors {url}")          → E2E 테스트
   Skill("gstack", "screenshot {pages}")          → 시각적 확인

6. bkit 검증 (PL):
   Task("bkit:gap-detector", ...) → Match Rate ≥ 90%
   Task("bkit:code-analyzer", ...) → 코드 품질 확인
   Match Rate < 90% → Task("bkit:pdca-iterator", ...) 자동 개선

7. PM 최종 승인:
   요구사항 충족 여부 확인

8. 완료:
   Skill("bkit:pdca", "report {{domain}}")  → Report 작성
   Agent("av-base-memory-keeper")           → 학습 이력 저장
   Edit av/SKILL.md → ROUTING_TABLE에 {{domain}} 경로 추가:
     {{domain}} + backend/frontend/api
       → Agent("av-{{domain}}-lead")

9. /av-vibe-forge health → 건강도 확인
```

---

## 11. 완성 검증 체크리스트

Phase 0~6 완료 후 실행:

```bash
# 1. 디렉토리 구조 확인
ls .claude/{skills,agents,rules,hooks,registry,agent-memory}

# 2. 레지스트리 확인
cat .claude/registry/components.json | jq '._meta.total'

# 3. 훅 파일 권한 확인
ls -la .claude/hooks/*.sh

# 4. settings.json 확인 (Agent Teams + 훅 + 권한)
cat .claude/settings.json | jq '.hooks | keys'
cat .claude/settings.json | jq '.env'
```

Claude Code 검증:
```
/av-vibe-forge health
  → 기대: 90/100 이상

/av run 코드 품질 검사
  → 기대: av-base-code-quality → Task("bkit:code-analyzer", ...)

/av run 브라우저 테스트
  → 기대: Skill("gstack", "check-errors {url}")

/av run 갭 분석
  → 기대: Task("bkit:gap-detector", ...)

/av run QA 실행
  → 기대: av-base-post-qa → gstack E2E + bkit:qa-monitor

/av-pm start test-feature
  → 기대: PM 대화(AskUserQuestion) → PRD(bkit) → PL 전달

/av run 보고서 작성
  → 기대: Skill("bkit:pdca", "report ...")
```

---

## 12. 기술 스택별 커스터마이즈 가이드

### NestJS + Next.js (TypeScript)

```
av-base-auditor 체크 3:
  "NestJS Module/Controller/Service DI 패턴 + Prisma 규칙 + Biome lint"

av-base-code-quality 빌드 명령어:
  "pnpm lint && pnpm typecheck && pnpm build"

av-bash-guard 금지 패턴 추가:
  "as any" 타입 강제, "import type" DI 사용
```

### FastAPI + React (Python)

```
av-base-auditor 체크 3:
  "FastAPI Router/Endpoint/Pydantic 패턴 + SQLAlchemy 규칙 + Ruff lint"

av-base-code-quality 빌드 명령어:
  "ruff check . && mypy . && pytest"

av-bash-guard 금지 패턴 추가:
  "eval(" 사용, "subprocess.shell=True"
```

### Django + React

```
av-base-auditor 체크 3:
  "Django View/Serializer/Model 패턴 + ORM 규칙 + flake8"

av-base-code-quality 빌드 명령어:
  "python manage.py check && pytest"
```

### Go + React

```
av-base-auditor 체크 3:
  "Go Handler/Service/Repository 패턴 + interface 규칙 + golint"

av-base-code-quality 빌드 명령어:
  "go vet ./... && go test ./... && go build ./..."
```

---

## 13. Claude 대화 표준 패턴 (AskUserQuestion 흐름)

### 13.1 Phase 시작 표준 프롬프트

모든 Phase는 단일 패턴으로 시작합니다:

```
Phase {N}을 시작해줘.
```

Claude가 AskUserQuestion으로 필요한 정보를 수집합니다. 추가 옵션이 있을 때만 지정:

```
Phase 2를 시작해줘. 기술 스택은 {stack}이야.
Phase 5를 시작해줘. 도메인은 {domain1}, {domain2}야.
Phase 6를 시작해줘. 금지 명령어는 {pattern}이야.
```

### 13.2 Phase별 AskUserQuestion 수집 항목

| Phase | 수집 항목 | 기본값 |
|-------|---------|--------|
| Phase 0 | 프로젝트 이름, 기술 스택, 도메인 그룹, 소스 루트 | src |
| Phase 1 | 조직 승인 프로세스, 멀티테넌트 여부 | PM→PL→Agent, 단일 테넌트 |
| Phase 2 | PM 최대 질문 수, PL 최대 팀 인원, 기억 영역 | 6개, 5명, 의사결정+패턴+아키텍처 |
| Phase 3 | 기술 스택 (코드 품질 도구), 감사 레벨 | Phase 0 재사용, 3단계 |
| Phase 4 | 컴포넌트 그룹 체계, ROUTING_TABLE 전략 | base/vibe 기본 |
| Phase 5 | ROUTING_TABLE 도메인 경로, UI 유무(gstack) | Phase 0 재사용 |
| Phase 6 | 금지 Bash 패턴, 세션 로드 컨텍스트, SubagentStart 로깅 | rm -rf, DROP |
| Phase 7 | 도메인 범위, 에이전트 역할, 완료 기준 | Lead+Backend+Frontend+QA |

### 13.3 사용자 안내 원칙

1. **질문 최소화**: Phase별로 3개 이하의 핵심 질문만
2. **기본값 제공**: 모든 항목에 합리적인 기본값 (Enter로 수락 가능)
3. **문맥 재사용**: Phase 0 설정은 이후 모든 Phase에서 재사용
4. **에러 시 즉시 안내**: 문제 발생 시 구체적인 재시도 방법 제시

---

## 14. gstack & bkit 통합 명세

### 14.1 통합 원칙

av 생태계 컴포넌트는 **조직 기반 플러그인 호출** 방식으로 gstack과 bkit을 활용한다:

- 사용자는 `/av {자연어}` 하나만 입력
- av ROUTING_TABLE이 의도를 분석하여 최적 컴포넌트 + 플러그인 선택
- PM/PL/Agent가 각자 역할에 따라 gstack/bkit을 직접 호출
- 플러그인 세부 명령어는 av 컴포넌트 내부에 캡슐화 (사용자 노출 최소화)

### 14.2 gstack 통합 상세 (7단계 생명주기)

```
호출 컴포넌트: av-pm-coordinator, av-do-orchestrator, av-base-post-qa, av/ROUTING_TABLE
호출 방법: Skill("gstack", "{subcommand} {args}")

생명주기별 사용:
  Think:   PM이 Skill("gstack", "navigate {ref-url}") — 경쟁사 탐색
  Plan:    PL이 Skill("gstack", "screenshot {ref}") — UI 레퍼런스
  Build:   Agent가 Skill("gstack", "navigate localhost") — 실시간 확인
  Review:  PL이 Skill("gstack", "screenshot {pages}") — 시각적 회귀
  Test:    QA가 Skill("gstack", "check-errors {url}") — E2E 테스트
  Ship:    PL이 Skill("canary", ...) — 카나리 모니터링
  Reflect: Memory가 Skill("benchmark", ...) — 성능 기준선
```

### 14.3 bkit 통합 상세 (문서 작성 전담)

```
호출 컴포넌트: av-pm-coordinator, av-do-orchestrator, av-base-auditor, av/ROUTING_TABLE
호출 방법: Skill("bkit:pdca", ...) 또는 Task("bkit:{agent}", ...)

문서 관리:
  PRD:     PM이 Skill("bkit:pdca", "plan {feature}")
  Plan:    PL이 Skill("bkit:pdca", "plan {feature}")
  Design:  PL이 Skill("bkit:pdca", "design {feature}")
  Report:  PL이 Skill("bkit:pdca", "report {feature}")

품질 검증:
  코드:    Auditor가 Task("bkit:code-analyzer", ...)
  갭:      PL이 Task("bkit:gap-detector", ...)
  런타임:  QA가 Task("bkit:qa-monitor", ...)
  자동개선: PL이 Task("bkit:pdca-iterator", ...) (Match Rate < 90%)
  Design:  PL이 Task("bkit:design-validator", ...)
```

### 14.4 Phase별 gstack / bkit 사용 매트릭스

| Phase | gstack | bkit |
|-------|--------|------|
| Phase 0~1 | — | `Skill("bkit:pdca", "plan|design")` |
| Phase 2 | PM 레퍼런스 탐색 | PM PRD 작성 |
| Phase 3 | — | PL Plan/Design |
| Phase 4 | — | Forge가 공식 frontmatter 보장 |
| Phase 5 | `av-base-post-qa` E2E | `av-base-code-quality` code-analyzer |
| Phase 6 | SubagentStart/Stop 로깅 | — |
| Phase 7 | 전 생명주기 (7단계) | 전 문서 관리 (PRD~Report) |

---

## 15. 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **PDCA Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`
- **Claude Code 공식 문서**: Agent, Skill, Hook, Rule, Memory, Agent Teams 최신 스펙 기준
- **av-org-protocol**: `.claude/rules/av-org-protocol.md`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
- **Phase 진행 가이드**: `guides/phase-progression.md`
- **네이밍 가이드**: `guides/naming-guide.md`
- **bkit 에이전트**: `bkit:gap-detector`, `bkit:code-analyzer`, `bkit:qa-monitor`, `bkit:pdca-iterator`, `bkit:report-generator`, `bkit:design-validator`
- **gstack**: 헤드리스 브라우저 `Skill("gstack", ...)` — navigate, screenshot, check-errors, interact
- **canary**: 카나리 배포 모니터링 `Skill("canary", ...)`
- **benchmark**: 성능 기준선 비교 `Skill("benchmark", ...)`
