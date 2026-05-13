---
name: av-base-plugin-routing
autovibe: true
version: "3.0"
created: "2026-03-29"
updated: "2026-05-13"
group: base
paths:
  - ".claude/agents/**"
  - ".claude/skills/**"
  - ".claude/rules/**"
---

# av-base-plugin-routing — 생태계 4축 플러그인 라우팅 규칙

> AutoVibe 생태계의 4축(Claude Code + gstack + bkit + GitNexus)이 상호 보완하여 AI 개발 생명주기를 완성한다.
> 에이전트/스킬이 각 플러그인을 호출하는 라우팅 규칙을 정의한다.
> **v3.0 변경 (2026-05-13)**: GitNexus(공유 코드 그래프 MCP)를 4축으로 승격. `av-base-codegraph` 게이트웨이 스킬로 캡슐화.
> **v2.0 변경**: `Task(...)` → `Agent(...)` 표기 통일, paths 스코프 추가, pdca-iterator 자동 트리거 명시

## 생태계 4축 정의

| 축 | 정체성 | 핵심 역할 | PDCA 매핑 |
|----|--------|----------|----------|
| **Claude Code** | Anthropic AI 런타임 엔진 | Agent Teams 실행, 코드 생성, Hook 이벤트, 메모리 | 전 단계 (실행 기반) |
| **gstack** | Fast Headless Browser | 페이지 탐색, E2E 테스트, 스크린샷, 인터랙션, 벤치마크 | Do·Check (시각적 검증) |
| **bkit** | Vibecoding Kit 플러그인 | PDCA 문서, Gap 분석, 코드 분석, QA 모니터링, 자동 개선 | Plan·Check·Act (품질 보증) |
| **GitNexus** | 공유 코드 그래프 MCP | 임팩트 분석, 컨텍스트 회수, 라우트/툴맵, 안전한 rename | Plan·Check (구조 분석) |

### 4축 상호 보완 원칙

1. **Claude Code가 생각하고 만든다** — AI 추론 + 코드 생성
2. **gstack이 보고 확인한다** — 브라우저 렌더링 + E2E 테스트
3. **bkit이 측정하고 개선한다** — Match Rate + 자동 반복
4. **GitNexus가 구조를 파악한다** — 코드 그래프 + 임팩트 + 컨텍스트
5. **av가 4축을 `/av {자연어}` 하나로 통합한다** — 사용자는 플러그인을 몰라도 됨

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

> **표기 원칙** (CC v2.1.63+): `Agent(...)` 사용. `Task(...)`는 별칭으로 동작하나 신규 작성 금지.

| 요청 의도 | bkit 호출 | 담당 | 트리거 |
|-----------|----------|------|--------|
| PRD/Plan 작성 | `Skill("bkit:pdca", "plan {feature}")` | PM → PL | 수동 |
| Design 작성 | `Skill("bkit:pdca", "design {feature}")` | PL | 수동 |
| Report 작성 | `Skill("bkit:pdca", "report {feature}")` | PL | PM 최종 승인 후 자동 |
| 코드 품질 분석 | `Agent("bkit:code-analyzer", ...)` | Auditor | 구현 완료 후 자동 |
| 설계-구현 갭 검증 | `Agent("bkit:gap-detector", ...)` | PL | PR 승인 게이트 자동 |
| 런타임 QA | `Agent("bkit:qa-monitor", ...)` | QA Agent | av-base-post-qa 호출 시 |
| 자동 개선 루프 | `Agent("bkit:pdca-iterator", ...)` | PL | gap < 90% 시 **자동 트리거** |
| Design 검증 | `Agent("bkit:design-validator", ...)` | Sync-Auditor | CLAUDE.md/docs 변경 후 자동 |

### pdca-iterator 자동 트리거 조건

```
PL 검증 프로토콜에서:
match_rate = Agent("bkit:gap-detector").result.match_rate
IF match_rate < 0.90:
  Agent("bkit:pdca-iterator", { target: 0.90, max_iterations: 2 })
  재측정 → 90% 미달 시 PM에 보고
```

### bkit 도메인 에이전트 사용 정책

bkit의 cto-lead, frontend-architect 등 도메인 에이전트는 av-base-* 에이전트와 책임이 중복된다.
**정책: av 에이전트가 우선. bkit 도메인 에이전트는 호출하지 않는다.**
단, 프로젝트 도메인 특화 에이전트 신설 시 bkit 에이전트 정의를 참고 패턴으로만 활용.

## GitNexus (코드 그래프) — 구조 분석 보강

