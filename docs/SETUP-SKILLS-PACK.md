# Rising Tides Skills Pack Setup

Install and configure the Rising Tides Skills Pack with 79 skills, 9 CLIs, 8 MCPs, and 12 plugins.

---

## What You Get

| Component | Count | Description |
|-----------|-------|-------------|
| Skills | 79 | Knowledge files that teach Claude workflows |
| CLIs | 9 | Command-line integrations (gh, stripe, vercel...) |
| MCPs | 8 | Rich API operations (context7, playwright...) |
| Plugins | 12 | Bundled skill + MCP packages |

---

## Automatic Setup (Recommended)

If you ran the setup script, skills are already installed to `~/.claude/`.

Verify installation:

```bash
# Check skills count
ls ~/.claude/skills | wc -l
# Should be 79

# Check plugins count
ls ~/.claude/plugins | wc -l
# Should be 12

# Check index file
cat ~/.claude/SKILLS_INDEX.json | head -20
```

Skip to [Using Skills](#using-skills) if you used the setup script.

---

## Manual Setup

### Step 1: Create Directories

```bash
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/plugins
```

### Step 2: Copy Skills Pack

If you downloaded the starter pack:

```bash
# From the starter pack directory
cp -r skills/* ~/.claude/skills/
cp -r plugins/* ~/.claude/plugins/
cp SKILLS_INDEX.json MCP_REGISTRY.md ATTRIBUTION.md ~/.claude/
```

Or clone from GitHub:

```bash
# Clone to a temp location
git clone --depth 1 https://github.com/TinyShaft22/rising-tides-starter.git /tmp/rising-tides

# Copy to ~/.claude/
cp -r /tmp/rising-tides/skills/* ~/.claude/skills/
cp -r /tmp/rising-tides/plugins/* ~/.claude/plugins/
cp /tmp/rising-tides/SKILLS_INDEX.json ~/.claude/
cp /tmp/rising-tides/MCP_REGISTRY.md ~/.claude/
cp /tmp/rising-tides/ATTRIBUTION.md ~/.claude/

# Cleanup
rm -rf /tmp/rising-tides
```

### Step 3: Verify Installation

```bash
# Check skills
ls ~/.claude/skills | head -10

# Check plugins
ls ~/.claude/plugins

# Check index
cat ~/.claude/SKILLS_INDEX.json | head
```

---

## File Structure After Install

```
~/.claude/
├── skills/                         # All 79 skills
│   ├── copywriting/
│   │   └── SKILL.md
│   ├── react-dev/
│   │   └── SKILL.md
│   └── ... (79 folders)
├── plugins/                        # All 12 plugins
│   ├── react-dev-plugin/
│   ├── webapp-testing-plugin/
│   └── ... (12 folders)
├── SKILLS_INDEX.json               # Master skill catalog
├── MCP_REGISTRY.md                 # MCP configurations
├── ATTRIBUTION.md                  # Skill sources
└── settings.json                   # User settings
```

---

## Using Skills

### Get Skill Recommendations

In any project, run:

```
/recommend skills
```

Claude analyzes your project and shows:
- Which skills to **IMPORT** (directly relevant)
- Which skills to **SKIP** (not relevant, with reasons)
- Plugin recommendations for MCP-dependent skills

### Pull Skills to Your Project

After reviewing recommendations:

```bash
# Copy specific skills to project level
cp -r ~/.claude/skills/react-dev .claude/skills/
```

### Invoke a Skill Directly

```
/copywriting write a headline for my SaaS product
/react-dev create a login form component
/stripe-integration set up payments
```

### Let Claude Choose

Just describe what you need:

```
Help me write landing page copy for my project
```

Claude automatically matches to the copywriting skill based on triggers.

### Trigger-Based Activation

Skills activate based on keywords:

| Say this... | Activates... |
|------------|--------------|
| "write copy" | copywriting |
| "react component" | react-dev |
| "stripe payments" | stripe-integration |
| "create diagram" | mermaid-diagrams |
| "debug this" | systematic-debugging |

---

## Using Plugins

Plugins bundle a skill with its MCP dependencies.

### Via /recommend skills (Recommended)

When you confirm plugin imports:
1. Skills copy to `.claude/skills/`
2. MCP configs merge into project's `.mcp.json`
3. MCPs auto-load when you restart Claude

### Manual Plugin Loading

```bash
# Single plugin
claude --plugin-dir ~/.claude/plugins/react-dev-plugin

# Multiple plugins
claude --plugin-dir ~/.claude/plugins/react-dev-plugin \
       --plugin-dir ~/.claude/plugins/webapp-testing-plugin
```

### Available Plugins

| Plugin | Contains | MCP |
|--------|----------|-----|
| react-dev-plugin | React development | context7 |
| frontend-design-plugin | Frontend architecture | context7 |
| frontend-ui-plugin | UI with components | context7 + shadcn |
| mcp-builder-plugin | MCP development | context7 |
| webapp-testing-plugin | E2E testing | playwright |
| browser-automation-plugin | Chrome automation | claude-in-chrome |
| video-generator-plugin | Video creation | remotion |
| git-workflow-plugin | Git + GitHub | github |
| context7-plugin | Direct docs access | context7 |
| playwright-plugin | Direct browser control | playwright |
| remotion-plugin | Direct video tools | remotion |
| memory-plugin | Direct memory access | memory |

---

## CLI Integrations

Some skills use external CLIs. Install as needed:

### GitHub CLI

```bash
# Mac
brew install gh

# Windows
winget install GitHub.cli

# Linux
sudo apt install gh

# Authenticate
gh auth login
```

### Stripe CLI

```bash
# Mac
brew install stripe/stripe-cli/stripe

# Windows
scoop install stripe

# Authenticate
stripe login
```

### Vercel CLI

```bash
npm install -g vercel
vercel login
```

### All Available CLIs

| CLI | Install | Auth |
|-----|---------|------|
| gh | `brew install gh` | `gh auth login` |
| stripe | `brew install stripe/stripe-cli/stripe` | `stripe login` |
| vercel | `npm install -g vercel` | `vercel login` |
| netlify | `npm install -g netlify-cli` | `netlify login` |
| firebase | `npm install -g firebase-tools` | `firebase login` |
| supabase | `brew install supabase/tap/supabase` | `supabase login` |
| gcloud | `brew install google-cloud-sdk` | `gcloud auth login` |
| jira | `brew install ankitpokhrel/jira-cli/jira-cli` | `jira init` |

---

## Updating the Skills Pack

### Using the Update Script

```bash
# Mac/Linux/WSL2
./scripts/update-skills.sh

# Windows
.\scripts\update-skills.ps1
```

### Manual Update

```bash
# Download latest
git clone --depth 1 https://github.com/TinyShaft22/rising-tides-starter.git /tmp/rising-tides

# Copy updated files
cp -r /tmp/rising-tides/skills/* ~/.claude/skills/
cp -r /tmp/rising-tides/plugins/* ~/.claude/plugins/
cp /tmp/rising-tides/SKILLS_INDEX.json ~/.claude/
cp /tmp/rising-tides/MCP_REGISTRY.md ~/.claude/

# Cleanup
rm -rf /tmp/rising-tides
```

---

## Skill Categories

| Category | Examples |
|----------|----------|
| Marketing | copywriting, seo-audit, email-sequence |
| Frontend | react-dev, frontend-design, design-system-starter |
| Backend | drizzle-orm, oauth-setup, supabase-guide |
| Workflow | commit-work, systematic-debugging, session-handoff |
| Documentation | mermaid-diagrams, crafting-effective-readmes |
| CRO | page-cro, form-cro, signup-flow-cro |

---

## Troubleshooting

### Skills not found

1. Check skills are in ~/.claude/skills/:
   ```bash
   ls ~/.claude/skills | wc -l
   # Should be 79
   ```

2. Verify SKILLS_INDEX.json exists:
   ```bash
   cat ~/.claude/SKILLS_INDEX.json | head
   ```

3. Restart Claude Code

### Skill not invoking

1. Check the skill folder exists:
   ```bash
   ls ~/.claude/skills/copywriting/
   ```

2. Check SKILL.md exists in the folder:
   ```bash
   cat ~/.claude/skills/copywriting/SKILL.md | head
   ```

### Plugin not loading

1. Check plugin path exists:
   ```bash
   ls ~/.claude/plugins/react-dev-plugin/
   ```

2. Verify plugin structure:
   ```
   plugin-name/
   ├── .mcp.json
   └── skills/
       └── skill-name/
           └── SKILL.md
   ```

### MCP errors

1. Check MCP package is available:
   ```bash
   npx -y @upstash/context7-mcp --help
   ```

2. Verify .mcp.json syntax

3. Check for npm/network issues

---

## Next Steps

You're all set! Try these:

```bash
# Start Claude
claude

# Get skill recommendations for your project
/recommend skills

# Or use skills directly
/copywriting write a headline for a productivity app
/react-dev create a React component for a user profile card
```

---

## Support

- **Community:** [Rising Tides on Skool](https://www.skool.com/rising-tides-9034)
- **Skills Pack Issues:** [GitHub Issues](https://github.com/TinyShaft22/rising-tides-starter/issues)

---

*Welcome to the Rising Tides community!*
