---
name: av-base-iterate
description: |
  bkit:pdca-iterator 표면화 — Evaluator-Optimizer 자동 개선 루프.
  Match Rate 측정 후 목표치 미달 시 자동으로 개선-재측정 반복.
  PL 검증 게이트 미달 또는 QA 실패 후 자동 개선에 사용.
autovibe: true
version: "1.0"
created: "2026-04-27"
group: base
argument-hint: "{feature} [--max=N] [--target=0.9]"
user-invocable: true
allowed-tools: [Read, Agent]
---

# av-base-iterate — Evaluator-Optimizer 자동 PDCA 반복

> bkit:pdca-iterator를 직접 호출하는 av 게이트웨이 스킬.
> Match Rate ≥ 90% 달성까지 최대 N회 자동 반복.

## 실행 시퀀스

1. **현재 상태 측정**
   ```
   Agent("bkit:gap-detector", { feature: "$1" })
   → match_rate 값 추출
   ```

2. **목표 달성 여부 판단**
   - `match_rate >= target(0.90)` → "이미 목표 달성" 메시지 출력 후 종료
   - `match_rate < target` → Step 3 진행

3. **자동 개선 루프 실행**
   ```
   Agent("bkit:pdca-iterator", {
     feature: "$1",
     target_match_rate: ${target:-0.90},
     max_iterations: ${max:-3}
   })
   ```

4. **최종 결과 리포트**
   ```
   이전 Match Rate: {초기값}%
   최종 Match Rate: {최종값}%
   반복 횟수: {N}회
   상태: {목표 달성 | 최대 반복 도달}
   ```

## 사용 예시

```bash
# 기본 사용 (목표 90%, 최대 3회)
/av-base-iterate user-auth

# 커스텀 목표/반복
/av-base-iterate payment-api --target=0.95 --max=2

# PL 검증 후 자동 호출 (av-do-orchestrator 내부)
Agent("av-base-iterate", { feature: "{feature}" })
```

## 자동 트리거 조건

| 조건 | 트리거 | 최대 반복 |
|------|--------|---------|
| PL 검증 게이트 < 90% | av-do-orchestrator | 2회 |
| QA 실패 | av-base-post-qa | 1회 |
| 수동 호출 | 사용자 | 3회 (기본) |
