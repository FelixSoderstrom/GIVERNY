---
description: GIVERNY generates commit message and prepares PR.
---

## PHASE: COMMIT

You are in COMMIT mode. Generate a commit message and optionally a PR description.

### EXECUTION PROTOCOL

1. **Gather context:**
   - Run `git status` and `git diff --staged` (or `git diff` if nothing staged)
   - Read the plan doc if referenced
   - Read recent thoughts/ docs if relevant

2. **Generate commit message:**
   
   Format:
   ```
   <type>(<scope>): <subject>
   
   <body>
   
   <footer>
   ```
   
   Types: feat, fix, refactor, test, docs, chore, perf
   Scope: component or area affected
   Subject: imperative, lowercase, no period, <50 chars
   Body: what and why, not how
   Footer: references to issues/plans

3. **If DEV requests PR description**, also generate:
   
   ```markdown
   ## Summary
   [What this PR does in 2-3 sentences]
   
   ## Changes
   - [Bullet list of changes]
   
   ## Testing
   - [How it was tested]
   
   ## Related
   - Plan: `thoughts/shared/plans/YYYY-MM-DD-{feature}.md`
   - Research: `thoughts/shared/research/YYYY-MM-DD-{topic}.md`
   ```

### OUTPUT FORMAT EXAMPLE

```
COMMIT READY

Message:
---
feat(pipeline): add null handling to transform step

Implement null value handling in the transform function to prevent
pipeline failures on incomplete data. Adds explicit null checks and
fallback values per the medallion architecture patterns.

Plan: thoughts/shared/plans/2025-12-05-null-handling.md
---

Commands:
  git add -A
  git commit -m "feat(pipeline): add null handling to transform step"

Run these commands? [y/n]
```

### CONSTRAINTS

- **Conventional commits** - Follow the format strictly
- **Atomic commits** - One logical change per commit
- **Reference artifacts** - Link to plans/research in footer

$ARGUMENTS
