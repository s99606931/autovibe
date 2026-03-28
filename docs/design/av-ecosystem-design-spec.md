# Design Spec: av-ecosystem-pdca-driven — AutoVibe 생태계 구축 설계 명세

> **Claude Code 실행용 완전 명세 문서**
> 이 문서만으로 신규 프로젝트에서 bkit PDCA를 통해 av 생태계를 재현 가능.
> 생성일: 2026-03-28 | 버전: 1.0
> **연관 PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
> **PDCA Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`

---

## 1. 디렉토리 구조 명세

### 1.1 `.claude/` 전체 구조

```
{project-root}/
├── .claude/
│   ├── skills/                  # 스킬 SKILL.md (사용자 직접 호출)
│   │   ├── av/                  # 마스터 게이트웨이
│   │   │   ├── SKILL.md
│   │   │   └── MEMORY.md
│   │   ├── av-vibe-forge/       # 마스터 오케스트레이터
│   │   │   ├── SKILL.md
│   │   │   └── MEMORY.md
│   │   └── {other-skills}/
│   ├── agents/                  # 에이전트 AGENT.md (Claude Code SubAgent)
│   │   ├── av-base-auditor.md
│   │   ├── av-base-optimizer.md
│   │   └── {other-agents.md}
│   ├── rules/                   # 규칙 파일 (항상 로드)
│   │   ├── av-base-spec.md
│   │   ├── av-org-protocol.md
│   │   └── {other-rules}.md
│   ├── hooks/                   # 훅 셸 스크립트
│   │   ├── av-post-write-monitor.sh
│   │   ├── av-session-discovery.sh
│   │   ├── av-content-scanner.sh
│   │   ├── av-bash-guard.sh
│   │   └── av-base-precompact.sh
│   ├── registry/
│   │   └── components.json      # 전체 컴포넌트 레지스트리
│   ├── agent-memory/            # 에이전트별 메모리
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
└── .claude/settings.json        # 훅 등록 설정
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
    "version": "1.0",
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
    ".claude/docs/av-claude-code-spec/topics/naming-rules.md",
    ".claude/docs/av-claude-code-spec/topics/protocols.md",
    ".claude/docs/av-claude-code-spec/topics/audit-rules.md"
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
"av-base-auditor": {
  "group": "base",
  "tier": null,
  "version": "1.0",
  "inherits": null,
  "children": [],
  "file": ".claude/agents/av-base-auditor.md",
  "scope": ".claude/**",
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "base",
  "portable": true,
  "description": "코드 품질·로직·메모리 검증 — 모든 av- 에이전트 작업 완료 후 Level 1~3 감사"
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
"av-post-write-monitor": {
  "group": "base",
  "tier": null,
  "version": "1.0",
  "hook-type": "PostToolUse",
  "trigger-tools": ["Write", "Edit"],
  "file": ".claude/hooks/av-post-write-monitor.sh",
  "status": "active",
  "created": "{{YYYY-MM-DD}}",
  "autovibe": true,
  "domain": "base",
  "portable": true
}
```

---

## 3. Rule 파일 형식 명세 (Phase 1)

### 3.1 Rule Frontmatter 공통 형식

```markdown
---
name: av-{rule-name}
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|util|{domain}}
paths:
  - "{glob-pattern}"   # 이 Rule이 적용되는 경로
---

# {Rule 제목} — {한줄 설명}

> {Rule의 목적과 적용 범위 설명}

## 1. 핵심 원칙
...

## 2. 상세 규칙
...
```

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
- 버전: `Major.Minor` 문자열 (e.g. `"1.0"`, `"2.1"`)
- 모든 생성은 `/av-vibe-forge`를 통해서만 (레지스트리 자동 등록)

## Topic Index

| Topic | 파일 | 내용 |
|-------|------|------|
| Frontmatter | `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` | 유형별 필수 필드 |
| Naming | `.claude/docs/av-claude-code-spec/topics/naming-rules.md` | av- 접두사, 도메인 |
| Protocols | `.claude/docs/av-claude-code-spec/topics/protocols.md` | 시작/종료 프로토콜 |
| Audit | `.claude/docs/av-claude-code-spec/topics/audit-rules.md` | 감사 계층 |
| Org Protocol | `.claude/rules/av-org-protocol.md` | 팀원→PL→PM 승인 |

## Stats

- spec: v1.0 | created: {{YYYY-MM-DD}}
- registry: `.claude/registry/components.json`
```