> **단일 진입점**: 모든 av 컴포넌트는 `Skill("av-base-codegraph", "{op} {args}")` 경유.
> `mcp__gitnexus__*` 직접 호출 금지 (정책: 일관성·fallback·캐시 일원화).

| 요청 의도 | codegraph 호출 | 담당 | 트리거 |
|-----------|---------------|------|--------|
| 자연어 코드 검색 | `Skill("av-base-codegraph", "query {pattern}")` | memory-keeper, vibecoder | 수동/조회 시 |
| Cypher 쿼리 | `Skill("av-base-codegraph", "cypher {query}")` | auditor (Level 3) | 종합 감사 |
| 심볼/파일 컨텍스트 | `Skill("av-base-codegraph", "context {symbol}")` | memory-keeper, refactor-advisor | 학습 저장·리팩토링 |
| 변경 임팩트 분석 | `Skill("av-base-codegraph", "impact {file}")` | auditor, refactor-advisor, PL | 구현 직후 자동 |
| API 임팩트 분석 | `Skill("av-base-codegraph", "api-impact {endpoint}")` | PL | API 변경 시 자동 |
| 라우트 토폴로지 | `Skill("av-base-codegraph", "route-map [scope]")` | PL, doc-generator | Design 단계·다이어그램 |
| 툴/의존 맵 | `Skill("av-base-codegraph", "tool-map [scope]")` | vibecoder, doc-generator | 생태계 분석 |
| 안전한 rename | `Skill("av-base-codegraph", "rename {old} {new}")` | refactor-advisor | 리팩토링 요청 시 |
| 스키마 정합성 | `Skill("av-base-codegraph", "shape-check {schema}")` | auditor, sync-auditor | CLAUDE.md/스키마 변경 |
| 변경 노드 탐지 | `Skill("av-base-codegraph", "detect-changes [since]")` | sync-auditor | 동기화 점검 |
| 인덱스 재구성 | `Skill("av-base-codegraph", "sync [repo]")` | 시스템 routine | 주기/수동 |

### GitNexus 자동 트리거 조건

```
# 구현 완료 직후 (PL 종료 프로토콜에 포함)
1) impact = Skill("av-base-codegraph", "impact {changed_files}")
2) IF impact.high_risk_nodes 존재:
     Agent("av-base-auditor", { level: 2, focus: impact.high_risk_nodes })

# 리팩토링 권고 시 (refactor-advisor)
1) preview = Skill("av-base-codegraph", "rename {old} {new}")
2) preview.affected_files 보고 → 사용자 확인 게이트
```

### MCP 가용성 / fallback

| 상태 | 동작 |
|------|------|
| `mcp list` 에 `gitnexus … Connected` | 정상 — codegraph 스킬 사용 |
| 미가용 (compose down 등) | 호출 측이 `source: "fallback"` 결과 수신 → Grep/Glob 기반 추정 |
| 인덱스 stale (detect-changes 결과 큼) | `Skill("av-base-codegraph", "sync")` 권고 |

설치/가동: `wsl-setup/install-gitnexus.sh` → user-scope MCP 자동 등록.

## Task Lock (멀티 세션 충돌 방지)

> 여러 Claude Code 세션이 동일 작업을 동시에 수행하는 충돌 방지.
> 단일 진입점: `Skill("av-base-task-lock", ...)`. 정책: `.claude/rules/av-base-task-lock.md`.

| 요청 의도 | task-lock 호출 | 담당 | 트리거 |
|-----------|---------------|------|--------|
| 작업 시작 전 락 | `Skill("av-base-task-lock", "acquire {key} [ttl]")` | PM, PL, Agent Team Lead | PRD 확정·Agent Team 스폰 직전 |
| 작업 종료 시 해제 | `Skill("av-base-task-lock", "release {key}")` | PM, PL | Report 직후·SubagentStop |
| 활성 락 조회 | `Skill("av-base-task-lock", "list")` | 모든 av 에이전트 | 사전 확인 |
| TTL 갱신 | `Skill("av-base-task-lock", "heartbeat {key}")` | 장기 작업 owner | 4분 주기 |
| 만료 정리 | `Skill("av-base-task-lock", "prune")` | SessionStart 훅 | 세션 시작 시 자동 |

### Task Lock 자동 트리거 조건

```
# PM 시작 프로토콜 (PRD 확정 직후)
key = "feature:" + slug
acquire(key, ttl=600)   # 충돌 시 AskUserQuestion(대기/강제/취소)

# PL Agent Team 스폰 프로토콜
key = "domain:" + domain
acquire(key, ttl=1800)  # 장기 작업 — heartbeat 의무

# UserPromptSubmit 훅이 /av pm 패턴 감지 시 현재 활성 락을 컨텍스트로 주입
```

