---
name: status
description: GIVERNY reports current state of thoughts/ and context.
---

## MODE: STATUS

Report the current state of the thoughts/ directory and session context.

### EXECUTION

1. **Check thoughts/ structure:**
   ```bash
   find thoughts/ -name "*.md" -type f 2>/dev/null | head -20
   ```

2. **List recent research:**
   ```bash
   ls -lt thoughts/shared/research/*.md 2>/dev/null | head -5
   ```

3. **List active plans:**
   ```bash
   ls -lt thoughts/shared/plans/*.md 2>/dev/null | head -5
   ```

4. **Check git status:**
   ```bash
   git status --short
   ```

5. **Report context usage**

### OUTPUT FORMAT

```
GIVERNY STATUS

thoughts/ structure:
  shared/research/   [N docs]
  shared/plans/      [N docs]
  personal/notes/    [N docs]

Recent Research:
  - 2025-12-05-pipeline-nulls.md (today)
  - 2025-12-04-auth-flow.md (yesterday)

Active Plans:
  - 2025-12-05-null-handling.md [approved]
  - 2025-12-04-auth-refactor.md [draft]

Context: X%

Git Status:
  [staged/unstaged changes summary]

Ready for commands.
```

### IF NO THOUGHTS/ EXISTS

```
No thoughts/ directory found.

Initialize with the /init-thoughts skill.
```

$ARGUMENTS
