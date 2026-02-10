# Connectors

This plugin works standalone for basic git operations.

## Required
None

## Recommended
- **gh CLI** — GitHub CLI for creating PRs, managing issues, and release workflows. Without it, GitHub-specific operations require manual steps.

## Optional
- **github MCP** — GitHub API operations for advanced workflows (bulk issue management, Actions triggers, repository analysis).

## Setup
```bash
# GitHub CLI
brew install gh  # Mac
# or: winget install GitHub.cli  # Windows
gh auth login

# GitHub MCP (optional)
claude mcp add github --scope project -- npx -y @anthropic-ai/mcp-server-github
```
