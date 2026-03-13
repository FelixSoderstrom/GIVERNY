---
description: Teaches GIVERNY how to create new tickets. Only invoked in plan phase after DEV approval
---

## SKILL: CREATE USER STORY

This skill provides context for calling `scripts/agent/issues/create_user_story.sh`.

### WHEN TO USE

- After DEV approves a plan (`/plan` phase, status: approved)
- After DEV approves a ticket (`/ticket` phase, status: approved)
- Never before DEV approval

### SCRIPT

```
scripts/agent/issues/create_user_story.sh
```

### ARGUMENT MAPPING

**Preferred: use `--file`** to pass the ticket/plan markdown directly. This avoids re-composing content into separate flags.

| Flag | Source | Required |
|------|--------|----------|
| `--file` | Path to ticket/plan markdown in `thoughts/` | **Yes** (preferred) |
| `--title` | Override file-derived title | No (auto-derived from filename) |
| `--tags` | Semicolon-separated tags | No |
| `--assignee` | Email if known | No |
| `--area` | Area path e.g. `"DataWiz\\Backend"` | No |
| `--dry-run` | Print command without executing | No |

When `--file` is used, the script:
- Converts ticket markdown (Problem, Solution, References, Acceptance Criteria) to HTML for the work item body
- Derives title from the filename (`YYYY-MM-DD-short-description.md` → `short description`)
- `--title` can still override the derived title

Legacy flags (`--goal`, `--persona`, `--reason`, `--description`) still work without `--file`.

Do NOT pass `--branch` — branching is handled separately by `/create-feature-branch`.

### EXPECTED OUTPUT

JSON to stdout:
```json
{"id":"42","url":"https://...","title":"...","branch":"","branch_status":"none"}
```

**Extract `id`** — this is the `work_item_id` that must be persisted into the plan doc frontmatter.

### EXIT CODES

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Extract `id`, persist to plan |
| 1 | API error (retryable) | Retry once |
| 2 | Invalid arguments | Fix the call |
| 3 | Prerequisites missing (`az`, `jq`, auth) | Report to DEV |

### POST-EXECUTION

1. Parse the JSON output
2. Extract the `id` field
3. Update the plan doc frontmatter: `work_item_id: <id>`
4. Report to DEV: work item created with ID and URL
