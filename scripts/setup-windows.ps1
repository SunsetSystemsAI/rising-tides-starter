# ===========================================
# Rising Tides - Complete Windows Setup Script
# ===========================================
# This script installs everything you need:
# - Git
# - Python 3
# - Node.js LTS
# - Claude Code
# - Rising Tides Skills Pack (bundled)
# ===========================================
#
# Run as Administrator:
#   Set-ExecutionPolicy Bypass -Scope Process -Force
#   .\setup-windows.ps1
# ===========================================

$ErrorActionPreference = "Stop"

# Get script location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StarterPackDir = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Rising Tides - Complete Setup Script    " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------
# Helper Functions
# -------------------------------------------

function Print-Step {
    param([string]$Number, [string]$Total, [string]$Message)
    Write-Host ""
    Write-Host "[$Number/$Total] $Message" -ForegroundColor Cyan
    Write-Host "-------------------------------------------"
}

function Print-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Print-Skip {
    param([string]$Message)
    Write-Host "[SKIP] $Message (already installed)" -ForegroundColor Yellow
}

function Print-Info {
    param([string]$Message)
    Write-Host "-> $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
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

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# -------------------------------------------
# Check for Administrator
# -------------------------------------------

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "WARNING: Not running as Administrator!" -ForegroundColor Red
    Write-Host "Some installations may fail." -ForegroundColor Red
    Write-Host ""
    Write-Host "To run as Administrator:" -ForegroundColor Yellow
    Write-Host "  1. Right-click PowerShell" -ForegroundColor Yellow
    Write-Host "  2. Select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "  3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# -------------------------------------------
# Step 1: Check winget
# -------------------------------------------

Print-Step "1" "8" "Checking winget..."

if (Test-Command "winget") {
    Print-Skip "winget"
} else {
    Print-Error "winget not found!"
    Write-Host ""
    Write-Host "winget is required but not installed." -ForegroundColor Red
    Write-Host "Please install 'App Installer' from the Microsoft Store" -ForegroundColor Yellow
    Write-Host "Or download from: https://github.com/microsoft/winget-cli/releases" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# -------------------------------------------
# Step 2: Install Git
# -------------------------------------------

Print-Step "2" "8" "Checking Git..."

if (Test-Command "git") {
    $gitVersion = (git --version) -replace "git version ", ""
    Print-Skip "Git ($gitVersion)"
} else {
    Print-Info "Installing Git..."
    winget install Git.Git --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
    Start-Sleep -Seconds 2
    Print-Success "Git installed"
}

# -------------------------------------------
# Step 3: Install Python 3
# -------------------------------------------

Print-Step "3" "8" "Checking Python 3..."

if (Test-Command "python") {
    $pythonVersion = (python --version 2>&1) -replace "Python ", ""
    if ($pythonVersion -match "^3\.") {
        Print-Skip "Python ($pythonVersion)"
    } else {
        Print-Info "Installing Python 3..."
        winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
        Refresh-Path
        Print-Success "Python 3 installed"
    }
} else {
    Print-Info "Installing Python 3..."
    winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
    Start-Sleep -Seconds 2
    Print-Success "Python 3 installed"
}

# -------------------------------------------
# Step 4: Install Node.js
# -------------------------------------------

Print-Step "4" "8" "Checking Node.js..."

Refresh-Path

if (Test-Command "node") {
    $nodeVersion = (node --version) -replace "v", ""
    $majorVersion = [int]($nodeVersion.Split('.')[0])

    if ($majorVersion -ge 18) {
        Print-Skip "Node.js (v$nodeVersion)"
    } else {
        Print-Info "Node.js version too old, upgrading..."
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent
        Refresh-Path
        Print-Success "Node.js upgraded"
    }
} else {
    Print-Info "Installing Node.js LTS..."
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent
    Refresh-Path
    Start-Sleep -Seconds 2
    Print-Success "Node.js installed"
}

# Verify npm
Refresh-Path
if (Test-Command "npm") {
    $npmVersion = npm --version
    Print-Skip "npm ($npmVersion)"
} else {
    Print-Error "npm not found - try restarting PowerShell"
}

# -------------------------------------------
# Step 5: Install Claude Code
# -------------------------------------------

Print-Step "5" "8" "Checking Claude Code..."

Refresh-Path

if (Test-Command "claude") {
    try {
        $claudeVersion = claude --version 2>&1 | Select-Object -First 1
        Print-Skip "Claude Code ($claudeVersion)"
    } catch {
        Print-Skip "Claude Code"
    }
    Print-Info "Updating Claude Code to latest..."
    try {
        claude update 2>$null
        Print-Success "Claude Code updated"
    } catch {
        Print-Info "Already up to date (or update not available)"
    }
} else {
    Print-Info "Installing Claude Code..."
    irm https://cli.anthropic.com/install.ps1 | iex
    Refresh-Path
    Print-Success "Claude Code installed"
}

# -------------------------------------------
# Step 6: Configure Claude Code
# -------------------------------------------

Print-Step "6" "8" "Configuring Claude Code..."

$claudeDir = "$env:USERPROFILE\.claude"
$settingsFile = "$claudeDir\settings.json"
$skillsDir = "$claudeDir\skills"
$pluginsDir = "$claudeDir\plugins"

# Create directories
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}
if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
}
if (-not (Test-Path $pluginsDir)) {
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
}

