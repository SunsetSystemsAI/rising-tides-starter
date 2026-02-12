#!/bin/bash

# ===========================================
# Rising Tides - FULL UNINSTALL
# ===========================================
#
#   ⚠️  WARNING: DESTRUCTIVE OPERATION  ⚠️
#
# This script removes EVERYTHING installed by
# the Rising Tides Starter Pack, including:
#
#   - Claude Code CLI
#   - All Claude configuration (~/.claude/)
#   - Rising Tides Skills and Plugins
#   - ENABLE_TOOL_SEARCH from shell profile
#
# This is a COMPLETE RESET. After running this,
# you'll need to reinstall everything from scratch.
#
# ===========================================

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"

# -------------------------------------------
# Big scary warning
# -------------------------------------------

clear
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                                                              ║${NC}"
echo -e "${RED}║   ⚠️   WARNING: COMPLETE UNINSTALL   ⚠️                       ║${NC}"
echo -e "${RED}║                                                              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}This will remove EVERYTHING:${NC}"
echo ""
echo -e "  ${RED}✗${NC} Claude Code CLI"
echo -e "  ${RED}✗${NC} All Claude configuration (~/.claude/)"
echo -e "  ${RED}✗${NC} Your settings.json and preferences"
echo -e "  ${RED}✗${NC} Your mcp.json and MCP configurations"
echo -e "  ${RED}✗${NC} All Rising Tides skills (187 skills)"
echo -e "  ${RED}✗${NC} All Rising Tides plugins (38 plugins)"
echo -e "  ${RED}✗${NC} SKILLS_INDEX.json and registry files"
echo -e "  ${RED}✗${NC} ENABLE_TOOL_SEARCH from shell profile"
echo ""
echo -e "${YELLOW}This will NOT remove (you may still need these):${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Node.js (many tools depend on it)"
echo -e "  ${GREEN}✓${NC} Git (you definitely need this)"
echo -e "  ${GREEN}✓${NC} Python (many tools depend on it)"
echo -e "  ${GREEN}✓${NC} Homebrew (Mac package manager)"
echo ""
echo -e "${CYAN}After this, you'll need to reinstall from scratch:${NC}"
echo "  1. Run the setup script again"
echo "  2. Run 'claude auth login' to re-authenticate"
echo "  3. Reconfigure your settings"
echo ""

# -------------------------------------------
# Triple confirmation
# -------------------------------------------

echo -e "${RED}${BOLD}This action cannot be undone.${NC}"
echo ""
read -p "Type 'DELETE' to confirm you want to remove everything: " confirm1

if [ "$confirm1" != "DELETE" ]; then
    echo ""
    echo "Uninstall cancelled. Nothing was removed."
    echo ""
    exit 0
fi

echo ""
echo -e "${YELLOW}Are you absolutely sure?${NC}"
read -p "Type 'YES' to proceed with full uninstall: " confirm2

if [ "$confirm2" != "YES" ]; then
    echo ""
    echo "Uninstall cancelled. Nothing was removed."
    echo ""
    exit 0
fi

echo ""
echo -e "${RED}Starting full uninstall...${NC}"
echo ""

# -------------------------------------------
# Remove Claude Code CLI
# -------------------------------------------

echo -e "${YELLOW}[1/4] Removing Claude Code CLI...${NC}"

# Try common installation locations
removed_claude=false

# ~/.local/bin (native installer)
if [ -f "$HOME/.local/bin/claude" ]; then
    rm -f "$HOME/.local/bin/claude"
    echo "  Removed: ~/.local/bin/claude"
    removed_claude=true
fi

# /usr/local/bin (some installers)
if [ -f "/usr/local/bin/claude" ] && [ -w "/usr/local/bin/claude" ]; then
    rm -f "/usr/local/bin/claude"
    echo "  Removed: /usr/local/bin/claude"
    removed_claude=true
fi

