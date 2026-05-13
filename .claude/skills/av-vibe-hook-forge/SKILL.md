---
name: av-vibe-hook-forge
description: |
  Hook 셸 스크립트 생성 전담. 공식 이벤트 타입(SubagentStart/Stop, ConfigChange 등)을
  포함한 표준 훅 파일을 생성하고 settings.json에 등록한다.
autovibe: true
version: "1.1"
created: "2026-03-29"
updated: "2026-05-13"
group: vibe
tier: meta
argument-hint: "[event-type] [name]"
user-invocable: false
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
---

# av-vibe-hook-forge — 훅 생성 전담

## 생성 프로토콜

1. AskUserQuestion: 이벤트 타입, 훅 이름, 매처
2. `.claude/hooks/{name}.sh` 생성 (공통 헤더 포함)
3. `chmod +x` 실행 권한 부여
4. `.claude/settings.json` 훅 등록
5. components.json hooks 섹션에 등록

## 지원 공식 이벤트 (CC v2.2 카탈로그)

| 이벤트 | 트리거 시점 | 비고 |
|--------|-----------|------|
| `SessionStart` | 세션 시작 (매처: `startup` / `compact` / `resume`) | av-session-discovery / av-base-precompact |
| `SessionEnd` | 세션 종료 | 정리/요약 작업 |
| `UserPromptSubmit` | 사용자 프롬프트 제출 | av-prompt-sync-trigger |
| `PreToolUse` | 도구 호출 직전 | av-bash-guard / av-content-scanner |
| `PostToolUse` | 도구 호출 직후 | av-post-write-monitor |
| `SubagentStart` | 서브에이전트 시작 | av-agent-spawn-logger |
| `SubagentStop` | 서브에이전트 종료 | av-agent-complete-logger |
| `PreCompact` | 컴팩션 직전 (CC v2.2+) | MEMORY.md 자동 스냅샷 |
| `ConfigChange` | settings.json 변경 | av-config-watcher |
| `Notification` | 시스템 알림 | 사용자 UX |
| `Stop` | 작업 중단 | 정리 작업 |

### 기존 10개 훅 매핑 (registry diff)

| 훅 | hook-type | 매처 | 상태 |
|----|-----------|------|------|
| av-post-write-monitor | PostToolUse | Write/Edit | active |
| av-session-discovery | SessionStart | — | active |
| av-content-scanner | PreToolUse | Write/Edit | active |
| av-bash-guard | PreToolUse | Bash | active |
| av-base-precompact | SessionStart | `compact` | active (v2.2 PreCompact로 마이그레이션 권고) |
| av-agent-spawn-logger | SubagentStart | — | active |
| av-agent-complete-logger | SubagentStop | — | active |
| av-config-watcher | ConfigChange | — | active |
| av-plugin-tracker | SessionStart | `startup` | active |
| av-prompt-sync-trigger | UserPromptSubmit | — | active |

### v2.2 마이그레이션 주의

- `av-base-precompact`는 현재 `SessionStart matcher=compact`로 동작. CC v2.2+ 환경에서 `PreCompact` 이벤트가 정식 지원되면 마이그레이션 권고. 기존 매핑은 유지.
