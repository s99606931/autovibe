# PRD: av-ecosystem-pdca-driven — bkit PDCA 기반 av 생태계 점진적 구축

> **PM**: av-pm-coordinator | **요청자**: CEO | **생성일**: 2026-03-28 | **개정**: 2026-03-29
> **상태**: CONFIRMED
> **연관 문서**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md` | `docs/design/av-ecosystem-design-spec.md`

---

## Executive Summary

| 항목 | 값 |
|------|-----|
| **Feature** | av-ecosystem-pdca-driven |
| **목표** | 사용자가 자연어로 요청하면 av 생태계가 최적의 에이전트 팀을 조직하여 PM/PL 승인 기반으로 최고 품질의 결과를 보장 |
| **규모** | Major (7 Phase, 60+ 컴포넌트 생성) |
| **완료 기준** | `/av-vibe-forge health` PASS + `/av run {task}` 정상 라우팅 + PM↔PL 조직 워크플로우 동작 |

### Value Delivered

| 관점 | 내용 |
|------|------|
| **Problem** | 복잡한 플러그인(gstack, bkit) 사용법을 모르는 사용자가 직접 명령어를 익히지 않고도 AI 에이전트 팀을 통해 프로젝트를 진행하고 싶다 |
| **Solution** | av 생태계가 자연어를 받아 PM이 요구사항을 대화로 도출하고, PL이 학습된 프로젝트 지식 기반으로 Plan/Design을 작성, Agent Team을 스폰하여 구현→테스트→출시까지 자동 오케스트레이션 |
| **Function UX Effect** | 사용자는 `/av {자연어}` 하나만 입력 → PM 대화 → PRD 확정 → PL Plan/Design → Agent Team 구현/테스트 → PL 검토 → Report → Archive |
| **Core Value** | gstack(실행·테스트·배포) + bkit(문서 작성) 플러그인을 av 에이전트 조직이 캡슐화 — 사용자는 자연어만으로 전문가 수준의 프로젝트 관리 |

---

## 1. 배경 및 목적

### 1.1 현재 상황

AllSaaS 프로젝트에서 운영 중인 av(AutoVibe) 생태계:

| 유형 | 수량 | 역할 |
|------|------|------|
| **Agents** | 101개 | 도메인별 전문 에이전트 (Lead/Backend/Frontend/QA/PM) |
| **Skills** | 53개 | 사용자 직접 호출 워크플로우 스킬 |
| **Hooks** | 9개 | Claude Code 이벤트 기반 자동화 |
| **Rules** | 8개 | 코딩 패턴·조직 프로토콜 강제 규칙 |

### 1.2 문제 정의

1. **이식(복사) 불가**: AllSaaS 특화 ERP 도메인 에이전트는 다른 프로젝트에서 무의미
2. **블랙박스 문제**: 파일만 복사하면 개발자/Claude가 생태계 목적과 작동 원리를 모름
3. **기술 스택 의존성**: NestJS/Prisma 특화 규칙이 다른 스택 프로젝트에서 오류 발생
4. **플러그인 접근성**: gstack, bkit 등 강력한 플러그인이 있지만 직접 사용하기 어려움
5. **조직 부재**: 에이전트가 단독으로 작업하여 품질 관리·승인 프로세스 없음

### 1.3 목표

- **자연어 인터페이스**: 사용자가 복잡한 플러그인 명령어를 몰라도 자연어로 모든 요청 가능
- **조직 기반 품질 보증**: PM↔사용자 대화 → PL 계획/설계 → Agent Team 구현 → PL/PM 검토·승인
- **gstack 전 생명주기**: 생각→계획→구축→검토→테스트→출시→성찰 전 과정에 gstack 활용
- **bkit 문서 전담**: 모든 문서(PRD, Plan, Design, Report)는 bkit 스킬로 관리
- **프로젝트 기억**: 전문 에이전트가 프로젝트 컨텍스트를 학습·기억·활용
- **범용성**: 기술 스택(NestJS, FastAPI, Django, Go 등) 무관하게 적용 가능

---

## 2. 핵심 요구사항

### 2.1 av 조직 구조 (PM → PL → Agent Team)

```
사용자 (자연어 요청)
    ↕ 대화
av-pm-coordinator (PM) ← opus 모델, memory: project
    │ 요구사항 도출, PRD 작성, 최종 승인
    │ bkit:pdca 스킬로 문서 관리
    ↓
