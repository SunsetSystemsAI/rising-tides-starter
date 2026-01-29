# ===========================================
# Rising Tides - Setup Verification Script
# ===========================================
# Checks that everything is installed correctly
# Run this after setup to verify your environment
# ===========================================

$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$SKILLS_DIR = "$CLAUDE_DIR\skills"
$PLUGINS_DIR = "$CLAUDE_DIR\plugins"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Rising Tides - Setup Verification       " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$PASS_COUNT = 0
$FAIL_COUNT = 0

function Check-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
    $script:PASS_COUNT++
}

function Check-Fail {
    param([string]$Message, [string]$Fix)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    Write-Host "  -> $Fix" -ForegroundColor Yellow
    $script:FAIL_COUNT++
}

function Check-Warn {
    param([string]$Message, [string]$Info)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
    Write-Host "  -> $Info" -ForegroundColor Yellow
}

function Test-Command {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# -------------------------------------------
# Check Node.js
# -------------------------------------------

Write-Host "Checking prerequisites..." -ForegroundColor Cyan
Write-Host ""

if (Test-Command "node") {
    $nodeVersion = (node --version) -replace "v", ""
    $majorVersion = [int]($nodeVersion.Split('.')[0])

    if ($majorVersion -ge 18) {
        Check-Pass "Node.js v$nodeVersion"
    } else {
        Check-Fail "Node.js v$nodeVersion - too old" "Need Node.js 18+. Run: winget install OpenJS.NodeJS.LTS"
    }
} else {
    Check-Fail "Node.js not found" "Install: winget install OpenJS.NodeJS.LTS"
}

# -------------------------------------------
# Check npm
# -------------------------------------------

if (Test-Command "npm") {
    $npmVersion = npm --version
    Check-Pass "npm $npmVersion"
} else {
    Check-Fail "npm not found" "npm should come with Node.js. Reinstall Node.js"
}

# -------------------------------------------
# Check npx
# -------------------------------------------

if (Test-Command "npx") {
    $npxVersion = npx --version
    Check-Pass "npx $npxVersion"
} else {
    Check-Fail "npx not found" "npx should come with Node.js. Reinstall Node.js"
}

# -------------------------------------------
# Check Git
# -------------------------------------------

if (Test-Command "git") {
    $gitVersion = (git --version) -replace "git version ", ""
    Check-Pass "Git $gitVersion"
} else {
    Check-Fail "Git not found" "Install: winget install Git.Git"
}

# -------------------------------------------
# Check Claude Code
# -------------------------------------------

Write-Host ""
Write-Host "Checking Claude Code..." -ForegroundColor Cyan
Write-Host ""

if (Test-Command "claude") {
    try {
        $claudeVersion = claude --version 2>&1 | Select-Object -First 1
        Check-Pass "Claude Code installed ($claudeVersion)"
    } catch {
        Check-Pass "Claude Code installed"
    }
} else {
    Check-Fail "Claude Code not found" "Install: irm https://claude.ai/install.ps1 | iex"
}

# -------------------------------------------
# Check Claude Auth
# -------------------------------------------

if (Test-Command "claude") {
    try {
        $authStatus = claude auth status 2>&1
        if ($authStatus -match "authenticated|logged in|valid") {
            Check-Pass "Claude authenticated"
        } else {
            Check-Warn "Claude not authenticated" "Run: claude auth login"
        }
    } catch {
        Check-Warn "Could not check auth status" "Run: claude auth login"
    }
}

# -------------------------------------------
# Check Settings
# -------------------------------------------

Write-Host ""
Write-Host "Checking configuration..." -ForegroundColor Cyan
Write-Host ""

$settingsFile = "$CLAUDE_DIR\settings.json"
if (Test-Path $settingsFile) {
    Check-Pass "Settings file exists"

    $settingsContent = Get-Content $settingsFile -Raw
    if ($settingsContent -match '"statusLine"\s*:\s*true') {
        Check-Pass "Status line enabled"
    } else {
        Check-Warn "Status line not enabled" "Add `"statusLine`": true to settings.json"
    }
} else {
    Check-Fail "Settings file missing" "Create $CLAUDE_DIR\settings.json"
}

# -------------------------------------------
# Check Tool Search
# -------------------------------------------

if ($env:ENABLE_TOOL_SEARCH -eq "auto") {
    Check-Pass "Tool Search enabled (ENABLE_TOOL_SEARCH=auto)"
} else {
    Check-Warn "Tool Search not enabled" "Add `$env:ENABLE_TOOL_SEARCH = 'auto' to your PowerShell profile"
}

# -------------------------------------------
# Check Memory MCP (optional)
# -------------------------------------------

if (Test-Command "claude") {
    try {
        $mcpList = claude mcp list 2>&1
        if ($mcpList -match "memory") {
            Check-Pass "Memory MCP configured"
        } else {
            Check-Warn "Memory MCP not configured" "Optional: Run 'claude mcp add memory --scope user'"
        }
    } catch {
        Check-Warn "Could not check MCP list" "Run: claude mcp list"
    }
}

# -------------------------------------------
# Check Skills Pack
# -------------------------------------------

Write-Host ""
Write-Host "Checking skills pack..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path $SKILLS_DIR) {
    $skillCount = (Get-ChildItem -Directory $SKILLS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($skillCount -gt 0) {
        Check-Pass "Skills installed: $skillCount skills in ~/.claude/skills/"
    } else {
        Check-Fail "Skills directory empty" "Re-run setup script"
    }
} else {
    Check-Fail "Skills not installed" "Run the setup script to install skills to ~/.claude/skills/"
}

if (Test-Path $PLUGINS_DIR) {
    $pluginCount = (Get-ChildItem -Directory $PLUGINS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($pluginCount -gt 0) {
        Check-Pass "Plugins installed: $pluginCount plugins in ~/.claude/plugins/"
    } else {
        Check-Warn "No plugins found" "Plugins should be in ~/.claude/plugins/"
    }
} else {
    Check-Warn "Plugins directory missing" "Plugins should be in ~/.claude/plugins/"
}

# -------------------------------------------
# Check Index File
# -------------------------------------------

$indexFile = "$CLAUDE_DIR\SKILLS_INDEX.json"
if (Test-Path $indexFile) {
    Check-Pass "SKILLS_INDEX.json exists"
} else {
    Check-Fail "SKILLS_INDEX.json missing" "Copy from starter pack to ~/.claude/"
}

$registryFile = "$CLAUDE_DIR\MCP_REGISTRY.md"
if (Test-Path $registryFile) {
    Check-Pass "MCP_REGISTRY.md exists"
} else {
    Check-Warn "MCP_REGISTRY.md missing" "Copy from starter pack to ~/.claude/"
}

# -------------------------------------------
# Summary
# -------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Verification Summary                    " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($FAIL_COUNT -eq 0) {
    Write-Host "All checks passed! ($PASS_COUNT passed)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your Rising Tides environment is ready."
    Write-Host ""
    Write-Host "Start Claude Code:"
    Write-Host "  claude" -ForegroundColor Green
    Write-Host ""
    Write-Host "Get skill recommendations:"
    Write-Host "  /recommend skills" -ForegroundColor Green
    Write-Host ""
    Write-Host "Try a skill:"
    Write-Host "  /copywriting write a headline for my SaaS" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "$FAIL_COUNT check(s) failed, $PASS_COUNT passed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix the issues above, then run this script again."
    Write-Host ""
}

# -------------------------------------------
# Support
# -------------------------------------------

Write-Host "Need help? Join the community:"
Write-Host "  https://www.skool.com/rising-tides-9034" -ForegroundColor Cyan
Write-Host ""