### 3.3 av-base-memory-first.md 최소 내용 템플릿

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

> 모든 av- 에이전트는 작업 시작 전 반드시 자신의 MEMORY.md를 읽어야 한다.

## 원칙

1. **에이전트 시작 프로토콜 STEP 1**: `Read .claude/agent-memory/{name}/MEMORY.md`
2. **스킬 시작 프로토콜 STEP 1**: `Read .claude/skills/{name}/MEMORY.md`
3. **글로벌 메모리 참조**: `~/.claude/projects/{project-slug}/memory/MEMORY.md`

## 메모리 계층

| 계층 | 경로 | 범위 |
|------|------|------|
| L1 에이전트 | `.claude/agent-memory/{name}/MEMORY.md` | 해당 에이전트 전용 |
| L2 스킬 | `.claude/skills/{name}/MEMORY.md` | 해당 스킬 전용 |
| L4 글로벌 | `~/.claude/projects/{slug}/memory/MEMORY.md` | 전체 공유 |

## MEMORY.md 초기 형식

```markdown
# {컴포넌트명} Memory

> 생성: {{YYYY-MM-DD}} | 마지막 업데이트: {{YYYY-MM-DD}}

## 라우팅 이력 (최근 5건)
(없음)

## 학습된 패턴
(없음)

## 주의 사항
(없음)
```
```

---

## 4. Agent 파일 형식 명세 (Phase 2)

### 4.1 Agent Frontmatter 공통 형식

```markdown
---
name: av-{agent-name}
description: |
  {에이전트 역할 설명 — 1~3줄}
  트리거: {언제 호출되는지}
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|{domain}}
tier: null
inherits: null
tools: [Read, Glob, Grep, Write, Edit]
model: sonnet
scope: "{glob-pattern}"
---

# {에이전트 이름} — {한줄 설명}

> {에이전트의 목적과 책임 설명}

## 역할 및 책임
...

## 실행 프로토콜

### 시작 프로토콜
```
STEP 1: Read .claude/agent-memory/{name}/MEMORY.md
STEP 2: {작업별 초기화}
```

### 종료 프로토콜
```
STEP 1: 결과 요약 출력
STEP 2: MEMORY.md 업데이트
STEP 3: av-base-auditor Level 1 Self-Check
```
```

### 4.2 av-base-auditor.md 최소 내용 템플릿

```markdown
---
name: av-base-auditor
description: |
  코드 품질·로직·메모리 검증 에이전트.
  모든 av- 에이전트 작업 완료 후 Level 1~3 감사 수행.
  트리거: 모든 av- 스킬/에이전트 종료 프로토콜 Step (Level에 따라)
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
tools: [Read, Glob, Grep, Write, Edit]
model: sonnet
scope: ".claude/**"
---

# av-base-auditor — 코드 품질·로직·메모리 검증

## 감사 레벨

| Level | 범위 | 트리거 |
|-------|------|--------|
| **Level 1** Self-Check | 자신의 출력물만 검토 | 모든 av- 에이전트 종료 시 |
| **Level 2** 표준 감사 | 변경 파일 전체 검토 | PL/PM 요청 시 |
| **Level 3** 종합 감사 | 전체 코드베이스 | 주기적 또는 릴리즈 전 |

## Level 1 Self-Check 체크리스트

- [ ] **체크 1**: 파일 포맷 — frontmatter autovibe:true + 필수 필드 존재
- [ ] **체크 2**: 네이밍 — av- 접두사 + kebab-case + 최대 4단어
- [ ] **체크 3**: 코드 품질 — {{기술 스택별 린트 규칙 — 커스터마이즈 필요}}
- [ ] **체크 4**: 메모리 — MEMORY.md 업데이트 여부 확인
- [ ] **체크 5**: 레지스트리 — components.json 등록 여부 확인

