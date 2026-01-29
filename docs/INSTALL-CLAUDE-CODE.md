# Claude Code Installation Guide

This guide walks you through installing and authenticating Claude Code.

---

## Step 1: Install Claude Code

Claude Code uses a native installer. No prerequisites needed for the install itself.

### Mac / Linux / WSL2

```bash
curl -fsSL https://cli.anthropic.com/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://cli.anthropic.com/install.ps1 | iex
```

### Verify Installation

```bash
claude --version
```

---

## Step 2: Authenticate

Claude Code needs to connect to your Anthropic account.

### Login

```bash
claude auth login
```

This will:
1. Open your browser to Anthropic's login page
2. Ask you to authorize Claude Code
3. Return you to the terminal once authenticated

### Verify Authentication

```bash
claude auth status
```

You should see:
```
Authenticated as: your-email@example.com
```

---

## Step 3: First Run

Start Claude Code to verify everything works:

```bash
claude
```

You should see:
- Claude Code starts up
- A welcome message appears
- You can type messages to Claude

Try a simple test:
```
> Hello, are you working?
```

Press `Ctrl+C` or type `/exit` to quit.

---

## Managing Claude Code

### Update to Latest

```bash
claude update
```

### Uninstall

**Mac/Linux/WSL2:**
```bash
rm -f ~/.local/bin/claude
```

**Windows:**
Remove the Claude binary from your local programs directory.

---

## Where Things Are Installed

| Item | Location |
|------|----------|
| CLI Binary | `~/.local/bin/claude` (Mac/Linux) |
| Settings | `~/.claude/settings.json` |
| Auth | `~/.claude/auth.json` |
| Project Config | `.claude/` in your project |

**Mac/Linux:** `~` is your home directory (`/Users/yourname` or `/home/yourname`)

**Windows:** `~` is `C:\Users\YourName`

---

## Troubleshooting

### "command not found: claude"

**Cause:** The installer directory is not in your PATH.

**Fix:**
```bash
# Add ~/.local/bin to your PATH
# Mac/Linux: Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

Restart your terminal after adding to your shell profile.

### "Authentication failed"

**Cause:** Token expired or invalid

**Fix:**
```bash
claude auth logout
claude auth login
```

### "Network error" during auth

**Cause:** Firewall or proxy blocking connection

**Fix:**
- Check your internet connection
- Disable VPN temporarily
- Check if your firewall allows outbound HTTPS

### Browser doesn't open during auth

**Fix:** Copy the URL from the terminal and paste it into your browser manually.

---

## Configuration Files

After installation, Claude Code creates these directories:

```
~/.claude/
├── settings.json    # Your preferences
├── auth.json        # Authentication token (don't share!)
└── logs/            # Debug logs
```

Your project can have its own config:

```
your-project/
└── .claude/
    └── settings.json   # Project-specific settings
```

---

## Next Step

Once Claude Code is installed and authenticated, proceed to [Configure Environment](CONFIGURE-ENVIRONMENT.md).
