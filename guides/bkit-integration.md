# bkit Plugin Integration Guide

> AutoVibe requires the bkit plugin for Claude Code to enable the PDCA skill.

## What is bkit?

bkit (Vibecoding Kit) is a Claude Code plugin that provides:
- `/pdca` skill — Plan-Do-Check-Act project management
- Agent team orchestration
- Quality gates (G1~G5)
- Memory management across sessions

## Installation

### Method 1: Claude Code Plugin Manager

```bash
# In Claude Code terminal
/plugin install bkit
```

### Method 2: Manual Installation

Check the official bkit documentation for the latest installation method.

## Verifying Installation

After installation, open Claude Code and check:
```
/bkit
```

You should see bkit's command menu. Then verify PDCA skill:
```
/pdca status
```

Expected: PDCA status dashboard appears.

## Key bkit Commands Used by AutoVibe

| Command | AutoVibe Usage |
|---------|---------------|
| `/pdca plan {feature}` | Plan each Phase (Phase 0~6) |
| `/pdca design {feature}` | Design detailed implementation |
| `/pdca do` | Execute implementation |
| `/pdca check` | Verify completion (G1~G5 gates) |
| `/pdca report {feature}` | Generate completion report |
| `/pdca status` | Check current PDCA progress |

## PDCA Workflow in AutoVibe

```
User: "Phase 1 Base Rules 구축해줘"

Claude internally runs:
  /pdca plan av-ecosystem-p1-rules
    → Reads Design Spec Phase 1 section
    → Creates PDCA plan document

  /pdca design av-ecosystem-p1-rules
    → References av-ecosystem-design-spec.md §3
    → Designs 4 rule files

  [Implementation]
    → Creates .claude/rules/av-base-spec.md
    → Creates .claude/rules/av-org-protocol.md
    → Creates .claude/rules/av-base-memory-first.md
    → Creates .claude/rules/av-util-mermaid-std.md
    → Updates components.json

  /pdca check
    → G1: File format check (autovibe:true frontmatter)
    → G2: Registry sync check
    → G3: (security — N/A for rule files)

  /pdca report av-ecosystem-p1-rules
    → Summary: 4 rules created, registry updated
```

## Quality Gates in AutoVibe

bkit's PDCA includes quality gates that AutoVibe uses:

| Gate | AutoVibe Check |
|------|---------------|
| G1 Code Quality | Component frontmatter validity + registry sync |
| G2 Match Rate | Design spec → actual file correspondence (≥90%) |
| G3 Security | No hardcoded secrets, proper permissions |
| G4 PL Review | (for team mode) Lead agent review |
| G5 PM Approval | (for team mode) PM final approval |

## Team Mode (Phase 6 Advanced)

When building domain agents in Phase 6, bkit's team mode enables:

```
/av-pm start {domain}-agents
  → bkit coordinates:
    Lead agent (domain analysis)
    Backend agent (API implementation)
    Frontend agent (UI implementation)
  → Parallel execution with isolation:worktree
  → Quality gates → PM approval → Archive
```

## Configuration

After bkit is installed, AutoVibe uses this bkit configuration in `.claude/settings.json`:

```json
{
  "plugins": {
    "bkit": {
      "pdca": {
        "docs_path": "docs/autovibe",
        "active_path": "docs/pdca/active",
        "archived_path": "docs/pdca/archived"
      }
    }
  }
}
```

## Troubleshooting

### `/pdca` command not found
Reinstall bkit plugin or restart Claude Code session.

### PDCA document not created
Ensure `docs/pdca/active/` directory exists:
```bash
mkdir -p docs/pdca/{active,archived}
```

### Team mode agents not spawning
Requires Claude Code v2.1.71+ with `isolation: "worktree"` support:
```bash
claude --version  # Check version
```