## 실행 프로토콜

### 시작 프로토콜
```
STEP 1: Read .claude/agent-memory/av-base-auditor/MEMORY.md
STEP 2: 요청 Level 확인 (1|2|3)
STEP 3: 해당 Level 체크리스트 실행
```

### 종료 프로토콜
```
STEP 1: 체크 결과 요약 출력 (PASS/FAIL 항목 수)
STEP 2: MEMORY.md 업데이트 (발견된 패턴)
STEP 3: Self-Check 면제 (자기 감사 방지)
```
```

### 4.3 MEMORY.md 초기 형식 (모든 에이전트 공통)

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

## 5. Skill 파일 형식 명세 (Phase 3~4)

### 5.1 Skill Frontmatter 공통 형식

```markdown
---
name: av-{skill-name}
description: |
  {스킬 역할 설명 — 1~3줄}
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: {base|vibe|{domain}}
tier: {meta|null}
inherits: null
argument-hint: "{서브커맨드 힌트}"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent]
---

# {스킬 이름} — {한줄 설명}

> {스킬 목적}

## 서브커맨드

| 커맨드 | 설명 |
|--------|------|
| `{cmd}` | {설명} |

## 실행 프로토콜

### 시작 프로토콜
```
STEP 1: Read .claude/skills/{name}/MEMORY.md
STEP 2: 인자 파싱 → 서브커맨드 분리
```

### 종료 프로토콜
```
STEP 1: 실행 결과 요약 출력
STEP 2: MEMORY.md 업데이트
STEP 3: av-base-auditor Level 1 또는 Level 2 감사 요청
```
```

### 5.2 av/SKILL.md ROUTING_TABLE 기본 형식

```markdown
---
name: av
description: |
  AutoVibe 마스터 게이트웨이. 자연어 요청 → 최적 컴포넌트 자동 선정 → 위임 실행.
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base
argument-hint: "run|find|optimize|health|stats [args]"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent, Skill]
---

# av — AutoVibe 마스터 게이트웨이

## ROUTING_TABLE (커스터마이즈 필수)

> 이 섹션은 프로젝트 도메인에 맞게 커스터마이즈해야 한다.
> Phase 6 도메인 확장 시 새 경로를 추가한다.

```
creation + any
  → Skill("av-vibe-forge", "skill {name}") 안내
  (전용 구현 스킬 없음 — /av-vibe-forge skill로 먼저 생성)

analysis + code/security/architecture
  → Task("av-base-auditor", "Level 2")

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

pm + any  【av-pm Team 모드】
  → Skill("av-pm", "start {feature}")
  → 팀 구성 → 병렬 구현

[fallback]
  → AskUserQuestion으로 선택지 제시

# Phase 6 이후 도메인 확장 예시:
# {domain} + backend/api/frontend
#   → Skill("av-do-orchestrator", "run {layer} {domain}")
#   또는 → Agent("av-{domain}-lead")
```
```

### 5.3 av-vibe-forge/SKILL.md 핵심 서브커맨드 형식

```markdown
---
name: av-vibe-forge
description: |
  AutoVibe 마스터 오케스트레이터. av- 생태계의 생성/조회/검증/관리를
  14개 서브커맨드로 제공. 생성 서브커맨드는 전용 forge에 위임.
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: vibe
tier: meta
argument-hint: "<subcommand> [args] [--options]"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task]
---

# av-vibe-forge — AutoVibe Master Orchestrator

## 서브커맨드 전체 (14종)

