#!/usr/bin/env bash
# common.sh — Shared utility library for agent-callable DevOps scripts.
# Source this file; do not execute directly. Keeps stdout clean for JSON output.
#
# Targets Azure DevOps (az CLI) — not GitHub.

# ---------------------------------------------------------------------------
# Config defaults (Azure DevOps)
# ---------------------------------------------------------------------------
DEFAULT_BASE_BRANCH="main"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"

# Azure DevOps defaults — parsed from git remote
_REMOTE_URL="$(git remote get-url origin 2>/dev/null || echo "")"
if [[ "$_REMOTE_URL" == *"dev.azure.com"* ]]; then
  # Format: git@ssh.dev.azure.com:v3/ORG/PROJECT/REPO
  # or:     https://dev.azure.com/ORG/PROJECT/_git/REPO
  AZ_ORG="$(echo "$_REMOTE_URL" | sed -E 's|.*dev\.azure\.com[:/]v3/([^/]+)/.*|\1|; s|.*dev\.azure\.com/([^/]+)/.*|\1|')"
  AZ_PROJECT="$(echo "$_REMOTE_URL" | sed -E 's|.*dev\.azure\.com[:/]v3/[^/]+/([^/]+)/.*|\1|; s|.*dev\.azure\.com/[^/]+/([^/]+)/.*|\1|' | sed 's/%20/ /g')"
  AZ_REPO="$(echo "$_REMOTE_URL" | sed -E 's|.*dev\.azure\.com[:/]v3/[^/]+/[^/]+/([^/]+).*|\1|; s|.*dev\.azure\.com/[^/]+/[^/]+/_git/([^/]+).*|\1|')"
  AZ_ORG_URL="https://dev.azure.com/${AZ_ORG}"
fi

# ---------------------------------------------------------------------------
# Logging (all output goes to stderr so stdout stays clean for JSON)
# ---------------------------------------------------------------------------
log_info()  { echo "[INFO] $*"  >&2; }
log_warn()  { echo "[WARN] $*"  >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# ---------------------------------------------------------------------------
# JSON output helpers
# ---------------------------------------------------------------------------
json_success() {
  jq -n --argjson data "$1" '{"status":"success","data":$data}'
}

json_error() {
  jq -n --arg msg "$1" '{"status":"error","message":$msg}' >&2
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
require_command() {
  if ! command -v "$1" &>/dev/null; then
    json_error "Required command not found: $1"
    exit 3
  fi
}

require_az_devops() {
  if ! az account show &>/dev/null 2>&1; then
    json_error "Azure CLI is not authenticated. Run 'az login'."
    exit 3
  fi
  if [[ -z "${AZ_ORG:-}" || -z "${AZ_PROJECT:-}" ]]; then
    json_error "Could not detect Azure DevOps org/project from git remote."
    exit 3
  fi
}

require_not_main() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    json_error "Operation not allowed on branch '$branch'."
    exit 2
  fi
}

require_clean_worktree() {
  if ! git diff --quiet HEAD -- 2>/dev/null || ! git diff --cached --quiet HEAD -- 2>/dev/null; then
    json_error "Working tree has uncommitted changes."
    exit 2
  fi
}
