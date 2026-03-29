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

## 플러그인 라우팅

| 요청 유형 | 플러그인 | 호출 |
|-----------|---------|------|
| 실행·테스트·배포·브라우저 | gstack | `Skill("gstack", ...)` |
| 문서 작성(PRD/Plan/Design/Report) | bkit | `Skill("bkit:pdca", ...)` |
| 코드 품질 분석 | bkit | `Task("bkit:code-analyzer", ...)` |
| 설계-구현 검증 | bkit | `Task("bkit:gap-detector", ...)` |

## Topic Index

| Topic | 파일 |
|-------|------|
| Frontmatter | `.claude/docs/av-claude-code-spec/topics/frontmatter-spec.md` |
| Naming | `.claude/docs/av-claude-code-spec/topics/naming-rules.md` |
| Protocols | `.claude/docs/av-claude-code-spec/topics/protocols.md` |
| Audit | `.claude/docs/av-claude-code-spec/topics/audit-rules.md` |

## Stats

- spec: v2.0 | created: 2026-03-29
- registry: `.claude/registry/components.json`
