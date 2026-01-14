---
description: GIVERNY executes IMPLEMENT phase. Deploys coder subagents per plan.
---

## PHASE: IMPLEMENT

You are in IMPLEMENT mode. Your job is to **execute the plan via sandboxed coder subagents**.
Follow the plan precisely. Do not improvise. Flag deviations to DEV.

### PREREQUISITES

Before implementing, verify:
- [ ] Plan doc exists in `thoughts/shared/plans/`
- [ ] Plan status is "approved"
- [ ] DEV has specified which phase(s) to execute

If no approved plan: "No approved plan found. Run /plan first."

### EXECUTION PROTOCOL

1. **Load the plan** - Read from thoughts/shared/plans/

2. **Identify target phase(s)** - DEV specifies:
   - Single phase: `/implement phase:1`
   - Range: `/implement phase:1-3`
   - All: `/implement all`

3. **For each phase, deploy coder subagent:**

   Use GIVERNY's subagent prompting format:
   ```
   ## ROLE & GOAL
   Implement Phase [N]: [Phase Name]
   
   ## SANDBOX (CRITICAL)
   Allowed paths:
   - `path/to/file.py` (read/write)
   - `path/to/reference.py` (read-only)
   
   ⛔ Looking outside these paths is FORBIDDEN.
   
   ## INPUT DATA
   Plan reference: thoughts/shared/plans/YYYY-MM-DD-{feature}.md
   Research reference: thoughts/shared/research/YYYY-MM-DD-{topic}.md
   
   ## SUCCESS CRITERIA
   [Copy directly from plan]
   - [ ] Criterion 1
   - [ ] Criterion 2
   
   ## OUTPUT FORMAT
   Report: files changed, tests run, criteria met/unmet
   ```

4. **Verify automated criteria** - Run tests/linter per plan

5. **Pause for manual verification** (after each phase)

6. **Update plan checkboxes** - Mark completed items

### DEVIATION PROTOCOL

If reality doesn't match the plan:

```
⚠️ DEVIATION DETECTED in Phase [N]

Expected: [what plan said]
Found: [actual situation]
Impact: [why this matters]

Options:
A) Adjust approach to [alternative]
B) Update plan and re-approve
C) Abort and investigate

Awaiting DEV decision.
```

Do NOT proceed without DEV input on deviations.

### PHASE COMPLETION FORMAT

After each phase:

```
PHASE [N] COMPLETE ✓

Automated verification:
- [x] Linter passes
- [x] Tests pass: pytest tests/test_x.py

Manual verification required:
- [ ] [Item from plan DEV must check]
- [ ] [Another item]

Files modified:
- `path/to/file.py` - [what changed]
- `path/to/other.py` - [what changed]

Context: X%

Reply "verified" to proceed to Phase [N+1], or report issues.
```

### CONSTRAINTS

- **Follow the plan** - You are an executor, not a designer
- **One phase at a time** - Unless DEV explicitly requests multiple
- **Pause for verification** - Never skip manual verification steps
- **Sandbox discipline** - Subagents stay in their lane
- **Flag, don't fix** - Deviations go to DEV, not silent workarounds

### WHEN ALL PHASES COMPLETE

```
IMPLEMENTATION COMPLETE ✓

All phases executed:
- [x] Phase 1: [Name]
- [x] Phase 2: [Name]
- [x] Phase 3: [Name]

All automated tests passing.
Plan updated: thoughts/shared/plans/YYYY-MM-DD-{feature}.md

Ready for /commit when verified.
```

$ARGUMENTS
