#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0")

Detect and install missing prerequisites for agent scripts.
Handles: az CLI, az devops extension, jq.

Exit codes:
  0  All prerequisites satisfied (nothing to install or all installed)
  1  Installation failed
EOF
  exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
INSTALLED=()
SKIPPED=()
FAILED=()

record_installed() { INSTALLED+=("$1"); }
record_skipped()   { SKIPPED+=("$1"); }
record_failed()    { FAILED+=("$1"); }

# ---------------------------------------------------------------------------
# Detect OS / package manager
# ---------------------------------------------------------------------------
detect_installer() {
  if command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v brew &>/dev/null; then
    echo "brew"
  elif command -v winget &>/dev/null; then
    echo "winget"
  elif command -v choco &>/dev/null; then
    echo "choco"
  else
    echo "unknown"
  fi
}

INSTALLER="$(detect_installer)"

# ---------------------------------------------------------------------------
# jq
# ---------------------------------------------------------------------------
install_jq() {
  if command -v jq &>/dev/null; then
    record_skipped "jq"
    return
  fi

  log_info "Installing jq..."
  case "$INSTALLER" in
    apt)    sudo apt-get update -qq && sudo apt-get install -y -qq jq ;;
    brew)   brew install jq ;;
    winget) winget install --id jqlang.jq -e --accept-source-agreements --accept-package-agreements ;;
    choco)  choco install jq -y ;;
    *)      log_error "No supported package manager found to install jq."
            record_failed "jq"; return ;;
  esac

  if command -v jq &>/dev/null; then
    record_installed "jq"
  else
    record_failed "jq"
  fi
}

# ---------------------------------------------------------------------------
# Azure CLI
# ---------------------------------------------------------------------------
install_az() {
  if command -v az &>/dev/null; then
    record_skipped "az"
    return
  fi

  log_info "Installing Azure CLI..."
  case "$INSTALLER" in
    apt)    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash ;;
    brew)   brew install azure-cli ;;
    winget) winget install --id Microsoft.AzureCLI -e --accept-source-agreements --accept-package-agreements ;;
    choco)  choco install azure-cli -y ;;
    *)      log_error "No supported package manager found to install az CLI."
            record_failed "az"; return ;;
  esac

  if command -v az &>/dev/null; then
    record_installed "az"
  else
    record_failed "az"
  fi
}

# ---------------------------------------------------------------------------
# Azure DevOps extension
# ---------------------------------------------------------------------------
install_az_devops() {
  if az extension show --name azure-devops &>/dev/null 2>&1; then
    record_skipped "az-devops-ext"
    return
  fi

  # az CLI must be available first
  if ! command -v az &>/dev/null; then
    log_error "Cannot install azure-devops extension: az CLI not available."
    record_failed "az-devops-ext"
    return
  fi

  log_info "Installing azure-devops extension..."
  if az extension add --name azure-devops --yes 2>/dev/null; then
    record_installed "az-devops-ext"
  else
    record_failed "az-devops-ext"
  fi
}

# ---------------------------------------------------------------------------
# Run all checks (order matters: az before az-devops)
# ---------------------------------------------------------------------------
install_jq
install_az
install_az_devops

# ---------------------------------------------------------------------------
# Output JSON
# ---------------------------------------------------------------------------
to_json_array() {
  if [[ $# -eq 0 ]]; then
    echo "[]"
    return
  fi
  printf '%s\n' "$@" | jq -R . | jq -s .
}

INSTALLED_JSON="$(to_json_array "${INSTALLED[@]+"${INSTALLED[@]}"}")"
SKIPPED_JSON="$(to_json_array "${SKIPPED[@]+"${SKIPPED[@]}"}")"
FAILED_JSON="$(to_json_array "${FAILED[@]+"${FAILED[@]}"}")"

if [[ ${#FAILED[@]} -gt 0 ]]; then
  jq -n \
    --argjson installed "$INSTALLED_JSON" \
    --argjson skipped "$SKIPPED_JSON" \
    --argjson failed "$FAILED_JSON" \
    '{"status":"partial_failure","installed":$installed,"already_present":$skipped,"failed":$failed}'
  exit 1
else
  jq -n \
    --argjson installed "$INSTALLED_JSON" \
    --argjson skipped "$SKIPPED_JSON" \
    '{"status":"success","installed":$installed,"already_present":$skipped,"failed":[]}'
  exit 0
fi
