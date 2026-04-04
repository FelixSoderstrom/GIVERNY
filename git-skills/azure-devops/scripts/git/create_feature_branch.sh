#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") <work-item-id> [branch-prefix]

Create a feature branch from ${DEFAULT_BASE_BRANCH} for the given Azure DevOps work item.

Arguments:
  work-item-id   Azure DevOps work item ID (required)
  branch-prefix  Branch name prefix (default: feature)

Exit codes:
  0  Success
  1  Git error
  2  Invalid arguments or closed work item
  3  Missing prerequisites
EOF
}

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  json_error "Work item ID is required. Usage: $(basename "$0") <work-item-id> [branch-prefix]"
  exit 2
fi

WI_ID="$1"
PREFIX="${2:-feature}"

if ! [[ "$WI_ID" =~ ^[0-9]+$ ]]; then
  json_error "Work item ID must be a positive integer: $WI_ID"
  exit 2
fi

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------
require_command az
require_command jq
require_az_devops

# ---------------------------------------------------------------------------
# Fetch work item
# ---------------------------------------------------------------------------
log_info "Fetching work item #${WI_ID}…"
WI_JSON="$(az boards work-item show --id "$WI_ID" \
  --org "$AZ_ORG_URL" \
  --output json 2>/dev/null)" || {
  json_error "Failed to fetch work item #${WI_ID}"
  exit 1
}

WI_STATE="$(echo "$WI_JSON" | jq -r '.fields["System.State"]')"
if [[ "$WI_STATE" == "Closed" || "$WI_STATE" == "Removed" || "$WI_STATE" == "Done" ]]; then
  json_error "Work item #${WI_ID} is in state '${WI_STATE}'."
  exit 2
fi

# ---------------------------------------------------------------------------
# Slugify title
# ---------------------------------------------------------------------------
TITLE="$(echo "$WI_JSON" | jq -r '.fields["System.Title"]')"
SLUG="$(echo "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed 's/[^a-z0-9]/-/g' \
  | sed 's/-\{2,\}/-/g' \
  | sed 's/^-//;s/-$//' \
  | cut -c1-50)"

BRANCH="${PREFIX}/${WI_ID}-${SLUG}"

# ---------------------------------------------------------------------------
# Idempotency: branch already exists
# ---------------------------------------------------------------------------
if git rev-parse --verify "refs/heads/${BRANCH}" &>/dev/null; then
  log_info "Branch '${BRANCH}' already exists."
  jq -n \
    --arg branch "$BRANCH" \
    --arg base "$DEFAULT_BASE_BRANCH" \
    --argjson work_item "$WI_ID" \
    '{"branch":$branch,"base":$base,"status":"already_exists","work_item":$work_item}'
  exit 0
fi

# ---------------------------------------------------------------------------
# Create and checkout branch
# ---------------------------------------------------------------------------
log_info "Creating branch '${BRANCH}' from '${DEFAULT_BASE_BRANCH}'…"
git checkout -b "$BRANCH" "$DEFAULT_BASE_BRANCH" >&2 || {
  json_error "Failed to create branch '${BRANCH}' from '${DEFAULT_BASE_BRANCH}'."
  exit 1
}

jq -n \
  --arg branch "$BRANCH" \
  --arg base "$DEFAULT_BASE_BRANCH" \
  --argjson work_item "$WI_ID" \
  '{"branch":$branch,"base":$base,"status":"created","work_item":$work_item}'
