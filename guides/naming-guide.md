# AutoVibe 네이밍 가이드

> **단일 진실 소스(Single Source of Truth)**
> 이 문서가 AutoVibe 생태계 내 모든 컴포넌트 이름의 기준입니다.
> PRD, Plan, Design Spec, 실제 파일명이 이 문서와 일치해야 합니다.

---

## 1. 네이밍 철학

AutoVibe의 모든 컴포넌트는 세 가지 원칙을 따릅니다:

1. **발견가능성**: 이름만 보고 무슨 컴포넌트인지 즉시 알 수 있어야 한다
2. **예측가능성**: 비슷한 역할의 컴포넌트는 비슷한 이름 패턴을 갖는다
3. **검색가능성**: `av-` 접두사로 AutoVibe 컴포넌트를 grep 한 번에 찾을 수 있다

```
av-base-auditor       → "AutoVibe 생태계의 base 도메인 auditor 에이전트"
av-vibe-forge         → "AutoVibe 생태계의 vibe 도메인 forge 스킬"
av-ecom-order-lead    → "AutoVibe 생태계의 ecom 도메인 order 파트 lead 에이전트"
```

---

## 2. 기본 형식

```
av-{domain}-{name}
 │    │        └─ kebab-case, 최대 3단어 (도메인 제외)
 │    └─ 도메인: base | vibe | util | {project-specific}
 └─ AutoVibe 생태계 마커 (필수, 항상 소문자)
```

### 규칙

| 규칙 | 예시 |
|------|------|
| `av-` 접두사 필수 | `av-base-auditor` ✅ `base-auditor` ❌ |
| 모두 소문자 | `av-base-auditor` ✅ `av-Base-Auditor` ❌ |
| 구분자는 하이픈만 | `av-base-auditor` ✅ `av_base_auditor` ❌ |
| 전체 최대 5단어 | `av-base-code-quality` ✅ `av-base-code-quality-checker` ❌ |
| 의미 있는 이름 | `av-base-auditor` ✅ `av-base-agent1` ❌ |

---

## 3. 도메인 구조

| 도메인 | 의미 | 이식 가능 | 예시 |
|--------|------|:--------:|------|
| `base` | 모든 프로젝트에 필수 — 범용 공통 컴포넌트 | ✅ | `av-base-auditor` |
| `vibe` | AutoVibe 메타 컴포넌트 — 생태계 자체 관리 도구 | ✅ | `av-vibe-forge` |
| `util` | 범용 유틸리티 — 특정 기능 보조 도구 | ✅ | `av-util-mermaid-std` |
| `{project}` | 프로젝트 특화 — 현재 프로젝트 도메인 | ❌ | `av-ecom-order-lead` |

### 도메인 선택 기준

```
새 컴포넌트를 만들 때:

Q1: "이 컴포넌트가 다른 프로젝트에서도 그대로 쓸 수 있는가?"
  → 예: base 또는 util 도메인
  → 아니오: {project} 도메인

Q2: "이 컴포넌트가 AutoVibe 생태계 자체를 관리하는가?" (예: 컴포넌트 생성, 레지스트리 관리)
  → 예: vibe 도메인
  → 아니오: Q1로 돌아가기

Q3: "base vs util 어느 것인가?"
  → 없으면 생태계가 작동하지 않는다 → base
  → 있으면 편리하지만 선택사항이다 → util
```

---

## 4. 컴포넌트 타입별 네이밍 패턴

### 4.1 Skill (사용자 직접 호출 — `/skill-name`)

```
위치: .claude/skills/{av-domain-name}/SKILL.md
명령어: /{av-domain-name}

패턴: av-{domain}-{verb-or-noun}

예시:
  av/SKILL.md           → /av (마스터 게이트웨이)
  av-vibe-forge/SKILL.md → /av-vibe-forge
  av-base-code-quality/SKILL.md → /av-base-code-quality
  av-pm/SKILL.md        → /av-pm
```

### 4.2 Agent (Claude Code 서브에이전트)

