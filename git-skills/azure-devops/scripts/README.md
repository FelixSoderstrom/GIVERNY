# Agent DevOps Scripts

Structured, idempotent bash scripts for AI agent DevOps operations against **Azure DevOps**. All scripts output JSON to stdout, log to stderr, and use typed exit codes.

## Exit Codes

| Code | Meaning | Agent Behavior |
|------|---------|----------------|
| 0 | Success | Proceed to next step |
| 1 | Operation failed (retryable) | Retry with same or adjusted params |
| 2 | Invalid arguments (agent error) | Don't retry; fix the call |
| 3 | Precondition not met | Install dependency or wait |

## Available Scripts

### `git/create_feature_branch.sh`
Create a feature branch from an Azure DevOps work item ID.
```bash
scripts/agent/git/create_feature_branch.sh <work-item-id> [prefix]
# Output: {"branch": "feature/42-fix-widget", "base": "main", "status": "created|already_exists", "work_item": 42}
```

### `git/commit_and_pr.sh`
Stage, commit, push, and create an Azure DevOps pull request.
```bash
scripts/agent/git/commit_and_pr.sh --message "feat: add widget" [--draft] [--work-items 42,43]
# Output: {"pr_url": "...", "pr_id": "123", "branch": "...", "status": "created|already_exists"}
```

### `issues/create_user_story.sh`
Create an Azure DevOps User Story from a markdown file.
```bash
scripts/agent/issues/create_user_story.sh --file path/to/ticket.md [--title "Override title"] [--tags "backend;api"] [--assignee email] [--branch name]
# Output: {"id": "42", "url": "...", "title": "...", "branch": "...", "branch_status": "created|already_exists|none"}
```

### `lib/install_prereqs.sh`
Detect and install missing prerequisites for all agent scripts.
```bash
scripts/agent/lib/install_prereqs.sh
# Output: {"status":"success|partial_failure","installed":[...],"already_present":[...],"failed":[...]}
```

### `issues/fetch_ticket.sh`
Fetch an Azure DevOps work item and save its description as markdown.
```bash
scripts/agent/issues/fetch_ticket.sh --work-item-id <id>
# Output: {"status":"success","path":"thoughts/personal/tickets/<id>.md","title":"...","message":"Ticket successfully saved to ..."}
```

## Shared Library

All scripts source `lib/common.sh` for:
- JSON output helpers (`json_success`, `json_error`)
- Logging (`log_info`, `log_warn`, `log_error`)
- Prerequisite checks (`require_command`, `require_az_devops`, `require_not_main`)
- Auto-detected Azure DevOps org/project from git remote

## Prerequisites

- `az` CLI installed and authenticated (`az login`)
- `az devops` extension installed
- `jq` installed
- Git repository with Azure DevOps remote configured
