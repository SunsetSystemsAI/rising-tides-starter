#!/bin/bash

# Rising Tides Starter Pack - Prerequisites Checker
# For Mac and Linux

echo "========================================"
echo "  Rising Tides Prerequisites Checker"
echo "========================================"
echo ""

PASS=0
FAIL=0

check_command() {
    local cmd=$1
    local name=$2
    local min_version=$3

    if command -v "$cmd" &> /dev/null; then
        version=$($cmd --version 2>&1 | head -n1)
        echo "[PASS] $name is installed"
        echo "       Version: $version"
        ((PASS++))
        return 0
    else
        echo "[FAIL] $name is NOT installed"
        echo "       Required: $min_version+"
        ((FAIL++))
        return 1
    fi
}

echo "Checking required software..."
echo "----------------------------------------"

# Check Node.js
check_command "node" "Node.js" "18.0.0"
echo ""

# Check npm
check_command "npm" "npm" "8.0.0"
echo ""

# Check Git
check_command "git" "Git" "2.30.0"
echo ""

echo "Checking optional software..."
echo "----------------------------------------"

# Check Claude Code
if command -v "claude" &> /dev/null; then
    version=$(claude --version 2>&1 | head -n1)
    echo "[PASS] Claude Code is installed"
    echo "       Version: $version"
    ((PASS++))
else
    echo "[INFO] Claude Code is NOT installed"
    echo "       Install with: curl -fsSL https://cli.anthropic.com/install.sh | sh"
fi
echo ""

# Check VS Code (optional)
if command -v "code" &> /dev/null; then
    echo "[PASS] VS Code is installed"
    ((PASS++))
else
    echo "[INFO] VS Code is not installed (optional)"
fi
echo ""

# Check Homebrew (Mac only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v "brew" &> /dev/null; then
        echo "[PASS] Homebrew is installed"
        ((PASS++))
    else
        echo "[INFO] Homebrew is not installed (recommended for Mac)"
        echo "       Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
    echo ""
fi

echo "========================================"
echo "  Summary"
echo "========================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "[SUCCESS] All prerequisites are installed!"
    echo ""
    echo "Next step: Install Claude Code"
    echo "  curl -fsSL https://cli.anthropic.com/install.sh | sh"
    echo "  claude auth login"
else
    echo "[ACTION REQUIRED] Please install missing prerequisites"
    echo ""
    echo "Quick install commands:"
    echo ""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Mac (using Homebrew):"
        echo "  brew install node@20 git"
    else
        echo "Linux (Ubuntu/Debian):"
        echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
        echo "  sudo apt-get install -y nodejs git"
    fi
fi

echo ""
echo "For detailed instructions, see docs/PREREQUISITES.md"
