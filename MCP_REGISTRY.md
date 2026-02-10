# MCP Registry

> **Single source of truth for MCP integrations.** Includes both global and project-level configurations.

**Last Updated:** January 23, 2026

---

## Key Principle: Project-Level by Default

**Global MCPs consume context in EVERY session.** Configure MCPs per-project to minimize overhead.

| Scope | When to Use |
|-------|-------------|
| **Global (User)** | Only `memory` — persistence is its purpose |
| **Project** | Everything else — load only when needed |

Enable Tool Search for additional optimization: `export ENABLE_TOOL_SEARCH=auto`

---

## MCP Quick Reference

### Tier 1: Essential

| MCP | Purpose | Recommended Scope | Skills That Use It |
|-----|---------|-------------------|-------------------|
| **memory** | Persistent knowledge graph | Global (user) | (all projects) |
| **claude-in-chrome** | Full browser control | Built-in | browser-automation |
| **context7** | Live documentation | Project | react-dev, frontend-design, mcp-builder |
| **playwright** | Browser automation | Project | webapp-testing |
| **github** | Repository operations | Project or Built-in | commit-work |
| **remotion** | Video generation | Project | video-generator |

### Tier 2: High Value (Install When Needed)

| MCP | Purpose | Recommended Scope | Skills That Use It |
|-----|---------|-------------------|-------------------|
| **n8n-mcp** | Workflow automation | Project | (workflow skills) |
| **stripe-mcp** | Payment operations | Project | (payment skills) |
| **pandadoc-mcp** | Proposal generation | Project | proposal-generator |

---

## Configuration Snippets

### Memory MCP

**Scope:** Global (user) — only MCP that should be global

**CLI Setup:**
```bash
claude mcp add memory --scope user
```

**Manual Config (add to Claude Code user settings):**
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": "/mnt/c/Users/[USERNAME]/Desktop/claude-memory.jsonl"
      }
    }
  }
}
```

**Paths by platform:**
- Windows (WSL): `/mnt/c/Users/[USERNAME]/Desktop/claude-memory.jsonl`
- Mac: `/Users/[USERNAME]/Desktop/claude-memory.jsonl`
- Linux: `/home/[USERNAME]/Desktop/claude-memory.jsonl`

---

### Claude in Chrome MCP

**Scope:** Built-in — no installation needed, just enable

**IMPORTANT:** This is a **built-in MCP**, not an npm package. It connects to the Claude in Chrome browser extension.

**Setup Steps:**

1. **Install Chrome extension** from https://claude.ai/chrome

2. **Enable in Claude Code** (one of these options):
   ```bash
   # Option A: Launch with flag
   claude --chrome

   # Option B: Enable permanently in ~/.claude.json
   "claudeInChromeDefaultEnabled": true
   ```

3. **Restart Chrome** after installing extension

4. **Restart Claude Code** to connect

**Platform Requirements:**

| Platform | Works? | Notes |
|----------|--------|-------|
| Windows (PowerShell) | ✅ Yes | Native support |
| macOS | ✅ Yes | May conflict with Claude.app Cowork |
| Linux | ✅ Yes | Native support |
| WSL | ❌ No | Cannot bridge to Windows Chrome |

**WSL Users:** Claude in Chrome does NOT work from WSL. Run Claude Code from Windows PowerShell instead.

**Verify:** Ask Claude "Get my browser tabs" — if connected, it will list your open Chrome tabs.

**Troubleshooting:** Use the `chrome-extension-troubleshooting` skill.

**Skills that use it:** browser-automation

---

### Context7 MCP

**Scope:** Project — only needed for dev projects

**CLI Setup:**
```bash
claude mcp add context7 --scope project
```

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**Verify:** Ask Claude "fetch React documentation using context7"

**Skills that use it:** react-dev, frontend-design, mcp-builder

---

### Playwright MCP

**Scope:** Project — only needed for testing projects

**CLI Setup:**
```bash
claude mcp add playwright --scope project
```

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp"]
    }
  }
}
```

**Verify:** Ask Claude to open a browser and navigate to a URL

**Skills that use it:** webapp-testing

---

### GitHub MCP

**Scope:** Project (or may be built-in — check first)

**CLI Setup:**
```bash
claude mcp add github --scope project
```

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**Note:** GitHub functionality is often built into Claude Code. Check if it works without adding this MCP first.

**Verify:** Ask Claude to list PRs or create an issue

