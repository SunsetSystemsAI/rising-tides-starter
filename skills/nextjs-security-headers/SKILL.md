---
name: nextjs-security-headers
description: "Use when configuring security headers for Next.js middleware. Invoke for Content-Security-Policy, X-Frame-Options, HSTS, clickjacking prevention, MIME confusion defense. security, OWASP, Next.js, CSP, content security policy, security headers, clickjacking, HSTS, middleware headers"
---

# Security Headers - Defense Against Multiple Attack Types

## Why Security Headers Are Critical

Without the right headers, browsers allow:
- Your site to be embedded in malicious iframes (clickjacking)
- Scripts from any origin (XSS amplification)
- Insecure HTTP connections (man-in-the-middle attacks)
- MIME type confusion (executing images as scripts)

## Headers We Apply

1. **Content-Security-Policy (CSP)** - Controls resource loading
2. **X-Frame-Options: DENY** - Prevents clickjacking
3. **X-Content-Type-Options: nosniff** - Prevents MIME confusion
4. **Strict-Transport-Security (HSTS)** - Forces HTTPS (production only)
5. **X-Robots-Tag: noindex, nofollow** - Protects private routes

## Implementation in Middleware

```typescript
import { clerkMiddleware } from '@clerk/nextjs/server';
import { NextResponse } from 'next/server';

export default clerkMiddleware((auth, req) => {
  const response = NextResponse.next();

  const clerkDomain = process.env.NEXT_PUBLIC_CLERK_FRONTEND_API_URL
    ? new URL(process.env.NEXT_PUBLIC_CLERK_FRONTEND_API_URL).origin : '';
  const convexDomain = process.env.NEXT_PUBLIC_CONVEX_URL
    ? new URL(process.env.NEXT_PUBLIC_CONVEX_URL).origin : '';

  const csp = [
    "default-src 'self'",
    `script-src 'self' 'unsafe-inline' 'unsafe-eval' ${clerkDomain} https://js.stripe.com`,
    `style-src 'self' 'unsafe-inline' ${clerkDomain}`,
    `connect-src 'self' ${clerkDomain} ${convexDomain} https://api.stripe.com`,
    `frame-src 'self' ${clerkDomain} https://js.stripe.com https://hooks.stripe.com`,
    "img-src 'self' data: https: blob:",
    "font-src 'self' data:",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "frame-ancestors 'none'"
  ].join('; ');

  response.headers.set('Content-Security-Policy', csp);
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');

  if (process.env.NODE_ENV === 'production') {
    response.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }

  if (req.nextUrl.pathname.startsWith('/dashboard')) {
    response.headers.set('X-Robots-Tag', 'noindex, nofollow');
  }

  return response;
});
```

## Customizing CSP for New Integrations

When adding third-party services, add their domains to the appropriate CSP directives.

## Testing Security Headers

```bash
curl -I http://localhost:3000
# Verify: X-Frame-Options, X-Content-Type-Options, Content-Security-Policy

# Online tools:
# https://securityheaders.com/
# https://observatory.mozilla.org/
```

## References

- Mozilla Security Headers Guide: https://infosec.mozilla.org/guidelines/web_security
- OWASP Secure Headers Project: https://owasp.org/www-project-secure-headers/
- Content Security Policy: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
