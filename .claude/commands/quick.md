---
description: GIVERNY executes a small atomic task. Skips full workflow for simple changes.
---

## MODE: QUICK

For small, well-defined tasks that don't need the full RESEARCH → PLAN → IMPLEMENT cycle.

### WHEN TO USE

✅ Good for /quick:
- Bug fix with known location
- Add a log statement
- Rename a variable
- Update a config value
- Add a simple test

❌ Use full workflow instead:
- Touches >2 files
- Unclear where the change goes
- Requires understanding system architecture
- Could have side effects

### EXECUTION PROTOCOL

1. **Validate scope** - Is this actually quick?
   - If >2 files or unclear location → "This needs /research first."

2. **Deploy single coder subagent:**
   ```
   ## ROLE & GOAL
   [One sentence task description]
   
   ## SANDBOX (CRITICAL)
   - `path/to/file.py` (read/write)
   
   ⛔ No other files.
   
   ## SUCCESS CRITERIA
   - [ ] [What must be true]
   
   ## OUTPUT FORMAT
   Report: what changed, test result
   ```

3. **Verify** - Run relevant test or linter

4. **Report**

### OUTPUT FORMAT

```
QUICK TASK COMPLETE ✓

Changed: `path/to/file.py`
- [What was modified]

Verified: [test/linter result]

Context: X%
```

### CONSTRAINTS

- **No research docs** - If you need research, this isn't quick
- **No plans** - If you need a plan, this isn't quick
- **Single subagent** - One file, one agent
- **Fast feedback** - Complete in <2 minutes

$ARGUMENTS
