#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") --title <title> [--draft] [--work-items <id1,id2>]

Push the current branch and open an Azure DevOps pull request.

Options:
  --title        PR title (required)
  --draft        Open the PR as a draft
  --work-items   Comma-separated work item IDs to link
  -h, --help     Show this help message

Exit codes:
  0  Success
  1  Git/az error
  2  Invalid arguments
  3  Missing prerequisites
EOF
  exit 2
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
TITLE=""
DRAFT=false
WORK_ITEMS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      [[ -z "${2:-}" ]] && { log_error "--title requires a value"; usage; }
      TITLE="$2"; shift 2 ;;
    --draft)
      DRAFT=true; shift ;;
    --work-items)
      [[ -z "${2:-}" ]] && { log_error "--work-items requires a value"; usage; }
      WORK_ITEMS="$2"; shift 2 ;;
    -h|--help)
      usage ;;
    *)
      log_error "Unknown argument: $1"
      usage ;;
  esac
done

if [[ -z "$TITLE" ]]; then
  log_error "--title is required"
  usage
fi

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
require_command az
require_command jq
require_az_devops
require_not_main

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

git push -u origin "$BRANCH" >&2 || { json_error "git push failed"; exit 1; }

# Check if a PR already exists for this branch
AZ_LIST_STDERR="$(mktemp)"
EXISTING_PR="$(az repos pr list \
  --source-branch "$BRANCH" \
  --repository "$AZ_REPO" \
  --org "$AZ_ORG_URL" \
  --project "$AZ_PROJECT" \
  --output json 2>"$AZ_LIST_STDERR" | jq '.[0] // empty')" || true

if [[ -s "$AZ_LIST_STDERR" ]]; then
  log_warn "az repos pr list: $(cat "$AZ_LIST_STDERR")"
fi
rm -f "$AZ_LIST_STDERR"

if [[ -n "$EXISTING_PR" ]]; then
  EXISTING_URL="$(echo "$EXISTING_PR" | jq -r '"'"${AZ_ORG_URL}/${AZ_PROJECT}/_git/data_wiz/pullrequest/"'" + (.pullRequestId | tostring)')"
  EXISTING_ID="$(echo "$EXISTING_PR" | jq -r '.pullRequestId')"
  jq -n --arg pr_url "$EXISTING_URL" --arg pr_id "$EXISTING_ID" --arg branch "$BRANCH" \
    '{"pr_url":$pr_url,"pr_id":$pr_id,"branch":$branch,"status":"already_exists"}'
  exit 0
fi

# Build the az repos pr create command
PR_CMD=(az repos pr create
  --source-branch "$BRANCH"
  --target-branch "$DEFAULT_BASE_BRANCH"
  --title "$TITLE"
  --repository "$AZ_REPO"
  --org "$AZ_ORG_URL"
  --project "$AZ_PROJECT"
  --output json
)

if [[ "$DRAFT" == true ]]; then
  PR_CMD+=(--draft true)
fi

if [[ -n "$WORK_ITEMS" ]]; then
  PR_CMD+=(--work-items "$WORK_ITEMS")
fi

log_info "Creating pull request…"
AZ_CREATE_STDERR="$(mktemp)"
PR_JSON=$("${PR_CMD[@]}" 2>"$AZ_CREATE_STDERR") || {
  AZ_ERR="$(cat "$AZ_CREATE_STDERR")"
  rm -f "$AZ_CREATE_STDERR"
  json_error "az repos pr create failed: ${AZ_ERR}"
  exit 1
}
rm -f "$AZ_CREATE_STDERR"

PR_ID="$(echo "$PR_JSON" | jq -r '.pullRequestId')"
PR_URL="${AZ_ORG_URL}/${AZ_PROJECT}/_git/data_wiz/pullrequest/${PR_ID}"

jq -n --arg pr_url "$PR_URL" --arg pr_id "$PR_ID" --arg branch "$BRANCH" \
  '{"pr_url":$pr_url,"pr_id":$pr_id,"branch":$branch,"status":"created"}'
