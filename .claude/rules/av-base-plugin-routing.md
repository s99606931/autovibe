---
name: av-base-plugin-routing
autovibe: true
version: "1.0"
created: "2026-03-29"
group: base
---

# av-base-plugin-routing — gstack/bkit 플러그인 라우팅 규칙

> av 생태계 에이전트/스킬이 gstack과 bkit 플러그인을 호출하는 규칙.

## gstack (실행·테스트·배포) — 7단계 생명주기

| 단계 | 요청 의도 | gstack 호출 | 담당 |
|------|-----------|------------|------|
| Think | 레퍼런스 탐색 | `Skill("gstack", "navigate {url}")` | PM |
| Plan | UI 레퍼런스 수집 | `Skill("gstack", "screenshot {ref}")` | PL |
| Build | 실시간 구현 확인 | `Skill("gstack", "navigate localhost:{port}")` | Agent Team |
| Review | 시각적 회귀 탐지 | `Skill("gstack", "screenshot {pages}")` | PL |
| Test | 브라우저 E2E | `Skill("gstack", "check-errors {url}")` | QA Agent |
| Test | 인터랙션 테스트 | `Skill("gstack", "interact {selector}")` | QA Agent |
| Ship | 카나리 배포 모니터링 | `Skill("canary", ...)` | PL |
| Reflect | 성능 기준선 비교 | `Skill("benchmark", ...)` | Memory Keeper |

## bkit (문서 작성) — 전 PDCA 주기

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

## 라우팅 원칙

1. 에이전트는 `av-base-plugin-routing` 규칙에 따라 플러그인을 직접 호출한다
2. 사용자는 `/av {자연어}` 하나만 입력 — av ROUTING_TABLE이 최적 플러그인 선택
3. PM/PL/Agent가 각자 역할에 따라 gstack/bkit을 호출
4. 플러그인 세부 명령어는 av 컴포넌트 내부에 캡슐화 (사용자 노출 최소화)
