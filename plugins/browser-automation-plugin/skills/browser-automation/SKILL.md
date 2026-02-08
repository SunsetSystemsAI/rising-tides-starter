---
name: browser-automation
description: Control Chrome browser for automation, testing, screenshots, and web interaction. Use when you need to navigate websites, fill forms, click elements, or capture screenshots.
mcp: claude-in-chrome
---

# Browser Automation (Claude in Chrome)

Control Chrome browser directly for automation, testing, and web interaction.

## Prerequisites

**Claude in Chrome is a BUILT-IN MCP** - no npm package to install.

### Setup Steps

1. **Install the Chrome extension**
   - Go to https://claude.ai/chrome
   - Install "Claude in Chrome" extension

2. **Enable in Claude Code** (one of these):
   ```bash
   # Option A: Launch with flag
   claude --chrome

   # Option B: Enable permanently
   # Add to ~/.claude.json: "claudeInChromeDefaultEnabled": true
   ```

3. **Verify connection**
   - Restart Chrome after installing extension
   - Restart Claude Code
   - Test with: `Get my browser tabs`

### Important: WSL Users

Claude in Chrome **does not work from WSL**. The native messaging bridge requires both Chrome and Claude Code to run in the same OS environment.

- **Windows users**: Run Claude Code from PowerShell, not WSL
- **Mac/Linux users**: Works natively

## Trigger

Invoke when:
- "take a screenshot of [website]"
- "fill out this form"
- "click the login button"
- "navigate to [url]"
- "test this web page"
- "automate [browser task]"
- "record a GIF of [workflow]"

## Available Tools

### Navigation & Context

| Tool | Purpose |
|------|---------|
| `tabs_context_mcp` | Get current tabs (call first!) |
| `tabs_create_mcp` | Create new tab |
| `navigate` | Go to URL or back/forward |
| `resize_window` | Set browser dimensions |

### Reading Pages

| Tool | Purpose |
|------|---------|
| `read_page` | Get accessibility tree of elements |
| `find` | Find elements by natural language |
| `get_page_text` | Extract text content |
| `javascript_tool` | Execute JavaScript |

### Interaction

| Tool | Purpose |
|------|---------|
| `computer` | Click, type, scroll, screenshot |
| `form_input` | Fill form fields |
| `upload_image` | Upload files to inputs |

### Recording

| Tool | Purpose |
|------|---------|
| `gif_creator` | Record browser actions as GIF |

### Debugging

| Tool | Purpose |
|------|---------|
| `read_console_messages` | Read browser console |
| `read_network_requests` | Monitor network activity |

## Workflow

### 1. Always Start with Context

```
Call tabs_context_mcp first to see available tabs
```

### 2. Navigate or Create Tab

```
Create new tab with tabs_create_mcp
Navigate to URL
```

### 3. Read the Page

```
Use read_page to get element tree
Use find for specific elements
```

### 4. Interact

```
Use computer for clicks/typing
Use form_input for form fields
```

### 5. Capture Results

```
Take screenshot with computer action="screenshot"
Record workflow with gif_creator
```

## Example: Fill a Form

```
1. tabs_context_mcp → get tab ID
2. navigate → go to form URL
3. read_page → find form elements
4. form_input → fill each field (ref from read_page)
5. computer action="left_click" → submit button
6. computer action="screenshot" → capture result
```

## Example: Record a Workflow

```
1. gif_creator action="start_recording"
2. computer action="screenshot" → initial frame
3. [perform actions]
4. computer action="screenshot" → final frame
5. gif_creator action="stop_recording"
6. gif_creator action="export" download=true
```

## Safety Rules

**Never:**
- Enter passwords or sensitive credentials
- Accept terms/agreements without user confirmation
- Make purchases without explicit approval
- Download files without permission
- Share personal information

**Always:**
- Get user confirmation for sensitive actions
- Verify URLs before navigation
- Stop and ask if something unexpected happens

## Tips

- Call `tabs_context_mcp` first in every session
- Use `find` with natural language: "search bar", "login button"
- Take screenshots before and after actions for debugging
- Use `read_page` with `filter="interactive"` for clickable elements only
- Check console messages when debugging JavaScript issues

## When to Use This Plugin

| Scenario | Use This Plugin |
|----------|-----------------|
| Web scraping | Yes |
| Form automation | Yes |
| Browser testing | Yes |
| Screenshot capture | Yes |
| Workflow recording | Yes |
| E2E testing (with assertions) | Consider webapp-testing-plugin instead |
