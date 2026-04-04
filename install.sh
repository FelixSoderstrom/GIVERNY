#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "         GIVERNY Installer"
echo "========================================"
echo

# Question 1: Installation target
echo "Install GIVERNY for:"
echo "  1) Claude Code"
echo "  2) GitHub Copilot"
echo "  3) Cursor"
echo "  4) All"
echo
read -p "Select [1-4]: " target_choice

case $target_choice in
    1) TARGET="claude" ;;
    2) TARGET="copilot" ;;
    3) TARGET="cursor" ;;
    4) TARGET="all" ;;
    *) echo "Invalid selection"; exit 1 ;;
esac

# Question 2: Installation scope
echo
echo "Installation scope:"
echo "  1) Global (applies to all projects)"
echo "  2) Repo-specific (current directory only)"
echo
read -p "Select [1-2]: " scope_choice

case $scope_choice in
    1) SCOPE="global" ;;
    2) SCOPE="repo" ;;
    *) echo "Invalid selection"; exit 1 ;;
esac

# Question 3: Git interaction skills
echo
echo "Include git interaction skills for:"
echo "  1) Azure DevOps"
echo "  2) GitHub"
echo "  3) None"
echo
read -p "Select [1-3]: " git_choice

case $git_choice in
    1) GIT_SKILLS="azure-devops" ;;
    2) GIT_SKILLS="github" ;;
    3) GIT_SKILLS="none" ;;
    *) echo "Invalid selection"; exit 1 ;;
esac

echo
echo "========================================"
echo "Configuration:"
echo "  Target: $TARGET"
echo "  Scope:  $SCOPE"
echo "  Git:    $GIT_SKILLS"
echo "========================================"
echo

# Installation functions
install_claude_global() {
    echo "Installing Claude Code (global)..."

    mkdir -p ~/.claude/agents
    mkdir -p ~/.claude/commands

    # Copy agents
    cp -v "$SCRIPT_DIR/.claude/agents/"*.md ~/.claude/agents/

    # Copy commands
    cp -v "$SCRIPT_DIR/.claude/commands/"*.md ~/.claude/commands/

    echo
    echo "Note: For global install, add CLAUDE.md content to your"
    echo "global settings or copy to each project as needed."
    echo
}

install_claude_repo() {
    echo "Installing Claude Code (repo-specific)..."

    local dest="${PWD}"

    if [[ "$dest" == "$SCRIPT_DIR" ]]; then
        echo "Error: Cannot install to GIVERNY source directory."
        echo "Run this script from your target project directory."
        exit 1
    fi

    mkdir -p "$dest/.claude/agents"
    mkdir -p "$dest/.claude/commands"

    # Copy agents
    cp -v "$SCRIPT_DIR/.claude/agents/"*.md "$dest/.claude/agents/"

    # Copy commands
    cp -v "$SCRIPT_DIR/.claude/commands/"*.md "$dest/.claude/commands/"

    # Copy CLAUDE.md if it doesn't exist, else warn
    if [[ -f "$dest/CLAUDE.md" ]]; then
        echo
        echo "Warning: CLAUDE.md already exists. Skipping."
        echo "Merge manually from: $SCRIPT_DIR/CLAUDE.md"
    else
        cp -v "$SCRIPT_DIR/CLAUDE.md" "$dest/CLAUDE.md"
    fi

    # Create thoughts directory structure
    mkdir -p "$dest/thoughts/shared/research"
    mkdir -p "$dest/thoughts/shared/plans"
    mkdir -p "$dest/thoughts/shared/prs"
    mkdir -p "$dest/thoughts/personal/tickets"
    mkdir -p "$dest/thoughts/personal/notes"

    echo "Created thoughts/ directory structure"
}

install_copilot_global() {
    echo
    echo "Warning: GitHub Copilot does not support global agent/skill config."
    echo "Copilot agents and skills must be installed per-repository."
    echo "Skipping global Copilot installation."
    echo
}

install_copilot_repo() {
    echo "Installing GitHub Copilot (repo-specific)..."

    local dest="${PWD}"

    if [[ "$dest" == "$SCRIPT_DIR" ]]; then
        echo "Error: Cannot install to GIVERNY source directory."
        echo "Run this script from your target project directory."
        exit 1
    fi

    mkdir -p "$dest/.github/agents"
    mkdir -p "$dest/.github/skills"

    # Copy agents
    cp -v "$SCRIPT_DIR/.github/agents/"*.md "$dest/.github/agents/"

    # Copy skills (recursive for skill directories)
    cp -rv "$SCRIPT_DIR/.github/skills/"* "$dest/.github/skills/"

    # Create copilot-instructions.md from CLAUDE.md if it doesn't exist
    if [[ -f "$dest/.github/copilot-instructions.md" ]]; then
        echo
        echo "Warning: .github/copilot-instructions.md already exists. Skipping."
    else
        # Extract core instructions for Copilot
        cp -v "$SCRIPT_DIR/CLAUDE.md" "$dest/.github/copilot-instructions.md"
        echo "Created .github/copilot-instructions.md"
    fi

    # Create thoughts directory structure
    mkdir -p "$dest/thoughts/shared/research"
    mkdir -p "$dest/thoughts/shared/plans"
    mkdir -p "$dest/thoughts/shared/prs"
    mkdir -p "$dest/thoughts/personal/tickets"
    mkdir -p "$dest/thoughts/personal/notes"

    echo "Created thoughts/ directory structure"
}