av-do-orchestrator (PL) ← opus 모델, memory: project
    │ Plan/Design 작성 (bkit), Agent Team 스폰 (Agent Teams)
    │ gstack으로 실행·테스트·배포 오케스트레이션
    ↓
Agent Team (Domain Agents)
    ├── av-{domain}-lead     ← 도메인 리드, 작업 분배
    ├── av-{domain}-backend  ← 백엔드 구현
    ├── av-{domain}-frontend ← 프론트엔드 구현
    └── av-{domain}-qa       ← gstack 브라우저 QA + bkit:qa-monitor
```

### 2.2 PM ↔ 사용자 대화 흐름

PM(`av-pm-coordinator`)은 사용자가 미처 생각하지 못한 요구사항을 질문으로 도출한다:

```
사용자: "결제 시스템을 만들어줘"
    ↓
PM: AskUserQuestion — 다음을 순차적으로 확인:
  1. "결제 수단은 무엇인가요? (카드/계좌이체/간편결제)"
  2. "정기결제(구독) 기능이 필요한가요?"
  3. "환불 처리 방식은? (전액/부분/수동승인)"
  4. "PG사는 어디를 사용하나요? (토스/나이스/스트라이프)"
  5. "결제 실패 시 재시도 정책은?"
  6. "결제 내역 대시보드가 필요한가요?"
    ↓
PM: 사용자 답변 종합 → PRD 작성 (bkit:pdca 스킬)
    ↓
PM: PRD를 PL에게 전달 → PL이 Plan/Design 작성
```

### 2.3 PL → Agent Team 워크플로우

```
PL (av-do-orchestrator):
  1. PRD 수신 → 프로젝트 학습 내용 기반으로 Plan 작성 (bkit)
  2. Plan → Design 상세 설계 (bkit)
  3. Agent Team 스폰 (Claude Code Agent Teams)
     - TeamCreate → 3~5명 도메인 에이전트
     - Task 할당 → 병렬 구현
  4. 구현 중: gstack으로 실시간 브라우저 확인
  5. 구현 완료: Agent Team 결과 수집 → PL 검토
  6. PL 승인 → PM 최종 승인 → Report (bkit)
  7. Archive → 프로젝트 기억 에이전트에 학습 이력 저장
