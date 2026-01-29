# ===========================================
# Rising Tides - Uninstall Script
# ===========================================
# Removes Claude Code and Rising Tides components
# Does NOT remove Node.js or Git (you may need those)
# ===========================================

$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$SKILLS_DIR = "$CLAUDE_DIR\skills"
$PLUGINS_DIR = "$CLAUDE_DIR\plugins"

Write-Host ""
Write-Host "============================================" -ForegroundColor Red
Write-Host "   Rising Tides - Uninstall                " -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""
Write-Host "This will remove:"
Write-Host "  - Claude Code CLI"
Write-Host "  - Claude configuration (~/.claude)"
Write-Host "  - Rising Tides Skills (~/.claude/skills/)"
Write-Host "  - Rising Tides Plugins (~/.claude/plugins/)"
Write-Host ""
Write-Host "This will NOT remove:" -ForegroundColor Yellow
Write-Host "  - Node.js (you may need it for other projects)"
Write-Host "  - Git (you may need it for other projects)"
Write-Host ""

# Confirm overall uninstall
$confirm = Read-Host "Are you sure you want to uninstall? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host ""
    Write-Host "Uninstall cancelled."
    Write-Host ""
    exit 0
}

Write-Host ""

# -------------------------------------------
# Remove Claude Code
# -------------------------------------------

Write-Host "[1/4] Claude Code CLI" -ForegroundColor Yellow

$claudeInstalled = $false
try {
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        $claudeInstalled = $true
    }
} catch {}

if ($claudeInstalled) {
    $removeClaude = Read-Host "  Remove Claude Code? (y/N)"
    if ($removeClaude -eq "y" -or $removeClaude -eq "Y") {
        Write-Host "  Uninstalling Claude Code..."
        $claudePath = "$env:LOCALAPPDATA\Programs\claude\claude.exe"
        if (Test-Path $claudePath) { Remove-Item $claudePath -Force }
        # Also try removing from .local/bin if installed via native installer
        $altPath = "$env:USERPROFILE\.local\bin\claude.exe"
        if (Test-Path $altPath) { Remove-Item $altPath -Force }

        # Check if removed
        $stillInstalled = $false
        try {
            if (Get-Command claude -ErrorAction SilentlyContinue) {
                $stillInstalled = $true
            }
        } catch {}

        if ($stillInstalled) {
            Write-Host "  Could not remove (try running as Administrator)" -ForegroundColor Red
        } else {
            Write-Host "  [OK] Claude Code removed" -ForegroundColor Green
        }
    } else {
        Write-Host "  Skipped"
    }
} else {
    Write-Host "  Not installed, skipping"
}

Write-Host ""

# -------------------------------------------
# Remove Skills
# -------------------------------------------

Write-Host "[2/4] Rising Tides Skills" -ForegroundColor Yellow

if (Test-Path $SKILLS_DIR) {
    $skillCount = (Get-ChildItem -Directory $SKILLS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "  Found: $SKILLS_DIR ($skillCount skills)"
    Write-Host ""
    $removeSkills = Read-Host "  Remove skills? (y/N)"
    if ($removeSkills -eq "y" -or $removeSkills -eq "Y") {
        Remove-Item -Recurse -Force $SKILLS_DIR -ErrorAction SilentlyContinue
        Write-Host "  [OK] Skills removed" -ForegroundColor Green
    } else {
        Write-Host "  Skipped (skills are preserved)"
    }
} else {
    Write-Host "  No skills found, skipping"
}

Write-Host ""

# -------------------------------------------
# Remove Plugins
# -------------------------------------------

Write-Host "[3/4] Rising Tides Plugins" -ForegroundColor Yellow

if (Test-Path $PLUGINS_DIR) {
    $pluginCount = (Get-ChildItem -Directory $PLUGINS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "  Found: $PLUGINS_DIR ($pluginCount plugins)"
    Write-Host ""
    $removePlugins = Read-Host "  Remove plugins? (y/N)"
    if ($removePlugins -eq "y" -or $removePlugins -eq "Y") {
        Remove-Item -Recurse -Force $PLUGINS_DIR -ErrorAction SilentlyContinue
        Write-Host "  [OK] Plugins removed" -ForegroundColor Green
    } else {
        Write-Host "  Skipped (plugins are preserved)"
    }
} else {
    Write-Host "  No plugins found, skipping"
}

Write-Host ""

# -------------------------------------------
# Remove Claude Config
# -------------------------------------------

Write-Host "[4/4] Claude configuration" -ForegroundColor Yellow

if (Test-Path $CLAUDE_DIR) {
    Write-Host "  Found: $CLAUDE_DIR"
    Write-Host ""
    Write-Host "  This contains:"
    Write-Host "    - settings.json (your preferences)"
    Write-Host "    - mcp.json (MCP configuration)"
    Write-Host "    - SKILLS_INDEX.json"
    Write-Host "    - Any cached data"
    Write-Host ""
    $removeConfig = Read-Host "  Remove ALL Claude configuration? (y/N)"
    if ($removeConfig -eq "y" -or $removeConfig -eq "Y") {
        Remove-Item -Recurse -Force $CLAUDE_DIR -ErrorAction SilentlyContinue
        Write-Host "  [OK] Configuration removed" -ForegroundColor Green
    } else {
        Write-Host "  Skipped (your settings are preserved)"
    }
} else {
    Write-Host "  No configuration found, skipping"
}

Write-Host ""

# -------------------------------------------
# Clean up PowerShell profile
# -------------------------------------------

Write-Host "Cleaning up environment..." -ForegroundColor Yellow

if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -match "ENABLE_TOOL_SEARCH") {
        Write-Host "  Found ENABLE_TOOL_SEARCH in PowerShell profile"
        $removeEnv = Read-Host "  Remove it? (y/N)"
        if ($removeEnv -eq "y" -or $removeEnv -eq "Y") {
            $newContent = $profileContent -replace '(?m)^.*ENABLE_TOOL_SEARCH.*$\r?\n?', ''
            $newContent = $newContent -replace '(?m)^.*Rising Tides - Tool Search.*$\r?\n?', ''
            Set-Content $PROFILE -Value $newContent.Trim()
            Write-Host "  [OK] Removed from PowerShell profile" -ForegroundColor Green
        }
    }
}

Write-Host ""

# -------------------------------------------
# Summary
# -------------------------------------------

Write-Host "============================================" -ForegroundColor Green
Write-Host "   Uninstall Complete                      " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Removed components based on your selections."
Write-Host ""
Write-Host "To reinstall later, run the setup script again:"
Write-Host "  .\scripts\setup-windows.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "Questions? Visit: https://skool.com/rising-tides"
Write-Host ""