if (Test-Path $settingsFile) {
    Print-Info "Settings file exists, preserving..."
} else {
    Print-Info "Creating settings file with status line enabled..."
    $settings = @{
        statusLine = $true
        theme = "dark"
    }
    $settings | ConvertTo-Json | Set-Content $settingsFile -Encoding UTF8
    Print-Success "Settings configured"
}

# Add ENABLE_TOOL_SEARCH to PowerShell profile
$profilePath = $PROFILE
$profileDir = Split-Path -Parent $profilePath

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue
if ($profileContent -notmatch "ENABLE_TOOL_SEARCH") {
    Print-Info "Adding ENABLE_TOOL_SEARCH to PowerShell profile..."
    Add-Content $profilePath "`n# Rising Tides - Tool Search for MCP efficiency"
    Add-Content $profilePath '$env:ENABLE_TOOL_SEARCH = "auto"'
    $env:ENABLE_TOOL_SEARCH = "auto"
    Print-Success "Tool Search enabled"
} else {
    Print-Skip "ENABLE_TOOL_SEARCH already in profile"
}

# -------------------------------------------
# Step 7: Install Rising Tides Skills Pack
# -------------------------------------------

Print-Step "7" "8" "Installing Rising Tides Skills Pack..."

$INSTALL_SUCCESS = $false

# Check if we're running from the starter pack directory (local install)
$localSkillsDir = Join-Path $StarterPackDir "skills"
$localPluginsDir = Join-Path $StarterPackDir "plugins"

