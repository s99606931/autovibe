---
name: av-base-plugin-routing
autovibe: true
version: "1.0"
created: "2026-03-29"
group: base
---

# av-base-plugin-routing — 생태계 3축 플러그인 라우팅 규칙

> AutoVibe 생태계의 3축(Claude Code + gstack + bkit)이 상호 보완하여 AI 개발 생명주기를 완성한다.
> 에이전트/스킬이 각 플러그인을 호출하는 라우팅 규칙을 정의한다.

## 생태계 3축 정의

| 축 | 정체성 | 핵심 역할 | PDCA 매핑 |
|----|--------|----------|----------|
| **Claude Code** | Anthropic AI 런타임 엔진 | Agent Teams 실행, 코드 생성, Hook 이벤트, 메모리 | 전 단계 (실행 기반) |
| **gstack** | Fast Headless Browser | 페이지 탐색, E2E 테스트, 스크린샷, 인터랙션, 벤치마크 | Do·Check (시각적 검증) |
| **bkit** | Vibecoding Kit 플러그인 | PDCA 문서, Gap 분석, 코드 분석, QA 모니터링, 자동 개선 | Plan·Check·Act (품질 보증) |

### 3축 상호 보완 원칙

1. **Claude Code가 생각하고 만든다** — AI 추론 + 코드 생성
2. **gstack이 보고 확인한다** — 브라우저 렌더링 + E2E 테스트
3. **bkit이 측정하고 개선한다** — Match Rate + 자동 반복
4. **av가 3축을 `/av {자연어}` 하나로 통합한다** — 사용자는 플러그인을 몰라도 됨

## gstack (시각적 검증) — 7단계 생명주기

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

## bkit (품질 보증) — 전 PDCA 주기

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

## Claude Code (AI 런타임) — av 실행 기반

| 요청 의도 | Claude Code 기능 | 담당 |
|-----------|-----------------|------|
| 에이전트 실행 | `Agent("av-pm-coordinator", ...)` | av 게이트웨이 |
| Team 스폰 | Agent Teams API | PL |
| 코드 생성 | Read, Write, Edit, Bash | Agent Team |
| 이벤트 처리 | Hook (PostToolUse, SessionStart, SubagentStop) | 자동 |
| 영구 학습 | `memory: project` → `.claude/agent-memory/` | 에이전트 자동 |

## 라우팅 원칙

1. 에이전트는 `av-base-plugin-routing` 규칙에 따라 3축 플러그인을 직접 호출한다
2. 사용자는 `/av {자연어}` 하나만 입력 — av ROUTING_TABLE이 최적 플러그인 선택
3. PM/PL/Agent가 각자 역할에 따라 Claude Code/gstack/bkit을 호출
4. 플러그인 세부 명령어는 av 컴포넌트 내부에 캡슐화 (사용자 노출 최소화)
5. 3축 중 하나라도 빠지면 해당 PDCA 단계의 자동화 품질이 저하된다
