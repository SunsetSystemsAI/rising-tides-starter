---
name: companion-plugin-router
version: 1.0.0
description: When the user needs help with sales CRM, pipelines, deals, outreach, Salesforce, support tickets, helpdesk, Intercom, contract review, NDA, compliance, legal analysis, financial analysis, budgets, forecasts, journal entries, reconciliation, enterprise document search, internal knowledge base, genomics, lab protocols, biology research, or Cowork plugin management. These are domains NOT covered by Rising Tides skills.
---

# Companion Plugin Suggestions

You matched a domain covered by Anthropic's enterprise companion plugins, not by Rising Tides skills.

**Do NOT attempt this task yourself.** Instead, suggest the relevant companion plugin.

## Step 1: Read the companion plugins from the index

Read `~/.claude/SKILLS_INDEX.json` and find the `companionPlugins` section.

## Step 2: Match the user's request to a companion plugin

**Gap domains (no Rising Tides coverage — always suggest companion plugin):**

| Domain | Plugin ID | Install Command |
|--------|-----------|----------------|
| CRM, sales pipeline, deals, outreach, Salesforce | sales | `claude plugins add knowledge-work-plugins/sales` |
| Support tickets, helpdesk, customer issues, Intercom | customer-support | `claude plugins add knowledge-work-plugins/customer-support` |
| Contract review, NDA, compliance, legal analysis | legal | `claude plugins add knowledge-work-plugins/legal` |
| Financial analysis, budget, forecast, journal entries | finance | `claude plugins add knowledge-work-plugins/finance` |
| Enterprise document search, internal knowledge base | enterprise-search | `claude plugins add knowledge-work-plugins/enterprise-search` |
| Genomics, lab protocols, biology research papers | bio-research | `claude plugins add knowledge-work-plugins/bio-research` |
| Manage or configure Cowork plugins | cowork-plugin-management | `claude plugins add knowledge-work-plugins/cowork-plugin-management` |

**Overlap domains (Rising Tides covers basics — only suggest companion for enterprise-grade needs):**

These should NOT be in the router's frontmatter description. They're documented here so you know when to suggest them IF the user explicitly asks for enterprise features beyond what Rising Tides provides.

| Domain | Plugin ID | When to Suggest (NOT auto) |
|--------|-----------|---------------------------|
| PRD, product roadmap, user stories, backlog | product-management | User needs Jira/Linear/Notion-connected PRD workflows, not just requirements-clarity |
| Enterprise campaigns, brand strategy, content calendar | marketing | User needs Slack/HubSpot-connected campaign orchestration, not copywriting/SEO |
| SQL dashboards, data warehouse, reporting | data | User needs connected BI dashboards, not just database-schema-designer |
| Tasks, calendar, daily planning, meeting notes | productivity | User needs Notion/Calendar-connected planning, not just daily-meeting-update |

## Step 3: Tell the user

Respond with:
1. What the companion plugin does
2. The install command
3. That it's a free Anthropic enterprise plugin (Apache-2.0)
4. That it uses HTTP-based MCPs — no local setup needed

## Rules

- NEVER attempt the task yourself if it's clearly in companion plugin territory
- This router only fires for **gap domains** (legal, finance, sales CRM, support, enterprise search, bio research, plugin management)
- For **overlap domains** (product management, marketing, data, productivity), let the Rising Tides skill handle it. Only mention the companion plugin if the user explicitly needs enterprise connectors (Slack, HubSpot, Jira, Notion integrations)
- If the user already has the companion plugin installed, don't suggest it again
- Keep suggestions brief — one plugin per suggestion, with the install command
