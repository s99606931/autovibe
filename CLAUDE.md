# AutoVibe (av) 프로젝트

## AutoVibe 생태계

자기 성장 AI 개발 생태계. 스펙: `.claude/rules/av-base-spec.md`
레지스트리: `.claude/registry/components.json`

### 조직 구조

| 역할 | 에이전트 | 모델 | 책임 |
|------|---------|------|------|
| PM | av-pm-coordinator | opus | 사용자 대화 → PRD(bkit) → 최종 승인 |
| PL | av-do-orchestrator | opus | Plan/Design(bkit) → Agent Team → gstack 검증 |
| Memory | av-base-memory-keeper | sonnet | 프로젝트 기억 관리 |

### 핵심 스킬

| 스킬 | 역할 |
|------|------|
| `/av {자연어}` | 마스터 게이트웨이 — 자연어 → 최적 컴포넌트 + PM/PL 라우팅 |
| `/av-vibe-forge` | 마스터 오케스트레이터 — skill/agent/hook/rule 관리 |
| `/av-pm start {feature}` | PM 인터페이스 — 사용자 대화 → PRD (bkit) |
| `/av-base-code-quality` | 코드 품질 게이트 (bkit:code-analyzer 통합) |
| `/av-base-post-qa` | QA (gstack E2E + bkit:qa-monitor) |
| `/av-base-git-commit` | git 커밋 자동화 |

### 플러그인 통합

| 플러그인 | 역할 | 호출 |
|---------|------|------|
| **gstack** | 실행·테스트·배포 (7단계 생명주기) | `Skill("gstack", ...)` |
| **bkit** | 문서 작성·코드 분석·갭 검증 | `Skill("bkit:pdca", ...)` / `Task("bkit:*", ...)` |
| **canary** | 카나리 배포 모니터링 | `Skill("canary", ...)` |
| **benchmark** | 성능 기준선 비교 | `Skill("benchmark", ...)` |

### 워크플로우

```
사용자 → /av {자연어}
  → PM 대화 (AskUserQuestion) → PRD (bkit)
  → PL Plan/Design (bkit) → Agent Team 스폰
  → 구현 → gstack 테스트 → PL 검토 (bkit:gap-detector)
  → PM 승인 → Report (bkit) → Archive → 기억 저장
```

### 컴포넌트

| 유형 | 수량 | 경로 |
|------|------|------|
| Agents | 11 | `.claude/agents/` |
| Skills | 16 | `.claude/skills/` |
| Hooks | 8 | `.claude/hooks/` |
| Rules | 5 | `.claude/rules/` |

### 메모리 계층

| 계층 | 경로 | 범위 |
|------|------|------|
| L1 에이전트 | `.claude/agent-memory/{name}/MEMORY.md` | 해당 에이전트 전용 |
| L2 스킬 | `.claude/skills/{name}/MEMORY.md` | 해당 스킬 전용 |
| L4 글로벌 | `~/.claude/projects/{slug}/memory/MEMORY.md` | 전체 공유 |
