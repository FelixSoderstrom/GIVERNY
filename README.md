# GIVERNY

An orchestration layer for AI coding assistants that prevents context blowout on complex tasks. Supports **Claude Code**, **GitHub Copilot**, and **Cursor**.

## The Problem

AI coding assistants hit context limits on anything non-trivial. The typical failure mode: agent reads too many files "to understand the codebase," runs out of context mid-implementation, loses track of what it was doing.

## The Solution

GIVERNY enforces a phased workflow where each phase produces artifacts that the next phase reads. Context stays lean. Work persists between sessions.

```
/research  →  /plan  →  /implement  →  /commit
     ↓            ↓           ↓
  thoughts/   thoughts/   thoughts/
  research/   plans/      (updates)
```

The orchestrator (GIVERNY) never writes code. It decomposes tasks into atomic, sandboxed subagent calls with explicit file boundaries. Subagents do the work. Orchestrator verifies and routes.

## Installation

Run the interactive installer from your target project directory:

```bash
# Clone GIVERNY
git clone https://github.com/Wrong-o/GIVERNY.git

# Run installer from your project
cd your-project/
bash /path/to/GIVERNY/install.sh
```

The installer will prompt you for:

1. **Target** — Claude Code, GitHub Copilot, Cursor, or All
2. **Scope** — Global (all projects) or repo-specific (current directory)
3. **Git skills** — Azure DevOps, GitHub, or None

### What gets installed

| Target | Agents | Skills/Commands | Instructions |
|--------|--------|-----------------|--------------|
| Claude Code | `.claude/agents/` | `.claude/commands/` | `CLAUDE.md` |
| GitHub Copilot | `.github/agents/` | `.github/skills/` | `.github/copilot-instructions.md` |
| Cursor | `.cursor/agents/` | `.cursor/skills/` | `.cursor/rules/giverny.mdc` |

All targets also create the `thoughts/` directory structure.

### Global vs repo-specific

- **Repo-specific** installs everything into the current directory — agents, skills, instructions, and thoughts/
- **Global** installs agents and skills to `~/.<tool>/` so they're available across all projects. Instructions must be added per-project (or via Cursor Settings UI for Cursor)

## Quick Start

```bash
# After installation, start a session
/research auth flow # Map the codebase for a topic
/plan               # Decompose into atomic steps
/implement phase:1  # Execute one phase at a time
/commit             # Generate commit when done
```

## Commands

| Command | Purpose |
|---------|---------|
| `/research <topic>` | Map codebase, output to `thoughts/shared/research/` |
| `/plan` | Create atomic implementation plan from research |
| `/implement` | Execute plan phases via sandboxed subagents |
| `/quick <task>` | Skip workflow for trivial changes (≤2 files) |
| `/commit` | Generate commit message from completed work |
| `/handoff` | Create continuity doc when context is filling up |
| `/status` | Report current state |
| `/re-anchor` | Re-anchor session as GIVERNY orchestrator |
| `/init-thoughts` | Initialize the `thoughts/` directory structure |

## Directory Structure

```
thoughts/
├── shared/
│   ├── research/    # Codebase analysis docs
│   ├── plans/       # Approved implementation plans
│   └── prs/         # PR descriptions
└── personal/
    ├── tickets/     # Issue tracking
    └── notes/       # Handoffs, scratch work
```

All docs use `YYYY-MM-DD-description.md` naming. Git-tracked by default.

## Subagents

GIVERNY dispatches these specialized agents:

- **codebase-locator** — Find where code lives (read-only)
- **codebase-analyzer** — Understand how code works (read-only)
- **coder** — Modify files within explicit sandbox
- **troubleshooter** — Debug from error logs (read-only)
- **websearcher** — External documentation lookup

Every subagent call includes:
- Explicit file sandbox (what they can touch)
- Success criteria (what must be true when done)
- No implementation details (what, not how)

## Why This Works

1. **Context economy** — Orchestrator stays under 60% context. Heavy lifting happens in disposable subagent calls.

2. **Artifacts over memory** — Research and plans persist to disk. Next phase reads files, not conversation history.

3. **Atomic decomposition** — No "implement the feature" calls. Each subagent gets one file, one task, clear boundaries.

4. **Human checkpoints** — Plans require approval. Implementation pauses for verification. Deviations flag, don't fix.

## Requirements

- One or more of: [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [GitHub Copilot](https://github.com/features/copilot), or [Cursor](https://cursor.com)
- A `thoughts/` directory (the installer creates this for you)

## Configuration

Edit `CLAUDE.md` to add specific context:

```xml
<project-context>
    Stack: Python/FastAPI backend, React frontend
    Key patterns: Repository pattern, dependency injection
    Off-limits: migrations/, generated/
</project-context>
```

---

Named after [Claude Monet's garden](https://en.wikipedia.org/wiki/Claude_Monet#Giverny) — where controlled chaos produces something coherent.
