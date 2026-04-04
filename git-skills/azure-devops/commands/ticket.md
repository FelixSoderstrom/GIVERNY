---
description: Activates TICKET mode, GIVERNY writes a ticket to the board. Manually invoked by DEV.
arguments: ["Bug/feature/fix description. Free text or file path"]
---

## CREATING NEW TICKETS

You are in TICKET mode. Your job is to **produce a structured ticket** ready for a backlog.
Do NOT implement. Do NOT plan. Only produce the ticket document.

### EXECUTION PROTOCOL

1. Parse DEV input - What problem is DEV describing? Extract:
   - The symptom or gap (Problem)
   - The proposed fix or feature (Solution)
   - Any files, constraints, or caveats mentioned (References)
   - What "done" looks like (Acceptance Criteria)

2. Gather context if needed:
   - If DEV references existing research, read from `thoughts/shared/research/`
   - If DEV references a plan, read from `thoughts/shared/plans/`
   - Deploy `codebase-locator` subagents to find exact file:line references when DEV gives vague pointers
   - Deploy `codebase-analyzer` subagents to confirm data flow or behavior when the problem description is ambiguous

3. Draft and persist - Use format below and save to `thoughts/personal/tickets/YYYY-MM-DD-{ticket-title}.md`

4. Iterate

5. **This step is blocked until DEV approves draft** - Invoke `create-new-ticket` skill for more info.

### OUTPUT FORMAT

```markdown
---
date: [ISO timestamp]
author: GIVERNY
status: draft
---

# Problem
[Clear description of the bug/repro, gap, or need. Include error messages, observed behavior, or user impact. Be specific — no vague "it doesn't work".]

# Solution
[Concise description of what should be built or changed. Describe the WHAT, not the HOW. Implementation details belong in a plan, not here.]

# References
- `path/to/file.py:123` - [why it's relevant]
- `path/to/other.py:45` - [why it's relevant]
- [Any external docs, caveats, constraints, or prior research/plan docs]

# Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
```

### ITERATION PROTOCOL

After drafting, present to DEV:
```
TICKET DRAFT
Saved: [path-to-ticket]

Problem: [one-line summary]
Solution: [one-line summary]
Criteria: [N] items

Reply with feedback or "approved" to finalize.
```

### CONSTRAINTS

- **No implementation details** - Describe outcomes, not code
- **Specific references** - Always include file:line when referencing code, never vague descriptions
- **Testable criteria** - Every acceptance criterion must be objectively verifiable
- **One ticket = one concern** - If DEV describes multiple problems, split into separate tickets
- **Markdown format** - Use codeblocks, headers/subheaders, bold, italics, etc for human reability

### WHEN APPROVED

Update the frontmatter status to `approved` and report:
```
TICKET APPROVED
Output: [path-to-ticket]

Uploading ticket to board..
```

### POST SCRIPT-EXECUTION

1. Parse the JSON output
2. Extract the `id` field
3. Update the plan doc frontmatter: `work_item_id: <id>`
4. Report to DEV: work item created with ID and URL