```
위치: .claude/agents/{av-domain-name}.md
메모리: .claude/agent-memory/{av-domain-name}/MEMORY.md

패턴: av-{domain}-{role}

역할별 접미사:
  -lead       → 도메인 총괄 오케스트레이터 (av-ecom-order-lead)
  -backend    → 백엔드 전담 (av-ecom-order-backend)
  -frontend   → 프론트엔드 전담 (av-ecom-order-frontend)
  -auditor    → 감사/검증 전담 (av-base-auditor)
  -advisor    → 제안/분석 전담 (av-base-refactor-advisor)
  -reviewer   → 리뷰 전담 (av-base-qa-reviewer)
  -committer  → 커밋 전담 (av-base-git-committer)
  -vibecoder  → 생태계 분석 (av-vibe-vibecoder)
```

### 4.3 Rule (항상 자동 로드)

```
위치: .claude/rules/{av-domain-name}.md

패턴: av-{domain}-{topic}

예시:
  av-base-spec.md          → AutoVibe 중앙 규칙 인덱스
  av-org-protocol.md       → 팀 협업 프로토콜
  av-base-memory-first.md  → 메모리 우선 읽기 원칙
  av-util-mermaid-std.md   → Mermaid 표준
```

### 4.4 Hook (이벤트 기반 자동 실행)

```
위치: .claude/hooks/{av-event-action}.sh

패턴: av-{event}-{action}.sh
  이벤트: post-write, pre-write, session, bash, precompact
  액션: monitor, scanner, guard, discovery

예시:
  av-post-write-monitor.sh  → PostToolUse(Write/Edit) 후 모니터링
  av-session-discovery.sh   → SessionStart 컨텍스트 로드
  av-content-scanner.sh     → PreToolUse(Write/Edit) 전 내용 검사
  av-bash-guard.sh          → PreToolUse(Bash) 전 명령어 검증
  av-base-precompact.sh     → PreCompact 메모리 초기화
```

---

## 5. 초기 컴포넌트 확정 테이블 (Phase 0~5, 단일 진실 소스)

> 이 테이블이 PRD, Plan, Design Spec, 실제 파일명의 기준입니다.

### Phase 0: 기반 인프라 (파일 5개)

| 파일 | 경로 | 설명 |
|------|------|------|
| `components.json` | `.claude/registry/components.json` | 빈 레지스트리 |
| `CLAUDE.md` | `CLAUDE.md` | AutoVibe 섹션 포함 |
| `frontmatter-spec.md` | `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` | 컴포넌트 형식 명세 |
| `naming-rules.md` | `.claude/docs/av-claude-code-spec/topics/naming-rules.md` | 네이밍 규칙 |
| `settings.json` | `.claude/settings.json` | 빈 훅 설정 |

### Phase 1: Base Rules (4개)

| 컴포넌트 이름 | 파일 경로 | 역할 |
|-------------|---------|------|
| `av-base-spec` | `.claude/rules/av-base-spec.md` | AutoVibe 중앙 규칙 인덱스 |
| `av-org-protocol` | `.claude/rules/av-org-protocol.md` | 팀원→PL→PM 3단계 승인 프로토콜 |
| `av-base-memory-first` | `.claude/rules/av-base-memory-first.md` | 메모리 우선 읽기 원칙 |
| `av-util-mermaid-std` | `.claude/rules/av-util-mermaid-std.md` | Mermaid 다이어그램 표준 |

### Phase 2: Base Agents (8개)

