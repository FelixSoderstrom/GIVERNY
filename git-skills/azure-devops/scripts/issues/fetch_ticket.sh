#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/common.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") --work-item-id <id>

Fetch an Azure DevOps work item and save its description to:
  thoughts/personal/tickets/<id>.md

Options:
  --work-item-id ID   Work item ID (required)
  -h, --help          Show this help

Exit codes:
  0  Success
  1  API error
  2  Invalid arguments
  3  Missing prerequisites
EOF
  exit "${1:-0}"
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
WI_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --work-item-id|--work_item_id)
      [[ -z "${2:-}" ]] && { log_error "--work-item-id requires a value"; usage 2; }
      WI_ID="$2"; shift 2 ;;
    -h|--help)
      usage 0 ;;
    *)
      log_error "Unknown option: $1"
      usage 2 ;;
  esac
done

if [[ -z "$WI_ID" ]]; then
  json_error "--work-item-id is required."
  exit 2
fi

if ! [[ "$WI_ID" =~ ^[0-9]+$ ]]; then
  json_error "Work item ID must be a positive integer: $WI_ID"
  exit 2
fi

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
require_command az
require_command jq
require_az_devops

# ---------------------------------------------------------------------------
# Fetch work item
# ---------------------------------------------------------------------------
log_info "Fetching work item #${WI_ID}..."
WI_JSON="$(az boards work-item show --id "$WI_ID" \
  --org "$AZ_ORG_URL" \
  --output json 2>/dev/null)" || {
  json_error "Failed to fetch work item #${WI_ID}"
  exit 1
}

# ---------------------------------------------------------------------------
# Extract fields
# ---------------------------------------------------------------------------
TITLE="$(echo "$WI_JSON" | jq -r '.fields["System.Title"] // "Untitled"')"
STATE="$(echo "$WI_JSON" | jq -r '.fields["System.State"] // "Unknown"')"
WI_TYPE="$(echo "$WI_JSON" | jq -r '.fields["System.WorkItemType"] // "Unknown"')"
ASSIGNED="$(echo "$WI_JSON" | jq -r '.fields["System.AssignedTo"].displayName // "Unassigned"')"
TAGS="$(echo "$WI_JSON" | jq -r '.fields["System.Tags"] // ""')"
DESCRIPTION="$(echo "$WI_JSON" | jq -r '.fields["System.Description"] // ""')"
ACCEPTANCE="$(echo "$WI_JSON" | jq -r '.fields["Microsoft.VSTS.Common.AcceptanceCriteria"] // ""')"
WI_URL="${AZ_ORG_URL}/${AZ_PROJECT}/_workitems/edit/${WI_ID}"

# Strip HTML tags for readable markdown
strip_html() {
  echo "$1" | sed 's/<br[^>]*>/\n/gi' \
            | sed 's/<\/p>/\n/gi' \
            | sed 's/<\/li>/\n/gi' \
            | sed 's/<li[^>]*>/- /gi' \
            | sed 's/<[^>]*>//g' \
            | sed 's/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g' \
            | sed '/^[[:space:]]*$/d'
}

DESC_MD="$(strip_html "$DESCRIPTION")"
ACC_MD="$(strip_html "$ACCEPTANCE")"

# ---------------------------------------------------------------------------
# Write markdown file
# ---------------------------------------------------------------------------
TICKET_DIR="${REPO_ROOT}/thoughts/personal/tickets"
mkdir -p "$TICKET_DIR"
TICKET_PATH="${TICKET_DIR}/${WI_ID}.md"

{
  echo "# #${WI_ID} — ${TITLE}"
  echo ""
  echo "| Field | Value |"
  echo "|-------|-------|"
  echo "| Type | ${WI_TYPE} |"
  echo "| State | ${STATE} |"
  echo "| Assigned | ${ASSIGNED} |"
  [[ -n "$TAGS" ]] && echo "| Tags | ${TAGS} |"
  echo "| URL | ${WI_URL} |"
  echo ""
  if [[ -n "$DESC_MD" ]]; then
    echo "## Description"
    echo ""
    echo "$DESC_MD"
    echo ""
  fi
  if [[ -n "$ACC_MD" ]]; then
    echo "## Acceptance Criteria"
    echo ""
    echo "$ACC_MD"
    echo ""
  fi
} > "$TICKET_PATH"

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
jq -n \
  --arg path "thoughts/personal/tickets/${WI_ID}.md" \
  --arg title "$TITLE" \
  --arg message "Ticket successfully saved to thoughts/personal/tickets/${WI_ID}.md" \
  '{"status":"success","path":$path,"title":$title,"message":$message}'
