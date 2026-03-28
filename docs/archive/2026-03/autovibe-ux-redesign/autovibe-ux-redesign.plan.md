# Plan: autovibe-ux-redesign — AutoVibe 전체 재설계 (사용자 경험 중심)

> **에이전트**: CTO Team (cto-lead + enterprise-expert + frontend-architect + qa-strategist)
> **생성일**: 2026-03-28 | **상태**: DRAFT
> **담당**: CTO Lead → bkit PDCA

---

## Executive Summary

| 항목 | 값 |
|------|-----|
| **Feature** | autovibe-ux-redesign |
| **생성일** | 2026-03-28 |
| **규모** | Major Redesign (문서 5개 수정 + 신규 3개 생성) |
| **완료 기준** | 5개 개선 영역 완료 + Gap Analysis ≥ 90% |

### Value Delivered

| 관점 | 내용 |
|------|------|
| **Problem** | AutoVibe 문서가 처음 사용자 입장에서 진입 장벽이 높고, 문서 경로 불일치·네이밍 모호성·Phase 기준 불명확으로 실제 사용이 어려움 |
| **Solution** | CTO 팀 관점의 전체 재설계 — 온보딩, 경로 정합성, 스킬 UX, Phase 명확성, 네이밍 가이드 5개 영역 동시 개선 |
| **Function UX Effect** | 처음 사용자가 README만 읽고도 30분 내 Phase 0을 완료할 수 있도록 진입 장벽 제거 + 모든 스킬 명령어가 일관된 UX 패턴을 따름 |
| **Core Value** | AutoVibe 생태계의 사용성(Usability)과 발견가능성(Discoverability) 향상 — "대화로 만드는" 경험이 문서에서부터 느껴지도록 |

---

## Context Anchor

| 항목 | 내용 |
|------|------|
| **WHY** | 사용자가 처음 AutoVibe를 접했을 때 "어디서 시작해야 하는지" 모르는 문제 해결 |
| **WHO** | 신규 프로젝트를 시작하는 개발자 (bkit 경험 있음, AutoVibe 처음) |
| **RISK** | 재설계 범위가 너무 넓어 핵심 개선 없이 문서만 늘어날 위험 → Module 단위 완료 기준으로 관리 |
| **SUCCESS** | 신규 사용자 30분 내 Phase 0 완료 가능 + 모든 경로 참조 일치 + 네이밍 가이드 제공 |
| **SCOPE** | 기존 문서 5개 수정 + 신규 가이드 3개 생성 (구현 코드 없음) |

---

## 1. 현재 상태 분석 (As-Is)

### 1.1 현재 디렉토리 구조

```
autovibe/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── docs/
│   ├── prd/
│   │   └── av-ecosystem-pdca-driven.prd.md
│   ├── plan/
│   │   └── av-ecosystem-pdca-driven-2026-03-28.md
│   └── design/
│       └── av-ecosystem-design-spec.md
└── guides/
    ├── getting-started.md
    ├── bkit-integration.md
    └── cc-official-docs.md
```

### 1.2 발견된 문제점 (5개 영역)

#### 영역 1: 문서 경로 불일치 (Critical)

| 문서 | 내부 참조 경로 | 실제 경로 |
|------|--------------|---------|
| PRD | `docs/00-pm/00.20-prd/` | `docs/prd/` |
| Plan | `docs/pdca/active/` | `docs/plan/` |
| Design Spec | `docs/80-reference/80.02-internal/` | `docs/design/` |
| `.bkit/state/memory.json` | level: "Starter" | pdca-status: "Dynamic" |

#### 영역 2: 온보딩 경험 미흡 (High)

- README 빠른 시작이 `cp -r` 명령어 위주 → 대화 우선 원칙과 모순
- `getting-started.md`의 Phase별 설명이 있지만 실제 대화 시나리오가 단편적
- "30분 이내 Phase 0 완료"를 보장하는 퀵스타트 가이드 없음
- bkit 미설치 사용자를 위한 안내 흐름 불명확

#### 영역 3: 네이밍 가이드 부재 (High)

