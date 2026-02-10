# Connectors

This plugin requires the Remotion MCP to render videos.

## Required
- **remotion** — Provides video rendering, preview, and composition management. Without it, this plugin cannot create videos.

## Recommended
None

## Optional
None

## Setup
```bash
claude mcp add remotion --scope project -- npx -y @anthropic-ai/mcp-server-remotion
```
