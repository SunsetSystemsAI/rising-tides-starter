#!/bin/bash

# ===========================================
# Rising Tides - Setup Verification Script
# ===========================================
# Checks that everything is installed correctly
# Run this after setup to verify your environment
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
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Rising Tides - Setup Verification       ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo -e "${GREEN}✓ PASS${NC} $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}✗ FAIL${NC} $1"
    echo -e "  ${YELLOW}→ $2${NC}"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}⚠ WARN${NC} $1"
    echo -e "  ${YELLOW}→ $2${NC}"
}

# -------------------------------------------
# Check Node.js
# -------------------------------------------

echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        check_pass "Node.js $(node --version)"
    else
        check_fail "Node.js $(node --version) - too old" "Need Node.js 18+. Run: brew install node@20 (Mac) or reinstall"
    fi
else
    check_fail "Node.js not found" "Install Node.js 18+ first"
fi

# -------------------------------------------
# Check npm
# -------------------------------------------

if command -v npm &> /dev/null; then
    check_pass "npm $(npm --version)"
else
    check_fail "npm not found" "npm should come with Node.js. Reinstall Node.js"
fi

# -------------------------------------------
# Check npx
# -------------------------------------------

if command -v npx &> /dev/null; then
    check_pass "npx $(npx --version)"
else
    check_fail "npx not found" "npx should come with Node.js. Reinstall Node.js"
fi

# -------------------------------------------
# Check Git
# -------------------------------------------

if command -v git &> /dev/null; then
    check_pass "Git $(git --version | cut -d' ' -f3)"
else
    check_fail "Git not found" "Install Git: brew install git (Mac) or apt install git (Linux)"
fi

# -------------------------------------------
# Check Claude Code
# -------------------------------------------

echo ""
echo -e "${BLUE}Checking Claude Code...${NC}"
echo ""

if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -n1)
    check_pass "Claude Code installed ($CLAUDE_VERSION)"
else
    check_fail "Claude Code not found" "Install: curl -fsSL https://claude.ai/install.sh | bash -s latest"
fi

# -------------------------------------------
# Check Claude Auth
# -------------------------------------------

if command -v claude &> /dev/null; then
    AUTH_STATUS=$(claude auth status 2>&1)
    if echo "$AUTH_STATUS" | grep -qi "authenticated\|logged in\|valid"; then
        check_pass "Claude authenticated"
    else
        check_warn "Claude not authenticated" "Run: claude auth login"
    fi
fi

# -------------------------------------------
# Check Settings
# -------------------------------------------

echo ""
echo -e "${BLUE}Checking configuration...${NC}"
echo ""

SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    check_pass "Settings file exists (~/.claude/settings.json)"

    if grep -q '"statusLine".*true' "$SETTINGS_FILE" 2>/dev/null; then
        check_pass "Status line enabled"
    else
        check_warn "Status line not enabled" "Add \"statusLine\": true to settings.json"
    fi
else
    check_fail "Settings file missing" "Create ~/.claude/settings.json"
fi

# -------------------------------------------
# Check Tool Search
# -------------------------------------------

if [ "$ENABLE_TOOL_SEARCH" = "auto" ]; then
    check_pass "Tool Search enabled (ENABLE_TOOL_SEARCH=auto)"
else
    check_warn "Tool Search not enabled" "Add 'export ENABLE_TOOL_SEARCH=auto' to your shell profile"
fi

# -------------------------------------------
# Check Memory MCP (optional)
# -------------------------------------------

if command -v claude &> /dev/null; then
    MCP_LIST=$(claude mcp list 2>&1)
    if echo "$MCP_LIST" | grep -qi "memory"; then
        check_pass "Memory MCP configured"
    else
        check_warn "Memory MCP not configured" "Optional: Run 'claude mcp add memory --scope user'"
    fi
fi

# -------------------------------------------
# Check Skills Pack
# -------------------------------------------

echo ""
echo -e "${BLUE}Checking skills pack...${NC}"
echo ""

if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=$(ls -1 "$SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SKILL_COUNT" -gt 0 ]; then
        check_pass "Skills installed: $SKILL_COUNT skills in ~/.claude/skills/"
    else
        check_fail "Skills directory empty" "Re-run setup script"
    fi
else
    check_fail "Skills not installed" "Run the setup script to install skills to ~/.claude/skills/"
fi

if [ -d "$PLUGINS_DIR" ]; then
    PLUGIN_COUNT=$(ls -1 "$PLUGINS_DIR" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$PLUGIN_COUNT" -gt 0 ]; then
        check_pass "Plugins installed: $PLUGIN_COUNT plugins in ~/.claude/plugins/"
    else
        check_warn "No plugins found" "Plugins should be in ~/.claude/plugins/"
    fi
else
    check_warn "Plugins directory missing" "Plugins should be in ~/.claude/plugins/"
fi

# -------------------------------------------
# Check Index File
# -------------------------------------------

if [ -f "$CLAUDE_DIR/SKILLS_INDEX.json" ]; then
    check_pass "SKILLS_INDEX.json exists"
else
    check_fail "SKILLS_INDEX.json missing" "Copy from starter pack to ~/.claude/"
fi

if [ -f "$CLAUDE_DIR/MCP_REGISTRY.md" ]; then
    check_pass "MCP_REGISTRY.md exists"
else
    check_warn "MCP_REGISTRY.md missing" "Copy from starter pack to ~/.claude/"
fi

# -------------------------------------------
# Summary
# -------------------------------------------

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Verification Summary                    ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All checks passed! ($PASS_COUNT passed)${NC}"
    echo ""
    echo "Your Rising Tides environment is ready."
    echo ""
    echo "Start Claude Code:"
    echo -e "  ${GREEN}claude${NC}"
    echo ""
    echo "Get skill recommendations:"
    echo -e "  ${GREEN}/recommend skills${NC}"
    echo ""
    echo "Try a skill:"
    echo -e "  ${GREEN}/copywriting${NC} write a headline for my SaaS"
    echo ""
else
    echo -e "${RED}$FAIL_COUNT check(s) failed${NC}, ${GREEN}$PASS_COUNT passed${NC}"
    echo ""
    echo "Fix the issues above, then run this script again."
    echo ""
fi

# -------------------------------------------
# Support
# -------------------------------------------

echo "Need help? Join the community:"
echo -e "  ${BLUE}https://www.skool.com/rising-tides-9034${NC}"
echo ""
