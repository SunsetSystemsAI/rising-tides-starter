# Testing Checklist for Clean System Install

Use this checklist when testing the setup scripts on a fresh system.

---

## Pre-Test: Verify Clean State

Before testing, confirm the system is "clean" (or note what's pre-installed):

### Check Existing Software

```bash
# Mac/Linux
node --version 2>/dev/null || echo "Node.js: NOT INSTALLED"
npm --version 2>/dev/null || echo "npm: NOT INSTALLED"
git --version 2>/dev/null || echo "Git: NOT INSTALLED"
python3 --version 2>/dev/null || echo "Python 3: NOT INSTALLED"
claude --version 2>/dev/null || echo "Claude Code: NOT INSTALLED"
```

```powershell
# Windows
node --version 2>$null; if (-not $?) { "Node.js: NOT INSTALLED" }
npm --version 2>$null; if (-not $?) { "npm: NOT INSTALLED" }
git --version 2>$null; if (-not $?) { "Git: NOT INSTALLED" }
python --version 2>$null; if (-not $?) { "Python: NOT INSTALLED" }
claude --version 2>$null; if (-not $?) { "Claude Code: NOT INSTALLED" }
```

### Check Target Directories Don't Exist

```bash
# Mac/Linux
ls ~/.claude 2>/dev/null || echo "~/.claude: DOES NOT EXIST (good for clean test)"
```

```powershell
# Windows
Test-Path "$env:USERPROFILE\.claude" # Should be False for clean test
```

---

## Test Execution

### 1. Run Setup Script

**Mac:**
```bash
./scripts/setup-mac.sh
```

**Linux/WSL:**
```bash
./scripts/setup-linux.sh
```

**Windows (PowerShell as Admin):**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-windows.ps1
```

### 2. Observe Script Output

Watch for these key checkpoints:

| Step | Expected Output |
|------|-----------------|
| Prerequisites check | Shows `[SKIP]` for installed, installs missing |
| Node.js install | Installs v20+ or skips if present |
| Git install | Installs or skips if present |
| Claude Code install | Native installer (`curl` or `irm`) |
| Settings creation | Creates `~/.claude/settings.json` |
| Tool Search | Adds `ENABLE_TOOL_SEARCH=auto` to shell profile |
| Skills copy | Reports "Copied X skills" |
| Plugins copy | Reports "Copied X plugins" |
| Memory MCP prompt | Asks "Set up Memory MCP? (y/N)" |

---

## Post-Test Verification

After the script completes, run these checks:

### 1. Software Versions

```bash
# All platforms
node --version      # Should be 18+ (ideally 20+)
npm --version       # Should be 8+
git --version       # Should be 2.30+
claude --version    # Should show version
```

**Expected:**
- [ ] Node.js 18+ installed
- [ ] npm 8+ installed
- [ ] Git 2.30+ installed
- [ ] Claude Code installed

### 2. Directory Structure

```bash
# Mac/Linux
ls ~/.claude/
```

```powershell
# Windows
Get-ChildItem "$env:USERPROFILE\.claude"
```

**Expected contents:**
- [ ] `skills/` folder exists
- [ ] `plugins/` folder exists
- [ ] `SKILLS_INDEX.json` exists
- [ ] `MCP_REGISTRY.md` exists
- [ ] `ATTRIBUTION.md` exists
- [ ] `settings.json` exists

### 3. Skill Count

```bash
# Mac/Linux
ls ~/.claude/skills | wc -l
```

```powershell
# Windows
(Get-ChildItem "$env:USERPROFILE\.claude\skills" -Directory).Count
```

**Expected:** 79 skills

### 4. Plugin Count

```bash
# Mac/Linux
ls ~/.claude/plugins | wc -l
```

```powershell
# Windows
(Get-ChildItem "$env:USERPROFILE\.claude\plugins" -Directory).Count
```

**Expected:** 12 plugins

### 5. Settings File

```bash
# Mac/Linux
cat ~/.claude/settings.json
```

```powershell
# Windows
Get-Content "$env:USERPROFILE\.claude\settings.json"
```

**Expected:** Contains `"statusLine": true`

### 6. Tool Search Environment Variable

```bash
# Mac/Linux (may need new terminal)
echo $ENABLE_TOOL_SEARCH
```

```powershell
# Windows (may need new terminal)
$env:ENABLE_TOOL_SEARCH
```

**Expected:** `auto`

### 7. SKILLS_INDEX.json Valid

```bash
# Mac/Linux
python3 -c "import json; json.load(open('$HOME/.claude/SKILLS_INDEX.json')); print('Valid JSON')"
```

```powershell
# Windows
python -c "import json; json.load(open(r'%USERPROFILE%\.claude\SKILLS_INDEX.json')); print('Valid JSON')"
```

**Expected:** `Valid JSON`

---

## Functional Test

### 1. Claude Code Authentication

```bash
claude auth login
```

**Expected:** Opens browser for authentication

### 2. Start Claude Code

```bash
claude
```

**Expected:** Claude Code starts with status line visible

### 3. Check Skills Available

In Claude Code, run:
```
/recommend skills
```

**Expected:** Claude responds with skill recommendations based on context

### 4. Test a Skill Directly

```
/copywriting write a headline for a productivity app
```

**Expected:** Claude invokes the copywriting skill and generates content

---

## Skip Logic Test

If some prerequisites were already installed, verify the script skipped them:

| Pre-installed | Expected Script Behavior |
|---------------|--------------------------|
| Node.js 18+ | `[SKIP] Node.js (vX.X.X)` |
| Git | `[SKIP] Git (X.X.X)` |
| Python 3 | `[SKIP] Python 3 (X.X.X)` |
| Claude Code | `[SKIP] Claude Code` |

**Test method:** Run the script again — everything should show `[SKIP]`.

---

## Verification Script

Run the built-in verification:

```bash
# Mac/Linux
./scripts/verify-setup.sh
```

```powershell
# Windows
.\scripts\verify-setup.ps1
```

**Expected:** All checks pass

---

## Cleanup (For Re-Testing)

To reset and test again:

```bash
# Mac/Linux - Remove only skills pack (keeps Claude Code)
rm -rf ~/.claude/skills ~/.claude/plugins ~/.claude/SKILLS_INDEX.json ~/.claude/MCP_REGISTRY.md ~/.claude/ATTRIBUTION.md

# Full reset (removes Claude config too)
rm -rf ~/.claude
```

```powershell
# Windows
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills", "$env:USERPROFILE\.claude\plugins"
```

---

## Test Results Template

```
Platform: [Mac / Windows / Linux / WSL2]
Date: YYYY-MM-DD
Tester: [Name]

PRE-INSTALLED:
- Node.js: [version or N/A]
- Git: [version or N/A]
- Python: [version or N/A]
- Claude Code: [version or N/A]

SCRIPT EXECUTION:
- [ ] Script ran without errors
- [ ] Skip logic worked for pre-installed items
- [ ] All missing items installed successfully

POST-INSTALL CHECKS:
- [ ] Node.js 18+ present
- [ ] Git present
- [ ] Claude Code present
- [ ] ~/.claude/skills/ has 79 folders
- [ ] ~/.claude/plugins/ has 12 folders
- [ ] SKILLS_INDEX.json valid
- [ ] settings.json has statusLine: true
- [ ] ENABLE_TOOL_SEARCH=auto set

FUNCTIONAL TESTS:
- [ ] claude auth login works
- [ ] claude starts with status line
- [ ] /recommend skills responds
- [ ] Direct skill invocation works

ISSUES FOUND:
[List any problems here]

OVERALL: [PASS / FAIL]
```

---

## Platform-Specific Notes

### Mac
- Xcode Command Line Tools may prompt for GUI installation
- Homebrew install may take several minutes
- M1/M2 Macs: Homebrew path is `/opt/homebrew/`

### Windows
- Must run PowerShell as Administrator
- winget must be available (comes with Windows 11, Windows 10 1709+)
- May need to restart PowerShell after install

### Linux
- Script supports apt, dnf, yum, and pacman
- May need sudo password during installation
- NodeSource adds Node.js repo automatically

### WSL2
- Script detects WSL and adjusts memory path
- Windows Desktop path: `/mnt/c/Users/[USERNAME]/Desktop/`