| 컴포넌트 이름 | 파일 경로 | 역할 |
|-------------|---------|------|
| `av-base-auditor` | `.claude/agents/av-base-auditor.md` | 코드 품질·로직·메모리 검증 |
| `av-base-optimizer` | `.claude/agents/av-base-optimizer.md` | 토큰·컴포넌트·설정 최적화 |
| `av-base-template` | `.claude/agents/av-base-template.md` | 템플릿 레지스트리·스캐폴딩 |
| `av-base-git-committer` | `.claude/agents/av-base-git-committer.md` | Conventional Commits 메시지 생성 |
| `av-base-refactor-advisor` | `.claude/agents/av-base-refactor-advisor.md` | 리팩토링 기회 탐지·제안 |
| `av-base-qa-reviewer` | `.claude/agents/av-base-qa-reviewer.md` | 대량 작업 후 QA 검수 |
| `av-base-sync-auditor` | `.claude/agents/av-base-sync-auditor.md` | CLAUDE.md 정합성 자동 검증 |
| `av-vibe-vibecoder` | `.claude/agents/av-vibe-vibecoder.md` | 생태계 갭 분석·신규 컴포넌트 추천 |

각 에이전트의 메모리 경로: `.claude/agent-memory/{컴포넌트-이름}/MEMORY.md`

### Phase 3: Meta Skills / Forge (6개)

| 컴포넌트 이름 | 파일 경로 | 역할 |
|-------------|---------|------|
| `av-vibe-skill-forge` | `.claude/skills/av-vibe-skill-forge/SKILL.md` | SKILL.md 생성 + 레지스트리 등록 |
| `av-vibe-agent-forge` | `.claude/skills/av-vibe-agent-forge/SKILL.md` | AGENT.md 생성 + MEMORY.md 초기화 |
| `av-vibe-hook-forge` | `.claude/skills/av-vibe-hook-forge/SKILL.md` | Hook 스크립트 생성 + settings.json 등록 |
| `av-vibe-rule-forge` | `.claude/skills/av-vibe-rule-forge/SKILL.md` | Rule .md 생성 + 레지스트리 등록 |
| `av-vibe-forge` | `.claude/skills/av-vibe-forge/SKILL.md` | 마스터 오케스트레이터 (14 서브커맨드) |
| `av-vibe-portable-init` | `.claude/skills/av-vibe-portable-init/SKILL.md` | 신규 프로젝트 원클릭 초기화 |

### Phase 4: Core Skills (10개)

| 컴포넌트 이름 | 파일 경로 | 명령어 | 역할 |
|-------------|---------|--------|------|
| `av` | `.claude/skills/av/SKILL.md` | `/av` | 마스터 게이트웨이 (자연어 → 라우팅) |
| `av-pm` | `.claude/skills/av-pm/SKILL.md` | `/av-pm` | PM 대화형 인터페이스 |
| `av-base-code-quality` | `.claude/skills/av-base-code-quality/SKILL.md` | `/av-base-code-quality` | 코드 품질 게이트 |
| `av-base-git-commit` | `.claude/skills/av-base-git-commit/SKILL.md` | `/av-base-git-commit` | git 커밋 자동화 |
| `av-base-sync` | `.claude/skills/av-base-sync/SKILL.md` | `/av-base-sync` | CLAUDE.md 자동 최신화 |
| `av-base-refactor` | `.claude/skills/av-base-refactor/SKILL.md` | `/av-base-refactor` | 리팩토링 스킬 |
| `av-base-post-qa` | `.claude/skills/av-base-post-qa/SKILL.md` | `/av-base-post-qa` | 대량 작업 후 QA |
| `av-ecosystem-optimizer` | `.claude/skills/av-ecosystem-optimizer/SKILL.md` | `/av-ecosystem-optimizer` | 생태계 최적화 |
| `av-agent-chat` | `.claude/skills/av-agent-chat/SKILL.md` | `/av-agent-chat` | 에이전트 자연어 대화 |
| `av-docs-guard` | `.claude/skills/av-docs-guard/SKILL.md` | `/av-docs-guard` | 문서 디렉토리 감시 |

### Phase 5: Hooks (5개)

