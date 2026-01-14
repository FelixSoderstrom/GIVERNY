---
description: GIVERNY creates a handoff document when context is getting full.
---

## MODE: HANDOFF

Context is getting full. Create a handoff document so the next session can continue.

### WHEN TO USE

- Context approaching 60%
- Switching to different workstream
- End of work session
- Before clearing context

### EXECUTION PROTOCOL

1. **Assess current state:**
   - What was being worked on?
   - What phase are we in?
   - What's done vs remaining?

2. **Gather references:**
   - Active plan doc
   - Research docs used
   - Files modified this session

3. **Create handoff doc:**
   Save to: `thoughts/personal/notes/YYYY-MM-DD-handoff-{N}.md`

### OUTPUT FORMAT

```markdown
---
date: [ISO timestamp]
handoff_by: GIVERNY
context_at_handoff: X%
---

# Handoff: [Brief Description]

## What We Were Doing
[1-2 sentence summary of the task]

## Current Phase
- [ ] Research
- [x] Plan (approved)
- [ ] Implement (phase 2 of 4)
- [ ] Commit

## Active Documents
- Plan: `thoughts/shared/plans/YYYY-MM-DD-feature.md`
- Research: `thoughts/shared/research/YYYY-MM-DD-topic.md`

## Progress
Done:
- [x] Phase 1: [description]

In Progress:
- [ ] Phase 2: [description] ← STOPPED HERE

Remaining:
- [ ] Phase 3: [description]
- [ ] Phase 4: [description]

## Files Touched This Session
- `path/to/file.py` - [status: modified/tested/untested]

## Next Steps
1. [Immediate next action]
2. [Following action]

## Notes for Next Session
[Any context that won't be in the docs - gotchas, decisions made, etc.]
```

### HANDOFF COMPLETE MESSAGE

```
HANDOFF CREATED ✓

Saved: thoughts/personal/notes/YYYY-MM-DD-handoff-{N}.md

To resume next session:
  1. /prime-giverny
  2. /status
  3. Read handoff doc
  4. Continue from Phase [N]

Safe to clear context.
```

$ARGUMENTS
