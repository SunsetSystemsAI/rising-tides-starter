---
name: nextjs-security-testing
description: "Use when testing security features and running pre-deployment verification. Invoke for CSRF testing, rate limit testing, security header verification, penetration testing, security checklist. security, OWASP, Next.js, security testing, verify security, pre-deployment, security checklist"
---

# Security Testing & Verification

## Testing Rate Limiting

```bash
node scripts/test-rate-limit.js
# Requests 1-5: 200 OK
# Requests 6-10: 429 Too Many Requests
```

## Testing CSRF Protection

```bash
# Without token (should fail): 403
curl -X POST http://localhost:3000/api/example-protected -d '{"title": "test"}'

# With valid token (should succeed): 200
TOKEN=$(curl -s http://localhost:3000/api/csrf -c cookies.txt | jq -r '.csrfToken')
curl -X POST http://localhost:3000/api/example-protected -b cookies.txt \
  -H "X-CSRF-Token: $TOKEN" -d '{"title": "test"}'
```

## Testing Input Validation

```bash
# XSS payload: should sanitize
curl -X POST ... -d '{"title": "<script>alert(1)</script>"}'
# Result: title = "alert(1)"

# Too long input: should reject with 400
curl -X POST ... -d '{"title": "AAAA...200 chars..."}'
```

## Testing Security Headers

```bash
curl -I http://localhost:3000
# Verify: Content-Security-Policy, X-Frame-Options: DENY, X-Content-Type-Options: nosniff
```

## Online Testing Tools

- Security Headers: https://securityheaders.com/
- Mozilla Observatory: https://observatory.mozilla.org/
- SSL Labs: https://www.ssllabs.com/ssltest/

## Pre-Deployment Security Checklist

### Environment
- [ ] All env vars set in production
- [ ] CSRF_SECRET and SESSION_SECRET generated (32+ bytes)
- [ ] Clerk production keys configured
- [ ] .env.local NOT committed

### Dependencies
- [ ] `npm audit --production` shows 0 vulnerabilities
- [ ] package-lock.json committed
- [ ] Next.js on latest stable

### Security Features
- [ ] CSRF, rate limiting, input validation tested
- [ ] Security headers verified
- [ ] Error messages are generic in production

### API Security
- [ ] All POST/PUT/DELETE have CSRF protection
- [ ] All public endpoints have rate limiting
- [ ] All input validated with Zod
- [ ] No sensitive data in logs or hardcoded secrets

## Manual Penetration Testing

Test XSS payloads in every input field:
```
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
"><script>alert('XSS')</script>
```

Test SQL injection:
```
' OR '1'='1
'; DROP TABLE users; --
```

## References

- OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
- Security Headers Scanner: https://securityheaders.com/
- Mozilla Observatory: https://observatory.mozilla.org/
