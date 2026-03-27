# PRD: av-ecosystem-pdca-driven — bkit PDCA 기반 av 생태계 점진적 구축

> **PM**: av-pm | **요청자**: CEO | **생성일**: 2026-03-28
> **상태**: CONFIRMED
> **연관 문서**: `docs/pdca/active/av-ecosystem-pdca-driven-2026-03-28.md` | `docs/80-reference/80.02-internal/av-ecosystem-design-spec.md`

---

## Executive Summary

| 항목 | 값 |
|------|-----|
| **Feature** | av-ecosystem-pdca-driven |
| **목표** | 신규 프로젝트에서 bkit PDCA 사이클을 통해 사용자와 대화하면서 av 생태계를 점진적으로 구축 |
| **규모** | Major (6 Phase, 50+ 컴포넌트 생성) |
| **완료 기준** | `/av-vibe-forge health` PASS + `/av run {task}` 정상 라우팅 |

### Value Delivered

| 관점 | 내용 |
|------|------|
| **Problem** | 신규 프로젝트마다 av 생태계를 처음부터 수동으로 설정해야 함 — 파일 복사(이식)만으로는 프로젝트 특화 커스터마이징 불가 |
| **Solution** | bkit의 `/pdca plan → design → do → check → report` 사이클을 통해 사용자와 대화하면서 프로젝트 맞춤형 av 생태계를 점진적으로 성장(Grow) |
| **Function UX Effect** | Claude Code가 PRD+Plan+Design 문서만 읽고 사용자와 대화하면서 각 Phase를 단계적으로 구현 — 완료 시 `/av run {자연어}` 하나로 모든 작업 자동화 |
| **Core Value** | 복사(이식) 없이 대화 기반 점진적 성장 — 어떤 기술 스택의 신규 프로젝트에도 적용 가능한 범용 AutoVibe 생태계 |

---

## 1. 배경 및 목적

### 1.1 현재 상황

AllSaaS 프로젝트에서 운영 중인 av(AutoVibe) 생태계는 다음 컴포넌트로 구성된다:

| 유형 | 수량 | 역할 |
|------|------|------|
| **Agents** | 101개 | 도메인별 전문 에이전트 (Lead/Backend/Frontend/QA/PM) |
| **Skills** | 53개 | 사용자 직접 호출 워크플로우 스킬 |
| **Hooks** | 9개 | Claude Code 이벤트 기반 자동화 |
| **Rules** | 8개 | 코딩 패턴·조직 프로토콜 강제 규칙 |

### 1.2 문제 정의

1. **이식(복사) 불가**: AllSaaS 특화 ERP 도메인 에이전트(av-erp-acc-lead 등)는 다른 프로젝트에서 무의미
2. **블랙박스 문제**: 파일만 복사하면 개발자/Claude가 생태계 목적과 작동 원리를 모름
3. **기술 스택 의존성**: NestJS/Prisma 특화 규칙이 다른 스택 프로젝트에서 오류 발생
4. **점진적 필요성**: 모든 컴포넌트를 한 번에 구축하면 초기 오버헤드가 너무 큼

### 1.3 목표

- **대화형 구축**: bkit PDCA 사이클로 사용자와 Claude가 대화하면서 필요한 컴포넌트만 선택적으로 생성
- **범용성**: 기술 스택(NestJS, FastAPI, Django, Go 등) 무관하게 적용 가능
- **자가 성장**: 한번 구축된 av 생태계가 새 도메인 요구사항에 따라 스스로 확장

---

## 2. 핵심 요구사항

### 2.1 Tier 분류

av 생태계 컴포넌트는 3계층으로 분류된다:

| Tier | 도메인 | 이식 가능 | 설명 |
|------|--------|:--------:|------|
| **Base** | `base`, `vibe`, `util` | ✅ | 모든 프로젝트에 공통 — 복사 없이 재생성 |
| **Project** | 프로젝트명 | ⚠️ | 현재 프로젝트 특화 (ERP, SaaS 등) — 커스터마이즈 필요 |
| **Domain** | 도메인명 | ❌ | 도메인 전용 — 각 프로젝트에서 신규 생성 |

### 2.2 Phase별 구축 요구사항