| # | 커맨드 | 설명 |
|---|--------|------|
| 1 | `skill [name]` | 스킬 생성 → av-vibe-skill-forge 위임 |
| 2 | `agent [name]` | 에이전트 생성 → av-vibe-agent-forge 위임 |
| 3 | `hook [type] [name]` | 훅 생성 → av-vibe-hook-forge 위임 |
| 4 | `rule [name]` | 룰 파일 생성 → av-vibe-rule-forge 위임 |
| 5 | `list [--group]` | 레지스트리 전체 또는 그룹별 목록 |
| 6 | `validate [name]` | 컴포넌트 검증 |
| 7 | `spec` | av-base-spec.md 표시 |
| 8 | `upgrade [name]` | 부모 변경 → 자식 전파 |
| 9 | `health` | 생태계 건강도 보고서 |
| 10 | `export [--portable]` | 컴포넌트 내보내기 |
| 11 | `import [path]` | 컴포넌트 가져오기 |
| 12 | `version [name]` | 버전 이력 조회 |
| 13 | `tree` | 상속 트리 시각화 |
| 14 | `audit-request` | 신규 컴포넌트 생성 요청 |

## 9. health 서브커맨드

```
1. components.json 로드 → 전체 컴포넌트 목록
2. 각 컴포넌트 파일 존재 확인 (Glob)
3. 상태 분류:
   - OK: 파일 존재 + frontmatter valid
   - MISSING: 파일 없음
   - UNREGISTERED: 파일 있으나 registry 없음
   - NO_MEMORY: MEMORY.md 없음
4. 100점 스코어: -5(UNREGISTERED) -10(MISSING) -3(NO_MEMORY)
5. 보고서 출력 + 권장 조치
```
```

---

## 6. Hook 파일 형식 명세 (Phase 5)

### 6.1 Hook 셸 스크립트 공통 헤더

```bash
#!/bin/bash
# name: av-{hook-name}
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: PreToolUse|PostToolUse|SessionStart
# trigger-tools: Write, Edit  (해당하는 경우)
# description: 훅 동작 설명

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_DIR="${CLAUDE_PROJECT_DIR}/.claude/logs"
mkdir -p "$LOG_DIR"
```

### 6.2 av-post-write-monitor.sh 최소 내용 템플릿

```bash
#!/bin/bash
# name: av-post-write-monitor
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: PostToolUse
# trigger-tools: Write, Edit
# description: Write/Edit 후 변경 파일 감지 및 로깅

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/write-monitor.log"
mkdir -p "$(dirname "$LOG_FILE")"

TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
FILE_PATH="${CLAUDE_TOOL_INPUT_FILE_PATH:-unknown}"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

echo "${TIMESTAMP} | ${TOOL_NAME} | ${FILE_PATH}" >> "$LOG_FILE"

# av- 생태계 파일 변경 감지
if [[ "$FILE_PATH" == *".claude/agents/"* || "$FILE_PATH" == *".claude/skills/"* ]]; then
  echo "[av-monitor] AutoVibe 컴포넌트 변경 감지: ${FILE_PATH}" >&2
fi

exit 0
```

### 6.3 av-session-discovery.sh 최소 내용 템플릿

```bash
#!/bin/bash
# name: av-session-discovery
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: SessionStart
# description: 세션 시작 시 av 생태계 컨텍스트 로드 및 상태 보고

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
REGISTRY="${CLAUDE_PROJECT_DIR}/.claude/registry/components.json"

if [ -f "$REGISTRY" ]; then
  AGENTS=$(jq -r '._meta.total.agents // 0' "$REGISTRY" 2>/dev/null || echo "0")
  SKILLS=$(jq -r '._meta.total.skills // 0' "$REGISTRY" 2>/dev/null || echo "0")
  HOOKS=$(jq -r '._meta.total.hooks // 0' "$REGISTRY" 2>/dev/null || echo "0")
  RULES=$(jq -r '._meta.total.rules // 0' "$REGISTRY" 2>/dev/null || echo "0")
  echo "[av-ecosystem] Agents:${AGENTS} Skills:${SKILLS} Hooks:${HOOKS} Rules:${RULES}"
else
  echo "[av-ecosystem] Registry 없음 — /av-vibe-portable-init setup 실행 권장"
fi

