---
name: av-base-codegraph
description: |
  GitNexus 코드 그래프 게이트웨이 스킬. mcp__gitnexus__* MCP 도구를 캡슐화하여
  av- 에이전트가 일관된 인터페이스로 코드 그래프(임팩트·컨텍스트·라우트맵·이름변경)를 조회/활용한다.
  에이전트는 mcp__gitnexus__* 직접 호출 대신 본 스킬을 경유한다.
autovibe: true
version: "1.0"
created: "2026-05-13"
group: base
argument-hint: "{operation} [args] — query|cypher|context|impact|api-impact|route-map|tool-map|rename|shape-check|detect-changes|list-repos|sync"
user-invocable: true
allowed-tools: [Read, Glob, Grep, Bash]
---

# av-base-codegraph — GitNexus 코드 그래프 게이트웨이

> 모든 av 컴포넌트가 GitNexus(공유 코드 그래프 MCP)에 접근할 때 사용하는 단일 진입점.
> 직접 `mcp__gitnexus__*` 호출 금지 — 본 스킬 또는 명세된 wrapper만 사용.

## 사용 원칙

1. **단일 진입점**: 에이전트는 `Skill("av-base-codegraph", "{op} {args}")` 형식으로 호출
2. **MCP 가용성**: gitnexus MCP 미가용 시 graceful degradation — 빈 결과 반환 + 로그
3. **읽기 우선**: 본 스킬은 코드 그래프 조회 중심. 코드 수정은 호출 측 에이전트 책임
4. **캐시 친화**: 동일 쿼리 30분 이내 재호출은 호출 측이 메모리에 보관

## OPERATION 매트릭스

> 각 operation은 동명의 `mcp__gitnexus__*` 도구를 1:1 매핑한다. 인자는 도구 시그니처를 따른다.

| Operation | MCP 도구 | 용도 | 주 호출자 |
|-----------|---------|------|----------|
| `query {pattern}` | `mcp__gitnexus__query` | 자연어 → 코드 노드 검색 | memory-keeper, vibecoder |
| `cypher {cypher}` | `mcp__gitnexus__cypher` | Cypher 쿼리 직접 실행 | auditor (Level 3) |
| `context {symbol\|file}` | `mcp__gitnexus__context` | 심볼·파일 주변 컨텍스트 회수 | memory-keeper, refactor-advisor |
| `impact {file\|symbol}` | `mcp__gitnexus__impact` | 변경이 영향 주는 노드 집합 | auditor, refactor-advisor, PL |
| `api-impact {endpoint}` | `mcp__gitnexus__api_impact` | API 엔드포인트 변경 영향 | PL (av-do-orchestrator) |
| `route-map [scope]` | `mcp__gitnexus__route_map` | 라우트(엔드포인트) 토폴로지 | PL, doc-generator |
| `tool-map [scope]` | `mcp__gitnexus__tool_map` | 호출/의존 도구 맵 | vibecoder, doc-generator |
| `rename {old} {new}` | `mcp__gitnexus__rename` | 안전한 심볼 일괄 변경 | refactor-advisor |
| `shape-check {schema}` | `mcp__gitnexus__shape_check` | 스키마/타입 정합성 | auditor, sync-auditor |
| `detect-changes [since]` | `mcp__gitnexus__detect_changes` | 변경 노드 탐지 | sync-auditor |
| `list-repos` | `mcp__gitnexus__list_repos` | 인덱싱된 저장소 목록 | health checks |
| `sync [repo]` | `mcp__gitnexus__group_sync` | 그래프 재인덱싱 | 수동/주기 routine |

## 호출 패턴

### 패턴 1 — 임팩트 분석 (auditor / refactor-advisor)
```
1) targets = Skill("av-base-codegraph", "impact src/api/user.ts")
2) targets.nodes 순회 → 영향 범위 보고
3) auditor: 영향 범위가 high-risk(테스트 미커버) 면 게이트 차단
```

### 패턴 2 — 컨텍스트 회수 (memory-keeper)
```
1) ctx = Skill("av-base-codegraph", "context UserService.authenticate")
2) MEMORY.md 의사결정 항목에 ctx.snippet 첨부 (코드 변화 추적 가능)
```

### 패턴 3 — 안전 이름 변경 (refactor-advisor)
```
1) preview = Skill("av-base-codegraph", "rename oldFn newFn --dry-run")
2) 영향 파일 N개 보고 → 사용자 확인 → 실제 적용은 호출 측
```

### 패턴 4 — 아키텍처 맵 (doc-generator / vibecoder)
```
1) map = Skill("av-base-codegraph", "route-map src/api")
2) doc-generator: Mermaid 다이어그램 변환 → docs/architecture/
3) vibecoder: 누락 라우트 vs components.json 갭 분석
```

## MCP 가용성 검사

```bash
# 호출 측이 본 스킬 invoke 전 사전 확인 (선택)
claude mcp list 2>/dev/null | grep -q "gitnexus.*Connected" \
  && echo "available" || echo "fallback"
```

미가용 시 호출 측 처리:
- `auditor`: Level 2 정적 분석만 수행, impact 항목은 "MCP 미가용으로 생략" 표기
- `refactor-advisor`: 정량 지표만 사용, rename 자동화는 비활성
- `PL`: route_map 대신 수동 design.md 참조
- `memory-keeper`: context 대신 grep 기반 추출

## fallback (gitnexus 미가용)

| Operation | fallback 방법 |
|-----------|--------------|
| `query` / `cypher` | `Grep` + `Glob` 결합 |
| `context` | `Read` + 20줄 범위 |
| `impact` | `Grep -r "{symbol}"` |
| `route-map` | `Grep -r "router\\.|app\\.(get\\|post\\|put\\|delete)"` |
| `rename` | `Edit replace_all` (사용자 확인 필수) |
| `shape-check` | typecheck (tsc/mypy) 호출 |

## 출력 형식

모든 operation은 다음 구조로 결과를 반환한다(호출 측이 가공):

```json
{
  "operation": "impact",
  "ok": true,
  "source": "gitnexus" | "fallback",
  "result": { ... },
  "notes": ["..."]
}
```

## 메모리 통합

- 본 스킬은 stateless — 호출 측이 결과를 자신의 MEMORY.md 에 보관
- 단, `list-repos` 결과는 `.claude/skills/av-base-codegraph/MEMORY.md` 에 캐시 가능