```

### 2.4 Tier 분류

| Tier | 도메인 | 이식 가능 | 설명 |
|------|--------|:--------:|------|
| **Base** | `base`, `vibe`, `util` | ✅ | 모든 프로젝트에 공통 |
| **Project** | 프로젝트명 | ⚠️ | 프로젝트 특화 — 커스터마이즈 필요 |
| **Domain** | 도메인명 | ❌ | 도메인 전용 — 프로젝트마다 신규 생성 |

### 2.5 Phase별 구축 요구사항

| Phase | 목표 | 컴포넌트 수 | 도구 |
|-------|------|:----------:|------|
| **Phase 0** | 기반 인프라 | 5개 | 수동 초기화 |
| **Phase 1** | Base Rules | 5개 | bkit `/pdca plan` |
| **Phase 2** | 조직 에이전트 (PM/PL/Memory) | 3개 | bkit `/pdca plan` |
| **Phase 3** | Base Agents | 8개 | bkit `/pdca plan` |
| **Phase 4** | Meta Skills (Forge) | 6개 | bkit `/pdca plan` |
| **Phase 5** | Core Skills (gstack/bkit 통합) | 10개 | bkit `/pdca plan` |
| **Phase 6** | Hooks & Settings | 8개 | bkit `/pdca plan` |
| **Phase 7** | 도메인 확장 (반복) | 무제한 | bkit `/pdca plan` |

### 2.6 Claude Code 실행 요건 (공식 최신 스펙 기반)

Claude Code가 이 PRD+Plan+Design 문서만으로 다음을 수행할 수 있어야 한다:

- [ ] `AskUserQuestion`으로 프로젝트 정보 수집 (이름, 스택, 도메인)
- [ ] `.claude/` 디렉토리 구조 자동 생성
- [ ] 각 Phase별 컴포넌트 파일 생성 및 레지스트리 등록
- [ ] Agent frontmatter에 공식 필수 필드 포함 (`memory`, `maxTurns`, `permissionMode` 등)
- [ ] Skill frontmatter에 공식 필수 필드 포함 (`context: fork`, `paths`, `$ARGUMENTS` 등)
- [ ] Hook에 공식 최신 이벤트 활용 (`SubagentStart/Stop`, `if` 조건, `type: agent` 등)
- [ ] Agent Teams로 PM/PL/Developer 팀 스폰
- [ ] gstack으로 브라우저 기반 테스트/검증 실행
- [ ] bkit 스킬로 PDCA 문서 관리 (Plan, Design, Report)
- [ ] `av-vibe-forge health` 검증으로 완성도 확인

---

## 3. 컴포넌트 인벤토리

### 3.1 Rules (5종)

| 컴포넌트 | 역할 | 이식 가능 |
|---------|------|:--------:|
| `av-base-spec` | AutoVibe 중앙 규칙 인덱스 | ✅ |
| `av-org-protocol` | PM→PL→Agent 3단계 승인 프로토콜 | ✅ |
| `av-base-memory-first` | 메모리 우선 읽기 원칙 | ✅ |
| `av-util-mermaid-std` | Mermaid 다이어그램 표준 | ✅ |
| `av-base-plugin-routing` | gstack/bkit 플러그인 라우팅 규칙 | ✅ |

### 3.2 조직 에이전트 (3종) — Phase 2 최우선 생성

| 컴포넌트 | 모델 | 역할 | 메모리 |
|---------|------|------|--------|
| `av-pm-coordinator` | opus | PM — 사용자 대화, 요구사항 도출, PRD 작성(bkit), 최종 승인 | `memory: project` |
| `av-do-orchestrator` | opus | PL — Plan/Design 작성(bkit), Agent Team 스폰, gstack 실행/테스트 조율, 검토 | `memory: project` |
| `av-base-memory-keeper` | sonnet | 프로젝트 기억 전문가 — 학습 이력, 패턴, 의사결정 기록 관리 | `memory: project` |

### 3.3 Base Agents (8종)

| 컴포넌트 | 역할 | 트리거 | 메모리 |
|---------|------|--------|--------|
| `av-base-auditor` | 코드 품질·로직·메모리 검증 (bkit:code-analyzer 활용) | 모든 작업 완료 후 | `memory: project` |
| `av-base-optimizer` | 토큰·컴포넌트·설정 최적화 | `/av optimize` | `memory: project` |
| `av-base-template` | 템플릿 레지스트리·스캐폴딩 | 신규 파일 생성 시 | `memory: project` |
| `av-base-git-committer` | Conventional Commits 메시지 생성 | 커밋 요청 시 | `memory: project` |
| `av-base-refactor-advisor` | 리팩토링 기회 탐지·제안 | 구현 완료 후 | `memory: project` |
| `av-base-qa-reviewer` | QA 검수 — gstack 브라우저 + bkit:qa-monitor 병행 | 구현 완료 후 | `memory: project` |
| `av-base-sync-auditor` | CLAUDE.md 정합성 자동 검증 | CLAUDE.md 변경 후 | `memory: project` |
| `av-vibe-vibecoder` | 생태계 갭 분석·신규 컴포넌트 추천 | `/av-vibe-forge health` | `memory: project` |

### 3.4 Meta Skills / Forge (6종)

| 컴포넌트 | 역할 |
|---------|------|
| `av-vibe-forge` | 마스터 오케스트레이터 (14 서브커맨드) |
| `av-vibe-skill-forge` | SKILL.md 생성 + 레지스트리 등록 |
| `av-vibe-agent-forge` | AGENT.md 생성 + MEMORY.md 생성 |
| `av-vibe-hook-forge` | Hook 셸 스크립트 생성 + settings.json 등록 |
| `av-vibe-rule-forge` | Rule .md 생성 + 레지스트리 등록 |
| `av-vibe-portable-init` | 신규 프로젝트 원클릭 초기화 |

### 3.5 Core Skills (10종)

| 컴포넌트 | 역할 | 플러그인 통합 |
|---------|------|-------------|
| `av` | 마스터 게이트웨이 (자연어 → 최적 컴포넌트 라우팅) | gstack + bkit 라우팅 |
| `av-pm` | PM 대화형 인터페이스 (PRD 협의 → 팀 구성) | bkit:pdca 문서 |
| `av-base-code-quality` | 코드 품질 게이트 | bkit:code-analyzer |
| `av-base-git-commit` | git 커밋 자동화 | — |
| `av-base-sync` | CLAUDE.md 자동 최신화 | — |
| `av-base-refactor` | 리팩토링 스킬 | — |
| `av-base-post-qa` | QA 오케스트레이션 | gstack(E2E) + bkit:qa-monitor |
| `av-ecosystem-optimizer` | 생태계 주기적 최적화 | — |
| `av-agent-chat` | 에이전트 자연어 대화 인터페이스 | — |
| `av-docs-guard` | 문서 디렉토리 무결성 감시 | bkit:design-validator |

### 3.6 Hooks (8종) — 공식 최신 이벤트 기반

| Hook | 이벤트 | 타입 | 신규 |
|------|--------|------|:----:|
| Write·Edit Monitor | `PostToolUse` (Write, Edit) | command | — |
| Session Discovery | `SessionStart` (startup, resume) | command | — |
| Content Scanner | `PreToolUse` (Write, Edit) | command | — |
| Bash Guard | `PreToolUse` (Bash) | command | — |
| Memory Compact | `SessionStart` (compact) | command | — |
| Agent Spawn Logger | `SubagentStart` | command | ✅ |
| Agent Complete Logger | `SubagentStop` | command | ✅ |
| Config Watcher | `ConfigChange` (skills, project_settings) | command | ✅ |

---

## 4. 사용자-Claude 대화 흐름 (조직 기반 워크플로우)

### 4.1 전체 흐름

```
[사용자 자연어 요청]
        ↓
