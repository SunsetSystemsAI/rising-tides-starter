<div align="center">

# Rising Tides Starter Pack

**From zero to a fully-configured Claude Code environment in one command.**

[![Security Audit](https://img.shields.io/badge/Security%20Audit-PASSED-brightgreen?style=for-the-badge&logo=shield)](SECURITY.md)
[![Skills](https://img.shields.io/badge/Skills-187-blue?style=for-the-badge)](skills/)
[![Plugins](https://img.shields.io/badge/Plugins-38-purple?style=for-the-badge)](plugins/)
[![MCPs](https://img.shields.io/badge/MCPs-18-orange?style=for-the-badge)](MCP_REGISTRY.md)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*A curated, security-audited collection of Claude Code skills from the open-source community.*

[Quick Start](#one-command-setup) | [What It Does](#what-the-installer-does) | [Security](#security-audit) | [Attribution](#attribution--credits) | [Community](https://www.skool.com/rising-tides-9034)

</div>

---

## What the Installer Does

The setup script is **non-destructive** — it only adds what's missing.

### Smart Skip Logic

| Component | If Already Installed | If Missing |
|-----------|---------------------|------------|
| **Claude Code** | ✅ Skip, just update to latest | Install |
| **Node.js 18+** | ✅ Skip | Install Node 20 |
| **Git** | ✅ Skip | Install |
| **Python 3** | ✅ Skip | Install |
| **Homebrew** (Mac) | ✅ Skip | Install |
| **Build tools** | ✅ Skip | Install |
| **Your settings** | ✅ Preserve existing | Create defaults |

### What Gets Installed

The script installs:
1. **Prerequisites** — Only what's missing (Node.js, Git, etc.)
2. **Claude Code** — Skipped if you already have it
3. **Rising Tides Skills Pack** — 187 skills + 38 plugins to `~/.claude/`
4. **Tool Search** — Adds `ENABLE_TOOL_SEARCH=true` to your shell profile

**It does NOT:**
- Overwrite your existing Claude settings
- Remove or modify your projects
- Change system configurations beyond adding tools to PATH
- Install anything you already have

---

## What You're Getting

The Rising Tides system uses **progressive disclosure** — you don't load all skills into context. Claude discovers what's available through a lightweight index and loads full skill content only when needed.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RISING TIDES PACK                               │
├─────────────────────────────────────────────────────────────────────────┤
│   187 Skills    │  Marketing, Frontend, Backend, Security, DevOps      │
│    38 Plugins   │  Bundled skill + MCP packages                        │
│     9 CLIs      │  gh, stripe, vercel, firebase, supabase...           │
│    18 MCPs      │  context7, playwright, github, n8n, remotion...      │
└─────────────────────────────────────────────────────────────────────────┘
```

### Skill Categories

| Category | Skills | What You Get |
|----------|--------|--------------|
| **Security** | 24 | Auditing, YARA rules, Semgrep, smart contracts, OWASP patterns |
| **Frontend** | 18 | React, Vue, Angular, TypeScript, design systems |
| **Backend** | 22 | Django, FastAPI, Spring Boot, NestJS, Rails, Laravel |
| **DevOps** | 15 | Kubernetes, Terraform, Docker, CI/CD, GitOps |
| **Marketing** | 23 | Copywriting, SEO, CRO, analytics, email sequences |
| **Architecture** | 12 | C4 diagrams, API design, microservices, cloud |
| **Documentation** | 11 | READMEs, Mermaid, presentations, Office docs |
| **Workflow** | 14 | Git, debugging, handoffs, requirements |
| **Languages** | 31+ | Python, Go, Rust, C++, Java, Kotlin, Swift, and more |

---

## Architecture

```mermaid
flowchart TB
    subgraph Project["Your Project"]
        direction TB
        Work["You're here building"]
        LocalSkills[".claude/skills/"]
        MCP[".mcp.json"]
    end

    subgraph Bridge["Discovery Layer"]
        Recommend["/recommend skills"]
        Index["SKILLS_INDEX.json<br/>Lightweight catalog"]
    end

    subgraph Global["~/.claude/ (Global Library)"]
        Skills["skills/<br/>187 folders"]
        Plugins["plugins/<br/>38 bundles"]
        Registry["MCP_REGISTRY.md"]
    end

    Work --> |"What skills help?"| Recommend
    Recommend --> |"Queries"| Index
    Index --> |"References"| Skills
    Skills --> |"Selected skills"| LocalSkills
    Plugins --> |"MCP config"| MCP

    style Project fill:#e1f5fe
    style Bridge fill:#fff3e0
    style Global fill:#e8f5e9
```

**You stay at project level.** You reach UP to the global library when needed, pull DOWN what helps.

### Progressive Disclosure (Context Efficiency)

| What | Tokens | When Loaded |
|------|--------|-------------|
| Skill descriptions | ~100 per skill | Session start |
| Full SKILL.md content | 500-2000 per skill | On invoke only |
| MCP tool schemas | ~500 per tool | On-demand (with Tool Search) |

**You're paying ~6% context for all 187 skills.** Full content loads only when you actually invoke a skill.

---

## One-Command Setup

### Mac

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-mac.sh -o /tmp/setup.sh && bash /tmp/setup.sh
```

> **Do NOT use `sudo`.** The script will ask for your password when needed.

### Windows

Open PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-windows.ps1' -OutFile "$env:TEMP\setup-windows.ps1"
& "$env:TEMP\setup-windows.ps1"
```

### Linux / WSL2

```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/setup-linux.sh -o /tmp/setup.sh && bash /tmp/setup.sh
```

---

## After Setup

The only manual step is authentication:

```bash
claude auth login
```

Then you're ready:

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
/security-audit check this codebase for vulnerabilities
```

---

## Security Audit

<div align="center">

### Security Status: PASSED

</div>

We take security seriously. Every skill and script in this collection has been audited.

```mermaid
flowchart LR
    subgraph Audit["Security Audit Process"]
        direction TB
        A["1,012+ Files Scanned"]
        B["Pattern Analysis"]
        C["Manual Review"]
        D["Fix & Verify"]
    end

    subgraph Results["Audit Results"]
        Critical["Critical: 0"]
        High["High: 0<br/>(2 fixed)"]
        Medium["Medium: 3<br/>(documented)"]
        Low["Low: 4<br/>(informational)"]
    end

    A --> B --> C --> D --> Results

    style Critical fill:#4caf50,color:#fff
    style High fill:#4caf50,color:#fff
    style Medium fill:#ff9800,color:#fff
    style Low fill:#2196f3,color:#fff
```

### What We Scanned

| Category | Count | Status |
|----------|-------|--------|
| Skill directories | 187 | ✅ Passed |
| Plugin directories | 37 | ✅ Passed |
| Shell scripts | 4 | ✅ Fixed |
| Python scripts | 76 | ✅ Reviewed |
| MCP configurations | 14 | ✅ Verified |
| **Total files** | **1,012+** | **✅ Audited** |

### Security Checks Performed

| Check | Result |
|-------|--------|
| Hardcoded API keys | ✅ None found |
| Malicious URLs | ✅ All official sources only |
| Data exfiltration code | ✅ None found |
| Command injection patterns | ✅ Fixed (2 instances) |
| Privilege escalation | ✅ Only in install docs |
| Unsafe file operations | ✅ None found |
| MCP over-permissions | ✅ Minimal permissions used |

### Community Repository Audit

We also audited 16 community repositories before including any skills:

| Verdict | Count | Outcome |
|---------|-------|---------|
| **Approved** | 10 repos | Included in collection |
| **Rejected** | 6 repos | Not included |

**Rejection reasons included:** telemetry uploading user data, unauditable binaries, `bypassPermissions` flags, and unsafe curl-to-bash patterns.

### Security Model

```mermaid
graph TB
    subgraph Safe["LOW RISK — Human Readable"]
        Skills["Skills<br/>SKILL.md files"]
        Docs["Documentation<br/>*.md files"]
        Index["Index files<br/>JSON catalogs"]
    end

    subgraph Trust["HIGHER RISK — Executable"]
        MCP["MCP Servers<br/>Run as processes"]
        NPX["npx packages<br/>Downloaded at runtime"]
    end

    Skills --> |"Auditable"| Review["You can read<br/>every line"]
    MCP --> |"Verified"| Approved["Only approved<br/>MCPs listed"]

    style Safe fill:#c8e6c9
    style Trust fill:#fff3e0
```

**Skills are safe by design** — they're just markdown files you can read and audit yourself.

**MCPs require trust** — we only include MCPs from verified publishers (Anthropic, Upstash, Microsoft).

📄 **[Full Security Report](SECURITY-AUDIT-SKILLS.md)** | **[Community Audit](SECURITY-AUDIT-COMMUNITY-REPOS.md)**

---

## Attribution & Credits

<div align="center">

### Standing on the Shoulders of Giants

*This collection curates and packages skills from the open-source community.*
*All credit goes to the original authors.*

</div>

We believe in giving credit where it's due. This pack wouldn't exist without the incredible work of these contributors:

### Original Skill Sources

| Source | Skills | Focus Area | License |
|--------|--------|------------|---------|
| **[Trail of Bits](https://github.com/trailofbits/skills)** | 24 | Security auditing, YARA, Semgrep, smart contracts | Apache-2.0 |
| **[Corey Haines](https://github.com/coreyhaines31/marketingskills)** | 23 | Marketing, SEO, CRO, copywriting | MIT |
| **[Jeff Allan](https://github.com/Jeffallan/claude-skills)** | 60+ | Languages, frameworks, architecture | MIT |
| **[Softaworks](https://github.com/softaworks/agent-toolkit)** | 40 | Dev workflow, architecture, communication | MIT |
| **[harperaa](https://github.com/harperaa/secure-claude-skills)** | 11 | Next.js security patterns (OWASP) | MIT |
| **[Vercel Labs](https://github.com/vercel-labs/agent-skills)** | 3 | React, web design | MIT |
| **[Ahmed Asmar](https://github.com/ahmedasmar/devops-claude-skills)** | 6 | DevOps, SRE, Kubernetes | MIT |
| **[Chris Wiles](https://github.com/ChrisWiles/claude-code-showcase)** | 5 | Claude Code patterns, hooks | MIT |
| **[rknall](https://github.com/rknall/claude-skills)** | 6 | Docker, GitLab stack | MIT |
| **[Anton Babenko](https://github.com/antonbabenko/terraform-skill)** | 1 | Terraform IaC | Apache-2.0 |
| **[obra/superpowers](https://github.com/obra/superpowers)** | 1 | Debugging methodology | MIT |
| **[lackeyjb](https://github.com/lackeyjb/playwright-skill)** | 1 | Playwright testing | MIT |
| **[Romuald Czlonkowski](https://github.com/czlonkowski/n8n-skills)** | 7 | n8n workflow automation | MIT |
| **Anthropic** | 13 | Built-in Claude Code skills | Apache-2.0 |

### MCP Server Sources

| MCP | Publisher | Repository |
|-----|-----------|------------|
| memory | Anthropic | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) |
| playwright | Anthropic | [anthropics/mcp-servers](https://github.com/anthropics/mcp-servers) |
| github | Anthropic | [anthropics/mcp-servers](https://github.com/anthropics/mcp-servers) |
| remotion | Anthropic | [anthropics/mcp-servers](https://github.com/anthropics/mcp-servers) |
| context7 | Upstash | [upstash/context7](https://github.com/upstash/context7) |
| shadcn | shadcn | [shadcn/ui](https://github.com/shadcn/ui) |
| docker | ckreiling | [ckreiling/mcp-server-docker](https://github.com/ckreiling/mcp-server-docker) |
| github-actions | ko1ynnky | [ko1ynnky/github-actions-mcp-server](https://github.com/ko1ynnky/github-actions-mcp-server) |
| n8n | Romuald Czlonkowski | [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) |

### Our Contribution

**What we did:**
- Curated 187 skills from 16+ sources
- Performed security audits on all code
- Created unified SKILLS_INDEX.json for efficient discovery
- Built 38 plugins bundling skills with MCPs
- Wrote one-command installers for all platforms
- Documented everything

**What we didn't do:**
- Write most of the skills (we're curators, not creators)
- Claim ownership of community work
- Remove attribution from original sources

📄 **[Full Attribution List](ATTRIBUTION.md)**

---

## File Locations After Install

```
~/.claude/                          # GLOBAL LIBRARY
├── skills/                         # All skills
│   ├── react-dev/
│   │   └── SKILL.md
│   ├── security-audit/
│   │   └── SKILL.md
│   └── ... (187 folders)
├── plugins/                        # Plugin bundles
│   ├── react-dev-plugin/
│   └── ... (38 folders)
├── SKILLS_INDEX.json               # Master skill catalog
├── MCP_REGISTRY.md                 # MCP configurations
├── ATTRIBUTION.md                  # Credit to original authors
└── SECURITY.md                     # Security documentation

your-project/                       # PROJECT LEVEL (where you work)
├── .claude/skills/                 # Skills pulled from global
└── .mcp.json                       # Project MCP config
```

---

## MCP Configuration

MCPs are configured **per-project** to minimize context overhead.

**Only Memory MCP should be global** — it stores persistent knowledge across all projects.

### Setting Up Memory MCP

```bash
claude mcp add memory --scope user
```

### Project-Level MCPs

When you run `/recommend skills` and confirm plugin imports, MCPs are configured automatically.

Or configure manually:

```bash
claude mcp add context7 --scope project
claude mcp add playwright --scope project
```

---

## Verification

After setup, verify your installation:

```bash
# Check versions
node --version       # Should be 18+
claude --version     # Should return version

# Check skills installed
ls ~/.claude/skills | wc -l  # Should be 187+

# Check index file
cat ~/.claude/SKILLS_INDEX.json | head

# Check Tool Search enabled
echo $ENABLE_TOOL_SEARCH  # Should be "true"
```

---

## Troubleshooting

### Script fails or stops partway on Mac

Clean up and retry:

```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/cleanup-mac.sh -o /tmp/cleanup.sh && bash /tmp/cleanup.sh
```

### "command not found: claude" after install

Close and reopen your terminal, then try again.

### Skills not loading

```bash
ls ~/.claude/skills | wc -l  # Should be 187+
cat ~/.claude/SKILLS_INDEX.json | head
```

### MCPs not working

```bash
claude mcp list
export ENABLE_TOOL_SEARCH=true
```

---

## Uninstall

We provide two uninstall options depending on what you need:

### Option 1: Remove Skills Pack Only (Recommended)

Removes Rising Tides content but **keeps Claude Code and all prerequisites** installed.

**Use this when:** You pulled skills globally, ran `/recommend skills` to import what you need to your project, and now want to clean up the global installation.

**Mac/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.sh -o /tmp/uninstall-skills.sh && bash /tmp/uninstall-skills.sh
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-skills.ps1' -OutFile "$env:TEMP\uninstall-skills.ps1"; & "$env:TEMP\uninstall-skills.ps1"
```

**What gets removed:**
- `~/.claude/skills/` (187 skills)
- `~/.claude/plugins/` (38 plugins)
- `SKILLS_INDEX.json`
- `MCP_REGISTRY.md`, `ATTRIBUTION.md`, `SECURITY.md`

**What stays intact:**
- Claude Code CLI
- Your `settings.json` and `mcp.json`
- Node.js, Git, Python, and all prerequisites

### Option 2: Full Uninstall (Everything)

> **⚠️ WARNING: This removes EVERYTHING and cannot be undone.**

Removes Claude Code, all configuration, and Rising Tides content. You'll need to reinstall from scratch.

**Use this when:** You want a complete reset or are done using Claude Code entirely.

**Mac/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.sh -o /tmp/uninstall-full.sh && bash /tmp/uninstall-full.sh
```

**Windows (PowerShell as Administrator):**
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall-full.ps1' -OutFile "$env:TEMP\uninstall-full.ps1"; & "$env:TEMP\uninstall-full.ps1"
```

**What gets removed:**
- Claude Code CLI
- Entire `~/.claude/` directory (all config, skills, plugins)
- `ENABLE_TOOL_SEARCH` from shell profile

**What stays (you may need these for other projects):**
- Node.js
- Git
- Python
- Homebrew (Mac)

### Interactive Uninstall Menu

If you want a guided experience, run the menu script:

**Mac/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall.sh -o /tmp/uninstall.sh && bash /tmp/uninstall.sh
```

**Windows:**
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SunsetSystemsAI/rising-tides-starter/main/scripts/uninstall.ps1' -OutFile "$env:TEMP\uninstall.ps1"; & "$env:TEMP\uninstall.ps1"
```

This presents a menu letting you choose between Skills Pack only or Full uninstall.

---

## Optional: Anthropic Enterprise Plugins

Rising Tides is **developer-focused**. For non-dev enterprise workflows, Anthropic offers HTTP-based MCP plugins that connect to services like Slack, Notion, and Salesforce:

| Plugin | What It Provides | Rising Tides Overlap |
|--------|------------------|---------------------|
| `productivity` | Slack, Notion, Calendar connectors | We have: daily-meeting-update, session-handoff |
| `sales` | Salesforce CRM, HubSpot pipelines | We have: copywriting, email-sequence (not CRM) |
| `customer-support` | Zendesk, Intercom tickets | We have: professional-communication (not tickets) |
| `product-management` | Jira, Linear integration | We have: requirements-clarity, qa-test-planner |
| `marketing` | Enterprise marketing tools | We have: 23 marketing skills (full coverage) |
| `legal` | Contract review, compliance | **Gap** — Rising Tides doesn't cover this |
| `finance` | Financial analysis, reporting | **Gap** — Rising Tides doesn't cover this |
| `data` | Data warehouse connectors | We have: database-schema-designer, analytics-tracking |

**Install if you need enterprise connectors:**
```bash
claude plugins add knowledge-work-plugins/productivity
claude plugins add knowledge-work-plugins/legal
claude plugins add knowledge-work-plugins/finance
```

**Skip if Rising Tides already covers your need** — don't install `marketing` if you're using our 23 marketing skills.

---

## Community & Support

<div align="center">

[![Community](https://img.shields.io/badge/Community-Skool-blue?style=for-the-badge)](https://www.skool.com/rising-tides-9034)
[![Issues](https://img.shields.io/badge/Issues-GitHub-black?style=for-the-badge&logo=github)](https://github.com/SunsetSystemsAI/rising-tides-starter/issues)
[![Skills Pack](https://img.shields.io/badge/Skills%20Pack-GitHub-black?style=for-the-badge&logo=github)](https://github.com/SunsetSystemsAI/rising-tides-pack)

</div>

- **Community:** [Rising Tides on Skool](https://www.skool.com/rising-tides-9034) — Get help, share wins
- **Issues:** [GitHub Issues](https://github.com/SunsetSystemsAI/rising-tides-starter/issues)
- **Skills Pack:** [Rising Tides Pack](https://github.com/SunsetSystemsAI/rising-tides-pack)

---

## License

This collection is MIT licensed. Individual skills retain their original licenses (MIT or Apache-2.0).

See [ATTRIBUTION.md](ATTRIBUTION.md) for per-skill license information.

---

<div align="center">

*From zero to Claude Code pro in one command.*

**A Rising Tide Lifts All Boats**

</div>
