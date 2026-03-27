# AutoVibe

> **AI-Native Self-Growing Development Ecosystem**
> Build your own AI agent ecosystem through conversation — not copy-paste.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-blue)](https://claude.ai/code)
[![bkit](https://img.shields.io/badge/bkit-Plugin_Required-green)](https://github.com/anthropics/claude-code)

---

## What is AutoVibe?

AutoVibe is a framework for building **self-growing AI agent ecosystems** on top of Claude Code.

Instead of copying files or running migration scripts, AutoVibe uses **PDCA-driven conversational growth**:
- You talk with Claude (via bkit's PDCA skill)
- Claude asks questions, understands your project
- Together you incrementally build an AI ecosystem tailored to your domain

```
Traditional: copy .claude/ files → import → hope it works
AutoVibe:   /pdca plan phase-0 → conversation → components created for YOUR project
```

---

## How It Works

AutoVibe provides 3 core documents that guide Claude Code + bkit to build your ecosystem:

| Document | Purpose |
|----------|---------|
| **PRD** | What is the av ecosystem & success criteria |
| **Plan** | Phase-by-phase PDCA execution plan (Phase 0~6) |
| **Design Spec** | Complete file format specs, templates & execution scenarios |

Claude Code reads these documents and — through conversation with you — builds the ecosystem **one PDCA phase at a time**.

---

## Prerequisites

1. **Claude Code CLI** v2.1.71+ — [Install](https://claude.ai/code)
2. **bkit plugin** — Claude Code plugin with PDCA skill
   ```bash
   # Install bkit plugin for Claude Code
   # See: guides/bkit-integration.md
   ```
3. **git** initialized project

---

## Quick Start

```bash
# 1. Clone AutoVibe docs
git clone https://github.com/{your-org}/autovibe.git
cp -r autovibe/docs your-project/docs/autovibe/

# 2. Open your project in Claude Code
cd your-project
claude

# 3. Start building your ecosystem (say this to Claude):
```

Tell Claude:
> "AutoVibe 생태계를 구축해줘. docs/autovibe/docs/ 폴더의 PRD, Plan, Design 문서를 참고해서 bkit PDCA로 시작해줘."

Or in English:
> "Help me build the AutoVibe ecosystem. Use the PRD, Plan, and Design documents in docs/autovibe/docs/ and start with bkit PDCA."

Claude will then:
1. Read the Design Spec
2. Ask you questions (project name, tech stack, domain groups)
3. Execute Phase 0: create `.claude/` directory structure
4. Continue Phase 1~6 through PDCA conversations

---

## Phase Overview

| Phase | Goal | Components |
|-------|------|-----------|
| **Phase 0** | Bootstrap infrastructure | `.claude/` structure, Registry, CLAUDE.md |
| **Phase 1** | Base Rules | 4 rules (spec, org-protocol, memory-first, mermaid-std) |
| **Phase 2** | Base Agents | 8 agents (auditor, optimizer, template, git, refactor, qa, sync, vibecoder) |
| **Phase 3** | Meta Skills / Forge | 6 skills (vibe-forge + 4 forge tools + portable-init) |
| **Phase 4** | Core Skills | 10 skills (av gateway, pm, code-quality, git-commit, sync, ...) |
| **Phase 5** | Hooks & Settings | 5 hooks (write-monitor, session-discovery, content-scanner, bash-guard, precompact) |
| **Phase 6** | Domain Expansion | Unlimited (conversation-driven domain agents & skills) |

---

## The av Ecosystem Components

Once built, your av ecosystem gives you:

### `/av {natural language}` — Master Gateway
```bash
/av run "implement user authentication backend"
# → Automatically routes to the right agent/skill

/av run "review code quality"
# → Triggers av-base-auditor Level 2

/av run "create a new payment domain agent"
# → /av-vibe-forge agent payment-lead
```

### `/av-pm start {feature}` — PM Interface
```
You: "I need a new order management feature"
Claude (as PM): Asks 3 rounds of questions → Creates PRD → Forms agent team → Parallel implementation
```

### `/av-vibe-forge {subcommand}` — Master Orchestrator
```bash
/av-vibe-forge skill my-domain-impl   # Create new skill
/av-vibe-forge agent my-domain-lead   # Create new agent
/av-vibe-forge health                 # Ecosystem health check (0-100 score)
/av-vibe-forge list                   # List all components
```

---

## Domain Expansion (Phase 6 — Infinite Growth)

After the base ecosystem is built, add domain-specific components through conversation:

```
You: "I need agents for e-commerce order management"

Claude executes:
  /av-pm start ecom-order-agents
  → PRD negotiation via AskUserQuestion
  → /av-vibe-forge agent ecom-order-lead --group ecom
  → /av-vibe-forge agent ecom-order-backend --group ecom
  → /av-vibe-forge skill ecom-order-impl --group ecom
  → Updates ROUTING_TABLE in av/SKILL.md

Result: /av run "process order refund" → ecom-order-lead automatically
```

---

## Tech Stack Compatibility

AutoVibe works with any tech stack. The Design Spec includes customization guides for:

| Stack | Build Tool | Lint/Quality |
|-------|-----------|--------------|
| NestJS + Next.js | pnpm turbo | Biome |
| FastAPI + React | uv + vite | Ruff + mypy |
| Django + React | pip + webpack | flake8 |
| Go + React | go build | golint |

---

## Document Structure

```
autovibe/
├── README.md                          # This file
├── LICENSE                            # MIT License
├── CONTRIBUTING.md                    # Contribution guide
├── docs/
│   ├── prd/
│   │   └── av-ecosystem-pdca-driven.prd.md    # Requirements & success criteria
│   ├── plan/
│   │   └── av-ecosystem-pdca-driven-*.md      # PDCA Phase plan
│   └── design/
│       └── av-ecosystem-design-spec.md         # Complete implementation spec
└── guides/
    ├── getting-started.md             # Step-by-step guide
    ├── bkit-integration.md            # bkit plugin setup
    └── cc-official-docs.md            # Claude Code official docs reference
```

---

## Core Principles

1. **Conversation-Driven**: Every component is created through dialogue, not scripts
2. **PDCA Cycle**: Plan → Design → Do → Check → Report for each phase
3. **Incremental Growth**: Start small (Phase 0~2), expand as needed (Phase 6+)
4. **Tech Stack Agnostic**: Works with any project stack via customization
5. **Self-Healing Memory**: Each agent/skill has its own MEMORY.md that improves over time

---

## The av- Naming Convention

All AutoVibe components follow strict naming:
```
av-{domain}-{name}
├── domain: base | vibe | util | {project-specific}
└── name: kebab-case, max 4 words

Examples:
  av-base-auditor       (base domain, auditor component)
  av-vibe-forge         (vibe domain, forge orchestrator)
  av-base-code-quality  (base domain, code quality skill)
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Key areas for contribution:
- Tech stack customization guides (Rails, Laravel, Spring Boot, etc.)
- Domain expansion templates
- Hook script improvements
- Translations

---

## License

MIT License — See [LICENSE](LICENSE)

---

## Acknowledgments

Built on top of:
- [Claude Code](https://claude.ai/code) by Anthropic
- [bkit](https://github.com/anthropics/claude-code) PDCA Plugin
- PDCA methodology (Plan-Do-Check-Act)
