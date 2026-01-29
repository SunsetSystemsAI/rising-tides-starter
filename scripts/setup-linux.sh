#!/bin/bash

# ===========================================
# Rising Tides - Complete Linux Setup Script
# ===========================================
# This script installs everything you need:
# - Build essentials (gcc, g++, make)
# - Python 3 (for node-gyp)
# - curl (for downloads)
# - Git
# - Node.js 20
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

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

PKG_MANAGER=$(detect_package_manager)
echo "Detected package manager: $PKG_MANAGER"

# -------------------------------------------
# Step 1: Update package manager
# -------------------------------------------

print_step "1" "Updating package manager..."

case $PKG_MANAGER in
    apt)
        sudo apt-get update -y
        print_success "Package lists updated"
        ;;
    dnf)
        sudo dnf check-update -y || true
        print_success "Package lists updated"
        ;;
    yum)
        sudo yum check-update -y || true
        print_success "Package lists updated"
        ;;
    pacman)
        sudo pacman -Sy
        print_success "Package lists updated"
        ;;
    *)
        print_error "Unknown package manager. Some installs may fail."
        ;;
esac

# -------------------------------------------
# Step 2: Install build essentials
# -------------------------------------------

print_step "2" "Checking build tools (gcc, g++, make)..."

NEED_BUILD_TOOLS=false

if ! command -v gcc &> /dev/null; then
    NEED_BUILD_TOOLS=true
fi

if ! command -v g++ &> /dev/null; then
    NEED_BUILD_TOOLS=true
fi

if ! command -v make &> /dev/null; then
    NEED_BUILD_TOOLS=true
fi

if [ "$NEED_BUILD_TOOLS" = true ]; then
    print_info "Installing build essentials..."
    case $PKG_MANAGER in
        apt)
            sudo apt-get install -y build-essential
            ;;
        dnf)
            sudo dnf groupinstall -y "Development Tools"
            ;;
        yum)
            sudo yum groupinstall -y "Development Tools"
            ;;
        pacman)
            sudo pacman -S --noconfirm base-devel
            ;;
    esac
    print_success "Build tools installed"
else
    print_skip "Build tools (gcc $(gcc --version 2>/dev/null | head -1 | cut -d' ' -f3))"
fi

# -------------------------------------------
# Step 3: Install Python 3
# -------------------------------------------

print_step "3" "Checking Python 3..."

if command -v python3 &> /dev/null; then
    print_skip "Python 3 ($(python3 --version 2>&1 | cut -d' ' -f2))"
else
    print_info "Installing Python 3..."
    case $PKG_MANAGER in
        apt)
            sudo apt-get install -y python3 python3-pip
            ;;
        dnf)
            sudo dnf install -y python3 python3-pip
            ;;
        yum)
            sudo yum install -y python3 python3-pip
            ;;
        pacman)
            sudo pacman -S --noconfirm python python-pip
            ;;
    esac
    print_success "Python 3 installed"
fi

# -------------------------------------------
# Step 4: Install curl
# -------------------------------------------

print_step "4" "Checking curl..."

if command -v curl &> /dev/null; then
    print_skip "curl"
else
    print_info "Installing curl..."
    case $PKG_MANAGER in
        apt)
            sudo apt-get install -y curl
            ;;
        dnf)
            sudo dnf install -y curl
            ;;
        yum)
            sudo yum install -y curl
            ;;
        pacman)
            sudo pacman -S --noconfirm curl
            ;;
    esac
    print_success "curl installed"
fi

# -------------------------------------------
# Step 5: Install Git
# -------------------------------------------

print_step "5" "Checking Git..."

if command -v git &> /dev/null; then
    print_skip "Git $(git --version | cut -d' ' -f3)"
else
    print_info "Installing Git..."
    case $PKG_MANAGER in
        apt)
            sudo apt-get install -y git
            ;;
        dnf)
            sudo dnf install -y git
            ;;
        yum)
            sudo yum install -y git
            ;;
        pacman)
            sudo pacman -S --noconfirm git
            ;;
    esac
    print_success "Git installed"
fi

# -------------------------------------------
# Step 6: Install Node.js
# -------------------------------------------

print_step "6" "Checking Node.js..."

