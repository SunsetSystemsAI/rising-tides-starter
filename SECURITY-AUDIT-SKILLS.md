# Security Audit Report: Rising Tides Skills Pack

**Date:** 2026-02-10
**Auditor:** Claude Opus 4.5
**Scope:** All skills, plugins, MCP configurations, and executable scripts

---

## Executive Summary

| Status | Result |
|--------|--------|
| **Overall** | **PASS** (with recommendations) |
| Critical Issues | 0 |
| High Issues | 2 |
| Medium Issues | 3 |
| Low/Informational | 4 |

The Rising Tides Skills Pack passes the security audit with no critical vulnerabilities. Two high-severity issues involve command injection risks in shell scripts that should be fixed before public release. Medium issues are configuration problems that don't pose direct security risks but should be addressed.

---

## Files Scanned

| Category | Count |
|----------|-------|
| Skill directories | 170 |
| Plugin directories | 37 |
| Skill files (md/py/sh/json) | 770 |
| Plugin files (md/py/sh/json) | 242 |
| MCP configuration files | 14 |
| Shell scripts | 4 |
| Python scripts | 76 |
| **Total files analyzed** | **1,012+** |

---

## Critical Findings

**None found.**

No hardcoded real API keys, no data exfiltration code, no malicious URLs, no unauthorized privilege escalation.

---

## High Findings (Must Fix)

### H1: Command Injection via `eval` in Shell Scripts

**Files:**
- `github/skills/qa-test-planner/scripts/generate_test_cases.sh` (line 33)
- `github/skills/qa-test-planner/scripts/create_bug_report.sh` (line 32)

**Issue:**
```bash
eval "$var_name=\"$input\""
```

This pattern allows command injection if user input contains shell metacharacters. An input like `$(rm -rf /)` or `; malicious_command` could execute arbitrary code.

**Risk:** High - Local code execution
**Exploitability:** Requires interactive user input (mitigates remote attack)

**Recommendation:**
Replace `eval` with a safer pattern using `declare` or indirect references:
```bash
# Option 1: Use declare (bash 4+)
declare "$var_name=$input"

# Option 2: Use nameref (bash 4.3+)
declare -n ref="$var_name"
ref="$input"

# Option 3: Use associative array
declare -A values
values["$var_name"]="$input"
```

---

### H2: `shell=True` with User-Controlled Input

**Files:**
- `github/skills/webapp-testing/scripts/with_server.py` (line 71)
- `github/plugins/webapp-testing-plugin/skills/webapp-testing/scripts/with_server.py` (line 71)

**Issue:**
```python
process = subprocess.Popen(
    server['cmd'],
    shell=True,  # Allows shell injection
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)
```

The `--server` argument is passed directly to shell execution.

**Risk:** Medium-High - The command comes from CLI arguments, which is the intended use case. However, if this script is ever called programmatically with untrusted input, it could allow command injection.

**Recommendation:**
Add a warning comment and consider using `shlex.split()` for simple commands:
```python
# WARNING: shell=True is intentional to support compound commands
# like "cd backend && npm start". Only use with trusted input.
```

Or for safer execution where possible:
```python
import shlex
# For simple commands, use shell=False
process = subprocess.Popen(
    shlex.split(server['cmd']),
    shell=False,
    ...
)
```

---

## Medium Findings (Should Fix)

### M1: Hardcoded User-Specific Path in MCP Config

**File:** `github/plugins/memory-plugin/.mcp.json`

**Issue:**
```json
"MEMORY_FILE": "/mnt/c/Users/Nick M/Desktop/claude-memory.jsonl"
```

This hardcoded path:
1. Will break for other users
2. Exposes local filesystem structure
3. May not work on non-WSL systems

**Recommendation:**
Use environment variable or relative path:
```json
"MEMORY_FILE": "${HOME}/.claude/memory.jsonl"
```
Or document that users must customize this value.

---

### M2: Example Credentials in Documentation

**File:** `github/skills/kubernetes-specialist/references/configuration.md` (lines 74-76)

**Issue:**
```yaml
db-password: "MySecurePassword123!"
api-key: "sk-1234567890abcdef"
jwt-secret: "super-secret-jwt-key"
```

While clearly examples (placeholder format), they could:
1. Be copied verbatim by careless users
2. Trigger secret scanning tools

**Recommendation:**
Use obviously fake placeholders:
```yaml
db-password: "<YOUR-DATABASE-PASSWORD>"
api-key: "sk-xxxx-replace-with-your-key"
jwt-secret: "<GENERATE-WITH-openssl-rand-base64-32>"
```

---

### M3: MCP Configurations Use `npx -y` for Automatic Installation

**Files:** Multiple `.mcp.json` files

**Pattern:**
```json
"command": "npx",
"args": ["-y", "@upstash/context7-mcp"]
```

The `-y` flag auto-confirms package installation without user prompt.

**Risk:** Low-Medium - Could install outdated or compromised packages if npm registry is compromised. This is standard practice for MCP servers but worth noting.

