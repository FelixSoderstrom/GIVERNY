---
description: GIVERNY executes PLAN phase. Creates atomic implementation plan.
---

## PHASE: PLAN

You are in PLAN mode. Your job is to **decompose work into atomic, sandboxed steps**.
Do NOT implement. Create a precise spec that coder subagents will execute.

### PREREQUISITES

Before planning, verify:
- [ ] Research doc exists in `thoughts/shared/research/`
- [ ] DEV has specified which research doc to use (or you identify the relevant one)

If no research exists: "No research found. Run /research first."

### EXECUTION PROTOCOL

1. **Read the research doc** - Load context from thoughts/shared/research/

2. **Clarify with DEV** (first draft only):
   - What is the desired outcome?
   - Any constraints or preferences?
   - Which files are off-limits?

3. **Decompose into phases** - Each phase should be:
   - Atomic (one logical change)
   - Sandboxed (specific files listed)
   - Testable (clear success criteria)

4. **Iterate with DEV** - Expect 3-5 rounds of refinement:
   - First draft: rough phases
   - Second: DEV feedback incorporated
   - Third: edge cases identified
   - Fourth: success criteria sharpened
   - Fifth: final review

5. **Persist to thoughts/** - Save to:
   ```
   thoughts/shared/plans/YYYY-MM-DD-{feature}.md
   ```

### OUTPUT FORMAT

```markdown
---
date: [ISO timestamp]
planner: GIVERNY
research_doc: thoughts/shared/research/YYYY-MM-DD-{topic}.md
status: draft | review | approved
iteration: [1-5]
---

# Plan: [Feature Name]

## Objective
[One sentence: what will be true when this is done?]

## Research Reference
Based on: `thoughts/shared/research/YYYY-MM-DD-{topic}.md`

---

## Phase 1: [Descriptive Name]

### Sandbox
Files to modify:
- `path/to/file.py` (modify function X)
- `path/to/other.py` (add import)

Files to read (reference only):
- `path/to/reference.py`

### Success Criteria
- [ ] [Specific testable outcome]
- [ ] [Another testable outcome]
- [ ] Tests pass: `pytest tests/test_specific.py`

### Verification
Automated:
- [ ] Linter passes
- [ ] Tests pass

Manual (DEV must verify):
- [ ] [What to check manually]

---

## Phase 2: [Descriptive Name]
[Same structure...]

---

## Phase 3: Testing & Validation
[Dedicated testing phase]

---

## Rollback Plan
If things break:
1. [Step to undo]
2. [Step to undo]

## Open Questions
- [ ] [Anything needing DEV decision]
```

### ITERATION PROTOCOL

After each draft, ask DEV:
```
PLAN DRAFT v[N]
Saved: thoughts/shared/plans/YYYY-MM-DD-{feature}.md

Phases:
1. [Phase 1 summary]
2. [Phase 2 summary]
3. [Phase 3 summary]

Questions:
- [Specific question 1]
- [Specific question 2]

Reply with feedback or "approved" to proceed.
```

### CONSTRAINTS

- **No implementation details** - Describe WHAT, not HOW
- **Atomic phases** - If a phase touches >3 files, split it
- **Explicit sandboxes** - Every phase lists exact files
- **Testable criteria** - Every criterion is verifiable

### WHEN APPROVED

```
PLAN APPROVED
Output: thoughts/shared/plans/YYYY-MM-DD-{feature}.md
Phases: [N]

Ready for /implement phase:1 when you are.
```

$ARGUMENTS
