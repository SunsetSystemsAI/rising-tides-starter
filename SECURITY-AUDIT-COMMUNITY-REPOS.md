# Security Audit: Community Repos for Rising Tides Gap Skills

**Date:** 2026-01-31
**Method:** skill-safety-check framework (dangerous patterns, source reputation, structure validation, content review, external URLs)
**Result:** 10 approved repos (6 dropped) from 16 audited

---

## Summary Table

| # | Repo | Stars | Verdict | Key Finding |
|---|------|-------|---------|-------------|
| 1 | [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) | 5,165 | **SAFE** | Clean showcase with hooks, skills, agents, CI workflows |
| 2 | [trailofbits/skills](https://github.com/trailofbits/skills) | 2,270 | **SAFE** | Premier security firm. 24 plugins with proper `.claude-plugin/` format |
| 3 | [lackeyjb/playwright-skill](https://github.com/lackeyjb/playwright-skill) | 1,546 | **SAFE** | `require(tempFile)` + `execSync` are by-design for Playwright execution |
| 4 | [antonbabenko/terraform-skill](https://github.com/antonbabenko/terraform-skill) | 848 | **SAFE** | Pure markdown, zero code. From top Terraform community leader |
| 5 | [ckreiling/mcp-server-docker](https://github.com/ckreiling/mcp-server-docker) | 670 | **SAFE** | Clean Docker MCP server, proper SDK usage |
| 6 | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | 187 | **SAFE** | 65 quality skills. Minor: `g` npm dep in package.json |
| 7 | [ko1ynnky/github-actions-mcp-server](https://github.com/ko1ynnky/github-actions-mcp-server) | 40 | **SAFE** | Clean MCP server with URL validation and input sanitization |
| 8 | [ahmedasmar/devops-claude-skills](https://github.com/ahmedasmar/devops-claude-skills) | 28 | **SAFE** | Quality DevOps skills from established engineer. Standard API usage |
| 9 | [rknall/claude-skills](https://github.com/rknall/claude-skills) | 13 | **SAFE** | Pure markdown, no scripts. 14-year GitHub account |
| 10 | [harperaa/secure-claude-skills](https://github.com/harperaa/secure-claude-skills) | 3 | **SAFE** | Zero npm deps, hardcoded repo URL in installer. 14-year account |

---

## Verdicts Overview

| Verdict | Count | Repos |
|---------|-------|-------|
| **SAFE** | 10 | ChrisWiles, trailofbits, lackeyjb, antonbabenko, ckreiling, Jeffallan, ko1ynnky, ahmedasmar, rknall, harperaa |
| **REVIEW** | 0 | — |
| **REJECT** | 0 | — |

---

## Dropped Repos (6)

The following repos were removed during review. Documented here for audit trail.

| Repo | Stars | Reason |
|------|-------|--------|
| invariantlabs-ai/mcp-scan | 1,417 | Telemetry uploads hostname/username to external server; redundant with trailofbits security coverage |
| ailabs-393/ai-labs-claude-skills | 289 | Empty JS stubs (`TODO: implement actual logic`), no real skill content |
| fr33d3m0n/skill-threat-modeling | 130 | Unauditable binary files (SQLite, .npz); trailofbits covers threat modeling |
| levnikolaevich/claude-code-skills | 72 | `bypassPermissions` in settings.local.json; testing covered by SAFE repos |
| AgentSecOps/SecOpsAgentKit | 43 | `bash <(curl ...)` patterns (6 instances); 2-month-old org; trailofbits covers security |
| ThamJiaHe/claude-prompt-engineering-guide | 26 | Documentation/examples only, not production skills |

---

## Detailed Findings by Tier

### Tier 1 — High Stars (5 SAFE)

**ChrisWiles/claude-code-showcase** (5,165 stars) — SAFE
- MCP config uses `${VAR}` template placeholders (standard)
- `skill-eval.js` reads local JSON only, no network calls
- GitHub workflows use official `anthropics/claude-code-action@beta` with restricted tool allowlist

**trailofbits/skills** (2,270 stars) — SAFE
- Trail of Bits = premier security research firm
- 24 plugins including fuzzing, YARA, semgrep, smart contract scanners
- Firebase scanner uses curl legitimately for security testing (not exfiltration)
- All scripts well-documented with clear purposes

**lackeyjb/playwright-skill** (1,546 stars) — SAFE
- `require(tempFile)` and `execSync('npx playwright install')` are inherent to purpose
- Env vars limited to Playwright config (`HEADLESS`, `SLOW_MO`, etc.)
- All network calls are to localhost dev servers only

**antonbabenko/terraform-skill** (848 stars) — SAFE
- Pure markdown, zero executable code
- Anton Babenko = creator of terraform-aws-modules (most popular TF modules)

**ckreiling/mcp-server-docker** (670 stars) — SAFE
- Clean Python MCP server using official Docker SDK
- No exfiltration, no telemetry, no external URLs

### Tier 2 — Medium Stars (1 SAFE)

**Jeffallan/claude-skills** (187 stars) — SAFE
- 65 skills with proper progressive disclosure (SKILL.md + 355+ reference docs)
- Scripts are filesystem-only (validation, doc generation)
- Minor: `package.json` depends on `g` npm package (single-letter, verify before use)

### Tier 3 — Low Stars (4 SAFE)

**ko1ynnky/github-actions-mcp-server** (40 stars) — SAFE
- URL validation restricts to `https://api.github.com/` only
- Input sanitization with regex validators
- `npm install --ignore-scripts` in Dockerfile (good practice)

**ahmedasmar/devops-claude-skills** (28 stars) — SAFE
- Senior DevOps engineer with 35 repos, 10-year account
- Python scripts call expected APIs (Datadog, kubectl, terraform)
- Flux bootstrap uses `$GITHUB_TOKEN` in standard prescribed way

**rknall/claude-skills** (13 stars) — SAFE
- Pure markdown, no scripts, no executables, no external URLs
- 14-year GitHub account with 24 repos

**harperaa/secure-claude-skills** (3 stars) — SAFE
- Zero npm dependencies, no postinstall scripts
- `bin/cli.js` uses hardcoded repo URL (no injection possible)
- `fs.rmSync` scoped to `.claude/skills/security` only
- 14-year GitHub account with 58 repos

---

## Adoption by Architecture Layer

How each approved repo maps to the Rising Tides architecture:

### Skills (knowledge layer — teaches Claude workflows)

| Repo | Stars | Gap Area | Notes |
|------|-------|----------|-------|
| ChrisWiles/claude-code-showcase | 5,165 | Testing + GH Actions | Skills + hooks + agents + CI patterns |
| trailofbits/skills | 2,270 | Security | 24 plugins (skill + MCP bundles) from Trail of Bits |
| antonbabenko/terraform-skill | 848 | Terraform IaC | Pure knowledge skill |
| Jeffallan/claude-skills | 187 | Testing, docs, workflows | 65 skills across multiple domains |
| ahmedasmar/devops-claude-skills | 28 | DevOps/K8s/CI-CD | Skills with diagnostic scripts |
| rknall/claude-skills | 13 | Docker validation | Pure knowledge skills |
| harperaa/secure-claude-skills | 3 | OWASP/Next.js security | Pure knowledge skills |

### Skills + MCP (skill teaches workflow, MCP provides tool access)

| Repo | Stars | Gap Area | Notes |
|------|-------|----------|-------|
| lackeyjb/playwright-skill | 1,546 | Testing (Playwright) | Skill with built-in Playwright execution engine |

### MCP Servers (tool layer — skills would reference these)

| Repo | Stars | Gap Area | Notes |
|------|-------|----------|-------|
| ckreiling/mcp-server-docker | 670 | Docker | MCP server; needs a Docker skill to pair with |
| ko1ynnky/github-actions-mcp-server | 40 | GH Actions | MCP server; pairs with CI/CD skills |

### Plugins (bundled skill + MCP — progressive disclosure)

| Repo | Stars | Notes |
|------|-------|-------|
| trailofbits/skills | 2,270 | Already structured as 24 plugins with proper `.claude-plugin/` format |

---

## Integration Notes

- **MCP-only repos** (ckreiling, ko1ynnky) need corresponding skills written to teach Claude when/how to use them, plus plugin wrappers for progressive disclosure
- **trailofbits** is already plugin-structured — can be adopted directly into the plugins system
- **lackeyjb/playwright-skill** bundles its own execution engine — could become a plugin with `.mcp.json`
- **Jeffallan/claude-skills** — remove `g` from `package.json` before any `npm install`
- Skills from other repos follow the standard pattern: skill teaches, CLI authenticates, MCP operates

---

## External URLs Inventory

| Repo | URLs Found | Assessment |
|------|-----------|------------|
| trailofbits/skills | Anthropic docs, Hugging Face blog, GitHub repos | All legitimate |
| ahmedasmar/devops-claude-skills | Datadog API (`https://api.{site}`) | Legitimate API |
| ko1ynnky/github-actions-mcp-server | `https://api.github.com/` | GitHub API (validated) |
| All others | None or self-references only | Clean |
