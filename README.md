# GIVERNY

An orchestration layer for Claude Code that prevents context blowout on complex tasks.

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

## Quick Start

```bash
# Copy .claude/ to your project root
cp -r .claude/ your-project/

# Start a session
/prime              # Load GIVERNY personality
/research auth flow # Map the codebase for a topic
/plan               # Decompose into atomic steps
/implement phase:1  # Execute one phase at a time
/commit             # Generate commit when done
```

## Commands

| Command | Purpose |
|---------|---------|
| `/prime` | Initialize GIVERNY for the session |
| `/research <topic>` | Map codebase, output to `thoughts/shared/research/` |
| `/plan` | Create atomic implementation plan from research |
| `/implement` | Execute plan phases via sandboxed subagents |
| `/quick <task>` | Skip workflow for trivial changes (≤2 files) |
| `/commit` | Generate commit message from completed work |
| `/handoff` | Create continuity doc when context is filling up |
| `/status` | Report current state |

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

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- A `thoughts/` directory (create manually or let commands create it)

## Configuration

Edit `.claude/commands/prime.md` to add project-specific context:

```xml
<project-context>
    Stack: Python/FastAPI backend, React frontend
    Key patterns: Repository pattern, dependency injection
    Off-limits: migrations/, generated/
</project-context>
```

---

Named after [Claude Monet's garden](https://en.wikipedia.org/wiki/Claude_Monet#Giverny) — where controlled chaos produces something coherent.
