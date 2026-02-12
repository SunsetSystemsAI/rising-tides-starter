#!/bin/bash

# ===========================================
# Rising Tides - Complete Mac Setup Script
# ===========================================
# This script installs everything you need:
# - Xcode Command Line Tools (build essentials)
# - Homebrew
# - Python 3
# - Git
# - Node.js 20
# - jq (JSON processor)
# - Claude Code
# - Rising Tides Skills Pack (bundled)
# ===========================================

set -e  # Exit on any error


BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_PACK_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Rising Tides - Complete Setup Script    ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Check this script is NOT run with sudo (causes Homebrew and PATH issues)
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script with sudo.${NC}"
    echo ""
    echo "Run it as your normal user. The script will ask for your"
    echo "password when it needs admin access."
    echo ""
    echo "Correct usage:"
    echo "  curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-mac.sh -o /tmp/setup.sh && bash /tmp/setup.sh"
    exit 1
fi

# -------------------------------------------
# Helper Functions
# -------------------------------------------

print_step() {
    echo ""
    echo -e "${BLUE}[$1/9]${NC} $2"
    echo "-------------------------------------------"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_skip() {
    echo -e "${YELLOW}⊘ $1 (already installed)${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# -------------------------------------------
# Step 1: Xcode Command Line Tools
# -------------------------------------------

print_step "1" "Checking Xcode Command Line Tools..."

if xcode-select -p &> /dev/null; then
    print_skip "Xcode Command Line Tools"
else
    print_info "Installing Xcode Command Line Tools..."
    print_info "A dialog may appear - click 'Install' to continue"
    xcode-select --install 2>/dev/null || true

    # Wait for installation
    echo "Waiting for Xcode tools installation..."
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    print_success "Xcode Command Line Tools installed"
fi

# -------------------------------------------
# Step 2: Install Homebrew
# -------------------------------------------

print_step "2" "Checking Homebrew..."

if command -v brew &> /dev/null; then
    print_skip "Homebrew"
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    print_success "Homebrew installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# -------------------------------------------
# Step 3: Install Python 3
# -------------------------------------------

print_step "3" "Checking Python 3..."

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_skip "Python 3 ($PYTHON_VERSION)"
else
    print_info "Installing Python 3..."
    brew install python@3
    print_success "Python 3 installed"
fi

# -------------------------------------------
# Step 4: Install Git
# -------------------------------------------

print_step "4" "Checking Git..."

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_skip "Git ($GIT_VERSION)"
else
    print_info "Installing Git..."
    brew install git
    print_success "Git installed"
fi

# -------------------------------------------
# Step 5: Install Node.js
# -------------------------------------------

print_step "5" "Checking Node.js..."

install_node() {
    print_info "Installing Node.js 20..."
    brew install node@20
    brew link --overwrite node@20 2>/dev/null || true

    # Add to PATH if needed
    if [[ -d "/opt/homebrew/opt/node@20/bin" ]]; then
        export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
        echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zshrc
    fi

    print_success "Node.js installed"
}

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        print_skip "Node.js $(node --version)"
    else
        print_info "Node.js version $NODE_VERSION is too old (need 18+), upgrading..."
        install_node
    fi
else
    install_node
fi

# Verify npm and npx
if command -v npm &> /dev/null; then
    print_skip "npm $(npm --version)"
else
    print_error "npm not found - try restarting terminal"
fi

if command -v npx &> /dev/null; then
    print_skip "npx $(npx --version)"
else
    print_error "npx not found - try restarting terminal"
fi

# -------------------------------------------
# Step 6: Install Claude Code
# -------------------------------------------

print_step "6" "Checking Claude Code..."

if command -v claude &> /dev/null; then
    print_skip "Claude Code $(claude --version 2>&1 | head -n1)"
    print_info "Updating Claude Code to latest..."
    claude update 2>/dev/null && print_success "Claude Code updated" || print_info "Already up to date (or update not available)"
else
    print_info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash -s latest

    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        SHELL_RC="$HOME/.zshrc"
        if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
            SHELL_RC="$HOME/.bashrc"
        fi
        if ! grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
            echo '' >> "$SHELL_RC"
            echo '# Claude Code' >> "$SHELL_RC"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        fi
    fi
    print_success "Claude Code installed"
fi

# -------------------------------------------
# Step 7: Install jq (useful for JSON processing)
# -------------------------------------------

print_step "7" "Checking utilities..."

if command -v jq &> /dev/null; then
    print_skip "jq"
else
    print_info "Installing jq (JSON processor)..."
    brew install jq
    print_success "jq installed"
fi

# -------------------------------------------
# Step 8: Configure Settings & Environment
# -------------------------------------------

print_step "8" "Configuring Claude Code..."

# Create Claude config directory
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/plugins"

if [ -f "$SETTINGS_FILE" ]; then
    print_info "Settings file exists, preserving..."
else
    print_info "Creating settings file with status line enabled..."
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "statusLine": true,
  "theme": "dark"
}
EOF
    print_success "Settings configured"
fi

# Add ENABLE_TOOL_SEARCH to shell profile if not present
SHELL_PROFILE="$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if ! grep -q "ENABLE_TOOL_SEARCH" "$SHELL_PROFILE" 2>/dev/null; then
    print_info "Adding ENABLE_TOOL_SEARCH to shell profile..."
    echo '' >> "$SHELL_PROFILE"
    echo '# Rising Tides - Tool Search for MCP efficiency' >> "$SHELL_PROFILE"
    echo 'export ENABLE_TOOL_SEARCH=true' >> "$SHELL_PROFILE"
    export ENABLE_TOOL_SEARCH=true
    print_success "Tool Search enabled"
else
    print_skip "ENABLE_TOOL_SEARCH already in profile"
fi

# -------------------------------------------
# Step 9: Install Rising Tides Skills Pack
# -------------------------------------------

print_step "9" "Installing Rising Tides Skills Pack..."

# Check if we're running from the starter pack directory (local install)
if [ -d "$STARTER_PACK_DIR/skills" ] && [ -d "$STARTER_PACK_DIR/plugins" ]; then
    print_info "Installing bundled skills pack..."

    # Copy skills
    if [ -d "$STARTER_PACK_DIR/skills" ]; then
        cp -r "$STARTER_PACK_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
        SKILL_COUNT=$(ls -1 "$CLAUDE_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')
        print_success "Copied $SKILL_COUNT skills to ~/.claude/skills/"
    fi

    # Copy plugins
    if [ -d "$STARTER_PACK_DIR/plugins" ]; then
        cp -r "$STARTER_PACK_DIR/plugins/"* "$CLAUDE_DIR/plugins/" 2>/dev/null || true
        PLUGIN_COUNT=$(ls -1 "$CLAUDE_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ')
        print_success "Copied $PLUGIN_COUNT plugins to ~/.claude/plugins/"
    fi

    # Copy index files
    if [ -f "$STARTER_PACK_DIR/SKILLS_INDEX.json" ]; then
        cp "$STARTER_PACK_DIR/SKILLS_INDEX.json" "$CLAUDE_DIR/"
        print_success "Copied SKILLS_INDEX.json"
    fi

    if [ -f "$STARTER_PACK_DIR/MCP_REGISTRY.md" ]; then
        cp "$STARTER_PACK_DIR/MCP_REGISTRY.md" "$CLAUDE_DIR/"
        print_success "Copied MCP_REGISTRY.md"
    fi

    if [ -f "$STARTER_PACK_DIR/ATTRIBUTION.md" ]; then
        cp "$STARTER_PACK_DIR/ATTRIBUTION.md" "$CLAUDE_DIR/"
        print_success "Copied ATTRIBUTION.md"
    fi

    INSTALL_SUCCESS=true
else
    # Remote install - download from GitHub
    print_info "Downloading Rising Tides Skills Pack from GitHub..."

    TEMP_DIR=$(mktemp -d)
    SKILLS_REPO="https://github.com/SunsetSystemsAI/rising-tides-starter.git"

    # Method 1: Try git clone
    DOWNLOAD_SUCCESS=false
    if command -v git &> /dev/null; then
        print_info "Trying git clone..."
        if git clone --depth 1 "$SKILLS_REPO" "$TEMP_DIR" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
        else
            print_info "Git clone did not succeed"
        fi
    fi

    # Method 2: Fall back to zip download
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
        print_info "Trying zip download..."
        ZIP_URL="https://github.com/SunsetSystemsAI/rising-tides-starter/archive/refs/heads/main.zip"
        ZIP_FILE="$TEMP_DIR/starter.zip"
        mkdir -p "$TEMP_DIR"
        if curl -fsSL "$ZIP_URL" -o "$ZIP_FILE" 2>/dev/null; then
            unzip -qo "$ZIP_FILE" -d "$TEMP_DIR" 2>/dev/null
            # Move extracted contents (GitHub zips create a subfolder)
            if [ -d "$TEMP_DIR/rising-tides-starter-main" ]; then
                mv "$TEMP_DIR/rising-tides-starter-main/"* "$TEMP_DIR/" 2>/dev/null || true
                rm -rf "$TEMP_DIR/rising-tides-starter-main"
            fi
            rm -f "$ZIP_FILE"
            DOWNLOAD_SUCCESS=true
        else
            print_info "Zip download did not succeed"
        fi
    fi

    if [ "$DOWNLOAD_SUCCESS" = true ]; then
        # Copy skills
        if [ -d "$TEMP_DIR/skills" ]; then
            cp -r "$TEMP_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
            SKILL_COUNT=$(ls -1 "$CLAUDE_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')
            print_success "Installed $SKILL_COUNT skills"
        fi

        # Copy plugins
        if [ -d "$TEMP_DIR/plugins" ]; then
            cp -r "$TEMP_DIR/plugins/"* "$CLAUDE_DIR/plugins/" 2>/dev/null || true
            PLUGIN_COUNT=$(ls -1 "$CLAUDE_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ')
            print_success "Installed $PLUGIN_COUNT plugins"
        fi

        # Copy index files
        [ -f "$TEMP_DIR/SKILLS_INDEX.json" ] && cp "$TEMP_DIR/SKILLS_INDEX.json" "$CLAUDE_DIR/"
        [ -f "$TEMP_DIR/MCP_REGISTRY.md" ] && cp "$TEMP_DIR/MCP_REGISTRY.md" "$CLAUDE_DIR/"
        [ -f "$TEMP_DIR/ATTRIBUTION.md" ] && cp "$TEMP_DIR/ATTRIBUTION.md" "$CLAUDE_DIR/"

        rm -rf "$TEMP_DIR"
        INSTALL_SUCCESS=true
    else
        print_error "Could not download skills pack from GitHub"
        echo ""
        echo -e "${YELLOW}This usually means one of:${NC}"
        echo "  1. The repository isn't public yet"
        echo "  2. Network/firewall blocking GitHub"
        echo ""
        echo -e "${YELLOW}What to do:${NC}"
        echo "  • Download the starter pack manually"
        echo "  • Run this script from the downloaded folder"
        echo "  • Join https://www.skool.com/rising-tides-9034 for support"
        echo ""
        rm -rf "$TEMP_DIR"
        INSTALL_SUCCESS=false
    fi
fi

# -------------------------------------------
# Optional: Set up Memory MCP
# -------------------------------------------

echo ""
echo -e "${BLUE}Optional: Persistent Memory MCP${NC}"
echo ""
echo "The Memory MCP lets Claude remember things across sessions."
echo "It stores knowledge in a file on your Desktop for easy access."
echo ""
read -p "Set up Memory MCP? (y/N): " setup_memory

if [[ "$setup_memory" =~ ^[Yy]$ ]]; then
    print_info "Configuring Memory MCP..."

    # Get username for path
    USERNAME=$(whoami)
    MEMORY_PATH="/Users/$USERNAME/Desktop/claude-memory.jsonl"

    # Use Claude CLI to add memory MCP
    if command -v claude &> /dev/null; then
        claude mcp add memory --scope user -- npx -y @modelcontextprotocol/server-memory --memory-path "$MEMORY_PATH" 2>/dev/null || {
            print_info "Could not auto-configure. Add manually after setup."
        }
        print_success "Memory MCP configured (file: ~/Desktop/claude-memory.jsonl)"
    else
        print_info "Claude CLI not available. Configure memory MCP manually after restarting."
    fi
else
    print_info "Skipped Memory MCP setup (you can add later with 'claude mcp add memory --scope user')"
fi

# -------------------------------------------
# Summary
# -------------------------------------------

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Setup Complete!                          ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Installed components:"
echo "  ✓ Xcode Command Line Tools"
echo "  ✓ Homebrew"
echo "  ✓ Python 3"
echo "  ✓ Git $(git --version 2>/dev/null | cut -d' ' -f3 || echo 'N/A')"
echo "  ✓ Node.js $(node --version 2>/dev/null || echo 'N/A')"
echo "  ✓ npm $(npm --version 2>/dev/null || echo 'N/A')"
echo "  ✓ jq"
echo "  ✓ Claude Code"
echo "  ✓ Status line enabled"
echo "  ✓ Tool Search enabled (ENABLE_TOOL_SEARCH=true)"

# Show skills summary if installed
if [ "$INSTALL_SUCCESS" = true ] && [ -d "$CLAUDE_DIR/skills" ]; then
    SKILL_COUNT=$(ls -1 "$CLAUDE_DIR/skills" 2>/dev/null | wc -l | tr -d ' ')
    PLUGIN_COUNT=$(ls -1 "$CLAUDE_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✓ Rising Tides Skills Pack ($SKILL_COUNT skills, $PLUGIN_COUNT plugins)"
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   Welcome to Rising Tides!                ${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "What you got:"
    echo "  • Marketing & SEO      — copywriting, seo-audit, marketing-psychology"
    echo "  • Frontend Dev         — react-dev, frontend-design, web-design-guidelines"
    echo "  • Backend & Database   — supabase-guide, firebase-guide, drizzle-orm"
    echo "  • Workflow & Git       — commit-work, github-workflow, session-handoff"
    echo "  • Deployment           — vercel-deployment, netlify-deployment"
    echo "  • Documentation        — mermaid-diagrams, c4-architecture, pdf, docx"
    echo "  • Design & Media       — canvas-design, video-generator, excalidraw"
    echo "  • Payments             — stripe-integration"
    echo "  • And much more!"
    echo ""
else
    echo "  ⚠ Skills Pack: See above for manual install instructions"
    echo ""
fi

echo "Skills location: ~/.claude/skills/"
echo "Plugins location: ~/.claude/plugins/"
echo ""
echo -e "${RED}============================================${NC}"
echo -e "${RED}   ⚠️  IMPORTANT: OPEN A NEW TERMINAL ⚠️     ${NC}"
echo -e "${RED}============================================${NC}"
echo ""
echo -e "  ${YELLOW}Close this terminal and open a NEW one.${NC}"
echo "  The 'claude' command won't work in this window."
echo ""
echo "  Or run this command to fix it now:"
echo -e "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
echo ""
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}   NEXT STEPS (in the new terminal)        ${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""
echo "  1. Authenticate Claude Code:"
echo -e "     ${GREEN}claude auth login${NC}"
echo ""
echo "  2. Navigate to a project folder:"
echo -e "     ${GREEN}cd ~/my-project${NC}"
echo ""
echo "  3. Start Claude Code from your project:"
echo -e "     ${GREEN}claude${NC}"
echo ""
echo "  4. Get skill recommendations for your project:"
echo -e "     ${GREEN}/recommend skills${NC}"
echo ""
echo "  5. Or try skills directly:"
echo -e "     ${GREEN}/copywriting${NC} write a headline for my SaaS"
echo -e "     ${GREEN}/react-dev${NC} create a login form component"
echo -e "     ${GREEN}/commit-work${NC} review and commit my changes"
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Need Help? Join the Community           ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "  ${GREEN}https://www.skool.com/rising-tides-9034${NC}"
echo ""
echo "  Get support, share wins, and connect with other users."
echo ""