if ((Test-Path $localSkillsDir) -and (Test-Path $localPluginsDir)) {
    Print-Info "Installing bundled skills pack..."

    # Copy skills
    if (Test-Path $localSkillsDir) {
        Copy-Item -Path "$localSkillsDir\*" -Destination $skillsDir -Recurse -Force
        $skillCount = (Get-ChildItem -Directory $skillsDir -ErrorAction SilentlyContinue | Measure-Object).Count
        Print-Success "Copied $skillCount skills to ~/.claude/skills/"
    }

    # Copy plugins
    if (Test-Path $localPluginsDir) {
        Copy-Item -Path "$localPluginsDir\*" -Destination $pluginsDir -Recurse -Force
        $pluginCount = (Get-ChildItem -Directory $pluginsDir -ErrorAction SilentlyContinue | Measure-Object).Count
        Print-Success "Copied $pluginCount plugins to ~/.claude/plugins/"
    }

    # Copy index files
    $indexFile = Join-Path $StarterPackDir "SKILLS_INDEX.json"
    if (Test-Path $indexFile) {
        Copy-Item $indexFile "$claudeDir\" -Force
        Print-Success "Copied SKILLS_INDEX.json"
    }

    $registryFile = Join-Path $StarterPackDir "MCP_REGISTRY.md"
    if (Test-Path $registryFile) {
        Copy-Item $registryFile "$claudeDir\" -Force
        Print-Success "Copied MCP_REGISTRY.md"
    }

    $attributionFile = Join-Path $StarterPackDir "ATTRIBUTION.md"
    if (Test-Path $attributionFile) {
        Copy-Item $attributionFile "$claudeDir\" -Force
        Print-Success "Copied ATTRIBUTION.md"
    }

    $INSTALL_SUCCESS = $true
} else {
    # Remote install - download from GitHub
    Print-Info "Downloading Rising Tides Skills Pack from GitHub..."

    $tempDir = Join-Path $env:TEMP "rising-tides-temp"
    $SKILLS_REPO = "https://github.com/TinyShaft22/rising-tides-starter.git"

    Refresh-Path

    try {
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force
        }

        git clone --depth 1 $SKILLS_REPO $tempDir 2>$null

        if ($LASTEXITCODE -eq 0) {
            # Copy skills
            $tempSkillsDir = Join-Path $tempDir "skills"
            if (Test-Path $tempSkillsDir) {
                Copy-Item -Path "$tempSkillsDir\*" -Destination $skillsDir -Recurse -Force
                $skillCount = (Get-ChildItem -Directory $skillsDir -ErrorAction SilentlyContinue | Measure-Object).Count
                Print-Success "Installed $skillCount skills"
            }

            # Copy plugins
            $tempPluginsDir = Join-Path $tempDir "plugins"
            if (Test-Path $tempPluginsDir) {
                Copy-Item -Path "$tempPluginsDir\*" -Destination $pluginsDir -Recurse -Force
                $pluginCount = (Get-ChildItem -Directory $pluginsDir -ErrorAction SilentlyContinue | Measure-Object).Count
                Print-Success "Installed $pluginCount plugins"
            }

            # Copy index files
            $tempIndex = Join-Path $tempDir "SKILLS_INDEX.json"
            if (Test-Path $tempIndex) { Copy-Item $tempIndex "$claudeDir\" -Force }
            $tempRegistry = Join-Path $tempDir "MCP_REGISTRY.md"
            if (Test-Path $tempRegistry) { Copy-Item $tempRegistry "$claudeDir\" -Force }
            $tempAttribution = Join-Path $tempDir "ATTRIBUTION.md"
            if (Test-Path $tempAttribution) { Copy-Item $tempAttribution "$claudeDir\" -Force }

            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            $INSTALL_SUCCESS = $true
        } else {
            throw "Clone failed"
        }
    } catch {
        Print-Error "Could not download skills pack from GitHub"
        Write-Host ""
        Write-Host "This usually means one of:" -ForegroundColor Yellow
        Write-Host "  1. The repository isn't public yet"
        Write-Host "  2. Network/firewall blocking GitHub"
        Write-Host ""
        Write-Host "What to do:" -ForegroundColor Yellow
        Write-Host "  - Download the starter pack manually"
        Write-Host "  - Run this script from the downloaded folder"
        Write-Host "  - Join https://skool.com/rising-tides for support"
        Write-Host ""
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        $INSTALL_SUCCESS = $false
    }
}

# -------------------------------------------
# Step 8: Optional Memory MCP Setup
# -------------------------------------------

Print-Step "8" "8" "Optional: Persistent Memory MCP..."

Write-Host ""
Write-Host "The Memory MCP lets Claude remember things across sessions." -ForegroundColor Cyan
Write-Host "It stores knowledge in a file on your Desktop for easy access."
Write-Host ""
$setupMemory = Read-Host "Set up Memory MCP? (y/N)"

if ($setupMemory -eq "y" -or $setupMemory -eq "Y") {
    Print-Info "Configuring Memory MCP..."

    $memoryPath = "$env:USERPROFILE\Desktop\claude-memory.jsonl"

    Refresh-Path

    if (Test-Command "claude") {
        try {
            claude mcp add memory --scope user -- npx -y @modelcontextprotocol/server-memory --memory-path $memoryPath 2>$null
            Print-Success "Memory MCP configured (file: ~/Desktop/claude-memory.jsonl)"
        } catch {
            Print-Info "Could not auto-configure. Add manually after setup."
        }
    } else {
        Print-Info "Claude CLI not available. Configure memory MCP manually after restarting."
    }
} else {
    Print-Info "Skipped Memory MCP setup (you can add later with 'claude mcp add memory --scope user')"
}

# -------------------------------------------
# Summary
# -------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   Setup Complete!                          " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed components:"

try { $gitVer = git --version 2>$null } catch { $gitVer = "N/A" }
try { $nodeVer = node --version 2>$null } catch { $nodeVer = "N/A" }
try { $npmVer = npm --version 2>$null } catch { $npmVer = "N/A" }
try { $pythonVer = python --version 2>$null } catch { $pythonVer = "N/A" }

Write-Host "  [OK] Git $gitVer"
Write-Host "  [OK] Python $pythonVer"
Write-Host "  [OK] Node.js $nodeVer"
Write-Host "  [OK] npm $npmVer"
Write-Host "  [OK] Claude Code"
Write-Host "  [OK] Status line enabled"
Write-Host "  [OK] Tool Search enabled (ENABLE_TOOL_SEARCH=auto)"

# Show skills summary if installed
if ($INSTALL_SUCCESS -and (Test-Path $skillsDir)) {
    $skillCount = (Get-ChildItem -Directory $skillsDir -ErrorAction SilentlyContinue | Measure-Object).Count
    $pluginCount = (Get-ChildItem -Directory $pluginsDir -ErrorAction SilentlyContinue | Measure-Object).Count

    Write-Host "  [OK] Rising Tides Skills Pack ($skillCount skills, $pluginCount plugins)"
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   Welcome to Rising Tides!                " -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "What you got:"
    Write-Host "  - Marketing & SEO      : copywriting, seo-audit, marketing-psychology"
    Write-Host "  - Frontend Dev         : react-dev, frontend-design, web-design-guidelines"
    Write-Host "  - Backend & Database   : supabase-guide, firebase-guide, drizzle-orm"
    Write-Host "  - Workflow & Git       : commit-work, github-workflow, session-handoff"
    Write-Host "  - Deployment           : vercel-deployment, netlify-deployment"
    Write-Host "  - Documentation        : mermaid-diagrams, c4-architecture, pdf, docx"
    Write-Host "  - Design & Media       : canvas-design, video-generator, excalidraw"
    Write-Host "  - Payments             : stripe-integration"
    Write-Host "  - And much more!"
    Write-Host ""
} else {
    Write-Host "  [!!] Skills Pack: See above for manual install instructions"
    Write-Host ""
}

Write-Host "Skills location: ~/.claude/skills/"
Write-Host "Plugins location: ~/.claude/plugins/"
Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "   NEXT STEPS                              " -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. CLOSE this PowerShell window"
Write-Host ""
Write-Host "  2. Open a NEW PowerShell window"
Write-Host "     (This ensures PATH is updated)" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Authenticate Claude Code:"
Write-Host "     claude auth login" -ForegroundColor Green
Write-Host ""
Write-Host "  4. Start Claude Code:"
Write-Host "     claude" -ForegroundColor Green
Write-Host ""
Write-Host "  5. Get skill recommendations for any project:"
Write-Host "     /recommend skills" -ForegroundColor Green
Write-Host ""
Write-Host "  6. Or try skills directly:"
Write-Host "     /copywriting" -ForegroundColor Green -NoNewline
Write-Host " write a headline for my SaaS"
Write-Host "     /react-dev" -ForegroundColor Green -NoNewline
Write-Host " create a login form component"
Write-Host "     /commit-work" -ForegroundColor Green -NoNewline
Write-Host " review and commit my changes"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Need Help? Join the Community           " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  https://skool.com/rising-tides" -ForegroundColor Green
Write-Host ""
Write-Host "  Get support, share wins, and connect with other users."
Write-Host ""
