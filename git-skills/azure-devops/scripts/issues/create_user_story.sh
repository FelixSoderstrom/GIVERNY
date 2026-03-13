#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") --file <path> [OPTIONS]

Create an Azure DevOps User Story from a markdown file.

Options:
  --file PATH        Markdown file to upload as ticket body (required)
  --title TEXT       Override title (default: derived from filename)
  --tags LIST        Semicolon-separated tags
  --assignee EMAIL   User email to assign
  --branch NAME      Feature branch to create and link
  --area PATH        Area path (e.g., "DataWiz\\Backend")
  --iteration PATH   Iteration path
  --dry-run          Print command as JSON without executing
  -h, --help         Show this help

Exit codes: 0=success, 1=API error, 2=invalid args, 3=prereqs missing
EOF
  exit "${1:-0}"
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
FILE=""
TITLE=""
TAGS=""
ASSIGNEE=""
BRANCH=""
AREA=""
ITERATION=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)        FILE="$2";      shift 2 ;;
    --title)       TITLE="$2";     shift 2 ;;
    --tags)        TAGS="$2";      shift 2 ;;
    --assignee)    ASSIGNEE="$2";  shift 2 ;;
    --branch)      BRANCH="$2";    shift 2 ;;
    --area)        AREA="$2";      shift 2 ;;
    --iteration)   ITERATION="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=true;   shift   ;;
    -h|--help)     usage 0                  ;;
    *)
      log_error "Unknown option: $1"
      usage 2
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
if [[ -z "$FILE" ]]; then
  json_error "--file is required."
  exit 2
fi

if [[ ! -f "$FILE" ]]; then
  json_error "File not found: $FILE"
  exit 2
fi

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
require_command az
require_command jq
require_az_devops

# ---------------------------------------------------------------------------
# Read file and derive title
# ---------------------------------------------------------------------------
BODY=""
while IFS= read -r line || [[ -n "$line" ]]; do
  BODY="${BODY}${line}"$'\n'
done < "$FILE"

if [[ -z "$TITLE" ]]; then
  base="$(basename "$FILE" .md)"
  base="${base#????-??-??-}"
  TITLE="${base//-/ }"
fi

# ---------------------------------------------------------------------------
# Build az command
# ---------------------------------------------------------------------------
AZ_CMD=(az boards work-item create
  --type "User Story"
  --title "$TITLE"
  --org "$AZ_ORG_URL"
  --project "$AZ_PROJECT"
  --output json
)

FIELDS=()
FIELDS+=("System.Description=<pre>${BODY}</pre>")
[[ -n "$TAGS" ]]      && FIELDS+=("System.Tags=${TAGS}")
[[ -n "$ASSIGNEE" ]]  && AZ_CMD+=(--assigned-to "$ASSIGNEE")
[[ -n "$AREA" ]]      && FIELDS+=("System.AreaPath=${AREA}")
[[ -n "$ITERATION" ]] && FIELDS+=("System.IterationPath=${ITERATION}")

AZ_CMD+=(--fields "${FIELDS[@]}")

# ---------------------------------------------------------------------------
# Dry-run
# ---------------------------------------------------------------------------
if [[ "$DRY_RUN" == true ]]; then
  jq -n --arg cmd "${AZ_CMD[*]}" '{"dry_run":true,"command":$cmd}'
  exit 0
fi

# ---------------------------------------------------------------------------
# Execute
# ---------------------------------------------------------------------------
log_info "Creating user story: ${TITLE}"
WI_JSON=$("${AZ_CMD[@]}" 2>/dev/null) || {
  json_error "Failed to create work item."
  exit 1
}

WI_ID="$(echo "$WI_JSON" | jq -r '.id')"
WI_URL="${AZ_ORG_URL}/${AZ_PROJECT}/_workitems/edit/${WI_ID}"

# ---------------------------------------------------------------------------
# Branch handling
# ---------------------------------------------------------------------------
BRANCH_STATUS="none"

if [[ -n "$BRANCH" ]]; then
  if git rev-parse --verify "refs/heads/${BRANCH}" &>/dev/null; then
    BRANCH_STATUS="already_exists"
    log_info "Branch '$BRANCH' already exists."
  else
    git checkout -b "$BRANCH" "$DEFAULT_BASE_BRANCH" >&2 2>/dev/null || {
      json_error "Failed to create branch '$BRANCH'."
      exit 1
    }
    BRANCH_STATUS="created"
    log_info "Branch '$BRANCH' created from '$DEFAULT_BASE_BRANCH'."
  fi
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
jq -n \
  --arg id "$WI_ID" \
  --arg url "$WI_URL" \
  --arg title "$TITLE" \
  --arg branch "${BRANCH:-}" \
  --arg branch_status "$BRANCH_STATUS" \
  '{"id":$id,"url":$url,"title":$title,"branch":$branch,"branch_status":$branch_status}'
