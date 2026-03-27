# Claude Code Official Documentation Reference

> This guide maps AutoVibe concepts to Claude Code's official features.
> Always refer to the latest official Claude Code documentation when implementing.

## Official Documentation Sources

| Resource | URL / Location |
|----------|---------------|
| Claude Code CLI Docs | `claude docs` (in terminal) |
| Claude Code Hooks | Settings → Hooks section |
| Agent Tool Spec | Built-in `/help agent` |
| Skill (Slash Command) Spec | `.claude/skills/` format |
| MCP Integration | `.mcp.json` format |

## Key Claude Code Features Used by AutoVibe

### 1. Sub-Agents (Agent Tool)

AutoVibe's av-* agents use Claude Code's Agent tool:

```markdown
# Official Spec (as of CC v2.1.81)
Agent(
  subagent_type: "av-base-auditor",  # Agent file name
  prompt: "Level 2 audit of {files}",
  isolation: "worktree",              # Optional: git worktree isolation
  effort: "high",                     # Optional: effort level
  run_in_background: false           # Optional: background execution
)
```

**Always check current CC docs for latest Agent parameters.**

### 2. Slash Commands (Skills)

AutoVibe's av-* skills use Claude Code's slash command system:

```yaml
# SKILL.md frontmatter (as of CC v2.1.81)
---
name: av-{skill-name}
description: |
  Skill description shown in autocomplete
argument-hint: "<subcommand> [args]"
user-invocable: true
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task, Agent]
---
```

**Check CC docs for the current list of available tools.**

### 3. Hooks

AutoVibe registers hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [...],   // After Write, Edit, Bash, etc.
    "PreToolUse": [...],    // Before Write, Edit, Bash, etc.
    "SessionStart": [...]   // When Claude Code session starts
  }
}
```

**Official CC hook events as of v2.1.81:**
- `SessionStart` — Session initialization
- `PreToolUse` — Before any tool
- `PostToolUse` — After any tool
- `PreCompact` — Before context compaction
- `Stop` — Session end

**Always verify supported hook events with current CC docs.**

### 4. Permissions (settings.json)

```json
{
  "permissions": {
    "allow": [
      "Bash(chmod +x .claude/hooks/*.sh)",
      "Bash(jq *)",
      "Bash(git log*)",
      "Write(.claude/**)"
    ],
    "deny": []
  }
}
```

### 5. Memory System

AutoVibe uses Claude Code's auto-memory:
```
~/.claude/projects/{project-slug}/memory/MEMORY.md
```

This is separate from bkit's memory system (`.bkit/state/memory.json`).

### 6. isolation: "worktree" (CC v2.1.79+)

Used in Phase 6 team mode for parallel agent execution:
```markdown
Agent("av-backend-agent", isolation: "worktree")  # Isolated git worktree
Agent("av-frontend-agent", isolation: "worktree") # Separate worktree
# Both run in parallel without file conflicts
```

---

## Version Compatibility Matrix

| AutoVibe Phase | Min CC Version | Key Feature |
|----------------|---------------|-------------|
| Phase 0~5 | v2.1.0 | Basic Agent + Hooks |
| Phase 6 (team mode) | v2.1.71 | isolation:worktree |
| Advanced hooks | v2.1.79+ | PreCompact + Stop events |

---

## Updating AutoVibe for New CC Versions

When Claude Code releases a new version:

1. Check release notes: `claude update` or official changelog
2. Identify new features relevant to AutoVibe
3. Update Design Spec to leverage new capabilities
4. Submit PR to AutoVibe repository

### Key areas to watch in CC updates:

- New hook events
- Agent tool new parameters (effort, isolation, etc.)
- Skill (SKILL.md) frontmatter changes
- New built-in tools
- Permission system changes

---

## Agent Frontmatter — Always Verify with CC Docs

```yaml
---
name: av-{name}              # Required
description: |               # Required — shown in agent autocomplete
  Role description
autovibe: true               # AutoVibe marker (not CC standard)
version: "1.0"               # AutoVibe versioning (not CC standard)
tools: [Read, Glob, Grep]    # Required — tools this agent can use
model: sonnet                # Required — sonnet|haiku|opus
scope: ".claude/**"          # Required — file access scope
# CC v2.1.80+ optional fields:
effort: medium               # low|medium|high|max
isolation: "worktree"        # Isolated git worktree
background: false            # Background task
---
```

**The fields marked as "Required" follow CC's official spec.**
**Fields marked "AutoVibe marker" are AutoVibe-specific metadata.**

---

## Skill Frontmatter — Always Verify with CC Docs

```yaml
---
name: av-{name}              # Required — slash command name
description: |               # Required — shown in /help and autocomplete
  Description
argument-hint: "<args>"      # Required — usage hint
user-invocable: true         # Required — can user call this directly?
allowed-tools: [...]         # Required — allowed tools for this skill
---
```

---

## Resources for Staying Current

```bash
# View Claude Code built-in help
/help

# View available tools
/help tools

# View slash command (skill) format
/help skills

# Check current CC version
claude --version

# Update CC to latest
claude update
```

Always cross-reference the AutoVibe Design Spec with current Claude Code documentation
before implementing. If there's a conflict, **CC official docs take precedence**.