install_azure_devops_claude_global() {
    echo "Installing Azure DevOps skills (global)..."

    mkdir -p ~/.claude/skills

    # Copy Azure DevOps skills
    cp -rv "$SCRIPT_DIR/git-skills/azure-devops/skills/"* ~/.claude/skills/

    # Copy ticket command
    cp -v "$SCRIPT_DIR/git-skills/azure-devops/commands/"*.md ~/.claude/commands/

    echo
    echo "Note: Azure DevOps scripts must be installed per-repo."
    echo "Run with repo-specific scope to install scripts."
}

install_azure_devops_claude_repo() {
    echo "Installing Azure DevOps skills (repo-specific)..."

    local dest="${PWD}"

    mkdir -p "$dest/.claude/skills"
    mkdir -p "$dest/scripts/agent"

    # Copy Azure DevOps skills
    cp -rv "$SCRIPT_DIR/git-skills/azure-devops/skills/"* "$dest/.claude/skills/"

    # Copy ticket command
    cp -v "$SCRIPT_DIR/git-skills/azure-devops/commands/"*.md "$dest/.claude/commands/"

    # Copy Azure DevOps scripts
    cp -rv "$SCRIPT_DIR/git-skills/azure-devops/scripts/"* "$dest/scripts/agent/"

    # Make scripts executable
    find "$dest/scripts/agent" -name "*.sh" -exec chmod +x {} \;

    echo
    echo "Azure DevOps scripts installed to scripts/agent/"
    echo "Prerequisites: az cli, jq"
    echo "Run: az login && az devops configure --defaults organization=YOUR_ORG project=YOUR_PROJECT"
}

install_cursor_global() {
    echo "Installing Cursor (global)..."

    mkdir -p ~/.cursor/agents
    mkdir -p ~/.cursor/skills

    # Copy agents
    cp -v "$SCRIPT_DIR/.cursor/agents/"*.md ~/.cursor/agents/

    # Copy skills (recursive for skill directories)
    cp -rv "$SCRIPT_DIR/.cursor/skills/"* ~/.cursor/skills/

    echo
    echo "Note: Global rules must be configured via Cursor Settings UI."
    echo "Copy the contents of .cursor/rules/giverny.mdc into your Cursor rules."
    echo
}

install_cursor_repo() {
    echo "Installing Cursor (repo-specific)..."

    local dest="${PWD}"

    if [[ "$dest" == "$SCRIPT_DIR" ]]; then
        echo "Error: Cannot install to GIVERNY source directory."
        echo "Run this script from your target project directory."
        exit 1
    fi

    mkdir -p "$dest/.cursor/agents"
    mkdir -p "$dest/.cursor/skills"
    mkdir -p "$dest/.cursor/rules"

    # Copy agents
    cp -v "$SCRIPT_DIR/.cursor/agents/"*.md "$dest/.cursor/agents/"

    # Copy skills (recursive for skill directories)
    cp -rv "$SCRIPT_DIR/.cursor/skills/"* "$dest/.cursor/skills/"

    # Copy rules
    cp -v "$SCRIPT_DIR/.cursor/rules/"*.mdc "$dest/.cursor/rules/"

    # Create thoughts directory structure
    mkdir -p "$dest/thoughts/shared/research"
    mkdir -p "$dest/thoughts/shared/plans"
    mkdir -p "$dest/thoughts/shared/prs"
    mkdir -p "$dest/thoughts/personal/tickets"
    mkdir -p "$dest/thoughts/personal/notes"

    echo "Created thoughts/ directory structure"
}

install_azure_devops_cursor_repo() {
    echo "Installing Azure DevOps skills for Cursor (repo-specific)..."

    local dest="${PWD}"

    mkdir -p "$dest/scripts/agent"

    # Copy Azure DevOps scripts
    cp -rv "$SCRIPT_DIR/git-skills/azure-devops/scripts/"* "$dest/scripts/agent/"

    # Make scripts executable
    find "$dest/scripts/agent" -name "*.sh" -exec chmod +x {} \;

    echo
    echo "Note: Azure DevOps Cursor skills not yet available."
    echo "Scripts installed to scripts/agent/ for manual use."
    echo "Prerequisites: az cli, jq"
    echo "Run: az login && az devops configure --defaults organization=YOUR_ORG project=YOUR_PROJECT"
}