| 컴포넌트 이름 | 파일 경로 | 이벤트 | 역할 |
|-------------|---------|--------|------|
| `av-post-write-monitor` | `.claude/hooks/av-post-write-monitor.sh` | PostToolUse(Write/Edit) | Write/Edit 후 변경 감지 |
| `av-session-discovery` | `.claude/hooks/av-session-discovery.sh` | SessionStart | 컨텍스트 로드 |
| `av-content-scanner` | `.claude/hooks/av-content-scanner.sh` | PreToolUse(Write/Edit) | 내용 검사 |
| `av-bash-guard` | `.claude/hooks/av-bash-guard.sh` | PreToolUse(Bash) | 금지 명령어 차단 |
| `av-base-precompact` | `.claude/hooks/av-base-precompact.sh` | PreCompact | 메모리 초기화 |

**총 Base Tier 컴포넌트: 33개** (Rules 4 + Agents 8 + Skills 16 + Hooks 5)

---

## 6. Phase 6: 도메인 확장 네이밍 패턴

Phase 6에서 프로젝트 특화 도메인을 추가할 때:

```
도메인 이름 결정: {project-domain} (예: ecom, payment, auth, hr)

Lead Agent:     av-{domain}-lead.md
Backend Agent:  av-{domain}-backend.md
Frontend Agent: av-{domain}-frontend.md
QA Agent:       av-{domain}-qa.md (선택)
Impl Skill:     av-{domain}-impl/SKILL.md
```

예시 — 이커머스 주문 도메인:

```
av-ecom-order-lead.md         → 주문 도메인 총괄
av-ecom-order-backend.md      → 주문 API/DB 전담
av-ecom-order-frontend.md     → 주문 UI 전담
av-ecom-order-impl/SKILL.md   → 주문 구현 스킬
```

예시 — 결제 도메인:

```
av-payment-lead.md            → 결제 도메인 총괄
av-payment-backend.md         → 결제 처리 전담
av-payment-impl/SKILL.md      → 결제 구현 스킬
```

---

## 7. 좋은 예 / 나쁜 예

### 좋은 예 ✅

```
av-base-auditor.md          → base 도메인, auditor 역할
av-vibe-forge/SKILL.md      → vibe 도메인, forge 스킬
av-base-git-committer.md    → base 도메인, git-committer 에이전트
av-ecom-order-lead.md       → ecom 도메인, order 파트, lead 에이전트
av-util-mermaid-std.md      → util 도메인, mermaid 표준 규칙
av-post-write-monitor.sh    → post-write 이벤트, monitor 훅
```

### 나쁜 예 ❌

```
base-auditor.md              → av- 접두사 없음
av_base_auditor.md           → 언더스코어 사용 금지
av-Base-Auditor.md           → 대문자 사용 금지
av-base-code-quality-checker.md  → 5단어 초과 (최대 5단어: av-base-code-quality)
av-agent1.md                 → 의미 없는 이름 금지
av-base.md                   → 이름이 너무 짧고 모호
auditor-av.md                → av- 접두사 위치 오류
```

### 모호한 경우 판단 기준

```
"이게 base야, util이야?"
  → 없으면 생태계가 깨지면: base
  → 없어도 되지만 있으면 좋으면: util

"도메인이 하나인가, 두 개인가?"
  → av-ecom-order-lead (ecom 도메인, order는 파트, lead는 역할) ✅
  → av-ecom-payment-lead (ecom 도메인, payment는 파트, lead는 역할) ✅
  → av-ecom-payment (역할 없음, 모호) ❌ → av-ecom-payment-lead로 명확화
```

---

## 8. 컴포넌트 이름 충돌 방지

같은 이름의 컴포넌트가 다른 타입으로 존재할 수 있습니다:

```
av-base-git-committer.md     → Agent (에이전트)
av-base-git-commit/SKILL.md  → Skill (스킬)
```

이는 의도된 설계입니다:
- **Agent** (`av-base-git-committer`): Claude가 서브에이전트로 호출
- **Skill** (`av-base-git-commit`): 사용자가 `/av-base-git-commit`으로 직접 호출

---

## 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **Design Spec**: `docs/design/av-ecosystem-design-spec.md`
- **Getting Started**: `guides/getting-started.md`
- **이 문서**: `guides/naming-guide.md`
