#!/bin/bash

# ===========================================
# Rising Tides - Uninstall Skills Pack Only
# ===========================================
# Removes ONLY the Rising Tides content:
#   - Skills (~/.claude/skills/)
#   - Plugins (~/.claude/plugins/)
#   - Index file (SKILLS_INDEX.json)
#   - Registry files (MCP_REGISTRY.md, ATTRIBUTION.md)
#
# DOES NOT REMOVE:
#   - Claude Code CLI
#   - Your Claude settings/config
#   - Node.js, Git, or any prerequisites
# ===========================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
PLUGINS_DIR="$CLAUDE_DIR/plugins"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   Uninstall Rising Tides Skills Pack      ${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo -e "${GREEN}This script removes ONLY the Rising Tides content.${NC}"
echo ""
echo "What will be removed:"
echo "  - Skills folder (~/.claude/skills/)"
echo "  - Plugins folder (~/.claude/plugins/)"
echo "  - SKILLS_INDEX.json"
echo "  - MCP_REGISTRY.md"
echo "  - ATTRIBUTION.md"
echo "  - SECURITY.md"
echo ""
echo -e "${GREEN}What stays INTACT:${NC}"
echo "  - Claude Code CLI (still installed)"
echo "  - Your settings.json (preferences preserved)"
echo "  - Your mcp.json (MCP config preserved)"
echo "  - Node.js, Git, and all prerequisites"
echo ""
echo -e "${YELLOW}Use case: You pulled skills globally, ran /recommend skills,${NC}"
echo -e "${YELLOW}imported what you need to your project, now cleaning up global.${NC}"
echo ""

# Confirm
read -p "Remove Rising Tides Skills Pack? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Cancelled. Nothing was removed."
    echo ""
    exit 0
fi

echo ""
removed_count=0

# -------------------------------------------
# Remove Skills
# -------------------------------------------

echo -e "${YELLOW}[1/6] Skills${NC}"
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(ls -1 "$SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$SKILLS_DIR"
    echo -e "  ${GREEN}✓ Removed $SKILL_COUNT skills${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Remove Plugins
# -------------------------------------------

echo -e "${YELLOW}[2/6] Plugins${NC}"
if [ -d "$PLUGINS_DIR" ]; then
    PLUGIN_COUNT=$(ls -1 "$PLUGINS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "$PLUGINS_DIR"
    echo -e "  ${GREEN}✓ Removed $PLUGIN_COUNT plugins${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Remove Index File
# -------------------------------------------

echo -e "${YELLOW}[3/6] SKILLS_INDEX.json${NC}"
if [ -f "$CLAUDE_DIR/SKILLS_INDEX.json" ]; then
    rm -f "$CLAUDE_DIR/SKILLS_INDEX.json"
    echo -e "  ${GREEN}✓ Removed${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Remove MCP Registry
# -------------------------------------------

echo -e "${YELLOW}[4/6] MCP_REGISTRY.md${NC}"
if [ -f "$CLAUDE_DIR/MCP_REGISTRY.md" ]; then
    rm -f "$CLAUDE_DIR/MCP_REGISTRY.md"
    echo -e "  ${GREEN}✓ Removed${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Remove Attribution
# -------------------------------------------

echo -e "${YELLOW}[5/6] ATTRIBUTION.md${NC}"
if [ -f "$CLAUDE_DIR/ATTRIBUTION.md" ]; then
    rm -f "$CLAUDE_DIR/ATTRIBUTION.md"
    echo -e "  ${GREEN}✓ Removed${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

# -------------------------------------------
# Remove Security Doc
# -------------------------------------------

echo -e "${YELLOW}[6/6] SECURITY.md${NC}"
if [ -f "$CLAUDE_DIR/SECURITY.md" ]; then
    rm -f "$CLAUDE_DIR/SECURITY.md"
    echo -e "  ${GREEN}✓ Removed${NC}"
    ((removed_count++))
else
    echo "  Not found, skipping"
fi

echo ""

# -------------------------------------------
# Summary
# -------------------------------------------

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Skills Pack Removed                     ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Removed $removed_count Rising Tides components."
echo ""
echo -e "${CYAN}Still installed:${NC}"
echo "  - Claude Code CLI: $(command -v claude 2>/dev/null || echo 'not in PATH')"
echo "  - Node.js: $(node --version 2>/dev/null || echo 'not installed')"
echo "  - Git: $(git --version 2>/dev/null | head -1 || echo 'not installed')"
echo ""
echo "Your Claude configuration is preserved:"
echo "  - ~/.claude/settings.json"
echo "  - ~/.claude/mcp.json"
echo ""
echo -e "${YELLOW}To reinstall the Skills Pack:${NC}"
echo "  Run the setup script again"
echo ""
echo -e "${RED}To remove EVERYTHING (Claude Code + prerequisites):${NC}"
echo "  Run: ./scripts/uninstall-full.sh"
echo ""