av 마스터 게이트웨이: 의도 분석 → 라우팅
        ↓
┌──────────────────────────────────────────────┐
│  PM (av-pm-coordinator)                      │
│  1. 사용자와 대화 — 요구사항 도출             │
│     └ 사용자가 생각하지 못한 질문으로 심화     │
│  2. 요구사항 확정 → PRD 작성 (bkit:pdca)      │
│  3. PRD를 PL에게 전달                         │
└──────────────┬───────────────────────────────┘
               ↓
┌──────────────────────────────────────────────┐
│  PL (av-do-orchestrator)                     │
│  1. PRD 수신 → 프로젝트 학습 내용 기반 분석   │
│  2. Plan 작성 (bkit:pdca)                     │
│  3. Design 작성 (bkit:pdca)                   │
│  4. Agent Team 스폰 (Claude Code Agent Teams) │
│     └ TeamCreate → Task 할당 → 병렬 구현      │
│  5. gstack으로 실행·테스트·배포 오케스트레이션  │
└──────────────┬───────────────────────────────┘
               ↓
┌──────────────────────────────────────────────┐
│  Agent Team (도메인 에이전트)                  │
│  1. 구현 (av-{domain}-backend/frontend)       │
│  2. 테스트 (av-{domain}-qa → gstack E2E)      │
│  3. 결과 보고 → PL 검토                       │
└──────────────┬───────────────────────────────┘
               ↓
