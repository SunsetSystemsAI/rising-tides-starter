# Skill: Recommend Skills for Project

Analyze the current project and recommend which global skills or plugins to use.

**CRITICAL: When recommending plugins, NEVER show `--plugin-dir` commands. Instead, configure MCPs in the project's `.mcp.json` file. This is the new architecture.**

## Trigger

Invoke when user says:
- "recommend skills"
- "what skills should I use"
- "check skills for this project"
- "import useful skills"

## Workflow

### Step 1: Read the Global Skills Index

Read the index file at:
```
~/.claude/SKILLS_INDEX.json
```

The Skills Index contains:
- 176 global skills organized by category
- 37 plugins (skill + optional MCP bundles)
- 17 MCPs and 9 CLI definitions
- Triggers for each skill (for matching against project needs)
- `toolImportance` per skill — maps MCPs/CLIs to tiers: "essential", "recommended", "optional"
- `relatedPlugins` per skill — complementary plugins that enhance the skill
- `companionSkills` per plugin — skills that pair well with the plugin

### Step 2: Inventory What's Already Available

Check what skills/plugins already exist in the project:
```bash
ls .claude/skills/ 2>/dev/null || echo "No project skills folder"
ls .claude/plugins/ 2>/dev/null || echo "No project plugins folder"
```

These are **already imported** - do NOT recommend re-importing them.

### Step 3: Read Project Planning Docs

Read the project's planning documents to understand goals:
- `.planning/PROJECT.md` (if exists)
- `.planning/ROADMAP.md` (if exists)
- `README.md` (if no planning docs)
- `CLAUDE.md` (project instructions)
- Ask user about goals if no docs found

### Step 4: Cross-Reference Skills Against Goals

For EVERY skill in the global index, assess:
- **IMPORT** - Directly useful for planned/current work
- **MAYBE** - Could be useful in some scenarios
- **SKIP** - Not relevant to this project

**CRITICAL: For skills that have a `"plugin"` field in the index, recommend the PLUGIN instead of the standalone skill.** Read the `plugins[]` array and each skill's `"plugin"` field from SKILLS_INDEX.json — do NOT rely on a hardcoded list. There are 37 plugins covering security, frontend, DevOps, testing, and more.

**Use `toolImportance` to prioritize recommendations:**
- If a skill has `"toolImportance": {"context7": "essential"}`, the MCP is critical — always recommend the plugin version so the MCP gets configured
- If `"recommended"`, mention the MCP enhances the skill and suggest the plugin
- If `"optional"`, the skill works fine standalone — only suggest the plugin if the user wants maximum capability

**Use `relatedPlugins` to suggest complementary plugins:**
- When recommending a skill, check its `relatedPlugins` array
- If the user is importing `react-dev`, also mention its related plugins: `frontend-design-plugin`, `frontend-ui-plugin`, `webapp-testing-plugin`
- Present these as "also pairs well with" — not required, but high-value combinations
- Don't overwhelm: show at most 2-3 related plugins per skill

### Step 4.5: Check Companion Plugins

Read `companionPlugins` from the index file. For each companion plugin:
- Match its triggers against the project context
- Only suggest if NO Rising Tides skill already covers the need
- These are Anthropic enterprise plugins — separate install path

**Key rule:** Rising Tides has 16 marketing skills. Only suggest the Anthropic `marketing` companion plugin if the user needs enterprise-grade campaign management with Slack/HubSpot connectors, not basic copywriting or SEO.

### Step 5: Present Assessment

Show FIVE sections:

**1. Already Available (no action needed)**
| Item | Type | Status |
|------|------|--------|
| [name] | Skill/Plugin | Already in project |

**2. Plugins to Install (for MCP-dependent skills)**
| Plugin | Skill | MCP | Importance | Why It Helps |
|--------|-------|-----|------------|--------------|
| [plugin-name] | [skill-name] | [mcp] | Essential/Recommended/Optional | [specific reason] |

Read `toolImportance` from each skill entry to populate the Importance column. "Essential" means the skill is significantly weaker without the MCP. "Recommended" means it noticeably enhances the skill. "Optional" means nice-to-have.

**IMPORTANT: Do NOT show `--plugin-dir` commands. MCPs will be configured in `.mcp.json` after user confirms.**

**3. Skills to Import (no MCP needed)**
| Skill | Category | Why It Helps | Also Pairs With |
|-------|----------|--------------|-----------------|
| [skill-name] | [category] | [specific reason] | [relatedPlugins if any] |

Read `relatedPlugins` from each skill entry. If the skill has related plugins the user isn't already importing, show them in the "Also Pairs With" column as suggestions.

