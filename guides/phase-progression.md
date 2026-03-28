# Phase 진행 가이드

> **목적**: 각 Phase의 GO/NO-GO 기준, 의존성, 롤백 방법을 명확히 합니다.
> Phase가 실패해도 해당 Phase만 재시도하면 됩니다.

---

## Phase 의존성 구조

```
Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6(반복)
  │          │          │          │          │          │
  └──필수──→ └──필수──→ └──필수──→ └──필수──→ └──필수──→ └──선택(추가)
```

**엄격한 순서 의존성**: 각 Phase는 이전 Phase 완료 후에만 시작 가능합니다.
- Phase 1은 Phase 0의 `.claude/` 디렉토리 구조가 있어야 합니다
- Phase 2는 Phase 1의 Rules가 로드된 상태에서 에이전트를 생성합니다
- Phase 3은 Phase 2의 에이전트를 Forge 스킬이 활용합니다
- Phase 4는 Phase 3의 Forge 도구를 사용하여 Core Skills를 생성합니다
- Phase 5는 Phase 4의 Core Skills가 정상 동작하는 상태에서 훅을 등록합니다

---

## Phase 0: 기반 인프라 구축

### 사전 조건
- Claude Code v2.1.71+ 실행 중
- bkit 플러그인 활성화 (`/bkit` 메뉴 표시)
- 프로젝트 루트에 git 초기화 완료 (`.git/` 존재)

### GO 기준 (다음 Phase로 진행)
- [ ] `.claude/` 하위 6개 디렉토리 존재 (skills, agents, rules, hooks, registry, agent-memory)
- [ ] `.claude/registry/components.json` 기본 구조 존재
- [ ] `CLAUDE.md`에 AutoVibe 섹션 추가됨
- [ ] `.claude/settings.json` 기본 파일 생성됨
- [ ] `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` 존재

### NO-GO 기준 (현재 Phase 재시도)
- `.claude/` 디렉토리 자체가 없음
- `components.json` 파일 없음 또는 JSON 형식 오류

### 완료 확인 명령어
```bash
ls -la .claude/
cat .claude/registry/components.json
```

### 예상 소요 시간: 10~30분

---

## Phase 1: Base Rules 생성

### 사전 조건
- Phase 0 GO 기준 모두 충족

### Claude 프롬프트
```
Phase 1 Base Rules 4종을 생성해줘.
```
Claude가 필요한 경우 추가 질문을 합니다:
- "조직 승인 프로세스 (팀원→PL→PM)가 필요한가요?"
- "멀티테넌트 지원이 필요한가요?"

### GO 기준
- [ ] `.claude/rules/av-base-spec.md` 존재 (autovibe: true frontmatter 포함)
- [ ] `.claude/rules/av-org-protocol.md` 존재
- [ ] `.claude/rules/av-base-memory-first.md` 존재
- [ ] `.claude/rules/av-util-mermaid-std.md` 존재
- [ ] `components.json`의 `rules` 섹션에 4개 등록됨

### NO-GO 기준
- Rule 파일 1개 이상 없음
- frontmatter에 `autovibe: true` 없음
- `components.json` 업데이트 안됨

### 롤백 방법
```bash
# 특정 Rule만 재생성
"av-base-spec Rule을 다시 생성해줘. frontmatter에 autovibe: true 포함해서."
```

### 예상 소요 시간: 5~10분

---

## Phase 2: Base Agents 생성

### 사전 조건
- Phase 1 GO 기준 모두 충족

### Claude 프롬프트
```
Phase 2 Base Agents 8종을 생성해줘.
기술 스택은 {내 기술 스택}이야.
```

### GO 기준
- [ ] `.claude/agents/` 에 8개 에이전트 파일 존재
  - av-base-auditor.md
  - av-base-optimizer.md
  - av-base-template.md
  - av-base-git-committer.md
  - av-base-refactor-advisor.md
  - av-base-qa-reviewer.md
  - av-base-sync-auditor.md
  - av-vibe-vibecoder.md
