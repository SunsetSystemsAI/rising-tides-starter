#!/bin/bash

# ===========================================
# Rising Tides - Uninstall Menu
# ===========================================
# Choose what to uninstall:
#   1. Skills Pack only (keep Claude Code)
#   2. Everything (full reset)
# ===========================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   Rising Tides - Uninstall                ${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Choose what to uninstall:"
echo ""
echo -e "${GREEN}  [1] Skills Pack Only${NC} (Recommended)"
echo "      Removes: skills, plugins, index files"
echo "      Keeps: Claude Code, settings, prerequisites"
echo "      Use this if you just want to clean up global skills"
echo ""
echo -e "${RED}  [2] EVERYTHING (Full Reset)${NC}"
echo "      Removes: Claude Code, ALL configuration, skills, plugins"
echo "      Keeps: Node.js, Git, Python (you may need these)"
echo "      ⚠️  WARNING: This cannot be undone!"
echo ""
echo -e "  [3] Cancel"
echo ""

read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo "Running Skills Pack uninstall..."
        echo ""
        if [ -f "$SCRIPT_DIR/uninstall-skills.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-skills.sh"
        else
            # Inline fallback if script not found
            echo -e "${RED}Error: uninstall-skills.sh not found${NC}"
            echo "Expected location: $SCRIPT_DIR/uninstall-skills.sh"
            echo ""
            echo "You can download it from:"
            echo "  https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.sh"
        fi
        ;;
    2)
        echo ""
        echo -e "${RED}Running FULL uninstall...${NC}"
        echo ""
        if [ -f "$SCRIPT_DIR/uninstall-full.sh" ]; then
            bash "$SCRIPT_DIR/uninstall-full.sh"
        else
            # Inline fallback if script not found
            echo -e "${RED}Error: uninstall-full.sh not found${NC}"
            echo "Expected location: $SCRIPT_DIR/uninstall-full.sh"
            echo ""
            echo "You can download it from:"
            echo "  https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.sh"
        fi
        ;;
    3|*)
        echo ""
        echo "Cancelled. Nothing was removed."
        echo ""
        ;;
esac