- `av-{도메인}-{이름}` 규칙이 README 한 곳에만 단편적으로 기술
- 스킬/에이전트/훅/룰 각각의 구체적 네이밍 패턴 없음
- 초기 생성 컴포넌트(Phase 0~5)의 이름이 PRD, Plan, Design Spec에서 미묘하게 다름
  - 예: PRD에서는 `av-base-code-quality`, Design Spec에서는 동일하나 Plan에서 누락
- Phase 6 도메인 확장 시 명명 규칙 예시 부족

#### 영역 4: Phase 진행 명확성 부족 (Medium)

- 각 Phase의 GO/NO-GO 판단 기준이 체크리스트만 존재
- Phase 실패 시 롤백 절차 없음
- Phase 간 의존성 명시 미흡 (Phase 2가 Phase 1 완료를 전제로 하지만 명시 없음)
- `/pdca status`로 현재 Phase 확인 후 재개하는 방법 불명확

#### 영역 5: 스킬 UX 불일치 (Medium)

- 각 Phase에서 Claude에게 전달하는 프롬프트 형식이 비표준
- `guides/getting-started.md`의 "Claude에게 말하기" 예시가 Phase마다 다른 형식
- AskUserQuestion 질문 목록이 Phase마다 다른 형식으로 기술됨
- 에러 발생 시 사용자 안내 미흡

---

## 2. 목표 상태 (To-Be)

### 2.1 개선된 디렉토리 구조

```
autovibe/
├── README.md                           ← 개선: 대화 우선 + 30분 퀵스타트 링크
├── CONTRIBUTING.md                     ← 유지
├── LICENSE                             ← 유지
├── docs/
│   ├── 01-plan/
│   │   └── features/
│   │       └── autovibe-ux-redesign.plan.md   ← 이 파일 (신규)
│   ├── prd/
│   │   └── av-ecosystem-pdca-driven.prd.md    ← 경로 참조 수정
│   ├── plan/
│   │   └── av-ecosystem-pdca-driven-*.md      ← 경로 참조 수정
│   └── design/
│       └── av-ecosystem-design-spec.md        ← 경로 참조 수정 + Phase 명확성 강화
└── guides/
    ├── getting-started.md              ← 개선: 온보딩 재작성
    ├── quick-start-30min.md            ← 신규: 30분 퀵스타트
    ├── naming-guide.md                 ← 신규: 네이밍 완전 가이드
    ├── phase-progression.md            ← 신규: Phase 진행/롤백/의존성 가이드
    ├── bkit-integration.md             ← 경미한 수정
    └── cc-official-docs.md             ← 유지
```

### 2.2 핵심 개선 원칙

1. **경로 실상 일치**: 모든 문서 내 참조 경로가 실제 파일 경로와 일치
2. **대화 우선**: 모든 시작 가이드가 CLI 명령어보다 Claude 대화를 먼저 제시
3. **30분 기준**: 처음 사용자가 README → Phase 0 완료까지 30분 내 가능
4. **네이밍 일관성**: 컴포넌트 이름이 PRD/Plan/Design/Guide 전체에서 동일
5. **GO/NO-GO 명시**: 각 Phase마다 명확한 진행/중단 기준 제시

---

## 3. 개선 모듈 (5개)

### Module 1: 문서 경로 정합성 수정

**우선순위**: P1 (Critical)

**대상 파일**: PRD, Plan, Design Spec (3개 수정)

| 현재 잘못된 참조 | 수정할 실제 경로 |
|----------------|---------------|
| `docs/00-pm/00.20-prd/av-ecosystem-pdca-driven.prd.md` | `docs/prd/av-ecosystem-pdca-driven.prd.md` |
| `docs/pdca/active/av-ecosystem-pdca-driven-*.md` | `docs/plan/av-ecosystem-pdca-driven-*.md` |
| `docs/80-reference/80.02-internal/av-ecosystem-design-spec.md` | `docs/design/av-ecosystem-design-spec.md` |

추가: `.bkit/state/memory.json` level 값 "Dynamic"으로 수정

**완료 기준:**
- [ ] 3개 문서 내 모든 경로 참조 실제 경로와 일치
- [ ] memory.json level 일치

---

### Module 2: 네이밍 가이드 생성

**우선순위**: P1 (신규)

**신규 파일**: `guides/naming-guide.md`

