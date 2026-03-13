---
description: Teaches GIVERNY how to create a feature branch. Only invoked at the start of IMPLEMENT-mode if not on correct feature branch.
---

## SKILL: CREATE FEATURE BRANCH

This skill provides context for calling `scripts/agent/git/create_feature_branch.sh`.

### WHEN TO USE

- First step of `/implement` phase
- Requires `work_item_id` in the plan doc frontmatter
- If `work_item_id` is missing: "No work item ID in plan. Run `/plan` approval flow first."

### SCRIPT

```
scripts/agent/git/create_feature_branch.sh <work-item-id> [branch-prefix]
```

### ARGUMENTS

| Positional | Source | Required |
|-----------|--------|----------|
| `work-item-id` | `work_item_id` from plan doc frontmatter | Yes |
| `branch-prefix` | Default: `feature`. Override only if DEV specifies | No |

### EXPECTED OUTPUT

JSON to stdout:
```json
{"branch":"feature/42-fix-widget","base":"main","status":"created","work_item":42}
```

`status` is either `"created"` or `"already_exists"` (idempotent).

### EXIT CODES

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success (created or already exists) | Proceed to implement phases |
| 1 | Git error (retryable) | Retry once |
| 2 | Invalid args or closed work item | Report to DEV |
| 3 | Prerequisites missing (`az`, `jq`, auth) | Report to DEV |

### POST-EXECUTION

1. Confirm branch name from JSON output
2. Proceed to implement phase 1