┌──────────────────────────────────────────────┐
│  검증 & 완료                                  │
│  1. PL 검토: bkit:gap-detector (≥90%)         │
│  2. PM 최종 승인                              │
│  3. Report 작성 (bkit:pdca report)            │
│  4. Archive → 기억 에이전트에 학습 이력 저장   │
└──────────────────────────────────────────────┘
```

### 4.2 gstack 생명주기 통합 (7단계)

| 단계 | 한국어 | gstack 활용 | 담당 |
|------|--------|-------------|------|
| **Think** | 생각 | `Skill("gstack", "navigate {url}")` 경쟁사·레퍼런스 탐색 | PM |
| **Plan** | 계획 | `Skill("gstack", "screenshot {ref}")` UI 레퍼런스 수집 | PL |
| **Build** | 구축 | `Skill("gstack", "navigate localhost")` 실시간 구현 확인 | Agent Team |
| **Review** | 검토 | `Skill("gstack", "screenshot {pages}")` 시각적 회귀 탐지 | PL |
| **Test** | 테스트 | `Skill("gstack", "check-errors {url}")` E2E + 콘솔 오류 | QA Agent |
| **Ship** | 출시 | `Skill("canary", ...)` 카나리 배포 모니터링 | PL |
| **Reflect** | 성찰 | `Skill("gstack", "benchmark {url}")` 성능 기준선 비교 | Memory Keeper |

### 4.3 bkit 문서 관리 통합

| 단계 | bkit 활용 | 담당 |
|------|-----------|------|
| **PRD 작성** | `Skill("bkit:pdca", "plan {feature}")` | PM |
| **Plan 작성** | `Skill("bkit:pdca", "plan {feature}")` | PL |
| **Design 작성** | `Skill("bkit:pdca", "design {feature}")` | PL |
| **구현 중 갭 분석** | `Task("bkit:gap-detector", ...)` | PL |
| **코드 품질 분석** | `Task("bkit:code-analyzer", ...)` | Auditor |
| **자동 개선** | `Task("bkit:pdca-iterator", ...)` (Match Rate < 90%) | PL |
| **Report 작성** | `Skill("bkit:pdca", "report {feature}")` | PL |
| **Design 검증** | `Task("bkit:design-validator", ...)` | PL |

---

## 5. 완료 기준

### 5.1 기능 완료 기준

- [ ] `/av-vibe-forge health` 스코어 ≥ 90/100
- [ ] `/av run {자연어 요청}` 정상 라우팅 (신뢰도 ≥ 8/10)
- [ ] `/av-pm start {feature}` → PM 대화 → PRD → PL 전달 완료
- [ ] PL이 Agent Team 스폰 → 병렬 구현 → 검토 완료
- [ ] G1~G5 품질 게이트 자동 동작 확인

### 5.2 플러그인 통합 완료 기준

- [ ] gstack: 7단계 생명주기(생각~성찰) 전 과정 연동
- [ ] bkit: 모든 PDCA 문서(PRD/Plan/Design/Report) bkit 스킬로 관리
- [ ] av-base-post-qa: `Skill("gstack", ...)` 브라우저 E2E 정상 동작
- [ ] av-base-code-quality: `Task("bkit:code-analyzer", ...)` 통합 정상 동작

### 5.3 조직 완료 기준

- [ ] PM↔사용자 대화로 요구사항 도출 → PRD 작성 워크플로우 동작
- [ ] PL이 Plan/Design 작성 → Agent Team 스폰 → 구현/테스트 조율
- [ ] Agent Team → PL 검토 → PM 승인 → Report → Archive
- [ ] 프로젝트 기억 에이전트(av-base-memory-keeper)가 학습 이력 관리

### 5.4 문서 완료 기준

- [ ] `components.json` 전체 컴포넌트 등록
- [ ] CLAUDE.md에 AutoVibe 생태계 섹션 추가
- [ ] 각 에이전트의 `memory: project` 설정으로 영구 메모리 활성화

### 5.5 범용성 검증

- [ ] NestJS 스택 프로젝트에서 동작 확인
- [ ] FastAPI 스택 프로젝트에서 동작 확인

---

## 6. 기술 제약

- **bkit 필수**: 신규 프로젝트에 bkit Claude Code 플러그인 설치 필요 — 문서 작성 전담
- **gstack 필수**: 프로젝트 전 생명주기(생각~성찰) 브라우저 기반 실행·테스트
- **Claude Code 버전**: v2.1.71+ (Agent Teams, `context: fork`, `SubagentStart/Stop` 훅)
- **Agent Teams**: `settings.json`에 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 설정 필요
- **파일 규칙**: av- 접두사 필수, autovibe:true frontmatter 필수
- **레지스트리 동기화**: 모든 컴포넌트는 `.claude/registry/components.json` 등록 필수
- **메모리**: 에이전트 frontmatter의 `memory: project` 필드로 `.claude/agent-memory/{name}/` 자동 관리

### 6.1 bkit 플러그인 통합 (문서 작성 전담)

| bkit 기능 | av 사용 시점 | 담당 |
|-----------|------------|------|
| `Skill("bkit:pdca", "plan ...")` | PRD/Plan 작성 | PM → PL |
| `Skill("bkit:pdca", "design ...")` | Design 작성 | PL |
| `Skill("bkit:pdca", "report ...")` | Report 작성 | PL |
| `Task("bkit:gap-detector", ...)` | 설계-구현 갭 분석 | PL |
| `Task("bkit:code-analyzer", ...)` | 코드 품질·보안 분석 | Auditor |
| `Task("bkit:qa-monitor", ...)` | Docker 로그 런타임 QA | QA Agent |
| `Task("bkit:pdca-iterator", ...)` | Match Rate < 90% 자동 개선 | PL |
| `Task("bkit:design-validator", ...)` | Design 문서 완성도 검증 | PL |

### 6.2 gstack 플러그인 통합 (실행·테스트·배포)

| gstack 기능 | av 사용 시점 | 담당 |
|------------|------------|------|
| `Skill("gstack", "navigate {url}")` | 레퍼런스 탐색, 실시간 구현 확인 | PM/Agent Team |
| `Skill("gstack", "screenshot {page}")` | 시각적 회귀 탐지, UI 레퍼런스 | PL |
| `Skill("gstack", "check-errors {url}")` | 브라우저 콘솔 오류 감지 | QA Agent |
| `Skill("gstack", "interact {selector}")` | 인터랙션 E2E 테스트 | QA Agent |
| `Skill("canary", ...)` | 카나리 배포 모니터링 | PL |
| `Skill("benchmark", ...)` | 성능 기준선 비교 | Memory Keeper |

---

## 7. 공식 Claude Code 스펙 준수사항 (2026-03 최신)

### 7.1 Agent Frontmatter 필수/선택 필드

```yaml
# 필수 필드
name: av-{agent-name}
description: |
  {에이전트 역할 설명}
