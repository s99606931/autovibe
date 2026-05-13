# av-base-task-lock — 멀티 세션 작업 락 정책

> 여러 Claude Code 세션이 같은 feature/PRD를 동시에 진행하는 충돌을 방지한다.
> 본 규칙은 정책. 구현·동작은 `Skill("av-base-task-lock", ...)` 게이트웨이.

## 1. 락 대상

다음 작업은 시작 전 반드시 락을 획득한다:

| 대상 | 키 권장 형태 | 트리거 |
|------|------------|--------|
| Feature/PRD | `feature:{slug}` | PM이 PRD 확정 직후 |
| Domain 단위 변경 | `domain:{name}` | PL이 도메인 에이전트 스폰 직전 |
| Sprint 작업 | `sprint:{id}` | sprint-master-planner 시작 시 |
| 대규모 리팩토링 | `refactor:{scope}` | refactor-advisor 실행 직전 |
| 인덱싱·동기화 | `op:gitnexus-sync`, `op:bkit-pdca-report` | 멀티-세션 충돌 우려 작업 |

**락 대상 아님** (단순 조회·읽기 작업):
- 코드 그래프 query/context/route-map
- 가이드 읽기, 메모리 조회
- gstack screenshot/check-errors

## 2. 키 네이밍

```
^[a-zA-Z0-9_:.-]+$
```

- 콜론(`:`)으로 네임스페이스 구분: `feature:`, `domain:`, `sprint:`, `op:`, `refactor:`
- 키워드는 kebab-case
- 파일 경로는 슬래시 대신 언더스코어: `file_src_api_user`

## 3. 충돌 시 동작 (PM/PL 에이전트 의무)

```
result = Skill("av-base-task-lock", "acquire feature:{key}")

IF result.ok AND NOT result.conflict:
  → 진행
ELSE IF result.conflict:
  → AskUserQuestion(
      question="{key}는 다른 세션이 작업 중입니다.\nowner: {current_owner}\n만료: {current_expires_at}",
      options=[
        "대기 — 다른 세션 완료 후 자동 재시도",
        "강제 진행 — 락 무시 (병행 작업 위험 수용)",
        "취소 — 작업 중단"
      ]
    )
  IF 대기:
    sleep 30s → 재시도 (최대 5회)
  IF 강제 진행:
    Skill("av-base-task-lock", "acquire {key}") 후 기존 락 덮어쓰기는 금지.
    별도 키(예: feature:{key}#forced-{sid})로 새 락 획득하고 진행.
  IF 취소:
    사용자에게 결과 보고 후 종료.
```

## 4. TTL · heartbeat

| 작업 유형 | 권장 TTL | heartbeat 간격 |
|---------|---------|---------------|
| 단순 도메인 작업 | 300초 (기본) | 불필요 |
| PRD 작성·PM 대화 | 600초 | 5분 |
| Agent Team 구현 | 1800초 | 5분 |
| Sprint 작업 | 3600초 | 5분 |

PM/PL은 장기 작업 시 매 4분(TTL의 80%)마다 `heartbeat` 호출 의무.

## 5. release 의무

```
TRY:
  Skill("av-base-task-lock", "acquire ...")
  작업 수행
FINALLY:
  Skill("av-base-task-lock", "release ...")
```

다음 시점에 반드시 release:
- 작업 정상 완료 (PM Report 직후)
- 작업 실패/중단 (Error/Cancel)
- Agent Team 해제 (`TeamDelete` 직전)
- SessionEnd 훅(미구현 시 만료에 의존)

## 6. 만료 자동 인수

- TTL 만료된 락은 새 세션이 자동 인수 가능 (죽은 세션 회수)
- `prune` 명령으로 일괄 정리: `Skill("av-base-task-lock", "prune")`
- SessionStart 훅이 자동 실행 권장

## 7. 보안 한계

- 본 락은 **충돌 회피 신호**이지 보안 격리가 아님
- 사용자가 강제 진행을 선택하면 우회 가능
- 멀티 머신 공유 락은 미지원 (로컬 파일 시스템 전용)
- 외부 서비스 분산 락(Redis 등)이 필요하면 별도 컴포넌트로 확장

## 8. 라우팅 통합

`av-base-plugin-routing.md`에 다음 라우팅 추가:

```
prevent + conflict/lock/락/충돌
  → Skill("av-base-task-lock", "acquire {key}")

list + active-task/locks/잠금/락목록
  → Skill("av-base-task-lock", "list")
```

## 9. 관련 컴포넌트

- Skill: `.claude/skills/av-base-task-lock/SKILL.md` — 게이트웨이
- Hook: `av-session-id-init.sh` — SessionStart에서 session.id 생성
- Hook: `av-pm-team-lock-check.sh` — UserPromptSubmit에서 `/av pm` 안내
- Agent: `av-pm-coordinator`, `av-do-orchestrator` — 본 규칙 준수 의무