## Claude Code (AI 런타임) — av 실행 기반

| 요청 의도 | Claude Code 기능 | 담당 | 비고 |
|-----------|-----------------|------|------|
| 에이전트 실행 | `Agent("av-pm-coordinator", ...)` | av 게이트웨이 | initialPrompt 자동 실행 |
| Team 스폰 | Agent Teams API | PL | `isolation: worktree` 옵션 |
| 코드 생성 | Read, Write, Edit, Bash | Agent Team | — |
| 이벤트 처리 | Hook (UserPromptSubmit, PostToolUse, SessionStart) | 자동 | — |
| 영구 학습 | `memory: project` → `.claude/agent-memory/` | 에이전트 자동 | — |

## Claude Code 신규 도구 (CC v2.2+)

> 6차 PDCA(2026-05-13) — Claude Code 최신 버전과 av 생태계 동기화.

| 도구 | 용도 | 사용 패턴 | 담당 |
|------|------|----------|------|
| `SendMessage(to, message)` | 기존 에이전트 대화 지속 (Agent 재호출 비용 절감) | PL이 Agent Team 멤버에 추가 지시할 때 | PL |
| `TeamCreate / TeamDelete` | Agent Team 표준 관리 | PL의 5인 팀 스폰 표준화 | PL |
| `Monitor(job_id, until=...)` | 백그라운드 작업 이벤트 스트림 | run_in_background 짝 — sleep loop 금지 | PL, QA, iterate |
| `EnterWorktree / ExitWorktree` | 격리 작업 디렉토리 진입/이탈 | `isolation: worktree` 옵션 후 자동 진입 | Agent Team |
| `run_in_background` | Agent/Bash 비동기 실행 | 장기 실행 작업 (pdca-iterator, E2E) | iterate, post-qa |
| `ScheduleWakeup / CronCreate` | 자체 스케줄링 | 주기 점검 routine 등록 | 시스템 |

### Task 표기 — 별칭과 별개 도구 구분 (필수 부기)

⚠️ **혼동 주의**:
- `Agent(...)` — 에이전트 호출 (정식, CC v2.1.63+)
- `Task(...)` — Agent의 별칭. 동작은 동일하나 **신규 작성 금지**
- `TaskCreate / TaskList / TaskUpdate` — **별개의 todo 관리 도구**. 에이전트 스폰과 무관

### 신규 도구 사용 예시

```python
# PL이 5인 팀을 표준 스폰 (TeamCreate + isolation)
team = TeamCreate({
    "name": "cc-v22-team",
    "members": ["lead", "rules-editor", "frontmatter-auditor", "memory-bootstrap", "qa"],
    "isolation": "worktree"  # 파일 충돌 우려 시
})

# 장기 작업은 비동기 + 이벤트 스트림 관찰 (sleep loop 금지)
job_id = Agent("bkit:pdca-iterator", { ... }, { "run_in_background": True })
Monitor(job_id, until="completion")

# 추가 지시는 SendMessage로 컨텍스트 유지
SendMessage(team.members.lead, "rules 갱신 우선순위로 처리해줘")

# 작업 종료 시 정리
TeamDelete(team.id)
```

### 환경 의존성

위 도구는 Claude Code v2.2+ 환경에서 사용 가능. 미가용 시 fallback:
- `TeamCreate` → 개별 `Agent(...)` 호출로 5인 스폰
- `Monitor` → run_in_background 종료 콜백
- `SendMessage` → Agent 재호출 (컨텍스트 손실 감수)
- `EnterWorktree` → `git worktree add` Bash 호출
- `CronCreate` → `~/.claude/routines/{name}.json` 설정 파일

## 라우팅 원칙

1. 에이전트는 이 규칙에 따라 4축 플러그인을 직접 호출한다 (단, GitNexus는 codegraph 스킬 경유)
2. 사용자는 `/av {자연어}` 하나만 입력 — av가 최적 플러그인 자동 선택
3. PM/PL/Agent가 각자 역할에 따라 Claude Code/gstack/bkit/GitNexus를 호출
4. 플러그인 세부 명령어는 av 컴포넌트 내부에 캡슐화 (사용자 노출 최소화)
5. 4축 중 하나라도 빠지면 해당 PDCA 단계의 자동화 품질이 저하된다 (GitNexus 미가용 시 graceful fallback)
6. **Agent() > Task() 표기** — Task는 별칭으로 유효하나 신규 작성 시 Agent() 사용
7. **GitNexus 직접 호출 금지** — `mcp__gitnexus__*` 대신 `Skill("av-base-codegraph", ...)` 사용
