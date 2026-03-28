# PDCA: av-ecosystem-pdca-driven — bkit PDCA 기반 av 생태계 점진적 구축

> **에이전트**: av-pm | **PL**: av-do-orchestrator | **PM**: av-pm-coordinator
> **생성**: 2026-03-28 | **상태**: DRAFT

---

## Plan (계획)

### 목표
bkit PDCA 사이클을 활용하여 신규 프로젝트에서 사용자와 대화하면서
av(AutoVibe) 생태계를 6개 Phase로 점진적으로 구축한다.
이식(복사)이 아닌 **대화형 점진적 성장(PDCA-Driven Growth)** 방식.

### 범위
`.claude/` 디렉토리 전체 생태계:
- Base Rules 4종, Base Agents 8종, Meta Skills(Forge) 6종, Core Skills 10종, Hooks 5종
- `components.json` 레지스트리, `settings.json` 훅 등록, `CLAUDE.md` AutoVibe 섹션

### Phase별 계획

---

#### Phase 0: 기반 인프라 구축 (Bootstrap)

**목표**: `.claude/` 디렉토리 구조 생성 + 빈 Registry + CLAUDE.md 스캐폴딩

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p0-bootstrap
/pdca design av-ecosystem-p0-bootstrap
```

**사용자-Claude 대화 포인트:**
- Q: "프로젝트 이름은 무엇인가요?" → `{{PROJECT_NAME}}`
- Q: "사용하는 기술 스택은?" → `{{TECH_STACK}}`
- Q: "주요 도메인 그룹은?" → `{{DOMAIN_GROUPS}}`
- Q: "소스 루트 경로는?" → `{{SRC_ROOT}}` (기본: `src`)

**생성 파일:**
```
.claude/
├── skills/           # 스킬 SKILL.md 파일 위치
├── agents/           # 에이전트 AGENT.md 파일 위치  (신규: .claude/agents/)
├── rules/            # 규칙 파일 위치
├── hooks/            # 훅 셸 스크립트 위치
├── registry/
│   └── components.json   # 빈 레지스트리
├── agent-memory/     # 에이전트 메모리
└── docs/             # av-claude-code-spec 등 문서
    └── av-claude-code-spec/
        └── topics/   # frontmatter-spec.md 등
```

**완료 기준:**
- [ ] `.claude/` 모든 서브디렉토리 생성
- [ ] `components.json` 기본 구조 생성 (빈 레지스트리)
- [ ] `CLAUDE.md` AutoVibe 섹션 추가

---

#### Phase 1: Base Rules 생성

**목표**: av 생태계의 핵심 규칙 4종 생성

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p1-rules
/pdca design av-ecosystem-p1-rules
```

**사용자-Claude 대화 포인트:**
- Q: "조직 승인 프로세스가 필요한가요? (팀원→PL→PM 3단계)" → av-org-protocol 커스터마이즈
- Q: "멀티테넌트 지원이 필요한가요?" → tenantId 관련 규칙 포함/제외

**생성 컴포넌트:**
```
.claude/rules/
├── av-base-spec.md         # AutoVibe 중앙 규칙 인덱스
├── av-org-protocol.md      # 팀원→PL→PM 승인 프로토콜
├── av-base-memory-first.md # 메모리 우선 읽기 원칙
└── av-util-mermaid-std.md  # Mermaid 다이어그램 표준
```

**완료 기준:**
- [ ] 4개 Rule 파일 생성 + `autovibe: true` frontmatter 포함
- [ ] `components.json` rules 섹션에 4개 등록

---

#### Phase 2: Base Agents 생성

