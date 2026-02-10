# Connectors

This plugin works standalone but testing is limited to code-level analysis without Playwright.

## Required
None

## Recommended
- **playwright** — Browser automation for running E2E tests. Without it, the skill can only advise on test strategy, not execute tests.

## Optional
None

## Setup
```bash
claude mcp add playwright --scope project -- npx -y @playwright/mcp
```