# npm global (if installed via npm)
if command -v npm &> /dev/null; then
    if npm list -g @anthropic-ai/claude-code &> /dev/null 2>&1; then
        npm uninstall -g @anthropic-ai/claude-code 2>/dev/null
        echo "  Removed: npm global package"
        removed_claude=true
    fi
fi

if [ "$removed_claude" = true ]; then
    echo -e "  ${GREEN}✓ Claude Code removed${NC}"
else
    if command -v claude &> /dev/null; then
        echo -e "  ${YELLOW}! Claude found but couldn't remove automatically${NC}"
        echo "    Location: $(which claude)"
        echo "    Try: rm -f $(which claude)"
    else
        echo "  Not installed, skipping"
    fi
fi

# -------------------------------------------
# Remove entire ~/.claude directory
# -------------------------------------------

echo ""
echo -e "${YELLOW}[2/4] Removing Claude configuration directory...${NC}"

if [ -d "$CLAUDE_DIR" ]; then
    # Show what's being removed
    echo "  Contents of ~/.claude/:"
    ls -la "$CLAUDE_DIR" 2>/dev/null | head -10
    if [ $(ls -1 "$CLAUDE_DIR" 2>/dev/null | wc -l) -gt 10 ]; then
        echo "  ... and more"
    fi
    echo ""

    rm -rf "$CLAUDE_DIR"
    echo -e "  ${GREEN}✓ Removed ~/.claude/ and all contents${NC}"
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Clean up shell profiles
# -------------------------------------------

echo ""
echo -e "${YELLOW}[3/4] Cleaning up shell profiles...${NC}"

cleaned_profile=false

for profile in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ -f "$profile" ]; then
        if grep -q "ENABLE_TOOL_SEARCH" "$profile"; then
            # Remove ENABLE_TOOL_SEARCH lines
            sed -i.bak '/ENABLE_TOOL_SEARCH/d' "$profile"
            sed -i.bak '/Rising Tides - Tool Search/d' "$profile"
            rm -f "${profile}.bak"
            echo "  Cleaned: $profile"
            cleaned_profile=true
        fi
    fi
done

if [ "$cleaned_profile" = true ]; then
    echo -e "  ${GREEN}✓ Shell profiles cleaned${NC}"
else
    echo "  No Rising Tides entries found in shell profiles"
fi

# -------------------------------------------
# Remove any cached/temp files
# -------------------------------------------

echo ""
echo -e "${YELLOW}[4/4] Removing temporary files...${NC}"

# Remove any temp setup files
rm -f /tmp/setup.sh 2>/dev/null
rm -f /tmp/setup-mac.sh 2>/dev/null
rm -f /tmp/setup-linux.sh 2>/dev/null
rm -f /tmp/cleanup.sh 2>/dev/null

echo -e "  ${GREEN}✓ Temporary files cleaned${NC}"

# -------------------------------------------
# Final summary
# -------------------------------------------

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║              FULL UNINSTALL COMPLETE                         ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "The following have been removed:"
echo "  - Claude Code CLI"
echo "  - ~/.claude/ directory (all config, skills, plugins)"
echo "  - ENABLE_TOOL_SEARCH from shell profiles"
echo ""
echo -e "${CYAN}Still installed (you may want to keep these):${NC}"
echo "  - Node.js: $(node --version 2>/dev/null || echo 'not installed')"
echo "  - Git: $(git --version 2>/dev/null | head -1 || echo 'not installed')"
echo "  - Python: $(python3 --version 2>/dev/null || echo 'not installed')"
echo ""
echo -e "${YELLOW}To reinstall everything:${NC}"
echo ""
echo "  Mac:"
echo "    curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-mac.sh | bash"
echo ""
echo "  Linux/WSL2:"
echo "    curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-linux.sh | bash"
echo ""
echo "Questions? Visit: https://www.skool.com/rising-tides-9034"
echo ""
