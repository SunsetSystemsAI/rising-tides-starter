# Welcome to Rising Tides

> First-time setup guide for new Rising Tides users.

## Triggers

- "welcome"
- "getting started"
- "first time"
- "what can you do"
- "help me get started"

## When to Use

Automatically or when user seems new to the system.

## What to Tell the User

### Welcome Message

Welcome to **Rising Tides**! You now have access to 79 skills that make Claude Code dramatically more capable.

### Quick Start

**Try these commands:**

1. **Get personalized recommendations:**
   ```
   /recommend skills
   ```
   Claude analyzes your project and suggests relevant skills.

2. **Try a skill directly:**
   ```
   /copywriting write a tagline for my app
   /react-dev create a login component
   /commit-work review my changes
   ```

3. **See what's available:**
   - Marketing & SEO: copywriting, seo-audit, marketing-psychology
   - Frontend: react-dev, frontend-design, web-design-guidelines
   - Backend: supabase-guide, firebase-guide, drizzle-orm
   - Workflow: commit-work, github-workflow, session-handoff
   - Docs: mermaid-diagrams, c4-architecture, pdf, docx
   - And 60+ more!

### How It Works

```
Your Project → /recommend skills → Matches to your needs → Skills load on-demand
```

Skills don't consume context until you invoke them. You're paying ~4% for access to all 79.

### Key Locations

- Skills: `~/.claude/skills/`
- Plugins: `~/.claude/plugins/`
- Index: `~/.claude/SKILLS_INDEX.json`
- MCP configs: `~/.claude/MCP_REGISTRY.md`

### Get Help

- Community: https://www.skool.com/rising-tides-9034
- Issues: https://github.com/TinyShaft22/rising-tides-starter/issues

### Next Steps

1. Navigate to a project you're working on
2. Run `/recommend skills` to see what helps
3. Start building!

## Response Style

- Be welcoming and encouraging
- Keep it concise
- Point to one next action
- Don't overwhelm with options