**목표**: 모든 프로젝트에 필요한 범용 에이전트 8종 생성

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p2-base-agents
/pdca design av-ecosystem-p2-base-agents
```

**사용자-Claude 대화 포인트:**
- Q: "코드 품질 체크 도구는?" (Biome/ESLint/Ruff 등) → av-base-auditor 커스터마이즈
- Q: "감사 레벨을 몇 단계로 설정할까요?" (1~3단계) → 감사 계층 설정

**생성 컴포넌트:**
```
.claude/agents/
├── av-base-auditor.md          # 코드 품질·로직·메모리 검증 (level 1~3)
├── av-base-optimizer.md        # 토큰·컴포넌트·설정 최적화
├── av-base-template.md         # 템플릿 레지스트리·스캐폴딩
├── av-base-git-committer.md    # Conventional Commits 메시지 생성
├── av-base-refactor-advisor.md # 리팩토링 기회 탐지·제안
├── av-base-qa-reviewer.md      # 대량 작업 QA 검수
├── av-base-sync-auditor.md     # CLAUDE.md 정합성 검증
└── av-vibe-vibecoder.md        # 생태계 갭 분석·컴포넌트 추천
```

**각 에이전트에 함께 생성:**
```
.claude/agent-memory/{name}/
└── MEMORY.md   # 초기 빈 메모리 파일
```

**완료 기준:**
- [ ] 8개 Agent 파일 생성 + 필수 frontmatter (name, tools, model, scope)
- [ ] 8개 MEMORY.md 초기화
- [ ] `components.json` agents 섹션에 8개 등록

---

#### Phase 3: Meta Skills / Forge 생성

**목표**: av 생태계의 핵심 오케스트레이터 및 생성 도구(Forge) 6종 생성

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p3-forge-skills
/pdca design av-ecosystem-p3-forge-skills
```

**사용자-Claude 대화 포인트:**
- Q: "컴포넌트 그룹 체계를 어떻게 설정할까요?" (예: [core] user, product [extended] analytics)
- Q: "기본 ROUTING_TABLE 전략은?" (도메인별 위임 규칙)

**생성 컴포넌트:**
```
.claude/skills/
├── av-vibe-forge/
│   └── SKILL.md        # 마스터 오케스트레이터 (14 서브커맨드)
├── av-vibe-skill-forge/
│   └── SKILL.md        # 스킬 생성 전담
├── av-vibe-agent-forge/
│   └── SKILL.md        # 에이전트 생성 전담
├── av-vibe-hook-forge/
│   └── SKILL.md        # 훅 생성 전담
├── av-vibe-rule-forge/
│   └── SKILL.md        # 룰 생성 전담
└── av-vibe-portable-init/
    └── SKILL.md        # 신규 프로젝트 초기화
```

**완료 기준:**
- [ ] 6개 Skill 파일 생성
- [ ] `av-vibe-forge` 14개 서브커맨드 동작 확인
- [ ] `components.json` skills 섹션에 6개 등록

---

#### Phase 4: Core Skills 생성

**목표**: 일상 워크플로우를 자동화하는 핵심 스킬 10종 생성

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p4-core-skills
/pdca design av-ecosystem-p4-core-skills
```

**사용자-Claude 대화 포인트:**
- Q: "ROUTING_TABLE에 어떤 도메인별 위임 규칙이 필요한가요?" → av/SKILL.md 커스터마이즈
- Q: "PM 워크플로우 팀 구성 기준은?" → av-pm/SKILL.md 도메인 감지 규칙

**생성 컴포넌트:**
```
.claude/skills/
├── av/
│   └── SKILL.md                # 마스터 게이트웨이 (ROUTING_TABLE 포함)
├── av-pm/
│   └── SKILL.md                # PM 대화형 인터페이스
├── av-base-code-quality/
│   └── SKILL.md                # 코드 품질 게이트
├── av-base-git-commit/
│   └── SKILL.md                # git 커밋 자동화
├── av-base-sync/
│   └── SKILL.md                # CLAUDE.md 자동 최신화
├── av-base-refactor/
│   └── SKILL.md                # 리팩토링 스킬
├── av-base-post-qa/
│   └── SKILL.md                # 대량 작업 QA
├── av-ecosystem-optimizer/
│   └── SKILL.md                # 생태계 최적화
├── av-agent-chat/
│   └── SKILL.md                # 에이전트 대화
└── av-docs-guard/
    └── SKILL.md                # 문서 디렉토리 감시