**4. Not Relevant (skipping)**
| Skill | Reason |
|-------|--------|
| [skill-name] | [why it doesn't apply] |

**5. Companion Plugins (Anthropic Enterprise — Optional)**

These are separate from Rising Tides. Install via `claude plugins add`.

| Plugin | Why It Helps | Install |
|--------|-------------|---------|
| [name] | [reason tied to project] | `claude plugins add knowledge-work-plugins/[id]` |

*These use HTTP-based MCPs (Slack, Notion, etc.) — no local setup needed.*

### Step 6: Get User Confirmation

Ask user which skills/plugins to use. Confirm before proceeding.

### Step 7: Install Plugins (Configure MCPs at Project Level)

For each confirmed plugin:

1. **Copy the skill to project level:**
   ```bash
   mkdir -p .claude/skills
   cp -r ~/.claude/plugins/[plugin-name]/skills/* .claude/skills/
   ```

2. **Read the plugin's MCP configuration:**
   ```bash
   cat ~/.claude/plugins/[plugin-name]/.mcp.json
   ```

3. **Create or merge into project's `.mcp.json`:**

   If project has no `.mcp.json`, create it with the plugin's MCP config.

   If project already has `.mcp.json`, merge the new MCP servers into the existing `mcpServers` object.

   **Example: After importing react-dev-plugin and webapp-testing-plugin:**
   ```json
   {
     "mcpServers": {
       "context7": {
         "command": "npx",
         "args": ["-y", "@upstash/context7-mcp"]
       },
       "playwright": {
         "command": "npx",
         "args": ["-y", "@playwright/mcp"]
       }
     }
   }
   ```

4. **Explain what happens:**
   - Skill files are now at project level (`.claude/skills/`)
   - MCP configuration is in project's `.mcp.json`
   - MCPs auto-load when Claude restarts in this project
   - No `--plugin-dir` flags needed
   - Uses Tool Search for deferred loading (near-zero context cost)

### Step 8: Import Skills (if any)

For confirmed skills (without MCP dependencies):
```bash
mkdir -p .claude/skills
cp -r ~/.claude/skills/[skill-name] .claude/skills/
```

### Step 9: Confirm Completion

Summarize what was done:
```
Skills imported to .claude/skills/: [list]
MCPs configured in .mcp.json: [list]
Ready to use: [skill commands]

Restart Claude to activate MCPs:
exit
claude
```

**Tip:** Enable Tool Search for optimal MCP context efficiency:
```bash
export ENABLE_TOOL_SEARCH=true
```

---

## Plugin vs Skill Decision Tree

```
Does the skill have a "plugin" field in the index?
├── Yes → Recommend the PLUGIN version
│   (read plugins[] from SKILLS_INDEX.json for the full list)
│
└── No → Import the standalone skill
    └── cp from ~/.claude/skills/
```

---

## Available Plugins

**Read `plugins[]` from SKILLS_INDEX.json** — there are 37 plugins. Do NOT use a hardcoded list. Plugins fall into two categories:

- **Skill plugins** (have `"skill"` field) — Bundle a skill + optional MCP
- **MCP wrapper plugins** (skill is `null`) — Direct tool access (context7, playwright, remotion, memory)

---

## Example Output

```
## Skills Analysis for [Project Name]

### Already Available (1 item)
| Item | Type | Status |
|------|------|--------|
| copywriting | Skill | Already imported |

### Plugins to Install (2 plugins)
| Plugin | Skill | MCP | Importance | Why It Helps |
|--------|-------|-----|------------|--------------|
| react-dev-plugin | react-dev | context7 | Recommended | Phase 2 involves new React components |
| webapp-testing-plugin | webapp-testing | playwright | Essential | E2E tests for Phase 3 — skill is significantly weaker without playwright |

> Also pairs well: `frontend-ui-plugin` (shadcn components for react-dev)

### Skills to Import (1 skill)
| Skill | Category | Why It Helps | Also Pairs With |
|-------|----------|--------------|-----------------|
| mermaid-diagrams | Docs | Document the system architecture | — |

### Not Relevant (remaining skills)
[Collapsed list with reasons]

---

Proceed with these recommendations? (yes/no)
```

After user confirms:

```
## Summary

**Skills imported to .claude/skills/:**
- react-dev
- webapp-testing
- mermaid-diagrams

**MCPs configured in .mcp.json:**
- context7 (for react-dev)
- playwright (for webapp-testing)

**Ready to use:**
- /react-dev (context7 MCP auto-loads)
- /webapp-testing (playwright MCP auto-loads)
- /mermaid (imported skill)

**Restart Claude to activate MCPs:**
exit
claude

**Tip:** Enable Tool Search for optimal MCP loading:
```bash
export ENABLE_TOOL_SEARCH=true
```
```

---

## Important Rules

1. **Never modify existing project skills/plugins** - They were added for a reason
2. **ALWAYS recommend plugins for MCP-dependent skills** - Not standalone skills
3. **Tie recommendations to specific roadmap items** - Not generic "could be useful"
4. **NEVER show `--plugin-dir` commands** - Configure MCPs in project's `.mcp.json` instead
5. **Mention Tool Search** - When recommending multiple plugins
6. **Prompt user to restart Claude** - MCPs only load on session start
7. **Companion plugins are suggestions, not imports** — They use `claude plugins add`, not skill copying
8. **Never recommend companion plugins if Rising Tides covers the need** — e.g., Rising Tides marketing skills cover copywriting/SEO; only suggest Anthropic marketing for enterprise campaign management with Slack/HubSpot connectors
9. **Companion plugins use HTTP-based MCPs** — No local setup or env vars needed

---

## MCP-Enhanced Skills → Plugin Equivalents

**Read from SKILLS_INDEX.json.** Any skill with both `"mcp"` and `"plugin"` fields should be recommended as its plugin. There are 17 MCPs across the system — filter skills where `skill.plugin !== null && skill.mcp !== null` to generate this mapping dynamically.

---

## File Locations

Global skills: `~/.claude/skills/`
Global index: `~/.claude/SKILLS_INDEX.json`
Plugins: `~/.claude/plugins/` or `./plugins/` (project-level)