구성:
1. AutoVibe 네이밍 철학 (av- 접두사 의미)
2. 도메인 구조 (base / vibe / util / {project})
3. 컴포넌트 타입별 네이밍 패턴 (Skill / Agent / Rule / Hook)
4. 초기 컴포넌트 확정 테이블 (Phase 0~5, 33개 — 단일 진실 소스)
5. Phase 6 도메인 확장 패턴
6. 좋은 예 / 나쁜 예

**완료 기준:**
- [ ] `guides/naming-guide.md` 생성
- [ ] Phase 0~5 전체 컴포넌트 33개 이름 테이블 포함
- [ ] PRD/Plan/Design 간 이름 100% 일치 확인

---

### Module 3: 온보딩 경험 개선

**우선순위**: P2 (Module 1 완료 후)

**수정**: `README.md`, `guides/getting-started.md`
**신규**: `guides/quick-start-30min.md`

README 변경:
- Before: `cp -r` 명령어 위주 3단계
- After: "Claude에게 말하기" 1단계 → 대화로 진행

**완료 기준:**
- [ ] README 빠른 시작 대화 우선 방식으로 재작성
- [ ] `quick-start-30min.md` 생성 (분 단위 타임라인)
- [ ] `getting-started.md` Phase별 프롬프트 형식 통일

---

### Module 4: Phase 진행 명확성 강화

**우선순위**: P2

**수정**: `docs/design/av-ecosystem-design-spec.md`
**신규**: `guides/phase-progression.md`

각 Phase별 포함 내용:
- 사전 조건 / 성공 기준(GO) / 실패 기준(NO-GO) / 롤백 방법 / 예상 시간

**완료 기준:**
- [ ] `guides/phase-progression.md` 생성
- [ ] Phase 0~6 각각 GO/NO-GO 기준 명시
- [ ] 롤백 절차 포함

---

### Module 5: 스킬 UX 표준화

**우선순위**: P3

**수정**: `docs/design/av-ecosystem-design-spec.md`, `guides/getting-started.md`

표준 프롬프트 형식:
```
모든 Phase: "Phase {N}을 시작해줘"
(Claude가 AskUserQuestion으로 필요 정보 수집)
```

**완료 기준:**
- [ ] Phase별 Claude 프롬프트 형식 통일
- [ ] AskUserQuestion 흐름 일관성 확보
- [ ] 에러 처리 시나리오 5개 이상 추가

---

## 4. CTO 팀 구성

| 역할 | 에이전트 | 담당 Module |
|------|---------|-----------|
| **CTO Lead** | cto-lead (opus) | 조율 + Module 1 |
| **Enterprise Expert** | enterprise-expert | Module 2 네이밍 가이드 |
| **Frontend Architect** | frontend-architect | Module 3 온보딩 UX |
| **QA Strategist** | qa-strategist | Module 4, 5 검증 |

```
팀 시작: /pdca team autovibe-ux-redesign
환경 필요: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

---

## 5. 성공 기준

| Gate | 기준 |
|------|------|
| G1: 경로 검증 | 전체 참조 경로 오류 0개 |
| G2: 네이밍 일관성 | 컴포넌트 이름 PRD/Plan/Design/Guide 간 100% 일치 |
| G3: 온보딩 검증 | 30분 퀵스타트 시나리오 완료 가능 |
| G4: Phase 명확성 | Phase 0~6 GO/NO-GO 기준 전부 명시 |
| G5: Gap Analysis | ≥ 90% Match Rate |

---

## 6. 실행 계획

| 단계 | Module | 실행 방식 |
|------|--------|---------|
| Phase 1 (병렬) | Module 1 + Module 2 | CTO Lead + Enterprise Expert |
| Phase 2 | Module 3 | Frontend Architect |
| Phase 3 (병렬) | Module 4 + Module 5 | QA Strategist |
| Phase 4 | Gap Analysis + Report | 전체 팀 |

---

## 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **기존 Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`
- **Design Spec**: `docs/design/av-ecosystem-design-spec.md`
- **Getting Started**: `guides/getting-started.md`
- **이 Plan**: `docs/01-plan/features/autovibe-ux-redesign.plan.md`