exit 0
```

### 6.4 av-bash-guard.sh 최소 내용 템플릿

```bash
#!/bin/bash
# name: av-bash-guard
# autovibe: true
# version: 1.0
# created: {{YYYY-MM-DD}}
# hook-type: PreToolUse
# trigger-tools: Bash
# description: 금지된 Bash 명령어 패턴 차단 (커스터마이즈 필요)

set -euo pipefail
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-}"

# 커스터마이즈: 프로젝트에 맞게 금지 패턴 추가/제거
BLOCKED_PATTERNS=(
  "rm -rf /"
  "sudo rm"
  "DROP TABLE"
  "DELETE FROM.*WHERE 1=1"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "[av-bash-guard] 금지된 명령어 패턴 감지: $pattern" >&2
    exit 2  # exit 2 = 차단 (Claude Code에 신호)
  fi
done

exit 0
```

---

## 7. CLAUDE.md AutoVibe 섹션 형식 (Phase 0)

CLAUDE.md에 다음 섹션을 추가한다:

```markdown
## AutoVibe 생태계

자기 성장 AI 개발 생태계. 상세: `.claude/registry/components.json`
스펙: `.claude/rules/av-base-spec.md`

### 핵심 스킬

| 스킬 | 역할 |
|------|------|
| `/av {자연어}` | 마스터 게이트웨이 — 자연어 → 최적 컴포넌트 자동 선정 + 실행 |
| `/av-vibe-forge` | 마스터 오케스트레이터 — skill/agent/hook/rule 생성·검증·관리 |
| `/av-pm start {feature}` | PM 인터페이스 — PRD 협의 → 팀 구성 |
| `/av-base-code-quality` | 코드 품질 게이트 |
| `/av-base-git-commit` | git 커밋 자동화 |
| `/av-base-sync` | CLAUDE.md 자동 최신화 |

### AutoVibe 컴포넌트

| 유형 | 수량 | 경로 |
|------|------|------|
| Agents | {{N}} | `.claude/agents/` |
| Skills | {{N}} | `.claude/skills/` |
| Hooks | {{N}} | `.claude/hooks/` |
| Rules | {{N}} | `.claude/rules/` |

### 메모리 계층

| 계층 | 경로 | 범위 |
|------|------|------|
| L1 에이전트 | `.claude/agent-memory/{name}/MEMORY.md` | 해당 에이전트 전용 |
| L2 스킬 | `.claude/skills/{name}/MEMORY.md` | 해당 스킬 전용 |
| L4 글로벌 | `~/.claude/projects/{slug}/memory/MEMORY.md` | 전체 공유 |

### PDCA 워크플로우

```
새 업무 → /av-pm start {feature} → PRD 협의 → 팀 구성 → 구현 → 검증 → Archive
```
```

---

## 8. settings.json 완전 형식 (Phase 5)

```json
{
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
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-session-discovery.sh"
          }
        ]
      },
      {
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
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-bash-guard.sh"
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
      "Bash(git diff*)"
    ]
  }
}
```

---

## 9. Frontmatter Spec 문서 형식 (Phase 0 — 필수 참조 문서)

이 파일은 `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`에 생성한다.

```markdown
# Frontmatter Spec — av- 컴포넌트 유형별 필수/선택 필드

## Agent (`.claude/agents/av-*.md`)

필수 필드: name, description, autovibe, version, created, group, tools, model, scope
선택 필드: tier, inherits, effort, isolation, background

## Skill (`.claude/skills/av-*/SKILL.md`)

필수 필드: name, description, autovibe, version, created, group, argument-hint, user-invocable, allowed-tools
선택 필드: tier, inherits, effort

## Hook (`.claude/hooks/av-*.sh`)

셸 스크립트 주석으로 메타데이터 기록:
# name, autovibe, version, created, hook-type, trigger-tools, description

## Rule (`.claude/rules/av-*.md`)

