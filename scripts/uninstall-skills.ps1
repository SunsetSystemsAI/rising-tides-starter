# ===========================================
# Rising Tides - Uninstall Skills Pack Only
# ===========================================
# Removes ONLY the Rising Tides content:
#   - Skills (~/.claude/skills/)
#   - Plugins (~/.claude/plugins/)
#   - Index file (SKILLS_INDEX.json)
#   - Registry files (MCP_REGISTRY.md, ATTRIBUTION.md)
#
# DOES NOT REMOVE:
#   - Claude Code CLI
#   - Your Claude settings/config
#   - Node.js, Git, or any prerequisites
# ===========================================

$CLAUDE_DIR = "$env:USERPROFILE\.claude"
$SKILLS_DIR = "$CLAUDE_DIR\skills"
$PLUGINS_DIR = "$CLAUDE_DIR\plugins"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Uninstall Rising Tides Skills Pack      " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script removes ONLY the Rising Tides content." -ForegroundColor Green
Write-Host ""
Write-Host "What will be removed:"
Write-Host "  - Skills folder (~/.claude/skills/)"
Write-Host "  - Plugins folder (~/.claude/plugins/)"
Write-Host "  - SKILLS_INDEX.json"
Write-Host "  - MCP_REGISTRY.md"
Write-Host "  - ATTRIBUTION.md"
Write-Host "  - SECURITY.md"
Write-Host ""
Write-Host "What stays INTACT:" -ForegroundColor Green
Write-Host "  - Claude Code CLI (still installed)"
Write-Host "  - Your settings.json (preferences preserved)"
Write-Host "  - Your mcp.json (MCP config preserved)"
Write-Host "  - Node.js, Git, and all prerequisites"
Write-Host ""
Write-Host "Use case: You pulled skills globally, ran /recommend skills," -ForegroundColor Yellow
Write-Host "imported what you need to your project, now cleaning up global." -ForegroundColor Yellow
Write-Host ""

# Confirm
$confirm = Read-Host "Remove Rising Tides Skills Pack? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host ""
    Write-Host "Cancelled. Nothing was removed."
    Write-Host ""
    exit 0
}

Write-Host ""
$removedCount = 0

# -------------------------------------------
# Remove Skills
# -------------------------------------------

Write-Host "[1/6] Skills" -ForegroundColor Yellow
if (Test-Path $SKILLS_DIR) {
    $skillCount = (Get-ChildItem -Directory $SKILLS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    Remove-Item -Recurse -Force $SKILLS_DIR -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed $skillCount skills" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Remove Plugins
# -------------------------------------------

Write-Host "[2/6] Plugins" -ForegroundColor Yellow
if (Test-Path $PLUGINS_DIR) {
    $pluginCount = (Get-ChildItem -Directory $PLUGINS_DIR -ErrorAction SilentlyContinue | Measure-Object).Count
    Remove-Item -Recurse -Force $PLUGINS_DIR -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed $pluginCount plugins" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Remove Index File
# -------------------------------------------

Write-Host "[3/6] SKILLS_INDEX.json" -ForegroundColor Yellow
if (Test-Path "$CLAUDE_DIR\SKILLS_INDEX.json") {
    Remove-Item -Force "$CLAUDE_DIR\SKILLS_INDEX.json" -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Remove MCP Registry
# -------------------------------------------

Write-Host "[4/6] MCP_REGISTRY.md" -ForegroundColor Yellow
if (Test-Path "$CLAUDE_DIR\MCP_REGISTRY.md") {
    Remove-Item -Force "$CLAUDE_DIR\MCP_REGISTRY.md" -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Remove Attribution
# -------------------------------------------

Write-Host "[5/6] ATTRIBUTION.md" -ForegroundColor Yellow
if (Test-Path "$CLAUDE_DIR\ATTRIBUTION.md") {
    Remove-Item -Force "$CLAUDE_DIR\ATTRIBUTION.md" -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

# -------------------------------------------
# Remove Security Doc
# -------------------------------------------

Write-Host "[6/6] SECURITY.md" -ForegroundColor Yellow
if (Test-Path "$CLAUDE_DIR\SECURITY.md") {
    Remove-Item -Force "$CLAUDE_DIR\SECURITY.md" -ErrorAction SilentlyContinue
    Write-Host "  [OK] Removed" -ForegroundColor Green
    $removedCount++
} else {
    Write-Host "  Not found, skipping"
}

Write-Host ""

# -------------------------------------------
# Summary
# -------------------------------------------

Write-Host "============================================" -ForegroundColor Green
Write-Host "   Skills Pack Removed                     " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Removed $removedCount Rising Tides components."
Write-Host ""
Write-Host "Still installed:" -ForegroundColor Cyan

# Check what's still installed
$claudePath = $null
try { $claudePath = (Get-Command claude -ErrorAction SilentlyContinue).Source } catch {}
Write-Host "  - Claude Code CLI: $($claudePath ?? 'not in PATH')"

$nodeVersion = $null
try { $nodeVersion = (node --version 2>$null) } catch {}
Write-Host "  - Node.js: $($nodeVersion ?? 'not installed')"

$gitVersion = $null
try { $gitVersion = (git --version 2>$null) } catch {}
Write-Host "  - Git: $($gitVersion ?? 'not installed')"

Write-Host ""
Write-Host "Your Claude configuration is preserved:"
Write-Host "  - ~/.claude/settings.json"
Write-Host "  - ~/.claude/mcp.json"
Write-Host ""
Write-Host "To reinstall the Skills Pack:" -ForegroundColor Yellow
Write-Host "  Run the setup script again"
Write-Host ""
Write-Host "To remove EVERYTHING (Claude Code + prerequisites):" -ForegroundColor Red
Write-Host "  Run: .\scripts\uninstall-full.ps1"
Write-Host ""
