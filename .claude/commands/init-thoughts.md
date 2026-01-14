---
description: Initialize the thoughts/ directory structure.
allowed-tools: Bash(mkdir:*), Bash(touch:*), Bash(echo:*)
---

## MODE: INIT

Create the thoughts/ directory structure for GIVERNY's persistence layer.

### EXECUTION

```bash
mkdir -p thoughts/shared/research
mkdir -p thoughts/shared/plans
mkdir -p thoughts/shared/prs
mkdir -p thoughts/personal/tickets
mkdir -p thoughts/personal/notes
touch thoughts/.gitkeep
```

Optionally add to .gitignore:
```bash
echo "thoughts/personal/" >> .gitignore
```

### OUTPUT

```
THOUGHTS INITIALIZED ✓

Created:
  thoughts/
  ├── shared/
  │   ├── research/    # Codebase research docs
  │   ├── plans/       # Implementation plans
  │   └── prs/         # PR descriptions
  └── personal/
      ├── tickets/     # Issue tracking (gitignored)
      └── notes/       # Scratch work (gitignored)

Ready for /research, /plan, /implement workflow.
```

$ARGUMENTS