# 권장 필드
tools: Read, Glob, Grep, Write, Edit, Bash, Agent, Skill
disallowedTools: []                    # 금지 도구 목록
model: sonnet|opus|haiku|inherit
permissionMode: default|plan|dontAsk   # 권한 처리 모드
maxTurns: 50                           # 최대 에이전틱 턴 수
memory: project|user|local             # 영구 메모리 디렉토리
background: false                      # 백그라운드 실행
effort: medium|high|max                # 추론 노력 수준
isolation: worktree                    # Git 워크트리 격리
# av 커스텀 필드
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base|vibe|{domain}
```

### 7.2 Skill Frontmatter 필수/선택 필드

```yaml
# 필수 필드
name: av-{skill-name}
description: |
  {스킬 역할 설명}
# 권장 필드
argument-hint: "{서브커맨드 힌트}"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent, Skill]
context: fork                          # 격리된 서브에이전트에서 실행
agent: general-purpose|Explore|Plan    # fork 시 에이전트 타입
disable-model-invocation: false        # Claude 자동 호출 차단
model: sonnet|opus|inherit
effort: medium|high
paths: ["src/**/*.ts"]                 # 지연 로딩 경로 패턴
hooks: {}                              # 스킬 스코프 훅
# av 커스텀 필드
autovibe: true
version: "1.0"
created: "{{YYYY-MM-DD}}"
group: base|vibe|{domain}
```

### 7.3 Skill 문자열 치환 (공식 지원)

| 변수 | 설명 |
|------|------|
| `$ARGUMENTS` | 모든 인자 |
| `$ARGUMENTS[N]` 또는 `$N` | N번째 인자 |
| `${CLAUDE_SESSION_ID}` | 현재 세션 ID |
| `${CLAUDE_SKILL_DIR}` | 스킬 디렉토리 경로 |
| `` !`command` `` | 전처리 명령어 실행 (출력이 내용 대체) |

### 7.4 Hook 공식 최신 이벤트

| 이벤트 | 발생 시점 | 매처 |
|--------|----------|------|
| `SessionStart` | 세션 시작 | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | 사용자 입력 제출 | — |
| `PreToolUse` | 도구 실행 전 | 도구명 (Bash, Write 등) |
| `PostToolUse` | 도구 성공 후 | 도구명 |
| `PostToolUseFailure` | 도구 실패 후 | 도구명 |
| `PermissionRequest` | 권한 대화상자 | 도구명 |
| `Stop` | Claude 응답 완료 | — |
| `SubagentStart` | 서브에이전트 스폰 | 에이전트 타입명 |
| `SubagentStop` | 서브에이전트 종료 | 에이전트 타입명 |
| `ConfigChange` | 설정 파일 변경 | `user_settings`, `project_settings`, `skills` |
| `FileChanged` | 감시 파일 변경 | 파일명(basename) |
| `CwdChanged` | 작업 디렉토리 변경 | — |

### 7.5 Hook 핸들러 타입

| 타입 | 설명 |
|------|------|
| `command` | 셸 스크립트 실행 |
| `http` | HTTP 엔드포인트 호출 |
| `prompt` | 단일턴 LLM 판단 (AI 기반 필터링) |
| `agent` | 멀티턴 에이전트 검증 (도구 접근 가능) |

---

## 8. 참조

- **Design Spec**: `docs/design/av-ecosystem-design-spec.md`
- **PDCA Plan**: `docs/plan/av-ecosystem-pdca-driven-2026-03-28.md`
- **Claude Code 공식 문서**: Agent, Skill, Hook, Rule, Memory, Agent Teams 스펙 기준
- **av-org-protocol**: `.claude/rules/av-org-protocol.md`
- **Registry**: `.claude/registry/components.json`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