install_azure_devops_copilot_repo() {
    echo "Installing Azure DevOps skills for Copilot (repo-specific)..."

    local dest="${PWD}"

    mkdir -p "$dest/scripts/agent"

    # Copy Azure DevOps scripts (skills would need conversion for Copilot)
    cp -rv "$SCRIPT_DIR/git-skills/azure-devops/scripts/"* "$dest/scripts/agent/"

    # Make scripts executable
    find "$dest/scripts/agent" -name "*.sh" -exec chmod +x {} \;

    echo
    echo "Note: Azure DevOps Copilot skills not yet available."
    echo "Scripts installed to scripts/agent/ for manual use."
}

apply_git_skills() {
    case $GIT_SKILLS in
        "github")
            echo "GitHub git skills included by default in commit command."
            ;;
        "azure-devops")
            case $TARGET in
                "claude")
                    if [[ "$SCOPE" == "global" ]]; then
                        install_azure_devops_claude_global
                    else
                        install_azure_devops_claude_repo
                    fi
                    ;;
                "copilot")
                    if [[ "$SCOPE" == "repo" ]]; then
                        install_azure_devops_copilot_repo
                    else
                        echo "Azure DevOps + Copilot global not supported."
                    fi
                    ;;
                "cursor")
                    if [[ "$SCOPE" == "repo" ]]; then
                        install_azure_devops_cursor_repo
                    else
                        echo "Azure DevOps + Cursor global not supported."
                    fi
                    ;;
                "all")
                    if [[ "$SCOPE" == "global" ]]; then
                        install_azure_devops_claude_global
                    else
                        install_azure_devops_claude_repo
                        install_azure_devops_copilot_repo
                        install_azure_devops_cursor_repo
                    fi
                    ;;
            esac
            ;;
        "none")
            echo "Git interaction skills skipped."
            ;;
    esac
}

# Execute installation based on selections
case $TARGET in
    "claude")
        if [[ "$SCOPE" == "global" ]]; then
            install_claude_global
        else
            install_claude_repo
        fi
        ;;
    "copilot")
        if [[ "$SCOPE" == "global" ]]; then
            install_copilot_global
        else
            install_copilot_repo
        fi
        ;;
    "cursor")
        if [[ "$SCOPE" == "global" ]]; then
            install_cursor_global
        else
            install_cursor_repo
        fi
        ;;
    "all")
        if [[ "$SCOPE" == "global" ]]; then
            install_claude_global
            install_copilot_global
            install_cursor_global
        else
            install_claude_repo
            install_copilot_repo
            install_cursor_repo
        fi
        ;;
esac

apply_git_skills

echo
echo "========================================"
echo "         Installation Complete"
echo "========================================"
echo
echo "Next steps:"
echo "  1. Edit CLAUDE.md (or copilot-instructions.md / .cursor/rules/) to add project context"
echo "  2. Run /re-anchor to initialize GIVERNY in your session (Claude Code, Copilot, or Cursor)"
echo "  3. Use /research <topic> to start mapping your codebase"
echo

# Show Azure DevOps prerequisites if selected
if [[ "$GIT_SKILLS" == "azure-devops" ]]; then
    echo "========================================"
    echo "     Azure DevOps Prerequisites"
    echo "========================================"
    echo
    echo "1. Install Azure CLI:"
    echo
    echo "   Linux (Debian/Ubuntu):"
    echo "     curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    echo
    echo "   macOS:"
    echo "     brew install azure-cli"
    echo
    echo "   Windows (PowerShell as Admin):"
    echo "     winget install Microsoft.AzureCLI"
    echo "     # Or download MSI: https://aka.ms/installazurecliwindows"
    echo
    echo "2. Install Azure DevOps extension:"
    echo "   az extension add --name azure-devops"
    echo
    echo "3. Install jq (JSON processor):"
    echo
    echo "   Linux (Debian/Ubuntu):"
    echo "     sudo apt install jq"
    echo
    echo "   macOS:"
    echo "     brew install jq"
    echo
    echo "   Windows:"
    echo "     winget install jqlang.jq"
    echo "     # Or: choco install jq"
    echo "     # Or: scoop install jq"
    echo
    echo "4. Authenticate and configure defaults:"
    echo "   az login"
    echo "   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT"
    echo
    echo "5. (Optional) Use PAT for non-interactive auth:"
    echo
    echo "   Linux/macOS:"
    echo "     export AZURE_DEVOPS_EXT_PAT=your_personal_access_token"
    echo
    echo "   Windows (PowerShell):"
    echo "     \$env:AZURE_DEVOPS_EXT_PAT=\"your_personal_access_token\""
    echo
    echo "   Windows (CMD):"
    echo "     set AZURE_DEVOPS_EXT_PAT=your_personal_access_token"
    echo
    echo "Customization:"
    echo "  Ticket templates and standards can be freely modified."
    echo "  Edit .claude/commands/ticket.md to change ticket format."
    echo "  Edit .claude/skills/create-new-ticket/SKILL.md for field mappings."
    echo
fi
