# ===========================================
# Rising Tides - FULL UNINSTALL
# ===========================================
#
#   WARNING: DESTRUCTIVE OPERATION
#
# This script removes EVERYTHING installed by
# the Rising Tides Starter Pack, including:
#
#   - Claude Code CLI
#   - All Claude configuration (~/.claude/)
#   - Rising Tides Skills and Plugins
#   - ENABLE_TOOL_SEARCH from PowerShell profile
#
# This is a COMPLETE RESET. After running this,
# you'll need to reinstall everything from scratch.
#
# ===========================================

$CLAUDE_DIR = "$env:USERPROFILE\.claude"

# -------------------------------------------
# Big scary warning
# -------------------------------------------

Clear-Host
Write-Host ""
Write-Host "================================================================" -ForegroundColor Red
Write-Host "                                                                " -ForegroundColor Red
Write-Host "      WARNING: COMPLETE UNINSTALL                               " -ForegroundColor Red
Write-Host "                                                                " -ForegroundColor Red
Write-Host "================================================================" -ForegroundColor Red
Write-Host ""
Write-Host "This will remove EVERYTHING:" -ForegroundColor White
Write-Host ""
Write-Host "  X Claude Code CLI" -ForegroundColor Red
Write-Host "  X All Claude configuration (~/.claude/)" -ForegroundColor Red
Write-Host "  X Your settings.json and preferences" -ForegroundColor Red
Write-Host "  X Your mcp.json and MCP configurations" -ForegroundColor Red
Write-Host "  X All Rising Tides skills (187 skills)" -ForegroundColor Red
Write-Host "  X All Rising Tides plugins (38 plugins)" -ForegroundColor Red
Write-Host "  X SKILLS_INDEX.json and registry files" -ForegroundColor Red
Write-Host "  X ENABLE_TOOL_SEARCH from PowerShell profile" -ForegroundColor Red
Write-Host ""
Write-Host "This will NOT remove (you may still need these):" -ForegroundColor Yellow
Write-Host ""
Write-Host "  + Node.js (many tools depend on it)" -ForegroundColor Green
Write-Host "  + Git (you definitely need this)" -ForegroundColor Green
Write-Host "  + Python (many tools depend on it)" -ForegroundColor Green
Write-Host ""
Write-Host "After this, you'll need to reinstall from scratch:" -ForegroundColor Cyan
Write-Host "  1. Run the setup script again"
Write-Host "  2. Run 'claude auth login' to re-authenticate"
Write-Host "  3. Reconfigure your settings"
Write-Host ""

# -------------------------------------------
# Triple confirmation
# -------------------------------------------

Write-Host "This action cannot be undone." -ForegroundColor Red
Write-Host ""
$confirm1 = Read-Host "Type 'DELETE' to confirm you want to remove everything"

