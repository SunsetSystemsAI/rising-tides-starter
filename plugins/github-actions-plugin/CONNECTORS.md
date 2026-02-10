# GitHub Actions Plugin Connectors

## Required MCP
- **github-actions** — Trigger, monitor, and debug GitHub Actions workflows

## Prerequisites
- Node.js 18+ (for npx)
- GitHub Personal Access Token with `repo` and `actions` scopes

## Environment Variables
- `GITHUB_PERSONAL_ACCESS_TOKEN` (required) — PAT with repo and actions permissions

## Getting Your Token
1. Go to https://github.com/settings/tokens
2. Generate new token (classic) with `repo` and `actions` scopes
3. Export: `export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...`

## Complementary CLI
- `gh` CLI handles simple operations (`gh run list`, `gh run view`)
- MCP provides richer workflow management and triggering capabilities
