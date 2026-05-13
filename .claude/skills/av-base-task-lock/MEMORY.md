# av-base-task-lock Memory

> 생성: 2026-05-13 | 마지막 업데이트: 2026-05-13

## 라우팅 이력 (최근 5건)
(없음)

## 검증 이력

### 2026-05-13 — 두 세션 충돌 시뮬레이션 (10/10 통과)

세션 A `aaaaaaaa-…` ↔ 세션 B `bbbbbbbb-…` 토글로 시뮬레이션.

| # | 시나리오 | 검증 항목 | 결과 |
|--:|---|---|:-:|
| T1 | A: acquire feature:order-refund (TTL 300) | 새 락 획득 + UUID owner 기록 | ✓ |
| T2 | B: 같은 키 acquire | ok:false, conflict:true, current_owner=A, exit 10 | ✓ |
| T3 | B: 다른 키 feature:user-auth acquire | 병행 락 허용 | ✓ |
| T4 | list — 두 락 동시 점유 | A·B 둘 다 held:true | ✓ |
| T5 | A: 자기 락 heartbeat | note: "renewed (same session)" | ✓ |
| T6 | B: A 락 release 시도 | ok:false, error:"not owner" | ✓ |
| T7 | A: 자기 락 release | 정상 해제 | ✓ |
| T8 | B: 같은 키 acquire (인수) | 정상 인수 | ✓ |
| T9 | TTL 2초 만료 자동 인수 | expired:true → 새 세션 acquire 성공 | ✓ |
| T10 | release/prune cleanup | count:0 | ✓ |

### 핵심 동작 확인

- **충돌 격리** (T2): 같은 키는 한 세션만 보유
- **병행 허용** (T3·T4): 서로 다른 키는 동시 보유 가능
- **소유권 강제** (T6): 다른 세션은 release 불가 (`not owner`)
- **재진입 안전** (T5): 같은 세션 재호출은 `renewed`
- **TTL 만료 인수** (T9): 죽은/만료 락은 새 세션이 자동 인수 — 회복 메커니즘
- **정상 핸드오프** (T7→T8): release 후 다른 세션이 즉시 acquire 가능

## 학습된 패턴

### TTL 결정 가이드
- 단순 도메인 작업: 300초 (기본)
- PRD 작성·대화: 600초
- Sprint 단위 장기 작업: 1800초 (반드시 heartbeat 필요)

### 충돌 빈도 모니터
충돌이 잦은 키는 다음 중 하나로 분할:
1. 더 작은 단위 (feature → file/symbol)
2. 작업자(세션) 사전 합의

### exit code 파이프 보존
호출 측이 종료 코드(0=성공, 10=충돌, 1=오류)로 분기하려면 파이프 사용 금지:
```bash
# ✗ exit code가 jq로 덮어씌워짐
$LOCK acquire feature:X | jq '.ok'

# ✓ 변수로 받고 $? 검사 또는 set -o pipefail + ${PIPESTATUS[0]}
result=$($LOCK acquire feature:X); rc=$?
```
또는 JSON `ok`/`conflict` 필드 직접 분기 (SKILL.md 권장 패턴).

## 주의 사항

- 락은 **충돌 회피용 신호**일 뿐 — 강제 진행이 가능. 보안 격리 아님.
- `release` 의무: PM/PL의 종료 프로토콜에 포함되지 않으면 만료(TTL)까지 점유.
- 같은 세션이 같은 키를 acquire 하면 갱신(renewed)으로 처리 — 재진입 안전.
