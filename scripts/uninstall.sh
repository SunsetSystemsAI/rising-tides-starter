#!/bin/bash

# ===========================================
# Rising Tides - Uninstall Script
# ===========================================
# Removes Claude Code and Rising Tides components
# Does NOT remove Node.js or Git (you may need those)
# ===========================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
PLUGINS_DIR="$CLAUDE_DIR/plugins"

echo ""
echo -e "${RED}============================================${NC}"
echo -e "${RED}   Rising Tides - Uninstall                ${NC}"
echo -e "${RED}============================================${NC}"
echo ""
echo "This will remove:"
echo "  • Claude Code CLI"
echo "  • Claude configuration (~/.claude)"
echo "  • Rising Tides Skills Pack (~/.claude/skills/)"
echo "  • Rising Tides Plugins (~/.claude/plugins/)"
echo ""
echo -e "${YELLOW}This will NOT remove:${NC}"
echo "  • Node.js (you may need it for other projects)"
echo "  • Git (you may need it for other projects)"
echo ""

# Confirm overall uninstall
read -p "Are you sure you want to uninstall? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Uninstall cancelled."
    echo ""
    exit 0
fi

echo ""

# -------------------------------------------
# Remove Claude Code
# -------------------------------------------

echo -e "${YELLOW}[1/4] Claude Code CLI${NC}"

if command -v claude &> /dev/null; then
    read -p "  Remove Claude Code? (y/N): " remove_claude
    if [[ "$remove_claude" =~ ^[Yy]$ ]]; then
        echo "  Uninstalling Claude Code..."
        rm -f "$HOME/.local/bin/claude" 2>/dev/null
        if command -v claude &> /dev/null; then
            echo -e "  ${RED}Could not remove (try: rm -f ~/.local/bin/claude)${NC}"
        else
            echo -e "  ${GREEN}✓ Claude Code removed${NC}"
        fi
    else
        echo "  Skipped"
    fi
else
    echo "  Not installed, skipping"
fi

echo ""

# -------------------------------------------
# Remove Skills
# -------------------------------------------

echo -e "${YELLOW}[2/4] Rising Tides Skills${NC}"

if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(ls -1 "$SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    echo "  Found: $SKILLS_DIR ($SKILL_COUNT skills)"
    echo ""
    read -p "  Remove skills? (y/N): " remove_skills
    if [[ "$remove_skills" =~ ^[Yy]$ ]]; then
        rm -rf "$SKILLS_DIR"
        echo -e "  ${GREEN}✓ Skills removed${NC}"
    else
        echo "  Skipped (skills are preserved)"
    fi
else
    echo "  No skills found, skipping"
fi

echo ""

# -------------------------------------------
# Remove Plugins
# -------------------------------------------

echo -e "${YELLOW}[3/4] Rising Tides Plugins${NC}"

if [ -d "$PLUGINS_DIR" ]; then
    PLUGIN_COUNT=$(ls -1 "$PLUGINS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    echo "  Found: $PLUGINS_DIR ($PLUGIN_COUNT plugins)"
    echo ""
    read -p "  Remove plugins? (y/N): " remove_plugins
    if [[ "$remove_plugins" =~ ^[Yy]$ ]]; then
        rm -rf "$PLUGINS_DIR"
        echo -e "  ${GREEN}✓ Plugins removed${NC}"
    else
        echo "  Skipped (plugins are preserved)"
    fi
else
    echo "  No plugins found, skipping"
fi

echo ""

# -------------------------------------------
# Remove Claude Config
# -------------------------------------------

echo -e "${YELLOW}[4/4] Claude configuration${NC}"

if [ -d "$CLAUDE_DIR" ]; then
    echo "  Found: $CLAUDE_DIR"
    echo ""
    echo "  This contains:"
    echo "    • settings.json (your preferences)"
    echo "    • mcp.json (MCP configuration)"
    echo "    • SKILLS_INDEX.json"
    echo "    • Any cached data"
    echo ""
    read -p "  Remove ALL Claude configuration? (y/N): " remove_config
    if [[ "$remove_config" =~ ^[Yy]$ ]]; then
        rm -rf "$CLAUDE_DIR"
        echo -e "  ${GREEN}✓ Configuration removed${NC}"
    else
        echo "  Skipped (your settings are preserved)"
    fi
else
    echo "  No configuration found, skipping"
fi

echo ""

# -------------------------------------------
# Remove ENABLE_TOOL_SEARCH from profile
# -------------------------------------------

echo -e "${YELLOW}Cleaning up environment...${NC}"

# Check and offer to remove from shell profiles
for profile in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$profile" ] && grep -q "ENABLE_TOOL_SEARCH" "$profile"; then
        echo "  Found ENABLE_TOOL_SEARCH in $profile"
        read -p "  Remove it? (y/N): " remove_env
        if [[ "$remove_env" =~ ^[Yy]$ ]]; then
            sed -i.bak '/ENABLE_TOOL_SEARCH/d' "$profile"
            sed -i.bak '/Rising Tides - Tool Search/d' "$profile"
            rm -f "${profile}.bak"
            echo -e "  ${GREEN}✓ Removed from $profile${NC}"
        fi
    fi
done

echo ""

# -------------------------------------------
# Summary
# -------------------------------------------

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Uninstall Complete                      ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Removed components based on your selections."
echo ""
echo "To reinstall later, run the setup script again:"
echo -e "  ${GREEN}./scripts/setup-mac.sh${NC}  (Mac)"
echo -e "  ${GREEN}./scripts/setup-linux.sh${NC}  (Linux/WSL2)"
echo ""
echo "Questions? Visit: https://www.skool.com/rising-tides-9034"
echo ""