**Recommendation:**
- Document the behavior in user-facing docs
- Consider pinning versions: `"@upstash/context7-mcp@1.2.3"`
- Add package integrity checks where possible

---

## Low/Informational Findings

### L1: `sudo` Usage in Installation Documentation

**Location:** Multiple skill files

**Examples:**
- `github/skills/git-workflow/SKILL.md` - Installing GitHub CLI
- `github/skills/stripe-integration/SKILL.md` - Installing Stripe CLI
- Various Linux package installation commands

**Assessment:** These are legitimate installation instructions from official documentation. No security concern.

---

### L2: `chmod +x` Usage

**Location:** Multiple skill files

**Examples:**
- Making hook scripts executable
- Setting up native host binaries
- Build output permissions

**Assessment:** All uses are for making scripts executable (`chmod +x`), not opening permissions (`chmod 777`). No security concern.

---

### L3: Path Traversal Patterns (`../`)

**Location:** Multiple files

**Categories found:**
1. **Import statements** - Normal relative imports in code examples
2. **Security education** - YARA rules and vulnerability examples teaching detection
3. **Schema references** - XML schema cross-references

**Assessment:** No actual path traversal vulnerabilities. Educational content appropriately shows attack patterns.

---

### L4: Network/Exfiltration References

**Location:** `github/skills/yara-rule-authoring/` and related files

**Context:** These are YARA malware detection rules teaching how to identify:
- C2 beacons
- Data exfiltration patterns
- Malicious network calls

**Assessment:** This is security education content, not malicious code. The skill teaches threat detection.

---

## Verification Checks Passed

| Check | Result | Notes |
|-------|--------|-------|
| Hardcoded real API keys | ✅ PASS | No real credentials found |
| Malicious URLs | ✅ PASS | All URLs are to official sources (github.com, npmjs.com, etc.) |
| Data exfiltration | ✅ PASS | No code sends data externally |
| Privilege escalation | ✅ PASS | sudo only in install docs |
| Unsafe file operations | ✅ PASS | No writes to sensitive system locations |
| Unvalidated redirects | ✅ PASS | No redirect handling code |
| Deprecated crypto | ✅ PASS | No weak crypto usage |
| MCP over-permissions | ✅ PASS | All MCP configs use minimal required permissions |

---

## Recommendations Summary

### Must Fix Before Release
1. **Replace `eval` in qa-test-planner scripts** with safer variable assignment
2. **Add warning comment to with_server.py** about shell=True usage

### Should Fix
3. **Fix hardcoded path in memory-plugin** - use environment variable
4. **Update example credentials** - use obviously fake placeholders
5. **Document npx -y behavior** - inform users about auto-install

### Consider
6. Pin MCP package versions for reproducibility
7. Add input validation to shell scripts
8. Consider adding a SECURITY.md file for vulnerability reporting

---

## Files Scanned (Categories)

### Shell Scripts
```
github/skills/dependency-updater/scripts/run-taze.sh
github/skills/dependency-updater/scripts/check-tool.sh
github/skills/qa-test-planner/scripts/generate_test_cases.sh
github/skills/qa-test-planner/scripts/create_bug_report.sh
```

### MCP Configurations
```
github/plugins/context7-plugin/.mcp.json
github/plugins/frontend-design-plugin/.mcp.json
github/plugins/git-workflow-plugin/.mcp.json
github/plugins/mcp-builder-plugin/.mcp.json
github/plugins/memory-plugin/.mcp.json
github/plugins/react-dev-plugin/.mcp.json
github/plugins/remotion-plugin/.mcp.json
github/plugins/video-generator-plugin/.mcp.json
github/plugins/frontend-ui-plugin/.mcp.json
github/plugins/webapp-testing-plugin/.mcp.json
github/plugins/playwright-plugin/.mcp.json
github/plugins/docker-plugin/.mcp.json
github/plugins/github-actions-plugin/.mcp.json
github/plugins/browser-automation-plugin/.mcp.json
```

### Python Scripts (76 files)
Key security-relevant files reviewed:
- `github/skills/k8s-troubleshooter/scripts/*.py`
- `github/skills/webapp-testing/scripts/with_server.py`
- `github/skills/plugin-forge/scripts/create_plugin.py`
- `github/skills/gitops-workflows/scripts/*.py`

### Skill Directories (170)
All SKILL.md files and supporting documentation reviewed for:
- Command injection patterns
- Credential exposure
- Malicious URLs
- Privilege escalation

---

## Conclusion

The Rising Tides Skills Pack is **safe for release** after addressing the two high-severity issues:

1. **H1:** Replace `eval` with safer variable assignment in qa-test-planner scripts
2. **H2:** Add safety documentation to with_server.py shell=True usage

The codebase demonstrates good security practices overall:
- No real credentials committed
- MCP configs use standard patterns
- Security-focused skills teach proper detection techniques
- All external references are to trusted sources

---

*Report generated by Claude Opus 4.5 security audit*