**Skills that use it:** commit-work

---

### Remotion MCP

**Scope:** Project — only needed for video projects

**CLI Setup:**
```bash
claude mcp add remotion --scope project
```

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "remotion": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-remotion"]
    }
  }
}
```

**Verify:** Ask Claude to create a video component

**Skills that use it:** video-generator

---

### n8n MCP (Tier 2)

**Scope:** Project

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": ["-y", "n8n-mcp"]
    }
  }
}
```

---

### Stripe MCP (Tier 2)

**Scope:** Project

**Project `.mcp.json`:**
```json
{
  "mcpServers": {
    "stripe": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp-server-stripe"],
      "env": {
        "STRIPE_SECRET_KEY": "${STRIPE_SECRET_KEY}"
      }
    }
  }
}
```

---

## MCP → Skill Mapping

| Skill | MCP | What the MCP Provides |
|-------|-----|----------------------|
| **browser-automation** | claude-in-chrome | Full Chrome browser control |
| **react-dev** | context7 | Current React documentation |
| **frontend-design** | context7 | Framework documentation |
| **mcp-builder** | context7 | MCP SDK documentation |
| **webapp-testing** | playwright | Browser automation |
| **commit-work** | github | PR and issue management |
| **video-generator** | remotion | Video creation |

### Skills That Reference MCPs But Don't Require Them

- **recommend-skills** — reads this registry to note dependencies
- **skill-creator** — knows how to add MCP instructions to skills

---

## Wrapper Skills for Manual MCP Use

Located at: `~/.claude/skills/_mcp-wrappers/`

| Wrapper Skill | MCP | When to Use |
|---------------|-----|-------------|
| `context7` | context7 | Pull docs for any library on demand |
| `playwright-mcp` | playwright | Browser automation outside testing |
| `remotion` | remotion | Video generation workflows |
| `github-mcp` | github | Advanced repo operations |
| `memory-graph` | memory | Manual memory management |

---

## Tool Search Integration

**Enable Tool Search** to defer MCP loading and reduce context usage:

```bash
# Add to ~/.bashrc or ~/.zshrc
export ENABLE_TOOL_SEARCH=auto
```

With Tool Search:
- MCP tool schemas load on-demand
- Dramatically reduces startup context
- Essential when multiple MCPs are configured

---

## Adding a New MCP

1. **Add to this registry** with both scopes documented
2. **Recommended scope** should be "Project" unless truly needed everywhere
3. **Create wrapper skill** (optional) in `skills/_mcp-wrappers/[name]/`
4. **Update SKILLS_INDEX.json** with `[MCP: name]` tags
5. **Update affected skills** with MCP setup instructions

---

## Removing an MCP

1. Remove from this registry
2. Remove `[MCP: name]` tags from SKILLS_INDEX.json
3. (Optional) Delete wrapper from `_mcp-wrappers/`
4. Remove from skills' MCP instructions
5. Uninstall: `claude mcp remove [name] --scope [user|project]`

---

## Skipped MCPs (with Reasons)

| MCP | Reason Skipped |
|-----|----------------|
| n8n-workflows | Not an MCP (workflow collection) |
| Repomix | Not an MCP (CLI tool) |
| Filesystem MCP | Claude Code already has file access |
| Brave Search | Redundant with built-in WebSearch |
| GitLab MCP | Using GitHub instead |
| Excel MCP | Have xlsx skill already |
| RefTools | Context7 covers this use case |

---

## Troubleshooting

### MCP Not Loading

1. **Check JSON syntax** in `.mcp.json`
2. **Check file location** — must be in project root
3. **Restart Claude Code** after config changes
4. **Test manually:** Run the npx command directly

### MCP Tools Not Appearing

1. **Check scope:** Configured for this project?
2. **Tool Search enabled?** Tools load on-demand
3. **Ask explicitly:** "Use context7 to fetch docs"

### Context Usage Too High

1. Enable Tool Search: `export ENABLE_TOOL_SEARCH=auto`
2. Move MCPs from global to project-level
3. Remove unused MCPs from configs

---

## Quick Reference

**Check what's configured:**
```bash
claude mcp list
```

**Add project MCP:**
```bash
claude mcp add [name] --scope project
```

**Remove MCP:**
```bash
claude mcp remove [name] --scope project
```

**View memory:**
```bash
cat ~/Desktop/claude-memory.jsonl | jq .
```
