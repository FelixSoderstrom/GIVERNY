## SKILL: PULL REQUEST

This skill provides context for calling `scripts/agent/git/pull-request.sh`.

### WHEN TO USE

- After all commits are done and DEV has approved the implementation
- Never before DEV explicitly approves
- If on `main`/`master`/`dev`/`prod`: script will refuse — must be on a feature branch

### SCRIPT

```
scripts/agent/git/pull-request.sh --title <title> [--draft] [--work-items <ids>]
```

### ARGUMENT MAPPING

Source the arguments from the plan doc and implementation context.

| Flag | Source | Required |
|------|--------|----------|
| `--title` | PR title derived from plan objective or commit history | Yes |
| `--draft` | Include if DEV requests draft PR | No |
| `--work-items` | `work_item_id` from plan doc frontmatter (comma-separated if multiple) | No |

### EXPECTED OUTPUT

JSON to stdout:
```json
{"pr_url":"https://...","pr_id":"123","branch":"feature/42-fix-widget","status":"created"}
```

`status` is either `"created"` or `"already_exists"` (idempotent).

### EXIT CODES

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success (PR created or exists) | Report PR URL to DEV |
| 1 | Git/az error (retryable) | Retry once |
| 2 | Invalid args or on protected branch | Report to DEV |
| 3 | Prerequisites missing (`az`, `jq`, auth) | Report to DEV |

### POST-EXECUTION

1. Parse JSON output
2. Report PR URL to DEV
3. If plan doc exists, save PR URL to `thoughts/shared/prs/`
