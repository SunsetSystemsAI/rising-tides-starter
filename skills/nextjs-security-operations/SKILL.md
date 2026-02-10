---
name: nextjs-security-operations
description: "Use when deploying and monitoring Next.js application security. Invoke for middleware decision guide, environment variable setup, pre-deployment checklist, security monitoring, maintenance schedule. security, OWASP, Next.js, security operations, deployment security, security monitoring, environment variables, production security"
---

# Security Operations & Deployment

## When to Apply Each Middleware

### Decision Matrix

| Route Type | Rate Limit | CSRF | Authentication |
|------------|------------|------|----------------|
| Public form submission | Yes | Yes | No |
| Protected data modification | Yes | Yes | Yes |
| Public read-only API | No | No | No |
| Protected read-only API | Maybe | No | Yes |
| Webhook endpoint | Yes | No | Signature |
| File upload | Yes | Yes | Yes |

**Order matters:** `export const POST = withRateLimit(withCsrf(handler));`
Rate limiting runs first to block excessive requests before CSRF verification.

## Environment Variables

### Required Secrets
```bash
# Generate with: node -p "require('crypto').randomBytes(32).toString('base64url')"
CSRF_SECRET=<32-byte-base64url-string>
SESSION_SECRET=<32-byte-base64url-string>

# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...

# Convex
NEXT_PUBLIC_CONVEX_URL=https://...convex.cloud
```

**Rules:** Different secrets for dev/staging/production. Never commit .env.local. Rotate quarterly.

## Security Monitoring Post-Deployment

### What to Monitor
- **Rate Limit Violations (429):** Repeated from same IP = potential brute force
- **CSRF Failures (403):** Spike = possible automated attack
- **Auth Failures (401/403):** Spikes = credential stuffing
- **Error Rate (500):** Sudden increase = attack or system issue

### Maintenance Schedule

**Daily:** Check error logs, Clerk dashboard for failed auth
**Weekly:** Run `npm audit --production`, check Dependabot alerts
**Monthly:** Full security audit, update dependencies, check security headers
**Quarterly:** Rotate secrets, major framework updates, penetration testing

## Quick Reference Commands

```bash
node -p "require('crypto').randomBytes(32).toString('base64url')"  # Generate secret
npm audit --production                                              # Pre-deploy check
npm outdated                                                        # Check updates
curl -I https://yourapp.com                                         # Test headers
grep -r "sk_live" . --exclude-dir=node_modules                     # Check for leaked secrets
```

## References

- OWASP Top 10 2021: https://owasp.org/www-project-top-ten/
- OWASP API Security Top 10: https://owasp.org/www-project-api-security/
- Next.js Security: https://nextjs.org/docs/app/guides/security
- Security Headers Scanner: https://securityheaders.com/
