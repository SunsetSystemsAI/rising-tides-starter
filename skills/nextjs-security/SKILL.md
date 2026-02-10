---
name: nextjs-security
description: Use when performing a full Next.js security audit or securing a Next.js
  application end-to-end. Invoke for comprehensive security review, security audit,
  secure my Next.js app, OWASP compliance. Next.js security audit, secure Next.js,
  full security review, OWASP Next.js, harden Next.js
dependencies:
  required:
  - nextjs-auth-security
  - nextjs-csrf-protection
  - nextjs-dependency-security
  - nextjs-input-validation
  - nextjs-payment-security
  - nextjs-rate-limiting
  - nextjs-security-headers
  - nextjs-security-operations
  - nextjs-security-overview
  - nextjs-security-testing
---

# Next.js Security Orchestrator

This skill coordinates a comprehensive security audit of a Next.js application by invoking 10 specialized security sub-skills in the correct order.

## When to Use

- User asks to "secure my Next.js app" or "do a security audit"
- Starting a new Next.js project and want security from the start
- Preparing for production deployment
- Responding to a security incident or audit request

## Sub-Skills (Invocation Order)

Run these in sequence. Each builds on the previous:

| Order | Skill | Purpose |
|-------|-------|---------|
| 1 | `nextjs-security-overview` | Defense-in-depth architecture, 5-layer security stack, OWASP scoring |
| 2 | `nextjs-auth-security` | Authentication/authorization with Clerk, route protection, RBAC |
| 3 | `nextjs-input-validation` | Zod validation, XSS prevention, input sanitization |
| 4 | `nextjs-csrf-protection` | CSRF tokens, form protection, session fixation prevention |
| 5 | `nextjs-security-headers` | CSP, HSTS, X-Frame-Options, clickjacking prevention |
| 6 | `nextjs-rate-limiting` | Brute force protection, API abuse prevention, DoS defense |
| 7 | `nextjs-payment-security` | PCI-DSS compliance, Stripe/Clerk Billing, webhook verification |
| 8 | `nextjs-dependency-security` | npm audit, supply chain security, typosquatting defense |
| 9 | `nextjs-security-operations` | Deployment checklist, env vars, monitoring, maintenance |
| 10 | `nextjs-security-testing` | CSRF tests, rate limit tests, header verification, penetration testing |

## Checkpoints

This orchestrator pauses between phases to confirm direction. At each checkpoint, the user can:
- **Review and confirm** — "looks good, continue"
- **Adjust** — "skip payments, focus on auth"
- **Auto-accept** — "auto-accept" or "just go" to skip all remaining checkpoints

Once auto-accept is enabled, the orchestrator runs through remaining phases without pausing.

## Workflow

### Quick Audit (Targeted)
If the user has a specific concern, invoke only the relevant sub-skill(s):
- "Fix my auth" → `nextjs-auth-security`
- "Add rate limiting" → `nextjs-rate-limiting`
- "Check my headers" → `nextjs-security-headers`

### Full Audit (Comprehensive)
For a full security audit, work through all 10 in order:

1. **Start with Overview** — Assess current security posture, identify gaps
2. **Auth & Access** — Verify authentication, authorization, route protection
3. **Input & Data** — Validate all user inputs, prevent injection
4. **CSRF** — Protect state-changing endpoints
5. **Headers** — Configure security headers in middleware
6. **Rate Limiting** — Protect against abuse
7. **Payments** — If applicable, verify PCI compliance
8. **Dependencies** — Audit packages, check for vulnerabilities
9. **Operations** — Pre-deployment checklist, env var audit
10. **Testing** — Verify all security measures work

### Output
After completing the audit, provide a summary:
- Security score (based on OWASP criteria from overview skill)
- Issues found per category
- Priority fixes (critical → high → medium → low)
- Checklist of completed vs remaining items