- [ ] `.claude/agent-memory/` 에 8개 MEMORY.md 생성됨
- [ ] `components.json`의 `agents` 섹션에 8개 등록됨
- [ ] 각 에이전트에 필수 frontmatter (name, tools, model, scope) 포함

### NO-GO 기준
- 에이전트 파일 1개 이상 없음
- MEMORY.md 없는 에이전트 존재
- frontmatter 필수 항목 누락

### 롤백 방법
```bash
"av-base-auditor 에이전트를 다시 생성해줘.
.claude/agent-memory/av-base-auditor/MEMORY.md도 함께 생성해줘."
```

### 예상 소요 시간: 15~20분

---

## Phase 3: Meta Skills (Forge) 생성

### 사전 조건
- Phase 2 GO 기준 모두 충족

### Claude 프롬프트
```
Phase 3 Meta Skills (Forge) 6종을 생성해줘.
av-vibe-skill-forge부터 순서대로 생성해줘.
```

### GO 기준
- [ ] `.claude/skills/` 에 6개 스킬 디렉토리/SKILL.md 존재
  - av-vibe-skill-forge/SKILL.md
  - av-vibe-agent-forge/SKILL.md
  - av-vibe-hook-forge/SKILL.md
  - av-vibe-rule-forge/SKILL.md
  - av-vibe-forge/SKILL.md
  - av-vibe-portable-init/SKILL.md
- [ ] `/av-vibe-forge skill test` 명령어 오류 없이 실행됨
- [ ] `components.json`의 `skills` 섹션에 6개 등록됨

### NO-GO 기준
- Forge 스킬 1개 이상 없음
- `/av-vibe-forge health` 실행 시 오류 발생
- `components.json` 미업데이트

### 롤백 방법
```bash
"/av-vibe-forge validate  # 어떤 스킬이 문제인지 확인"
"av-vibe-skill-forge 스킬을 다시 생성해줘."
```

### 예상 소요 시간: 15~20분

---

## Phase 4: Core Skills 생성

### 사전 조건
- Phase 3 GO 기준 모두 충족 (특히 av-vibe-forge 동작 확인 필수)

### Claude 프롬프트
```
Phase 4 Core Skills 10종을 생성해줘.
ROUTING_TABLE은 {내 도메인 그룹}에 맞게 설정해줘.
```

### GO 기준
- [ ] `.claude/skills/` 에 10개 스킬 디렉토리/SKILL.md 존재
  - av/SKILL.md, av-pm/SKILL.md, av-base-code-quality/SKILL.md
  - av-base-git-commit/SKILL.md, av-base-sync/SKILL.md
  - av-base-refactor/SKILL.md, av-base-post-qa/SKILL.md
  - av-ecosystem-optimizer/SKILL.md, av-agent-chat/SKILL.md, av-docs-guard/SKILL.md
- [ ] `/av run "코드 품질 검사"` 정상 라우팅됨 (av-base-auditor로)
- [ ] `/av-pm start test` AskUserQuestion 시작됨
- [ ] `components.json`의 `skills` 섹션에 10개 추가 등록됨 (누적 16개)

### NO-GO 기준
- `/av` 스킬 없음 (게이트웨이 없으면 전체 시스템 작동 불가)
- ROUTING_TABLE에 기본 경로 없음
- `components.json` 누적 개수 불일치

### 예상 소요 시간: 15~25분

---

## Phase 5: Hooks & Settings 등록

### 사전 조건
- Phase 4 GO 기준 모두 충족

### Claude 프롬프트
```
Phase 5 Hooks 5종을 생성하고 settings.json에 등록해줘.
금지할 Bash 명령어는 {패턴}이야.
```

### GO 기준
- [ ] `.claude/hooks/` 에 5개 스크립트 존재
  - av-post-write-monitor.sh
  - av-session-discovery.sh
  - av-content-scanner.sh
  - av-bash-guard.sh
  - av-base-precompact.sh