필수 필드: name, autovibe, version, created, group, paths (배열)
```

---

## 10. Phase별 Claude Code 실행 시나리오

### Phase 0 실행 시나리오

Claude Code가 실행해야 하는 작업:

```
1. AskUserQuestion: 프로젝트 정보 수집
   - 프로젝트 이름: {{PROJECT_NAME}}
   - 기술 스택: {{TECH_STACK}}
   - 소스 루트: {{SRC_ROOT}}
   - 도메인 그룹: {{DOMAIN_GROUPS}}

2. Bash: mkdir -p .claude/{skills,agents,rules,hooks,registry,agent-memory,docs/av-claude-code-spec/topics}

3. Write: .claude/registry/components.json (빈 레지스트리)

4. Write: .claude/docs/av-claude-code-spec/topics/frontmatter-spec.md

5. Edit CLAUDE.md: AutoVibe 섹션 추가
   (CLAUDE.md 없으면 Write로 신규 생성)
```

### Phase 1 실행 시나리오

```
1. Write: .claude/rules/av-base-spec.md (§3.2 템플릿 사용)
2. Write: .claude/rules/av-org-protocol.md (팀 규모·승인 프로세스 커스터마이즈)
3. Write: .claude/rules/av-base-memory-first.md (§3.3 템플릿 사용)
4. Write: .claude/rules/av-util-mermaid-std.md
5. Edit: .claude/registry/components.json → rules 섹션에 4개 추가
6. Edit: .claude/registry/components.json → _meta.total.rules = 4
```

### Phase 2 실행 시나리오

```
각 에이전트별 실행:
1. Write: .claude/agents/{agent-name}.md (§4.1 frontmatter 형식 사용)
2. Bash: mkdir -p .claude/agent-memory/{agent-name}
3. Write: .claude/agent-memory/{agent-name}/MEMORY.md (§4.3 초기 형식)
4. Edit: .claude/registry/components.json → agents 섹션에 추가

8개 에이전트 모두 반복:
  av-base-auditor, av-base-optimizer, av-base-template,
  av-base-git-committer, av-base-refactor-advisor, av-base-qa-reviewer,
  av-base-sync-auditor, av-vibe-vibecoder
```

### Phase 3 실행 시나리오

```
각 Forge 스킬별 실행:
1. Bash: mkdir -p .claude/skills/{skill-name}
2. Write: .claude/skills/{skill-name}/SKILL.md
3. Write: .claude/skills/{skill-name}/MEMORY.md
4. Edit: .claude/registry/components.json → skills 섹션에 추가

6개 스킬 순서:
  1. av-vibe-skill-forge  (스킬 생성 도구 — 먼저 생성)
  2. av-vibe-agent-forge  (에이전트 생성 도구)
  3. av-vibe-hook-forge   (훅 생성 도구)
  4. av-vibe-rule-forge   (룰 생성 도구)
  5. av-vibe-forge        (마스터 오케스트레이터)
  6. av-vibe-portable-init (이식 초기화)
```

### Phase 4 실행 시나리오

```
1. av/SKILL.md 생성 (ROUTING_TABLE 프로젝트 맞춤 커스터마이즈 — §5.2)
2. av-pm/SKILL.md 생성 (도메인 감지 규칙 커스터마이즈)
3. 나머지 8개 스킬 생성:
   av-base-code-quality, av-base-git-commit, av-base-sync,
   av-base-refactor, av-base-post-qa, av-ecosystem-optimizer,
   av-agent-chat, av-docs-guard
