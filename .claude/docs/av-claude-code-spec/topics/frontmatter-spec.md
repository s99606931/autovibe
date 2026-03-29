# Frontmatter Spec — av- 컴포넌트 유형별 필수/선택 필드 (공식 스펙 기반)

## Agent (`.claude/agents/av-*.md`)

**공식 필수**: name, description
**공식 권장**: tools, disallowedTools, model, permissionMode, maxTurns, memory, background, effort, isolation, skills, initialPrompt
**av 필수**: autovibe, version, created, group

## Skill (`.claude/skills/av-*/SKILL.md`)

**공식 필수**: name, description
**공식 권장**: argument-hint, user-invocable, disable-model-invocation, allowed-tools, context, agent, model, effort, paths, hooks, shell
**문자열 치환**: $ARGUMENTS, $ARGUMENTS[N], $N, ${CLAUDE_SESSION_ID}, ${CLAUDE_SKILL_DIR}, !`command`
**Supporting Files**: reference.md, examples.md (SKILL.md와 같은 디렉토리)
**av 필수**: autovibe, version, created, group

## Hook (`.claude/hooks/av-*.sh`)

**공식 이벤트**: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, Stop, SubagentStart, SubagentStop, ConfigChange, FileChanged, CwdChanged
**공식 핸들러 타입**: command, http, prompt, agent
**공식 매처**: 도구명, startup|resume|clear|compact, 에이전트타입명 등
**공식 조건**: if (permission rule syntax)
**종료코드**: 0=허용, 2=차단(stderr->Claude), 기타=허용
셸 스크립트 주석으로 메타데이터: # name, autovibe, version, created, hook-type, trigger-tools, description

## Rule (`.claude/rules/av-*.md`)

**공식 필수**: (없음 — 마크다운 파일만 있으면 됨)
**공식 권장**: paths (배열 — 지연 로딩 경로 패턴)
**av 필수**: name, autovibe, version, created, group, paths
