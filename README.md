# Rising Tides Starter Pack

**Go from zero to a fully-configured Claude Code environment with one command.**

This starter pack installs all prerequisites, Claude Code, and the complete Rising Tides Skills Pack automatically.

---

## What You're Getting

The Rising Tides system uses **progressive disclosure** — you don't load all skills into context. Claude discovers what's available through a lightweight index and loads full skill content only when needed.

```
┌─────────────────────────────────────────────────────────────┐
│                    RISING TIDES PACK                         │
├─────────────────────────────────────────────────────────────┤
│  79 Skills     │  Marketing, Frontend, Backend, Workflow    │
│  12 Plugins    │  Bundled skill + MCP packages              │
│   9 CLIs       │  gh, stripe, vercel, firebase...           │
│   8 MCPs       │  context7, playwright, github...           │
└─────────────────────────────────────────────────────────────┘
```

---

## One-Command Setup

### Mac

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/TinyShaft22/rising-tides-starter/main/scripts/setup-mac.sh | bash
```

Or if you've downloaded the starter pack:

```bash
./scripts/setup-mac.sh
```

### Windows

Open PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TinyShaft22/rising-tides-starter/main/scripts/setup-windows.ps1' -OutFile "$env:TEMP\setup-windows.ps1"
& "$env:TEMP\setup-windows.ps1"
```

Or if you've downloaded the starter pack:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-windows.ps1
```

### Linux (Ubuntu/Debian) / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/TinyShaft22/rising-tides-starter/main/scripts/setup-linux.sh | bash
```

Or if you've downloaded the starter pack:

```bash
./scripts/setup-linux.sh
```

---

## What Gets Installed

The setup script automatically installs (skipping anything already present):

| Component | Description |
|-----------|-------------|
| **Node.js 20** | Runtime for MCP servers and JS tooling |
| **Git** | Version control |
| **Claude Code** | Installed via native installer |
| **Status Line** | Better UX configured |
| **Tool Search** | `ENABLE_TOOL_SEARCH=auto` for MCP efficiency |
| **Rising Tides Skills Pack** | Skills copied to `~/.claude/skills/` |

---

## After Setup

The only manual step is authentication (requires your browser):

```bash
claude auth login
```

Then you're ready to go:

```bash
claude
```

### Get Skill Recommendations

In any project, run:

```
/recommend skills
```

Claude analyzes your project and shows which skills to import (and which to skip).

### Or Try Skills Directly

```
/copywriting write a headline for my productivity app
/react-dev create a login form component
/commit-work review and commit my changes
```

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                      YOUR PROJECT                                │
│  You're here, building something. You have a plan.              │
│  .claude/skills/ ← Skills get pulled here                       │
└─────────────────────────────────────────────────────────────────┘
         │                                           ▲
         │ "What skills would help?"                 │ Selected skills
         ▼                                           │ pulled down
┌─────────────────────────────────────────────────────────────────┐
│                    /recommend skills                             │
│  The bridge between your project and the global library         │
│  Analyzes your project → Queries index → Shows recommendations  │
└─────────────────────────────────────────────────────────────────┘
         │                                           │
         │ Queries                                   │
         ▼                                           │
┌─────────────────────────────────────────────────────────────────┐
│                    SKILLS_INDEX.json                             │
│  Lightweight catalog: names, triggers, cli/mcp refs             │
│  Fast discovery without loading all SKILL.md files              │
└─────────────────────────────────────────────────────────────────┘
         │                                           │
         │ References                                │
         ▼                                           │
┌─────────────────────────────────────────────────────────────────┐
│                    GLOBAL SKILLS (~/.claude/)                    │
│  skills/ — all skill folders                                    │
│  plugins/ — MCP bundles                                         │
│  Source of truth. User reaches up to access.                    │
└─────────────────────────────────────────────────────────────────┘
```

**You stay at project level.** You reach UP to the global library when needed, pull DOWN what helps.

---

## File Locations After Install

```
~/.claude/                          # GLOBAL LIBRARY
├── skills/                         # All skills
│   ├── react-dev/
│   │   └── SKILL.md
│   ├── copywriting/
│   │   └── SKILL.md
│   └── ... (79 folders)
├── plugins/                        # Plugin bundles
│   ├── react-dev-plugin/
│   └── ... (12 folders)
├── SKILLS_INDEX.json               # Master skill catalog
├── MCP_REGISTRY.md                 # MCP configurations
└── ATTRIBUTION.md                  # Skill sources

~/Desktop/
└── claude-memory.jsonl             # Persistent memory (if configured)