```

### Phase 5 실행 시나리오

```
1. Write: .claude/hooks/av-post-write-monitor.sh (§6.2 템플릿)
2. Write: .claude/hooks/av-session-discovery.sh (§6.3 템플릿)
3. Write: .claude/hooks/av-content-scanner.sh
4. Write: .claude/hooks/av-bash-guard.sh (§6.4 템플릿)
5. Write: .claude/hooks/av-base-precompact.sh
6. Bash: chmod +x .claude/hooks/*.sh
7. Write|Edit: .claude/settings.json (§8 형식 사용)
8. Edit: registry → hooks 섹션 5개 추가
```

### Phase 6 확장 시나리오 (반복)

```
사용자: "{{domain}} 도메인 에이전트가 필요해"

1. /av-pm start {{domain}}-agents
   → AskUserQuestion: 도메인 범위, 컴포넌트 수, 완료 기준
   → PRD 생성

2. /av-vibe-forge agent {{domain}}-lead --group {{domain}}
   → av-vibe-agent-forge가 AGENT.md + MEMORY.md 생성

3. /av-vibe-forge skill {{domain}}-impl --group {{domain}}
   → av-vibe-skill-forge가 SKILL.md 생성

4. Edit av/SKILL.md → ROUTING_TABLE에 {{domain}} 경로 추가:
   {{domain}} + backend/frontend/api
     → Agent("av-{{domain}}-lead")
     또는 → Skill("av-{{domain}}-impl")

5. /av-vibe-forge health → 건강도 확인
```

---

## 11. 완성 검증 체크리스트

Phase 0~5 완료 후 실행:

```bash
# 1. 디렉토리 구조 확인
ls .claude/{skills,agents,rules,hooks,registry,agent-memory}

# 2. 레지스트리 확인
cat .claude/registry/components.json | jq '._meta.total'

# 3. 훅 파일 권한 확인
ls -la .claude/hooks/*.sh

# 4. settings.json 훅 등록 확인
cat .claude/settings.json | jq '.hooks | keys'
```

Claude Code 검증:
```
/av-vibe-forge health
  → 기대: 90/100 이상

/av run 코드 품질 검사
  → 기대: av-base-code-quality 라우팅

/av-pm start test-feature
  → 기대: AskUserQuestion PRD 협의 시작
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
Phase 4를 시작해줘. 도메인은 {domain1}, {domain2}야.
Phase 5를 시작해줘. 금지 명령어는 {pattern}이야.
```

### 13.2 Phase별 AskUserQuestion 수집 항목

| Phase | 수집 항목 | 기본값 |
|-------|---------|--------|
| Phase 0 | 프로젝트 이름, 기술 스택, 도메인 그룹, 소스 루트 | src |
| Phase 1 | 팀 승인 프로세스 여부, 멀티테넌트 여부 | 단일 개발자, 단일 테넌트 |
| Phase 2 | 기술 스택 (코드 품질 도구 선택) | Phase 0 설정 재사용 |
| Phase 3 | 컴포넌트 그룹 체계, ROUTING_TABLE 전략 | base/vibe 기본 경로 |
| Phase 4 | 도메인 경로 추가 여부 | Phase 0 도메인 그룹 재사용 |
| Phase 5 | 금지 Bash 명령어 패턴, 세션 로드 컨텍스트 | rm -rf, DROP TABLE |
| Phase 6 | 도메인 범위, 에이전트 역할, 완료 기준 | Lead + Backend + Impl |

### 13.3 사용자 안내 원칙

1. **질문 최소화**: Phase별로 3개 이하의 핵심 질문만
2. **기본값 제공**: 모든 항목에 합리적인 기본값 (Enter로 수락 가능)
3. **문맥 재사용**: Phase 0 설정은 이후 모든 Phase에서 재사용
4. **에러 시 즉시 안내**: 문제 발생 시 구체적인 재시도 방법 제시

---

## 14. 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **PDCA Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`
- **Phase 진행 가이드**: `guides/phase-progression.md` (GO/NO-GO 기준, 롤백 방법)
- **네이밍 가이드**: `guides/naming-guide.md` (컴포넌트 이름 단일 진실 소스)
- **현재 av 생태계 샘플**:
  - Rules: `/data/all-saas/.claude/rules/av-*.md`
  - Agents: `/data/all-saas/.claude/agents/` (또는 CLAUDE.md agent 섹션)
  - Skills: `/data/all-saas/.claude/skills/av-*/SKILL.md`
  - Registry: `/data/all-saas/.claude/registry/components.json`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
- **bkit PDCA Skill**: bkit 플러그인 `/pdca` 명령어
