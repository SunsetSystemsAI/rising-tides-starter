# Rising Tides Starter Pack - Prerequisites Checker
# For Windows PowerShell

Write-Host "========================================"
Write-Host "  Rising Tides Prerequisites Checker"
Write-Host "========================================"
Write-Host ""

$pass = 0
$fail = 0

function Check-Command {
    param (
        [string]$Command,
        [string]$Name,
        [string]$MinVersion
    )

    try {
        $version = & $Command --version 2>&1 | Select-Object -First 1
        Write-Host "[PASS] $Name is installed" -ForegroundColor Green
        Write-Host "       Version: $version"
        $script:pass++
        return $true
    }
    catch {
        Write-Host "[FAIL] $Name is NOT installed" -ForegroundColor Red
        Write-Host "       Required: $MinVersion+"
        $script:fail++
        return $false
    }
}

Write-Host "Checking required software..."
Write-Host "----------------------------------------"

# Check Node.js
Check-Command -Command "node" -Name "Node.js" -MinVersion "18.0.0"
Write-Host ""

# Check npm
Check-Command -Command "npm" -Name "npm" -MinVersion "8.0.0"
Write-Host ""

# Check Git
Check-Command -Command "git" -Name "Git" -MinVersion "2.30.0"
Write-Host ""

Write-Host "Checking optional software..."
Write-Host "----------------------------------------"

# Check Claude Code
try {
    $claudeVersion = & claude --version 2>&1 | Select-Object -First 1
    Write-Host "[PASS] Claude Code is installed" -ForegroundColor Green
    Write-Host "       Version: $claudeVersion"
    $pass++
}
catch {
    Write-Host "[INFO] Claude Code is NOT installed" -ForegroundColor Yellow
    Write-Host "       Install with: irm https://cli.anthropic.com/install.ps1 | iex"
}
Write-Host ""

# Check VS Code
try {
    $null = & code --version 2>&1
    Write-Host "[PASS] VS Code is installed" -ForegroundColor Green
    $pass++
}
catch {
    Write-Host "[INFO] VS Code is not installed (optional)" -ForegroundColor Yellow
}
Write-Host ""

# Check winget
try {
    $null = & winget --version 2>&1
    Write-Host "[PASS] winget is available" -ForegroundColor Green
    $pass++
}
catch {
    Write-Host "[INFO] winget is not available" -ForegroundColor Yellow
    Write-Host "       Update Windows or use manual installation"
}
Write-Host ""

Write-Host "========================================"
Write-Host "  Summary"
Write-Host "========================================"
Write-Host "Passed: $pass"
Write-Host "Failed: $fail"
Write-Host ""

if ($fail -eq 0) {
    Write-Host "[SUCCESS] All prerequisites are installed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Install Claude Code"
    Write-Host "  irm https://cli.anthropic.com/install.ps1 | iex"
    Write-Host "  claude auth login"
}
else {
    Write-Host "[ACTION REQUIRED] Please install missing prerequisites" -ForegroundColor Red
    Write-Host ""
    Write-Host "Quick install commands (run as Administrator):"
    Write-Host ""
    Write-Host "Using winget:"
    Write-Host "  winget install OpenJS.NodeJS.LTS"
    Write-Host "  winget install Git.Git"
    Write-Host ""
    Write-Host "Or download manually:"
    Write-Host "  Node.js: https://nodejs.org/"
    Write-Host "  Git: https://git-scm.com/download/win"
}

Write-Host ""
Write-Host "For detailed instructions, see docs/PREREQUISITES.md"