your-project/                       # PROJECT LEVEL (where you work)
├── .claude/skills/                 # Skills pulled from global
└── .mcp.json                       # Project MCP config
```

---

## MCP Configuration

MCPs are configured **per-project** (not global) to minimize context overhead.

**Only Memory MCP should be global** — it stores persistent knowledge across all projects.

### Setting Up Memory MCP

The setup script offers to configure this. You can also do it manually:

```bash
claude mcp add memory --scope user
```

### Project-Level MCPs

When you run `/recommend skills` and confirm plugin imports, MCPs are configured automatically in your project's `.mcp.json`.

Or configure manually:

```bash
# In your project directory
claude mcp add context7 --scope project
claude mcp add playwright --scope project
```

See `MCP_REGISTRY.md` for all available MCPs and configurations.

---

## Context Efficiency

**The big question:** Won't all these skills bloat my context window?

**Answer:** No. The system uses progressive disclosure:

| What | Tokens | When Loaded |
|------|--------|-------------|
| Skill frontmatter (triggers) | ~100 per skill | Session start (fixed) |
| Full SKILL.md content | 500-2000 per skill | On invoke only |
| MCP tool schemas | ~500 per tool | On-demand (with Tool Search) |

**You're paying ~4% context for all skills.** Full content loads only when invoked.

---

## Manual Setup (If Preferred)

If you prefer step-by-step control:

1. [Prerequisites Guide](docs/PREREQUISITES.md) - Install Node.js, Git
2. [Install Claude Code](docs/INSTALL-CLAUDE-CODE.md) - CLI installation
3. [Configure Environment](docs/CONFIGURE-ENVIRONMENT.md) - Status line, Tool Search
4. [Setup Skills Pack](docs/SETUP-SKILLS-PACK.md) - Copy skills to ~/.claude/

---

## Utility Scripts

### Verify Your Setup

```bash
# Mac/Linux/WSL2
./scripts/verify-setup.sh

# Windows
.\scripts\verify-setup.ps1
```

### Update Skills

```bash
# Mac/Linux/WSL2
./scripts/update-skills.sh

# Windows
.\scripts\update-skills.ps1
```

### Uninstall

```bash
# Mac/Linux/WSL2
./scripts/uninstall.sh

# Windows
.\scripts\uninstall.ps1
```

---

## Troubleshooting

### Script fails on Mac

```bash
# If permission denied
chmod +x scripts/setup-mac.sh
./scripts/setup-mac.sh
```

### Script fails on Windows

```powershell
# Must run as Administrator
# Right-click PowerShell → Run as Administrator

# If execution policy error
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### "command not found: claude" after install

Close and reopen your terminal, then try again.

### Skills not loading

Verify installation:
```bash
ls ~/.claude/skills | wc -l  # Should be 79+
cat ~/.claude/SKILLS_INDEX.json | head
```

### MCPs not working

Check configuration:
```bash
claude mcp list
```

Enable Tool Search:
```bash
export ENABLE_TOOL_SEARCH=auto
```

---

## What the Scripts Do

> **Smart Install:** All scripts check what's already installed and skip those components. Safe to run multiple times — it won't reinstall or overwrite existing software.

### Mac Script

1. Installs Xcode Command Line Tools
2. Installs Homebrew (if missing)
3. Installs Node.js 20, Git, Python 3, jq
4. Installs Claude Code via native installer
5. Creates `~/.claude/settings.json` with status line
6. Adds `ENABLE_TOOL_SEARCH=auto` to shell profile
7. Copies skills/plugins to `~/.claude/`
8. Optionally configures Memory MCP

### Windows Script

1. Verifies winget is available
2. Installs Git, Python 3, Node.js LTS via winget
3. Installs Claude Code via native installer
4. Creates settings in `%USERPROFILE%\.claude\`
5. Adds `ENABLE_TOOL_SEARCH` to PowerShell profile
6. Copies skills/plugins to `~/.claude/`
7. Optionally configures Memory MCP

### Linux Script

1. Updates package manager (apt/dnf/yum/pacman)
2. Installs build tools, Git, Python 3, curl
3. Installs Node.js 20 via NodeSource
4. Installs Claude Code via native installer
5. Creates `~/.claude/settings.json`
6. Adds `ENABLE_TOOL_SEARCH=auto` to shell profile
7. Copies skills/plugins to `~/.claude/`
8. Optionally configures Memory MCP

---

## File Structure

```
New user starter pack/
├── README.md                   # You are here
├── CLAUDE.md                   # Instructions for Claude
├── SKILLS_INDEX.json           # Master skill catalog
├── MCP_REGISTRY.md             # MCP configurations
├── ATTRIBUTION.md              # Skill sources
├── SECURITY.md                 # Security model
│
├── skills/                     # All 79 skills (bundled)
├── plugins/                    # All 12 plugins (bundled)
│
├── docs/
│   ├── QUICKSTART.md           # 5-minute manual setup
│   ├── PREREQUISITES.md        # Manual prerequisite install
│   ├── INSTALL-CLAUDE-CODE.md
│   ├── CONFIGURE-ENVIRONMENT.md
│   ├── SETUP-SKILLS-PACK.md
│   ├── PLUGIN-GUIDE.md
│   ├── MCP-SETUP-GUIDE.md
│   └── ARCHITECTURE.md
│
├── scripts/
│   ├── setup-mac.sh
│   ├── setup-linux.sh
│   ├── setup-windows.ps1
│   ├── verify-setup.sh / .ps1
│   ├── update-skills.sh / .ps1
│   ├── uninstall.sh / .ps1
│   └── check-prerequisites.sh / .ps1
│
└── config/
    ├── sample-settings.json
    └── sample-mcp.json
```

---

## Support

- **Community:** [Rising Tides on Skool](https://www.skool.com/rising-tides-9034) — Get help, share wins
- **Issues:** [GitHub Issues](https://github.com/TinyShaft22/rising-tides-starter/issues)
- **Skills Pack:** [Rising Tides Pack](https://github.com/TinyShaft22/rising-tides-pack)

---

*From zero to Claude Code pro in one command.*
