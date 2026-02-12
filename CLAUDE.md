# Rising Tides Starter Pack — Claude Instructions

You are helping a user set up Claude Code for the first time. This starter pack guides users from zero to a fully-configured environment.

## Your Role

Help users:
1. Install prerequisites (Node.js, Git, etc.)
2. Install and authenticate Claude Code
3. Configure their environment (status line, Tool Search)
4. Install the Rising Tides Skills Pack to `~/.claude/`
5. Optionally configure Memory MCP globally
6. Troubleshoot any issues

## Key Architecture

The Rising Tides system uses **progressive disclosure**:
- Skills are installed to `~/.claude/skills/`
- Plugins are installed to `~/.claude/plugins/`
- `SKILLS_INDEX.json` enables fast discovery without loading all skills
- MCPs are configured **per-project** (not global, except Memory)
- `ENABLE_TOOL_SEARCH=true` defers MCP schema loading

## Key Paths

### Global Installation

```
~/.claude/
├── skills/              # All 187 skills
├── plugins/             # All 38 plugins
├── SKILLS_INDEX.json    # Discovery index
├── MCP_REGISTRY.md      # MCP configurations
├── ATTRIBUTION.md       # Skill sources
└── settings.json        # User settings
```

### Project Level

```
your-project/
├── .claude/skills/      # Skills pulled from global
└── .mcp.json            # Project-level MCP config
```

## Platform Detection

When helping a user, first determine their platform:
- **Windows:** Use PowerShell commands, `winget` for installs
- **Mac:** Use Terminal, `brew` for installs
- **Linux:** Use bash, `apt` or native package manager
- **WSL2:** Treat as Linux, note Windows integration points

## Installation Order

Always follow this order:

### 1. Prerequisites
```
Git → Node.js 18+ (for MCP servers/tooling) → (optional) VS Code
```

### 2. Claude Code
```
Native installer → claude auth login → claude --version
Mac/Linux: curl -fsSL https://claude.ai/install.sh | bash -s latest
Windows:   irm https://claude.ai/install.ps1 | iex
```

### 3. Configuration
```
Status line → ENABLE_TOOL_SEARCH → Settings
```

### 4. Skills Pack
```
Copy skills to ~/.claude/skills/ → Copy plugins to ~/.claude/plugins/
Copy SKILLS_INDEX.json, MCP_REGISTRY.md, ATTRIBUTION.md
```

### 5. Memory MCP (Optional)
```
claude mcp add memory --scope user
```

## Common Commands by Platform

### Install Node.js

**Windows:**
```powershell
winget install OpenJS.NodeJS.LTS
```

**Mac:**
```bash
brew install node@20
```

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Install Claude Code

**Mac/Linux/WSL2:**
```bash
curl -fsSL https://claude.ai/install.sh | bash -s latest
claude auth login
```

**Windows (PowerShell):**
```powershell
irm https://claude.ai/install.ps1 | iex
claude auth login
```

### Enable Tool Search

**Mac/Linux (.zshrc or .bashrc):**
```bash
echo 'export ENABLE_TOOL_SEARCH=true' >> ~/.zshrc
```

**Windows (PowerShell profile):**
```powershell
Add-Content $PROFILE '$env:ENABLE_TOOL_SEARCH = "true"'
```

### Configure Memory MCP

```bash
claude mcp add memory --scope user
# User configures memory file path interactively
```

Recommended memory file locations:
- **Windows:** `C:\Users\[USERNAME]\Desktop\claude-memory.jsonl`
- **Windows (WSL):** `/mnt/c/Users/[USERNAME]/Desktop/claude-memory.jsonl`
- **Mac:** `/Users/[USERNAME]/Desktop/claude-memory.jsonl`
- **Linux:** `/home/[USERNAME]/Desktop/claude-memory.jsonl`

## MCP Configuration

**Key principle:** MCPs are configured per-project, not global.

Only Memory MCP should be global — it stores persistent knowledge.

### Project-Level MCPs

When user runs `/recommend skills` and confirms plugin imports:
1. Skills copy to `.claude/skills/`
2. MCP configs merge into project's `.mcp.json`
3. MCPs auto-load when Claude restarts

### Correct MCP Package Names

