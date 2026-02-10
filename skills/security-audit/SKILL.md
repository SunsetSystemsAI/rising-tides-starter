---
name: security-audit
description: Use when performing a comprehensive security audit on any codebase (not
  just Next.js). Invoke for security audit, vulnerability scan, secure my app, code
  security review, OWASP compliance, penetration testing prep.
dependencies:
  required:
  - security-code-review
  - security-entry-points
  - security-insecure-defaults
  - security-sharp-edges
  - security-static-analysis
  - security-variant-analysis
---

# Security Audit Orchestrator

Coordinates a comprehensive security audit of any application by invoking specialized security sub-skills. For Next.js specifically, use `nextjs-security` instead — it has 10 Next.js-specific sub-skills.

## When to Use

- User asks to "audit my app for security" or "find vulnerabilities"
- Preparing for a penetration test or compliance review
- Responding to a security incident
- General codebase security review (any language/framework)

## Sub-Skills (Invocation Order)

| Order | Skill | Purpose | MCP |
|-------|-------|---------|-----|
| 1 | `security-audit-context` | Deep architectural context building, line-by-line analysis | — |
| 2 | `security-code-review` | Manual code review for vulnerabilities, OWASP Top 10 | — |
| 3 | `security-entry-points` | Identify state-changing entry points, attack surface mapping | — |
| 4 | `security-static-analysis` | Automated scanning with CodeQL, Semgrep | — |
| 5 | `security-insecure-defaults` | Detect fail-open defaults, misconfigured security settings | — |
| 6 | `security-sharp-edges` | Find error-prone APIs and dangerous patterns | — |
| 7 | `security-variant-analysis` | Hunt for bug variants across the codebase | — |
| 8 | `security-differential-review` | Review recent changes for security regressions | github |

## Checkpoints

This orchestrator pauses between phases to confirm direction. At each checkpoint, the user can:
- **Review and confirm** — "looks good, continue"
- **Adjust** — "focus more on auth, skip the static analysis"
- **Auto-accept** — "auto-accept" or "just go" to skip all remaining checkpoints

Once auto-accept is enabled, the orchestrator runs through remaining phases without pausing.

## Workflow

### Quick Audit (Targeted)
If the user has a specific concern, invoke only the relevant sub-skill(s):
- "Review this PR for security" → `security-differential-review`
- "Find insecure defaults" → `security-insecure-defaults`
- "Run static analysis" → `security-static-analysis`
- "Map the attack surface" → `security-entry-points`

### Full Audit (Comprehensive)

**Phase 1: Context Building**
1. **Deep Analysis** — Invoke `security-audit-context` to build architectural understanding
   - Map data flows, trust boundaries, privilege levels
   - Identify sensitive operations (auth, crypto, payments, data access)
   - Build a mental model of the system before hunting bugs

> **Checkpoint:** Confirm understanding of the architecture and high-risk areas

**Phase 2: Manual Review**
2. **Code Review** — Invoke `security-code-review` for OWASP Top 10 analysis
   - Injection, auth failures, data exposure, misconfig, SSRF, etc.
3. **Entry Points** — Invoke `security-entry-points` to map attack surface
   - All state-changing endpoints, user inputs, external interfaces

> **Checkpoint:** Present initial findings — critical and high severity issues

**Phase 3: Automated Analysis**
4. **Static Analysis** — Invoke `security-static-analysis` for automated scanning
   - CodeQL queries, Semgrep rules, known vulnerability patterns
5. **Insecure Defaults** — Invoke `security-insecure-defaults` for misconfigurations
6. **Sharp Edges** — Invoke `security-sharp-edges` for dangerous API usage

> **Checkpoint:** Present automated findings, cross-reference with manual review

**Phase 4: Deep Dive**
7. **Variant Analysis** — Invoke `security-variant-analysis` to hunt related bugs
   - If Phase 2-3 found a bug, search for variants of the same pattern
8. **Change Review** — Invoke `security-differential-review` on recent commits
   - Look for security regressions in recent changes

### Output
After completing the audit, provide a security report:
- **Executive Summary** — Overall risk level, critical findings count
- **Findings by Severity** — Critical / High / Medium / Low / Informational
- **Each Finding** — Description, location, impact, remediation, evidence
- **Attack Surface Map** — Entry points, trust boundaries, data flows
- **Recommendations** — Priority-ordered fix list
- **Positive Findings** — Security measures already in place
