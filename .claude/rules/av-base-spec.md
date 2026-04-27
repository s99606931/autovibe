---
name: av-base-spec
autovibe: true
version: "2.0"
created: "2026-03-29"
group: base
paths:
  - ".claude/agents/**"
  - ".claude/skills/**"
  - ".claude/rules/**"
---

# AutoVibe Claude Code Spec (av-base-spec)

> 모든 av- 컴포넌트 중앙 규칙 인덱스.

## Quick Reference

- `av-` = AutoVibe 생태계 산출물 (Rule/Agent/Skill/Hook에만 적용)
- `autovibe: true` frontmatter 필수
- 네이밍: `av-{domain}-{name}` (kebab-case, 최대 4단어, 도메인 필수)
- 도메인: `vibe` (메타) | `base` (범용 필수) | `util` (범용 선택) | `{project}` (프로젝트 전용)
- 버전: `Major.Minor` 문자열 (e.g. `"1.0"`, `"2.1"`)
- 모든 생성은 `/av-vibe-forge`를 통해서만 (레지스트리 자동 등록)
- Agent는 `memory: project` 필드로 영구 메모리 자동 관리 (공식 스펙)
- Skill은 `context: fork` 필드로 격리 실행 가능 (공식 스펙)

## 조직 구조

| 역할 | 에이전트 | 모델 | 책임 |
|------|---------|------|------|
| **PM** | av-pm-coordinator | opus | 사용자 대화, PRD(bkit), 최종 승인 |
| **PL** | av-do-orchestrator | opus | Plan/Design(bkit), Agent Team 스폰, gstack 검증 |
| **Memory** | av-base-memory-keeper | sonnet | 프로젝트 기억 관리 |

## 생태계 3축

AutoVibe는 3개의 독립 플랫폼을 하나의 AI 개발 생명주기로 통합한다.

| 축 | 정체성 | 핵심 역할 |
|----|--------|----------|
| **Claude Code** | AI 런타임 엔진 | 에이전트 실행, 코드 생성, Hook 이벤트, 메모리 |
| **gstack** | Fast Headless Browser | 브라우저 E2E, 스크린샷, 인터랙션, 벤치마크 |
| **bkit** | Vibecoding Kit | PDCA 문서, Gap 분석, 코드 분석, 자동 개선 |

## 플러그인 라우팅

> **표기 원칙** (CC v2.1.63+): `Agent(...)` 사용. `Task(...)`는 별칭으로 동작하나 **신규 작성 금지**.

| 요청 유형 | 축 | 호출 |
|-----------|---|------|
| 에이전트 실행·코드 생성 | Claude Code | `Agent(...)` / `Read,Write,Edit` |
| 실행·테스트·배포·브라우저 | gstack | `Skill("gstack", ...)` |
| 문서 작성(PRD/Plan/Design/Report) | bkit | `Skill("bkit:pdca", ...)` |
| 코드 품질 분석 | bkit | `Agent("bkit:code-analyzer", ...)` |
| 설계-구현 검증 | bkit | `Agent("bkit:gap-detector", ...)` |

## Topic Index

| Topic | 파일 |
|-------|------|
| Frontmatter | `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` |
| Naming | `.claude/docs/av-claude-code-spec/topics/naming-rules.md` |
| Protocols | `.claude/docs/av-claude-code-spec/topics/protocols.md` |
| Audit | `.claude/docs/av-claude-code-spec/topics/audit-rules.md` |
| Memory First | `.claude/rules/av-base-memory-first.md` |
| Plugin Routing | `.claude/rules/av-base-plugin-routing.md` |
| Code Quality Gates | `.claude/rules/av-base-code-quality-gates.md` |
| Org Protocol | `.claude/rules/av-org-protocol.md` |

## Stats

- spec: v2.0 | created: 2026-03-29
- registry: `.claude/registry/components.json`