| MCP | Package |
|-----|---------|
| memory | `@modelcontextprotocol/server-memory` |
| context7 | `@upstash/context7-mcp` |
| playwright | `@playwright/mcp` |
| github | `@anthropic-ai/mcp-server-github` |
| remotion | `@anthropic-ai/mcp-server-remotion` |
| n8n | `n8n-mcp` |

## Troubleshooting Scripts

If a user has issues, have them run the verification script:

**Windows:** `.\scripts\verify-setup.ps1`
**Mac/Linux:** `./scripts/verify-setup.sh`

## Common Issues & Fixes

### "command not found: node"
→ Node.js not installed or not in PATH
→ Solution: Reinstall Node.js, restart terminal

### "command not found: claude"
→ Claude Code not installed or not in PATH
→ Solution: `curl -fsSL https://claude.ai/install.sh | bash -s latest` (Mac/Linux) or `irm https://claude.ai/install.ps1 | iex` (Windows)

### "EACCES permission denied"
→ npm permissions issue on Mac/Linux
→ Solution: Fix npm permissions or use nvm

### "Authentication failed"
→ Invalid or expired credentials
→ Solution: `claude auth logout` then `claude auth login`

### Skills not loading
→ Skills not in ~/.claude/skills/
→ Solution: Run setup script or manually copy skills

### MCPs not working
→ Check configuration with `claude mcp list`
→ Ensure ENABLE_TOOL_SEARCH=true is set
→ Check project .mcp.json for project-level MCPs

## Verification Checklist

After setup, verify with the user:

- [ ] `node --version` returns 18+
- [ ] `npm --version` returns a version
- [ ] `git --version` returns a version
- [ ] `claude --version` returns a version
- [ ] `claude auth status` shows authenticated
- [ ] Status line appears in Claude Code
- [ ] `ls ~/.claude/skills | wc -l` returns 187+
- [ ] `cat ~/.claude/SKILLS_INDEX.json | head` shows valid JSON
- [ ] `echo $ENABLE_TOOL_SEARCH` returns "true"
- [ ] `claude mcp list` shows memory (if configured)

## Uninstall Options

There are TWO uninstall options. Make sure users understand the difference:

### Option 1: Skills Pack Only (Safe)

Removes Rising Tides content but keeps Claude Code and prerequisites.

**Use case:** User pulled skills globally, ran `/recommend skills`, imported what they need to their project, and now wants to clean up global.

**What's removed:**
- `~/.claude/skills/` (187 skills)
- `~/.claude/plugins/` (38 plugins)
- `SKILLS_INDEX.json`, `MCP_REGISTRY.md`, `ATTRIBUTION.md`, `SECURITY.md`

**What stays:**
- Claude Code CLI
- `settings.json` and `mcp.json` (user preferences)
- Node.js, Git, Python, all prerequisites

**Commands:**

Mac/Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.sh -o /tmp/uninstall-skills.sh && bash /tmp/uninstall-skills.sh
```

Windows:
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.ps1' -OutFile "$env:TEMP\uninstall-skills.ps1"; & "$env:TEMP\uninstall-skills.ps1"
```

### Option 2: Full Uninstall (Destructive)

**WARN users clearly:** This removes EVERYTHING and cannot be undone.

**Use case:** Complete reset or user is done with Claude Code entirely.

**What's removed:**
- Claude Code CLI
- Entire `~/.claude/` directory (ALL config, skills, plugins)
- `ENABLE_TOOL_SEARCH` from shell profile

**What stays (user may need for other projects):**
- Node.js, Git, Python, Homebrew

**Commands:**

Mac/Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.sh -o /tmp/uninstall-full.sh && bash /tmp/uninstall-full.sh
```

Windows (as Administrator):
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.ps1' -OutFile "$env:TEMP\uninstall-full.ps1"; & "$env:TEMP\uninstall-full.ps1"
```

### Interactive Menu

For guided experience:

Mac/Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall.sh -o /tmp/uninstall.sh && bash /tmp/uninstall.sh
```

Windows:
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall.ps1' -OutFile "$env:TEMP\uninstall.ps1"; & "$env:TEMP\uninstall.ps1"
```

## Response Style

- Be concise and direct
- Give platform-specific commands
- Explain what each step does briefly
- Offer to troubleshoot if something fails
- Celebrate when setup completes successfully