| Phase | 목표 | 컴포넌트 수 | bkit PDCA |
|-------|------|:----------:|-----------|
| **Phase 0** | 기반 인프라 | 5개 | 수동 초기화 (bkit 전용) |
| **Phase 1** | Base Rules | 4개 | `/pdca plan rules` |
| **Phase 2** | Base Agents | 8개 | `/pdca plan base-agents` |
| **Phase 3** | Meta Skills (Forge) | 6개 | `/pdca plan forge-skills` |
| **Phase 4** | Core Skills | 10개 | `/pdca plan core-skills` |
| **Phase 5** | Hooks & Settings | 5개 | `/pdca plan hooks` |
| **Phase 6** | 도메인 확장 | 무제한 | `/pdca plan {domain}-expansion` |

### 2.3 Claude Code 실행 요건

Claude Code가 이 PRD+Plan+Design 문서만으로 다음을 수행할 수 있어야 한다:

- [ ] `AskUserQuestion`으로 프로젝트 정보 수집 (이름, 스택, 도메인)
- [ ] `.claude/` 디렉토리 구조 자동 생성
- [ ] 각 Phase별 컴포넌트 파일 생성 및 레지스트리 등록
- [ ] `av-vibe-forge health` 검증으로 완성도 확인

---

## 3. 컴포넌트 인벤토리 (Base Tier — 모든 프로젝트 공통)

### 3.1 Rules (4종)

| 컴포넌트 | 역할 | 이식 가능 |
|---------|------|:--------:|
| `av-base-spec` | AutoVibe 중앙 규칙 인덱스 | ✅ |
| `av-org-protocol` | 팀원→PL→PM 3단계 승인 프로토콜 | ✅ |
| `av-base-memory-first` | 메모리 우선 읽기 원칙 | ✅ |
| `av-util-mermaid-std` | Mermaid 다이어그램 표준 | ✅ |

### 3.2 Base Agents (8종)

| 컴포넌트 | 역할 | 트리거 |
|---------|------|--------|
| `av-base-auditor` | 코드 품질·로직·메모리 검증 | 모든 작업 완료 후 |
| `av-base-optimizer` | 토큰·컴포넌트·설정 최적화 | `/av optimize` |
| `av-base-template` | 템플릿 레지스트리·스캐폴딩 | 신규 파일 생성 시 |
| `av-base-git-committer` | Conventional Commits 메시지 생성 | 커밋 요청 시 |
| `av-base-refactor-advisor` | 리팩토링 기회 탐지·제안 | 구현 완료 후 |
| `av-base-qa-reviewer` | 대량 작업 후 QA 검수 | 대량 구현 완료 후 |
| `av-base-sync-auditor` | CLAUDE.md 정합성 자동 검증 | CLAUDE.md 변경 후 |
| `av-vibe-vibecoder` | 생태계 갭 분석·신규 컴포넌트 추천 | `/av-vibe-forge health` |

### 3.3 Meta Skills / Forge (6종)

| 컴포넌트 | 역할 |
|---------|------|
| `av-vibe-forge` | 마스터 오케스트레이터 (14 서브커맨드) |
| `av-vibe-skill-forge` | SKILL.md 생성 + 레지스트리 등록 |
| `av-vibe-agent-forge` | AGENT.md 생성 + MEMORY.md 생성 |
| `av-vibe-hook-forge` | Hook 셸 스크립트 생성 + settings.json 등록 |
| `av-vibe-rule-forge` | Rule .md 생성 + 레지스트리 등록 |
| `av-vibe-portable-init` | 신규 프로젝트 원클릭 초기화 |

### 3.4 Core Skills (10종)

| 컴포넌트 | 역할 |
|---------|------|
| `av` | AutoVibe 마스터 게이트웨이 (자연어 → 최적 컴포넌트) |
| `av-pm` | PM 대화형 인터페이스 (PRD 협의 → 팀 구성) |
| `av-base-code-quality` | 코드 품질 게이트 (lint + typecheck + build) |
| `av-base-git-commit` | git 커밋 자동화 |
| `av-base-sync` | CLAUDE.md 자동 최신화 |
| `av-base-refactor` | 리팩토링 스킬 |
| `av-base-post-qa` | 대량 작업 후 QA 오케스트레이션 |
| `av-ecosystem-optimizer` | 생태계 주기적 최적화 |
| `av-agent-chat` | 에이전트 자연어 대화 인터페이스 |
| `av-docs-guard` | 문서 디렉토리 무결성 감시 |