```

**완료 기준:**
- [ ] 10개 Skill 파일 생성
- [ ] `/av run {자연어}` → ROUTING_TABLE 라우팅 정상 동작
- [ ] `components.json` skills 섹션에 10개 추가 등록 (누적 16개)

---

#### Phase 5: Hooks & Settings 등록

**목표**: Claude Code 이벤트 기반 자동화 훅 5종 + settings.json 등록

**bkit PDCA 실행 명령어:**
```
/pdca plan av-ecosystem-p5-hooks
/pdca design av-ecosystem-p5-hooks
```

**사용자-Claude 대화 포인트:**
- Q: "Write 이벤트 후 어떤 자동 검사가 필요한가요?" → write-monitor 커스터마이즈
- Q: "세션 시작 시 자동으로 로드할 컨텍스트가 있나요?" → session-discovery 커스터마이즈
- Q: "금지할 Bash 명령어 패턴이 있나요?" → bash-guard 커스터마이즈

**생성 컴포넌트:**
```
.claude/hooks/
├── av-post-write-monitor.sh    # Write/Edit 후 변경 감지
├── av-session-discovery.sh     # SessionStart: 컨텍스트 로드
├── av-content-scanner.sh       # Write/Edit 전 내용 검사
├── av-bash-guard.sh            # Bash 명령어 금지 규칙
└── av-base-precompact.sh       # PreCompact: 메모리 초기화
```

**settings.json 훅 등록 형식:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-post-write-monitor.sh" }]
      }
    ],
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-session-discovery.sh" }] },
      { "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-base-precompact.sh" }] }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-content-scanner.sh" }]
      },
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/av-bash-guard.sh" }]
      }
    ]
  }
}
```

**완료 기준:**
- [ ] 5개 훅 셸 스크립트 생성 + 실행 권한 부여 (`chmod +x`)
- [ ] `.claude/settings.json` 훅 등록 완료
- [ ] `components.json` hooks 섹션에 5개 등록

---

#### Phase 6: 도메인 확장 (반복 사이클)

**목표**: 프로젝트 특화 도메인 에이전트·스킬을 bkit PDCA로 지속 확장

**bkit PDCA 실행 명령어 (반복):**
```
/av-pm start {domain}-agents    # 도메인 전담 에이전트 PRD 협의
/pdca plan {domain}-agents
/pdca design {domain}-agents
/av-vibe-forge agent {domain}-lead --group {domain}
/av-vibe-forge agent {domain}-backend --group {domain}
/av-vibe-forge skill {domain}-impl --group {domain}
```

**사용자-Claude 대화 예시:**
```
사용자: "이커머스 주문 관리 에이전트가 필요해"
Claude: /av-pm start ecom-order-agents
  → AskUserQuestion: 주문 도메인 범위, 기술 스택, 완료 기준
  → PRD 생성 → 팀 구성
  → /av-vibe-forge agent ecom-order-lead
  → /av-vibe-forge agent ecom-order-backend
  → /av-vibe-forge skill ecom-order-impl
  → ROUTING_TABLE에 ecom 도메인 경로 추가
```

**완료 기준:**
- [ ] 도메인별 Lead + Backend 에이전트 생성
- [ ] 도메인 전용 구현 스킬 생성
- [ ] `av/SKILL.md` ROUTING_TABLE에 도메인 경로 추가
- [ ] `/av run {domain} {task}` 정상 라우팅

---

### 완료 기준 (전체)

| 항목 | 기준 |
|------|------|
| **건강도** | `/av-vibe-forge health` ≥ 90/100 |
| **게이트웨이** | `/av run {자연어}` 신뢰도 ≥ 8/10 |
| **PM 워크플로우** | `/av-pm start {feature}` → PRD → 팀 완성 |
| **Registry** | `components.json` Base Tier 33개 등록 |
| **품질 게이트** | G1~G5 자동 동작 확인 |

---

## Do (실행)

> 이 섹션은 각 Phase 실행 시 작성됩니다.

- **시작**: 미정 | **완료**: 미정
- **Phase 진행 현황**: Phase 0 대기 중

---

## Check (검증)

| Gate | 결과 | 담당 | 비고 |
|------|------|------|------|
| G1 코드 품질 | 대기 | 팀원 셀프 | Biome/ESLint + TypeCheck |
| G2 Match Rate | 대기 | 팀원 셀프 | ≥90% 기준 |
| G3 보안 | 대기 | 팀원 셀프 | OWASP |
| G4 PL 검토 | 대기 | av-do-orchestrator | - |
| G5 PM 승인 | 대기 | av-pm-coordinator | - |

---

## Act (개선)

> PM APPROVED 후 작성 예정

- **학습 내용**: TBD
- **개선 제안**: TBD
- **Archive 일시**: TBD
- **Archive 경로**: `docs/pdca/archived/archive/2026-03/av-ecosystem-pdca-driven/`

---

## 참조

- **PRD**: `docs/prd/av-ecosystem-pdca-driven.prd.md`
- **Design Spec**: `docs/design/av-ecosystem-design-spec.md`
- **av-org-protocol**: `.claude/rules/av-org-protocol.md`
- **Frontmatter Spec**: `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md`