if ($confirm1 -ne "DELETE") {
    Write-Host ""
    Write-Host "Uninstall cancelled. Nothing was removed."
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "Are you absolutely sure?" -ForegroundColor Yellow
$confirm2 = Read-Host "Type 'YES' to proceed with full uninstall"

if ($confirm2 -ne "YES") {
    Write-Host ""
    Write-Host "Uninstall cancelled. Nothing was removed."
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "Starting full uninstall..." -ForegroundColor Red
Write-Host ""

# -------------------------------------------
# Remove Claude Code CLI
# -------------------------------------------

Write-Host "[1/4] Removing Claude Code CLI..." -ForegroundColor Yellow

$removedClaude = $false

# Check common installation locations
$claudeLocations = @(
    "$env:LOCALAPPDATA\Programs\claude\claude.exe",
    "$env:USERPROFILE\.local\bin\claude.exe",
    "$env:APPDATA\npm\claude.cmd",
    "$env:APPDATA\npm\claude"
)

foreach ($loc in $claudeLocations) {
    if (Test-Path $loc) {
        Remove-Item -Force $loc -ErrorAction SilentlyContinue
        Write-Host "  Removed: $loc"
        $removedClaude = $true
    }
}

# Try npm uninstall
try {
    $npmList = npm list -g @anthropic-ai/claude-code 2>$null
    if ($npmList) {
        npm uninstall -g @anthropic-ai/claude-code 2>$null
        Write-Host "  Removed: npm global package"
        $removedClaude = $true
    }
} catch {}

if ($removedClaude) {
    Write-Host "  [OK] Claude Code removed" -ForegroundColor Green
} else {
    $claudeCmd = $null
    try { $claudeCmd = (Get-Command claude -ErrorAction SilentlyContinue).Source } catch {}
    if ($claudeCmd) {
        Write-Host "  [!] Claude found but couldn't remove automatically" -ForegroundColor Yellow
        Write-Host "      Location: $claudeCmd"
        Write-Host "      Try: Remove-Item -Force '$claudeCmd'"
    } else {
        Write-Host "  Not installed, skipping"
    }
}

# -------------------------------------------
# Remove entire ~/.claude directory
# -------------------------------------------

Write-Host ""
Write-Host "[2/4] Removing Claude configuration directory..." -ForegroundColor Yellow

if (Test-Path $CLAUDE_DIR) {
    # Show what's being removed
    Write-Host "  Contents of ~/.claude/:"
    Get-ChildItem $CLAUDE_DIR -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object {
        Write-Host "    $($_.Name)"
    }
    $itemCount = (Get-ChildItem $CLAUDE_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($itemCount -gt 10) {
        Write-Host "    ... and more"
    }
    Write-Host ""

    Remove-Item -Recurse -Force $CLAUDE_DIR -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed ~/.claude/ and all contents" -ForegroundColor Green
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Clean up PowerShell profile
# -------------------------------------------

Write-Host ""
Write-Host "[3/4] Cleaning up PowerShell profile..." -ForegroundColor Yellow

$cleanedProfile = $false

if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if ($profileContent -match "ENABLE_TOOL_SEARCH") {
        $newContent = $profileContent -replace '(?m)^.*ENABLE_TOOL_SEARCH.*$\r?\n?', ''
        $newContent = $newContent -replace '(?m)^.*Rising Tides.*$\r?\n?', ''
        Set-Content $PROFILE -Value $newContent.Trim()
        Write-Host "  Cleaned: $PROFILE"
        $cleanedProfile = $true
    }
}

if ($cleanedProfile) {
    Write-Host "  [OK] PowerShell profile cleaned" -ForegroundColor Green
} else {
    Write-Host "  No Rising Tides entries found in PowerShell profile"
}

# -------------------------------------------
# Remove any cached/temp files
# -------------------------------------------

Write-Host ""
Write-Host "[4/4] Removing temporary files..." -ForegroundColor Yellow

$tempFiles = @(
    "$env:TEMP\setup-windows.ps1",
    "$env:TEMP\setup.ps1"
)

foreach ($f in $tempFiles) {
    if (Test-Path $f) {
        Remove-Item -Force $f -ErrorAction SilentlyContinue
    }
}

Write-Host "  [OK] Temporary files cleaned" -ForegroundColor Green

# -------------------------------------------
# Final summary
# -------------------------------------------

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "                                                                " -ForegroundColor Green
Write-Host "              FULL UNINSTALL COMPLETE                           " -ForegroundColor Green
Write-Host "                                                                " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "The following have been removed:"
Write-Host "  - Claude Code CLI"
Write-Host "  - ~/.claude/ directory (all config, skills, plugins)"
Write-Host "  - ENABLE_TOOL_SEARCH from PowerShell profile"
Write-Host ""
Write-Host "Still installed (you may want to keep these):" -ForegroundColor Cyan

$nodeVersion = $null
try { $nodeVersion = (node --version 2>$null) } catch {}
Write-Host "  - Node.js: $($nodeVersion ?? 'not installed')"

$gitVersion = $null
try { $gitVersion = (git --version 2>$null) } catch {}
Write-Host "  - Git: $($gitVersion ?? 'not installed')"

$pythonVersion = $null
try { $pythonVersion = (python --version 2>$null) } catch {}
Write-Host "  - Python: $($pythonVersion ?? 'not installed')"

Write-Host ""
Write-Host "To reinstall everything:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Open PowerShell as Administrator and run:"
Write-Host ""
Write-Host "  Set-ExecutionPolicy Bypass -Scope Process -Force" -ForegroundColor Cyan
Write-Host "  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-windows.ps1' -OutFile `"`$env:TEMP\setup-windows.ps1`"" -ForegroundColor Cyan
Write-Host "  & `"`$env:TEMP\setup-windows.ps1`"" -ForegroundColor Cyan
Write-Host ""
Write-Host "Questions? Visit: https://www.skool.com/rising-tides-9034"
Write-Host ""
