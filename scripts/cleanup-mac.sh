#!/bin/bash

# ===========================================
# Rising Tides - Mac Cleanup Script
# Undoes everything the setup script installed
# ===========================================

# Re-exec from temp file if piped via curl | bash (stdin not available for prompts)
if [ -z "${__RT_FROM_FILE:-}" ]; then
    TMPSCRIPT=$(mktemp /tmp/rt-cleanup-XXXXXXXX) || TMPSCRIPT="/tmp/rt-cleanup-$$.sh"
    curl -fsSL "https://raw.githubusercontent.com/TinyShaft22/rising-tides-starter/main/scripts/cleanup-mac.sh" -o "$TMPSCRIPT" 2>/dev/null || true
    if [ -s "$TMPSCRIPT" ]; then
        export __RT_FROM_FILE=1
        exec bash "$TMPSCRIPT" "$@"
    fi
    rm -f "$TMPSCRIPT" 2>/dev/null || true
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${RED}============================================${NC}"
echo -e "${RED}   Rising Tides - Cleanup / Uninstall      ${NC}"
echo -e "${RED}============================================${NC}"
echo ""
echo "This will remove everything the setup script installed:"
echo "  • Claude Code"
echo "  • Rising Tides skills, plugins, settings"
echo "  • Node.js 20 (via Homebrew)"
echo "  • jq (via Homebrew)"
echo "  • Homebrew itself"
echo "  • Shell profile additions"
echo ""
echo -e "${YELLOW}Xcode CLI Tools, Python, and Git will NOT be removed${NC}"
echo -e "${YELLOW}(they're macOS essentials you likely want to keep)${NC}"
echo ""
read -p "Are you sure? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# 1. Remove Claude Code
echo -e "${YELLOW}[1/6] Removing Claude Code...${NC}"
if command -v claude &> /dev/null; then
    # Remove the binary
    CLAUDE_BIN=$(which claude 2>/dev/null)
    if [ -n "$CLAUDE_BIN" ]; then
        rm -f "$CLAUDE_BIN" 2>/dev/null || sudo rm -f "$CLAUDE_BIN"
        echo "  Removed $CLAUDE_BIN"
    fi
fi
# Remove ~/.claude directory (skills, plugins, settings, all of it)
if [ -d "$HOME/.claude" ]; then
    rm -rf "$HOME/.claude"
    echo "  Removed ~/.claude/"
fi
# Remove claude local data
rm -rf "$HOME/.local/share/claude" 2>/dev/null
rm -rf "$HOME/.config/claude" 2>/dev/null
echo -e "${GREEN}  Done${NC}"

# 2. Remove memory file if it exists
echo -e "${YELLOW}[2/6] Removing memory file...${NC}"
if [ -f "$HOME/Desktop/claude-memory.jsonl" ]; then
    rm -f "$HOME/Desktop/claude-memory.jsonl"
    echo "  Removed ~/Desktop/claude-memory.jsonl"
else
    echo "  No memory file found"
fi
echo -e "${GREEN}  Done${NC}"

# 3. Uninstall Homebrew packages
echo -e "${YELLOW}[3/6] Removing Homebrew packages...${NC}"
if command -v brew &> /dev/null; then
    brew uninstall node@20 2>/dev/null && echo "  Removed node@20" || echo "  node@20 not installed"
    brew uninstall jq 2>/dev/null && echo "  Removed jq" || echo "  jq not installed"
    # Clean up unused dependencies
    brew autoremove 2>/dev/null
    brew cleanup 2>/dev/null
    echo -e "${GREEN}  Done${NC}"
else
    echo "  Homebrew not found, skipping"
fi

# 4. Uninstall Homebrew
echo -e "${YELLOW}[4/6] Removing Homebrew...${NC}"
if command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    echo -e "${GREEN}  Done${NC}"
else
    echo "  Homebrew not found, skipping"
fi
# Clean up Homebrew leftovers
sudo rm -rf /opt/homebrew 2>/dev/null || true
sudo rm -f /etc/paths.d/homebrew 2>/dev/null || true

# 5. Clean shell profiles
echo -e "${YELLOW}[5/6] Cleaning shell profiles...${NC}"
for PROFILE in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ -f "$PROFILE" ]; then
        # Remove Rising Tides lines
        sed -i '' '/ENABLE_TOOL_SEARCH/d' "$PROFILE" 2>/dev/null
        sed -i '' '/Rising Tides/d' "$PROFILE" 2>/dev/null
        # Remove Homebrew lines
        sed -i '' '/homebrew\/bin\/brew shellenv/d' "$PROFILE" 2>/dev/null
        sed -i '' '/opt\/homebrew/d' "$PROFILE" 2>/dev/null
        # Remove node@20 PATH lines
        sed -i '' '/node@20/d' "$PROFILE" 2>/dev/null
        # Remove claude PATH lines
        sed -i '' '/\.local\/bin/d' "$PROFILE" 2>/dev/null
        echo "  Cleaned $PROFILE"
    fi
done
echo -e "${GREEN}  Done${NC}"

# 6. Remove npm/node caches
echo -e "${YELLOW}[6/6] Cleaning caches...${NC}"
rm -rf "$HOME/.npm" 2>/dev/null && echo "  Removed ~/.npm/" || true
rm -rf "$HOME/.node-gyp" 2>/dev/null && echo "  Removed ~/.node-gyp/" || true
echo -e "${GREEN}  Done${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Cleanup Complete                        ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Everything has been removed. To start fresh:"
echo ""
echo "  1. Restart your terminal"
echo "  2. Run the setup script:"
echo "     curl -fsSL https://raw.githubusercontent.com/TinyShaft22/rising-tides-starter/main/scripts/setup-mac.sh | bash"
echo ""