- [ ] 모든 스크립트에 실행 권한 있음 (`chmod +x`)
- [ ] `.claude/settings.json` 훅 등록 완료 (PostToolUse, PreToolUse, SessionStart)
- [ ] `components.json`의 `hooks` 섹션에 5개 등록됨

### NO-GO 기준
- 훅 스크립트 실행 권한 없음
- `settings.json`에 훅 미등록
- 스크립트에 셸 문법 오류

### 완료 확인 명령어
```bash
ls -la .claude/hooks/    # x 권한 확인
cat .claude/settings.json | python3 -m json.tool  # JSON 유효성 확인
```

### 예상 소요 시간: 10분

---

## Phase 5 완료 — 생태계 검증

Phase 5 완료 후 전체 생태계 검증:

```
/av-vibe-forge health
```

기대 출력:
```
════════════════════════════════════════
  AutoVibe 생태계 건강도: 95/100 이상
════════════════════════════════════════
  ✅ OK: 33개 컴포넌트
  ⚠️ STALE: 0개
  ❌ MISSING: 0개
```

점수가 90 미만이면:
```
/av-vibe-forge validate   # MISSING 항목 확인
"MISSING 항목을 다시 생성해줘."
```

---

## Phase 6: 도메인 확장 (반복 사이클)

Phase 6은 독립적으로 반복 실행 가능합니다.
Phase 5 완료 후 언제든지 새 도메인을 추가할 수 있습니다.

### Claude 프롬프트
```
{도메인명} 도메인 전담 에이전트가 필요해.
```

Claude가 자동으로:
1. `/av-pm start {domain}-agents` 실행
2. AskUserQuestion으로 도메인 범위, 스택, 완료 기준 확인
3. PRD 생성 후 도메인 에이전트/스킬 생성

### GO 기준 (도메인별)
- [ ] `av-{domain}-lead.md` 에이전트 생성됨
- [ ] `av-{domain}-backend.md` 에이전트 생성됨 (필요시)
- [ ] `av-{domain}-impl/SKILL.md` 스킬 생성됨
- [ ] `av/SKILL.md` ROUTING_TABLE에 도메인 경로 추가됨
- [ ] `/av run "{domain} {task}"` 정상 라우팅됨

### NO-GO 기준 (도메인별 — 재시도)
- Lead 에이전트 없이 Backend/Impl만 생성된 경우 (오케스트레이터 없음)
- ROUTING_TABLE에 도메인 경로 추가 안됨 (라우팅 불가)
- `components.json`에 신규 컴포넌트 미등록

> **Phase 6 특성**: Phase 6는 무한 반복 사이클입니다. "전체 실패"는 없으며,
> 도메인별로 GO/NO-GO를 개별 판단합니다. NO-GO 시 해당 도메인만 재시도하세요.

### 예상 소요 시간: 도메인당 15~30분

---

## 전체 Phase 진행 체크리스트

```
[ ] Phase 0: .claude/ 구조 + 빈 레지스트리 + CLAUDE.md
[ ] Phase 1: Base Rules 4종 + components.json 등록
[ ] Phase 2: Base Agents 8종 + MEMORY.md + components.json 등록
[ ] Phase 3: Meta Skills(Forge) 6종 + /av-vibe-forge 동작 확인
[ ] Phase 4: Core Skills 10종 + /av 라우팅 확인
[ ] Phase 5: Hooks 5종 + settings.json 등록 + health ≥ 90/100
[ ] Phase 6: 도메인별 반복 확장
```

---

## 참조

- **네이밍 가이드**: [guides/naming-guide.md](naming-guide.md)
- **퀵스타트**: [guides/quick-start-30min.md](quick-start-30min.md)
- **Design Spec**: [docs/design/av-ecosystem-design-spec.md](../docs/design/av-ecosystem-design-spec.md)