install_node() {
    print_info "Installing Node.js 20..."
    case $PKG_MANAGER in
        apt)
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        dnf)
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo dnf install -y nodejs
            ;;
        yum)
            curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
            sudo yum install -y nodejs
            ;;
        pacman)
            sudo pacman -S --noconfirm nodejs npm
            ;;
    esac
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
    print_error "npm not found after Node.js install"
fi

if command -v npx &> /dev/null; then
    print_skip "npx $(npx --version)"
else
    print_error "npx not found after Node.js install"
fi

# -------------------------------------------
# Step 7: Install Claude Code
# -------------------------------------------

print_step "7" "Checking Claude Code..."

if command -v claude &> /dev/null; then
    print_skip "Claude Code $(claude --version 2>&1 | head -n1)"
    print_info "Updating Claude Code to latest..."
    claude update 2>/dev/null && print_success "Claude Code updated" || print_info "Already up to date (or update not available)"
else
    print_info "Installing Claude Code..."
    curl -fsSL https://cli.anthropic.com/install.sh | sh
    print_success "Claude Code installed"
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
SHELL_PROFILE="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
fi

if ! grep -q "ENABLE_TOOL_SEARCH" "$SHELL_PROFILE" 2>/dev/null; then
    print_info "Adding ENABLE_TOOL_SEARCH to shell profile..."
    echo '' >> "$SHELL_PROFILE"
    echo '# Rising Tides - Tool Search for MCP efficiency' >> "$SHELL_PROFILE"
    echo 'export ENABLE_TOOL_SEARCH=auto' >> "$SHELL_PROFILE"
    export ENABLE_TOOL_SEARCH=auto
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
    SKILLS_REPO="https://github.com/TinyShaft22/rising-tides-starter.git"

    if git clone --depth 1 "$SKILLS_REPO" "$TEMP_DIR" 2>/dev/null; then
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
        echo "  • Join https://skool.com/rising-tides for support"
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

    # Get username for path - handle both regular Linux and WSL
    USERNAME=$(whoami)

    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # WSL - use Windows Desktop path
        WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        MEMORY_PATH="/mnt/c/Users/$WINDOWS_USER/Desktop/claude-memory.jsonl"
    else
        # Regular Linux
        MEMORY_PATH="/home/$USERNAME/Desktop/claude-memory.jsonl"
        # Create Desktop if it doesn't exist
        mkdir -p "/home/$USERNAME/Desktop"
    fi

    # Use Claude CLI to add memory MCP
    if command -v claude &> /dev/null; then
        claude mcp add memory --scope user -- npx -y @modelcontextprotocol/server-memory --memory-path "$MEMORY_PATH" 2>/dev/null || {
            print_info "Could not auto-configure. Add manually after setup."
        }
        print_success "Memory MCP configured (file: $MEMORY_PATH)"
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
echo "  ✓ Build tools (gcc, g++, make)"
echo "  ✓ Python 3"
echo "  ✓ curl"
echo "  ✓ Git $(git --version 2>/dev/null | cut -d' ' -f3 || echo 'N/A')"
echo "  ✓ Node.js $(node --version 2>/dev/null || echo 'N/A')"
echo "  ✓ npm $(npm --version 2>/dev/null || echo 'N/A')"
echo "  ✓ Claude Code"
echo "  ✓ Status line enabled"
echo "  ✓ Tool Search enabled (ENABLE_TOOL_SEARCH=auto)"

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
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}   NEXT STEPS                              ${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""
echo "  1. Authenticate Claude Code:"
echo -e "     ${GREEN}claude auth login${NC}"
echo ""
echo "  2. Start Claude Code:"
echo -e "     ${GREEN}claude${NC}"
echo ""
echo "  3. Get skill recommendations for any project:"
echo -e "     ${GREEN}/recommend skills${NC}"
echo ""
echo "  4. Or try skills directly:"
echo -e "     ${GREEN}/copywriting${NC} write a headline for my SaaS"
echo -e "     ${GREEN}/react-dev${NC} create a login form component"
echo -e "     ${GREEN}/commit-work${NC} review and commit my changes"
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Need Help? Join the Community           ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "  ${GREEN}https://skool.com/rising-tides${NC}"
echo ""
echo "  Get support, share wins, and connect with other users."
echo ""