### 3.5 Hooks (5종)

| Hook | 이벤트 | 스크립트 |
|------|--------|---------|
| Write·Edit Monitor | `PostToolUse` (Write, Edit) | `av-post-write-monitor.sh` |
| Session Discovery | `SessionStart` | `av-session-discovery.sh` |
| Content Scanner | `PreToolUse` (Write, Edit) | `av-content-scanner.sh` |
| Bash Guard | `PreToolUse` (Bash) | `av-bash-guard.sh` |
| Memory Init | `SessionStart` | `av-base-precompact.sh` |

---

## 4. 사용자-Claude 대화 흐름 (bkit PDCA 기반)

```
[신규 프로젝트 시작]
        ↓
사용자: "av 생태계를 구축하고 싶어"
        ↓
Claude: /pdca plan av-ecosystem-phase-0
  → AskUserQuestion: 프로젝트 이름, 기술 스택, 도메인 그룹
  → Plan 문서 생성
        ↓
Claude: /pdca design av-ecosystem-phase-0
  → Design Spec 참조하여 상세 설계
        ↓
Claude: Phase 0 구현 (.claude/ 구조, Registry, CLAUDE.md)
        ↓
Claude: /pdca check → G1~G3 검증
        ↓
[Phase 1 반복: Base Rules 생성]
[Phase 2 반복: Base Agents 생성]
[Phase 3 반복: Meta Skills(Forge) 생성]
[Phase 4 반복: Core Skills 생성]
[Phase 5 반복: Hooks 등록]
        ↓
[Phase 6: 도메인 특화 컴포넌트 확장]
  → 사용자: "회계 도메인 전담 에이전트가 필요해"
  → Claude: /av-vibe-forge agent {domain}-lead --group {domain}
  → 대화를 통해 도메인 에이전트 설계 → 생성
        ↓
[생태계 완성: /av-vibe-forge health PASS]
```

---

## 5. 완료 기준

### 5.1 기능 완료 기준

- [ ] `/av-vibe-forge health` 스코어 ≥ 90/100
- [ ] `/av run {자연어 요청}` 정상 라우팅 (신뢰도 ≥ 8/10)
- [ ] `/av-pm start {feature}` → PRD 협의 → 팀 구성 완료
- [ ] G1~G5 품질 게이트 자동 동작 확인

### 5.2 문서 완료 기준

- [ ] `components.json` 전체 컴포넌트 등록 (Base Tier)
- [ ] CLAUDE.md에 AutoVibe 생태계 섹션 추가
- [ ] 각 에이전트/스킬 MEMORY.md 초기화 완료

### 5.3 범용성 검증

- [ ] NestJS 스택 프로젝트에서 동작 확인
- [ ] FastAPI 스택 프로젝트에서 동작 확인 (av-vibe-portable-init 커스터마이즈)

---

## 6. 기술 제약

- **bkit 필수**: 신규 프로젝트에 bkit Claude Code 플러그인 설치 필요
- **Claude Code 버전**: v2.1.71+ (isolation:worktree, background agent)
- **파일 규칙**: av- 접두사 필수, autovibe:true frontmatter 필수
- **레지스트리 동기화**: 모든 컴포넌트는 `.claude/registry/components.json` 등록 필수
- **메모리 계층**: L1(에이전트) + L2(스킬) + L4(글로벌) 3계층 메모리 시스템 준수

---

## 7. 참조

- **Design Spec**: `docs/80-reference/80.02-internal/av-ecosystem-design-spec.md`
- **PDCA Plan**: `docs/pdca/active/av-ecosystem-pdca-driven-2026-03-28.md`
- **av-base-spec**: `.claude/rules/av-base-spec.md`
- **av-org-protocol**: `.claude/rules/av-org-protocol.md`
- **Registry**: `.claude/registry/components.json`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
