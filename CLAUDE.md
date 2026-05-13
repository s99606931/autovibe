# AutoVibe (av) 프로젝트
> **CC v2.2+ (Opus 4.7 / 1M context / deferred tools)** | bkit v2.0.8 Dynamic | 6차 PDCA — CC 통합 (2026-05-13)

@.claude/rules/av-base-spec.md
@.claude/rules/av-base-plugin-routing.md
@.claude/rules/av-org-protocol.md
@.claude/rules/av-base-code-quality-gates.md

## AutoVibe 생태계

자기 성장 AI 개발 생태계. 자연어 → 최적 플러그인 자동 라우팅.

> 상세: `.claude/rules/av-base-spec.md` | 라우팅: `.claude/rules/av-base-plugin-routing.md` (v3.0 — 4축)
> 조직 프로토콜: `.claude/rules/av-org-protocol.md` | 레지스트리: `.claude/registry/components.json`

### 생태계 4축 (요약)

| 축 | 정체성 | PDCA 역할 |
|----|--------|-----------|
| **Claude Code** | AI 런타임 엔진 | 전 단계 — Agent 실행, 코드 생성 |
| **gstack** | Headless Browser | Do·Check — E2E·스크린샷·벤치마크 |
| **bkit** | Vibecoding Kit | Plan·Check·Act — PDCA·Gap 분석·자동 개선 |
| **GitNexus** | 공유 코드 그래프 MCP | Plan·Check — 임팩트·컨텍스트·라우트맵 (`av-base-codegraph` 경유) |

4축 상호 보완: Claude가 만들고 → gstack이 보고 → bkit이 측정·개선 → GitNexus가 구조를 파악. 단독 사용 불가.

### 핵심 스킬

| 스킬 | 역할 |
|------|------|
| `/av {자연어}` | 마스터 게이트웨이 — 자연어 → 최적 컴포넌트 |
| `/av-vibe-forge` | 컴포넌트 생성·관리 |
| `/av-pm start {feature}` | PM 인터페이스 → PRD |
| `/av-base-code-quality` | 코드 품질 게이트 |
| `/av-base-post-qa` | QA (gstack E2E + bkit:qa-monitor) |
| `/av-base-iterate` | 자동 개선 루프 (bkit:pdca-iterator) |
| `/av-base-codegraph` | GitNexus 코드 그래프 게이트웨이 (impact/context/route-map/rename) |
| `/av-base-task-lock` | 멀티 세션 작업 락 (acquire/release/status/list) |
| `/av-base-git-commit` | git 커밋 자동화 |

### 워크플로우

```
사용자 → /av {자연어}
  → PM 대화 (AskUserQuestion) → PRD (bkit:pdca plan)
  → PL Plan/Design (bkit) → Agent Team 스폰
  → 구현 → gstack 테스트 → PL 검토 (bkit:gap-detector)
  → match_rate < 90% 이면 자동 pdca-iterator 루프
  → PM 승인 → Report (bkit) → Memory Keeper 자동 저장
```

### 컴포넌트 인벤토리

| 유형 | 수량 | 경로 |
|------|-----:|------|
| Agents | 13 | `.claude/agents/` |
| Skills | 19 | `.claude/skills/` |
| Hooks | 12 | `.claude/hooks/` |
| Rules | 7 | `.claude/rules/` |

### 외부 플러그인

| 플러그인 | 역할 | 호출 |
|---------|------|------|
| **gstack** | 실행·테스트·배포 | `Skill("gstack", ...)` |
| **bkit** | 문서·코드 분석·갭 검증 | `Skill("bkit:pdca", ...)` / `Agent("bkit:*", ...)` |
| **GitNexus** | 공유 코드 그래프 MCP | `Skill("av-base-codegraph", ...)` (직접 `mcp__gitnexus__*` 금지) |
| **canary** | 카나리 배포 모니터링 | `Skill("canary", ...)` |
| **benchmark** | 성능 기준선 비교 | `Skill("benchmark", ...)` |

### 플러그인 호출 표기 원칙 (CC v2.1.63+)

`Agent(...)` 사용 — `Task(...)`는 별칭으로 유효하나 **신규 작성 금지**.

⚠️ **혼동 주의**: `TaskCreate / TaskList / TaskUpdate`는 todo 관리 도구로 **별개**. 에이전트 스폰과 무관하다.

### Claude Code 신규 도구 (CC v2.2+)

| 도구 | 용도 | 사용 컴포넌트 |
|------|------|-------------|
| `SendMessage(to, message)` | 기존 에이전트 대화 지속 (Agent 재호출 대신) | PL ↔ Agent Team |
| `TeamCreate / TeamDelete` | Agent Team 표준 관리 | PL (av-do-orchestrator) |
| `Monitor(job_id)` | 백그라운드 작업 이벤트 스트림 | run_in_background와 짝 |
| `EnterWorktree / ExitWorktree` | 격리 작업 디렉토리 (`isolation: worktree`) | PL Agent Team 스폰 |
| `run_in_background` | Agent/Bash 비동기 실행 | post-qa, iterate, 장기 작업 |
| `ScheduleWakeup / CronCreate` | 자체 스케줄링 | 주기 점검 routine |

> 상세 패턴: `.claude/rules/av-base-plugin-routing.md` §"Claude Code 신규 도구"

### Harness Engineering

Git 품질 게이트: `.githooks/pre-commit` (Gate 1~4) + `.githooks/pre-push` (Gate 5~7)
팀 온보딩: `bash scripts/install-hooks.sh`

### 메모리 계층 (3-tier)

| 계층 | 경로 | 범위 | 자동화 |
|------|------|------|--------|
| L1 에이전트 | `.claude/agent-memory/{name}/MEMORY.md` | 해당 에이전트 | `memory: project` |
| L2 스킬 | `.claude/skills/{name}/MEMORY.md` | 해당 스킬 | 수동 Read/Write |
| L4 글로벌 | `~/.claude/projects/{slug}/memory/MEMORY.md` | 전체 공유 | Claude Code auto-memory |

> 상세 정책: `.claude/rules/av-base-memory-first.md` | 자동 백업: precompact 훅 → `.claude/logs/snapshots/{ts}/`

### 품질 점수 (5차 PDCA, 2026-04-27)

| 지표 | 점수 | 상태 |
|------|-----:|------|
| bkit:gap-detector | **99.50%** | 사실상 만점 |
| bkit:code-analyzer | **100/100** | 만점 ⭐⭐ |
| 메모리 계층 / 외부 통합 | 100 / 99.5 | 자기진화 완성 |

### 주기 점검 routine

| Routine | 주기 | 트리거 | 비고 |
|---------|------|--------|------|
| 5차 PDCA 재측정 | 격주 화 09:00 KST | 2026-05-11 시작 | 기존 등록 |
| **CC 업데이트 동기화** | **월 1회 (매월 1일 09:00 KST)** | `/av "CC 최신 변경 카탈로그 확인하고 av 생태계 갭 분석"` | 본 6차 PDCA에서 신설 |

> 설정 파일: `~/.claude/routines/cc-update-sync.json` — `CronCreate` 가용 시 자동 등록, 미가용 시 본 라인이 표준 명세.

다음 cc-sync 측정: 2026-06-01 09:00 KST
