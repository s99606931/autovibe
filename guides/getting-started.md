# Getting Started with AutoVibe

> Build your AI agent ecosystem in 6 phases through PDCA conversations.

## Prerequisites

Before starting, ensure you have:

1. **Claude Code CLI** v2.1.71 or later
   ```bash
   claude --version
   # Should show: 2.1.71 or higher
   ```

2. **bkit plugin** installed in Claude Code
   - bkit provides the `/pdca` skill required for the PDCA-driven approach
   - See [bkit-integration.md](bkit-integration.md) for installation

3. **git initialized project**
   ```bash
   git init your-project
   cd your-project
   ```

4. **AutoVibe docs** copied to your project
   ```bash
   git clone https://github.com/{your-org}/autovibe.git /tmp/autovibe
   mkdir -p docs/autovibe
   cp -r /tmp/autovibe/docs/* docs/autovibe/
   ```

---

## Step-by-Step Guide

### Step 1: Open Claude Code in your project

```bash
cd your-project
claude
```

### Step 2: Start Phase 0 — Bootstrap Infrastructure

Say to Claude:
```
docs/autovibe/design/av-ecosystem-design-spec.md 를 참고해서
bkit PDCA로 AutoVibe Phase 0 기반 인프라를 구축해줘
```

Or in English:
```
Please read docs/autovibe/design/av-ecosystem-design-spec.md and
use bkit PDCA to build the AutoVibe Phase 0 bootstrap infrastructure.
```

Claude will:
1. Run `/pdca plan av-ecosystem-p0-bootstrap`
2. Ask you questions:
   - "What is your project name?"
   - "What tech stack are you using?"
   - "What are your domain groups?"
   - "What is your source root path?"
3. Create the `.claude/` directory structure
4. Initialize `components.json` registry
5. Add AutoVibe section to `CLAUDE.md`

### Step 3: Continue with Phase 1 — Base Rules

After Phase 0 completes:
```
Phase 0 완료. Phase 1 Base Rules로 진행해줘
```

Or:
```
Phase 0 complete. Continue with Phase 1 Base Rules.
```

Claude creates 4 rule files:
- `.claude/rules/av-base-spec.md`
- `.claude/rules/av-org-protocol.md`
- `.claude/rules/av-base-memory-first.md`
- `.claude/rules/av-util-mermaid-std.md`

### Step 4: Phase 2 — Base Agents

```
Phase 2 Base Agents 진행해줘
```

8 agents created:
- `av-base-auditor` — code quality validator
- `av-base-optimizer` — ecosystem optimizer
- `av-base-template` — template scaffolding
- `av-base-git-committer` — Conventional Commits
- `av-base-refactor-advisor` — refactoring advisor
- `av-base-qa-reviewer` — QA reviewer
- `av-base-sync-auditor` — CLAUDE.md sync validator
- `av-vibe-vibecoder` — ecosystem gap detector

### Step 5: Phase 3 — Meta Skills (Forge)

6 forge tools created — these enable you to create MORE components:
- `av-vibe-forge` — master orchestrator (14 subcommands)
- `av-vibe-skill-forge` — creates new skills
- `av-vibe-agent-forge` — creates new agents
- `av-vibe-hook-forge` — creates hook scripts
- `av-vibe-rule-forge` — creates rule files
- `av-vibe-portable-init` — project initialization

### Step 6: Phase 4 — Core Skills

10 workflow automation skills:
- `/av` — master gateway (natural language routing)
- `/av-pm` — PM interface (PRD → team formation)
- `/av-base-code-quality` — lint + typecheck + build
- `/av-base-git-commit` — git commit automation
- `/av-base-sync` — CLAUDE.md auto-update
- etc.

### Step 7: Phase 5 — Hooks

5 hook scripts registered in `.claude/settings.json`:
- Write/Edit monitor
- Session discovery
- Content scanner
- Bash guard
- PreCompact initializer

### Verification

After all phases complete:
```
/av-vibe-forge health
```

Expected output:
```
════════════════════════════════
AutoVibe 생태계 건강도: 95/100
════════════════════════════════
✅ OK: 33개
⚠️ STALE: 0개
❌ MISSING: 0개
════════════════════════════════
```

---

## Phase 6: Domain Expansion (Ongoing)

Once the base ecosystem is ready, expand it through conversation:

```
나는 [도메인명] 도메인 전담 에이전트가 필요해
```

Example:
```
이커머스 주문 관리 도메인을 위한 에이전트가 필요해

→ Claude:
  /av-pm start ecom-order-agents
  /av-vibe-forge agent ecom-order-lead --group ecom
  /av-vibe-forge agent ecom-order-backend --group ecom
  /av-vibe-forge skill ecom-order-impl --group ecom
  → ROUTING_TABLE 업데이트
```

After that:
```
/av run "주문 환불 처리 API 구현"
→ Automatically routes to ecom-order-lead → ecom-order-backend
```

---

## Common Commands After Setup

| Command | Description |
|---------|-------------|
| `/av {natural language}` | Smart routing gateway |
| `/av-pm start {feature}` | Start new feature with PM conversation |
| `/av-vibe-forge health` | Ecosystem health check |
| `/av-vibe-forge skill {name}` | Create new skill |
| `/av-vibe-forge agent {name}` | Create new agent |
| `/av-base-code-quality` | Run code quality checks |
| `/av-base-git-commit` | Auto-generate commit message |
| `/av-base-sync` | Sync CLAUDE.md |

---

## Troubleshooting

### `.claude/` directory not created
Make sure you're running Claude Code from your project root:
```bash
pwd  # Should show your project root
claude
```

### bkit PDCA skill not found
Install the bkit plugin first. See [bkit-integration.md](bkit-integration.md).

### Phase failed mid-way
Check the PDCA document at `docs/pdca/active/` for progress:
```
/pdca status
```

Resume from where it stopped by telling Claude which phase to continue.

### components.json not updating
After creating components manually, ask Claude to update the registry:
```
components.json 레지스트리를 현재 .claude/ 폴더 기준으로 동기화해줘
```
