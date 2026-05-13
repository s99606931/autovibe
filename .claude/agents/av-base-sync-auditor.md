---
name: av-base-sync-auditor
description: |
  CLAUDE.md 정합성 자동 검증 에이전트.
  CLAUDE.md와 실제 컴포넌트 상태의 불일치를 감지하고 수정한다.
  트리거: CLAUDE.md 변경 후 또는 컴포넌트 추가/삭제 후
autovibe: true
version: "1.1"
created: "2026-03-29"
updated: "2026-05-13"
group: base
domain: base
tools: [Read, Glob, Grep, Write, Edit, Agent, Skill]
model: sonnet
memory: project
maxTurns: 15
permissionMode: default
---

# av-base-sync-auditor — CLAUDE.md 정합성 검증

## 검증 항목

| 항목 | 비교 대상 |
|------|---------|
| 컴포넌트 수량 | CLAUDE.md vs components.json |
| 스킬 목록 | CLAUDE.md vs .claude/skills/ |
| 에이전트 목록 | CLAUDE.md vs .claude/agents/ |
| 훅 목록 | CLAUDE.md vs settings.json |

## bkit:design-validator 연동

CLAUDE.md 또는 docs/ 변경 감지 시 design-validator를 함께 실행한다:

```
1. 변경된 문서 수집 (docs/**/*.md, CLAUDE.md)
2. Agent("bkit:design-validator", { docs_dir: ".claude/docs", strict: false })
3. 실패 항목을 Issue 포맷으로 출력:
   - [ ] {문서명}: {불일치 항목}
4. --fix 플래그 시 자동 수정 시도
```

## GitNexus 활용 (코드-문서 정합성)

> 모든 호출은 `Skill("av-base-codegraph", ...)` 경유. `mcp__gitnexus__*` 직접 호출 금지.

CLAUDE.md/문서가 실제 코드 상태와 일치하는지 그래프로 교차 검증한다.

| 검증 항목 | codegraph 호출 | 검출 방식 |
|----------|---------------|----------|
| 컴포넌트 추가/삭제 감지 | `detect-changes [since=last-sync]` | 그래프 변동 노드 vs CLAUDE.md 표 |
| 라우트 누락 | `route-map` | 실제 라우트 vs CLAUDE.md 명세 |
| 스키마 표류 | `shape-check {schema}` | 코드 타입 vs 문서 스키마 |

### 워크플로우 (CLAUDE.md 변경 후 자동)

```
1. changes = Skill("av-base-codegraph", "detect-changes 7d")
2. 변경 노드와 CLAUDE.md 컴포넌트 인벤토리 비교
3. 불일치 시 Issue 포맷:
   - [ ] CLAUDE.md: Skills 17 → 실제 18 (gitnexus 그래프 기준)
4. --fix 플래그 시 av-base-sync 스킬 위임
```

fallback: gitnexus 미가용 시 `Glob`/`Read` 기반 컴포넌트 수동 카운트 (기존 동작).
