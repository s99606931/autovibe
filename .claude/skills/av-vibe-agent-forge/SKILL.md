---
name: av-vibe-agent-forge
description: |
  AGENT.md 생성 전담. 공식 frontmatter 필드(memory, maxTurns, permissionMode 등)를
  포함한 표준 에이전트 파일을 생성하고 레지스트리에 등록한다.
autovibe: true
version: "1.1"
created: "2026-03-29"
updated: "2026-05-13"
group: vibe
tier: meta
argument-hint: "[name] [--group group] [--model model]"
user-invocable: false
allowed-tools: [Read, Write, Edit, Glob, Grep, AskUserQuestion]
---

# av-vibe-agent-forge — 에이전트 생성 전담

## 생성 프로토콜

1. AskUserQuestion: 에이전트 이름, 역할, 모델, 그룹
2. `.claude/agents/{name}.md` 생성 (공식 frontmatter 완전 형식)
3. `memory: project` 설정 → `.claude/agent-memory/{name}/` 자동 관리
4. components.json agents 섹션에 등록 (permissionMode 포함)
5. `_meta.total.agents` 증가

## 표준 frontmatter 체크리스트 (CC v2.2+)

| 필드 | 필수? | 기본값 | 비고 |
|------|------|--------|------|
| `name` | ✅ | — | kebab-case, `av-{domain}-{name}` 패턴 |
| `description` | ✅ | — | 1-3줄 요약, 트리거 조건 명시 |
| `model` | 권장 | `sonnet` | `opus`는 PM/PL에만 |
| `memory` | 권장 | `project` | L1 자동 (`.claude/agent-memory/{name}/`) |
| `maxTurns` | 권장 | `20` | 작업 복잡도에 따라 조정 |
| `permissionMode` | **권장** | `default` | `plan` / `default` / `auto` — 누락 시 보정 필수 |
| `tools` | 권장 | — | 명시 권장 (Read/Write/Edit/Bash/Agent/Skill) |
| `disallowedTools` | 선택 | — | 명시적 차단 (예: memory-keeper는 Bash 차단) |
| `isolation` | 선택 | — | `worktree` 옵션 (파일 충돌 우려 시) |
| `background` | 선택 | — | `run_in_background` 기본화 |
| `autovibe` | ✅ | `true` | av 식별자 |
| `version` | ✅ | `"1.0"` | Major.Minor 문자열 |
| `created` | ✅ | YYYY-MM-DD | 생성일 |
| `updated` | 선택 | YYYY-MM-DD | 변경 시 갱신 |
| `group` | ✅ | `base` | base/vibe/util/{project} |
| `domain` | ✅ | `base` | group과 보통 동일 |

### 검증 규칙

- 신규 에이전트는 `permissionMode` 누락 시 forge가 자동으로 `default` 부여
- registry 등록 항목은 frontmatter와 1:1 동기화 (model/memory/maxTurns/permissionMode)
- 신규 에이전트가 `memory: project`이면 `.claude/agent-memory/{name}/MEMORY.md` 부트스트랩 자동 생성

## 필수 포함 공식 필드 (요약)

- `name`, `description` (필수)
- `tools`, `model`, `memory: project`, `maxTurns`, `permissionMode` (권장)
- `autovibe: true`, `version`, `created`, `group` (av 필수)
- 선택: `disallowedTools`, `effort`, `isolation`, `background`
