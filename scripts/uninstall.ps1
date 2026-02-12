# ===========================================
# Rising Tides - Uninstall Menu
# ===========================================
# Choose what to uninstall:
#   1. Skills Pack only (keep Claude Code)
#   2. Everything (full reset)
# ===========================================

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Rising Tides - Uninstall                " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose what to uninstall:"
Write-Host ""
Write-Host "  [1] Skills Pack Only (Recommended)" -ForegroundColor Green
Write-Host "      Removes: skills, plugins, index files"
Write-Host "      Keeps: Claude Code, settings, prerequisites"
Write-Host "      Use this if you just want to clean up global skills"
Write-Host ""
Write-Host "  [2] EVERYTHING (Full Reset)" -ForegroundColor Red
Write-Host "      Removes: Claude Code, ALL configuration, skills, plugins"
Write-Host "      Keeps: Node.js, Git, Python (you may need these)"
Write-Host "      WARNING: This cannot be undone!" -ForegroundColor Red
Write-Host ""
Write-Host "  [3] Cancel"
Write-Host ""

$choice = Read-Host "Enter your choice (1/2/3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Running Skills Pack uninstall..."
        Write-Host ""
        $skillsScript = Join-Path $SCRIPT_DIR "uninstall-skills.ps1"
        if (Test-Path $skillsScript) {
            & $skillsScript
        } else {
            Write-Host "Error: uninstall-skills.ps1 not found" -ForegroundColor Red
            Write-Host "Expected location: $skillsScript"
            Write-Host ""
            Write-Host "You can download it from:"
            Write-Host "  https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.ps1"
        }
    }
    "2" {
        Write-Host ""
        Write-Host "Running FULL uninstall..." -ForegroundColor Red
        Write-Host ""
        $fullScript = Join-Path $SCRIPT_DIR "uninstall-full.ps1"
        if (Test-Path $fullScript) {
            & $fullScript
        } else {
            Write-Host "Error: uninstall-full.ps1 not found" -ForegroundColor Red
            Write-Host "Expected location: $fullScript"
            Write-Host ""
            Write-Host "You can download it from:"
            Write-Host "  https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.ps1"
        }
    }
    default {
        Write-Host ""
        Write-Host "Cancelled. Nothing was removed."
        Write-Host ""
    }
}
