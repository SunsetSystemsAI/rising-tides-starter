---
name: security-code-review
description: "Use when performing security analysis, code audits, PR security review, or implementing secure code. Invoke for security audit, vulnerability review, OWASP prevention, auth implementation, diff review, threat modeling."
---

# Security Code Review

Comprehensive security skill covering deep code analysis, differential review of changes, and secure implementation guidance.

## Core Principles

1. **Risk-First**: Focus on auth, crypto, value transfer, external calls, validation
2. **Evidence-Based**: Every finding backed by line numbers, git history, attack scenarios
3. **Bottom-Up**: Build understanding from code, not assumptions
4. **Honest**: State coverage limits, confidence levels, and uncertainty explicitly
5. **Defense-in-Depth**: Assume all input is malicious, all external calls adversarial

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "I get the gist" | Gist-level misses edge cases | Line-by-line analysis required |
| "This function is simple" | Simple functions compose into complex bugs | Apply 5 Whys anyway |
| "Small PR, quick review" | Heartbleed was 2 lines | Classify by RISK, not size |
| "External call is probably fine" | External = adversarial until proven otherwise | Trace into code or model as hostile |
| "Just a refactor, no security impact" | Refactors break invariants | Analyze as HIGH until proven LOW |
| "I'll remember this invariant" | Context degrades | Write it down explicitly |
| "No tests = not my problem" | Missing tests = elevated risk | Flag in report, elevate severity |

---

## Mode Selection

Choose your mode based on the task:

| Mode | When to Use | Go To |
|------|-------------|-------|
| **Deep Audit** | Full codebase security analysis, architecture review, threat modeling | Section 1 |
| **Diff Review** | PR review, commit review, change-focused security analysis | Section 2 |
| **Secure Implementation** | Writing auth, validation, encryption, OWASP prevention | Section 3 |

---

## Section 1: Deep Audit Mode

For building comprehensive security understanding of a codebase before vulnerability hunting.

### Phase 1 -- Initial Orientation

1. Identify major modules, files, entrypoints
2. Map actors (users, admins, external services)
3. Identify important state variables and storage
4. Build preliminary structure without assuming behavior

### Phase 2 -- Ultra-Granular Function Analysis

Every non-trivial function receives:

**Per-Function Checklist:**
- **Purpose**: Why it exists, role in the system
- **Inputs & Assumptions**: Parameters, implicit inputs (state, env), preconditions
- **Outputs & Effects**: Returns, state writes, events, external interactions
- **Block-by-Block Analysis**: What each block does, why it's ordered this way, what invariants it maintains

Apply per block: **First Principles**, **5 Whys**, **5 Hows**

**Cross-Function Flow Analysis:**
- Internal calls: Jump into callee, trace data/assumptions through caller -> callee -> return
- External calls with available code: Treat as internal, continue block-by-block
- External calls without code (black box): Model as adversarial -- consider reverts, bad returns, reentrancy, unexpected state changes
- **Continuity Rule**: Treat entire call chain as one execution flow. Never reset context.

### Phase 3 -- Global System Understanding

1. **State & Invariant Reconstruction**: Map reads/writes per state variable, derive cross-function invariants
2. **Workflow Reconstruction**: End-to-end flows (auth, deposit, withdraw, lifecycle), state transforms, persistent assumptions
3. **Trust Boundary Mapping**: Actor -> entrypoint -> behavior, untrusted input paths, privilege changes
4. **Complexity Clustering**: Functions with many assumptions, high branching, coupled state changes -- these guide vulnerability hunting

### Stability Rules

- Never reshape evidence to fit earlier assumptions; update the model and state corrections explicitly
- Periodically anchor key invariants, state relationships, actor roles
- Use "Unclear; need to inspect X" instead of "It probably..."
- Cross-reference new insights against previous findings for coherence

---

## Section 2: Diff Review Mode

Security-focused review of PRs, commits, and diffs.

### Codebase Size Strategy

| Size | Strategy | Approach |
|------|----------|----------|
| SMALL (<20 files) | DEEP | Read all deps, full git blame |
| MEDIUM (20-200) | FOCUSED | 1-hop deps, priority files |
| LARGE (200+) | SURGICAL | Critical paths only |

### Risk Classification

| Risk Level | Triggers |
|------------|----------|
| HIGH | Auth, crypto, external calls, value transfer, validation removal |
| MEDIUM | Business logic, state changes, new public APIs |
| LOW | Comments, tests, UI, logging |

### Workflow

1. **Triage**: Classify changed files by risk level
2. **Code Analysis**: Deep review of HIGH risk files, surface scan of MEDIUM, skip LOW
3. **Test Coverage**: Check tests exist for security-critical changes
4. **Blast Radius**: Calculate callers/dependents of changed code (quantitatively for HIGH risk)
5. **Adversarial Modeling** (HIGH risk): Concrete attack scenarios, exploit feasibility
6. **Report**: Generate markdown report with findings, line numbers, commits

### Red Flags (Stop and Investigate)

- Removed code from "security", "CVE", or "fix" commits
- Access control modifiers removed (e.g., internal -> external)
- Validation removed without replacement
- External calls added without checks
- High blast radius (50+ callers) + HIGH risk change

### Quality Checklist

- [ ] All changed files analyzed
- [ ] Git blame on removed security code
- [ ] Blast radius calculated for HIGH risk
- [ ] Attack scenarios are concrete, not generic
- [ ] Findings reference specific line numbers and commits
- [ ] Report file generated

---

## Section 3: Secure Implementation Mode

Guidance for writing secure code and preventing OWASP Top 10 vulnerabilities.

### Workflow

1. **Threat Model**: Identify attack surface and threats
2. **Design**: Plan security controls
3. **Implement**: Write secure code with defense in depth
4. **Validate**: Test security controls
5. **Document**: Record security decisions

### MUST DO

- Hash passwords with bcrypt/argon2 (never plaintext)
- Use parameterized queries (prevent SQL injection)
- Validate and sanitize all user input
- Implement rate limiting on auth endpoints
- Use HTTPS everywhere
- Set security headers (CSP, CORS, HSTS)
- Log security events (auth failures, privilege changes)
- Store secrets in environment variables or secret managers

### MUST NOT DO

- Store passwords in plaintext
- Trust user input without validation
- Expose sensitive data in logs or error messages
- Use weak encryption algorithms (MD5, SHA1 for passwords)
- Hardcode secrets in code
- Disable security features for convenience

### Output Template

When implementing security features, provide:
1. Secure implementation code
2. Security considerations noted
3. Configuration requirements (env vars, headers)
4. Testing recommendations

### Reference Topics

OWASP Top 10, bcrypt/argon2, JWT, OAuth 2.0, OIDC, CSP, CORS, rate limiting, input validation, output encoding, AES/RSA encryption, TLS, security headers, session management

---

## When NOT to Use This Skill

- Documentation-only changes (no security impact)
- Formatting/linting (cosmetic changes)
- User explicitly requests quick summary only (they accept risk)

For these cases, use standard code review instead.
