---
name: av-base-task-lock
description: |
  멀티 세션 작업 락. /av pm team 등 여러 Claude Code 세션이 동일 작업을
  동시에 수행하는 충돌을 방지한다. flock 기반 atomic, TTL 5분, heartbeat 갱신,
  파일 기반 저장(.claude/state/locks/), 세션 식별자(.claude/state/session.id) 사용.
autovibe: true
version: "1.0"
created: "2026-05-13"
group: base
argument-hint: "{operation} [args] — acquire|release|status|list|heartbeat|prune"
user-invocable: true
allowed-tools: [Read, Glob, Grep, Bash]
---

# av-base-task-lock — 멀티 세션 작업 락 게이트웨이

> 여러 세션이 같은 feature/PRD/도메인을 동시에 작업하는 충돌을 방지한다.
> PM/PL이 작업 시작 전에 acquire, 종료 시 release.

## 사용 원칙

1. **단일 진입점**: 모든 av 컴포넌트는 본 스킬을 경유. 직접 파일 조작 금지.
2. **세션 식별**: `.claude/state/session.id` 가 없으면 SessionStart 훅이 자동 생성.
3. **TTL/heartbeat**: 기본 300초. 장기 작업은 5분마다 `heartbeat` 호출.
4. **만료 자동 인수**: 만료된 락은 새 세션이 자동 인수 (예: 죽은 세션의 락 회수).
5. **충돌 시**: PM/PL 에이전트가 `AskUserQuestion`으로 "대기/강제/취소" 선택지 제시.

## OPERATION 매트릭스

| Operation | 인자 | 종료 코드 | 용도 |
|-----------|------|----------|------|
| `acquire <key> [ttl]` | TTL=300s 기본 | 0=획득/갱신, 10=충돌 | 작업 시작 전 락 획득 |
| `release <key>` | — | 0=해제, 10=소유권 없음 | 작업 종료 시 |
| `status <key>` | — | 0 | 단일 락 상태 |
| `list` | — | 0 | 활성 락 전체 |
| `heartbeat <key>` | — | 0=갱신, 10=소유권 없음 | TTL 갱신 (장기 작업) |
| `prune` | — | 0 | 만료 락 일괄 정리 |

## 키 규칙

```
^[a-zA-Z0-9_:.-]+$
```

권장 네이밍:
- Feature: `feature:order-refund`, `feature:user-auth`
- Domain: `domain:payment`, `domain:order`
- Sprint: `sprint:m1`, `sprint:cc-v22`
- File-scope: `file:src/api/user.ts` (콜론 사용 금지 → `file_src_api_user`)

## 호출 패턴

### 패턴 1 — PM/PL 작업 시작
```
result = Skill("av-base-task-lock", "acquire feature:order-refund")
IF result.ok == false AND result.conflict:
  AskUserQuestion(
    "feature:order-refund 은 다른 세션이 작업 중입니다 (owner: {result.current_owner}, 만료: {result.current_expires_at}).",
    [대기, 강제 진행, 취소]
  )
ELSE:
  진행
```

### 패턴 2 — 장기 작업 heartbeat
```
WHILE 작업 중:
  매 4분마다: Skill("av-base-task-lock", "heartbeat feature:order-refund")
```

### 패턴 3 — 작업 종료 (의무)
```
TRY:
  작업 수행
FINALLY:
  Skill("av-base-task-lock", "release feature:order-refund")
```

### 패턴 4 — 세션 시작 시 정리
```
SessionStart 훅에서: Skill("av-base-task-lock", "prune")
```

## Bash 직접 호출

```bash
$CLAUDE_PROJECT_DIR/.claude/skills/av-base-task-lock/lock.sh acquire feature:order-refund 600
$CLAUDE_PROJECT_DIR/.claude/skills/av-base-task-lock/lock.sh status feature:order-refund
$CLAUDE_PROJECT_DIR/.claude/skills/av-base-task-lock/lock.sh release feature:order-refund
$CLAUDE_PROJECT_DIR/.claude/skills/av-base-task-lock/lock.sh list
```

출력은 모두 JSON. 호출 측이 `ok` / `conflict` / `held` 필드로 분기.

## 출력 스키마

```json
// acquire 성공
{ "ok": true, "op": "acquire", "key": "feature:order-refund",
  "owner": "sid-abc", "expires_at_epoch": 1747125600 }

// acquire 충돌
{ "ok": false, "op": "acquire", "key": "feature:order-refund",
  "conflict": true, "current_owner": "sid-xyz",
  "current_expires_at_epoch": 1747124900 }

// status
{ "ok": true, "op": "status", "key": "feature:order-refund",
  "held": true, "expired": false, "owner": "sid-abc",
  "expires_at_epoch": 1747125600, "ttl_seconds": 300, "acquired_at": "..." }
```

## 저장 위치 (gitignored)

```
.claude/state/locks/{key}.lock.json     # 락 본체
.claude/state/locks/{key}.lock.json.flock  # flock 보조 파일
.claude/state/session.id                # 현재 세션 UUID (SessionStart 훅 생성)
```

`.gitignore`에 `.claude/state/` 가 이미 등록되어 있어 커밋되지 않는다.

## 페일세이프

- jq 미설치 환경: 기본 acquire/release/status는 동작 (출력 형식 단순화)
- flock 미지원: Linux 표준 도구, WSL Ubuntu 24.04 포함됨
- 세션 ID 파일 누락: PID + hostname + epoch로 fallback

## 메모리 통합

본 스킬은 stateless. 락 정보는 파일에만 보관. 호출 측이 결과를 자기 MEMORY.md 에 저장하면 의사결정 이력 추적 가능.

## 관련 컴포넌트

- Rule: `.claude/rules/av-base-task-lock.md` — 정책
- Hook: `av-session-id-init.sh` (SessionStart) — session.id 생성
- Hook: `av-pm-team-lock-check.sh` (UserPromptSubmit) — `/av pm` 패턴 안내
- Agent: `av-pm-coordinator`, `av-do-orchestrator` — 본 스킬 경유 의무
