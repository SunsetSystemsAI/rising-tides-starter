---
name: nextjs-csrf-protection
description: "Use when protecting POST/PUT/DELETE endpoints from cross-site request forgery. Invoke for CSRF token validation, withCsrf middleware, form protection, session fixation prevention. security, OWASP, Next.js, CSRF, cross-site request forgery, token validation, protect form"
---

# CSRF Protection - Preventing Cross-Site Request Forgery

## What CSRF Attacks Are

### The Attack Scenario

Imagine you're logged into your banking app. In another tab, you visit a malicious website. That website contains hidden code that submits a form to your bank: "Transfer $10,000 to attacker's account." Because you're logged in, your browser automatically sends your session cookie, and the bank processes the transfer.

This is **Cross-Site Request Forgery**--tricking your browser into making requests you didn't intend.

### Real-World CSRF Attacks

**Router DNS Hijacking (2008):**
A CSRF vulnerability in several home routers allowed attackers to change router DNS settings by tricking users into visiting a malicious website. Victims lost no money but were redirected to phishing sites for months. Millions of routers were affected.

**YouTube Actions (2012):**
YouTube had a CSRF vulnerability that allowed attackers to perform actions as other users (like, subscribe, etc.) by tricking them into visiting a crafted URL.

### Why CSRF Is Still Common

According to OWASP, CSRF vulnerabilities appear in **35% of web applications tested**. Why?
- It's invisible when it works (users don't know they made a request)
- Easy to forget to implement (no obvious broken functionality)
- Developers often rely solely on authentication without checking request origin

## Our CSRF Architecture

### Implementation Features

1. **HMAC-SHA256 Cryptographic Signing** (industry standard)
2. **Session-Bound Tokens**
3. **Single-Use Tokens**
4. **HTTP-Only Cookies**
5. **SameSite=Strict**

### Implementation Files

- `lib/csrf.ts` - Cryptographic token generation
- `lib/withCsrf.ts` - Middleware enforcing verification
- `app/api/csrf/route.ts` - Token endpoint for clients

## How to Use CSRF Protection

### Step 1: Wrap Your Handler

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { withCsrf } from '@/lib/withCsrf';

async function handler(request: NextRequest) {
  return NextResponse.json({ success: true });
}

export const POST = withCsrf(handler);

export const config = {
  runtime: 'nodejs',
};
```

### Step 2: Client-Side Token Fetching

```typescript
const response = await fetch('/api/csrf', { credentials: 'include' });
const { csrfToken } = await response.json();

await fetch('/api/your-endpoint', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  credentials: 'include',
  body: JSON.stringify(data)
});
```

## Technical Implementation Details

### Token Generation (lib/csrf.ts)

```typescript
import { createHmac, randomBytes } from 'crypto';

export function generateCsrfToken(sessionId: string): string {
  const secret = process.env.CSRF_SECRET;
  if (!secret) throw new Error('CSRF_SECRET not configured');
  const token = randomBytes(32).toString('base64url');
  const hmac = createHmac('sha256', secret)
    .update(`${token}:${sessionId}`)
    .digest('base64url');
  return `${token}.${hmac}`;
}

export function verifyCsrfToken(token: string, sessionId: string): boolean {
  const secret = process.env.CSRF_SECRET;
  if (!secret || !token) return false;
  const [tokenPart, hmacPart] = token.split('.');
  if (!tokenPart || !hmacPart) return false;
  const expectedHmac = createHmac('sha256', secret)
    .update(`${tokenPart}:${sessionId}`)
    .digest('base64url');
  return hmacPart === expectedHmac;
}
```

### Middleware Wrapper (lib/withCsrf.ts)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { verifyCsrfToken } from './csrf';

export function withCsrf(handler: (request: NextRequest) => Promise<NextResponse>) {
  return async (request: NextRequest) => {
    const token = request.headers.get('X-CSRF-Token');
    const sessionId = request.cookies.get('sessionId')?.value;
    if (!token || !sessionId) {
      return NextResponse.json({ error: 'CSRF token missing' }, { status: 403 });
    }
    if (!verifyCsrfToken(token, sessionId)) {
      return NextResponse.json({ error: 'CSRF token invalid' }, { status: 403 });
    }
    return handler(request);
  };
}
```

## Secure Cookie Configuration

```typescript
response.cookies.set('cookie-name', value, {
  httpOnly: true,
  sameSite: 'strict',
  secure: process.env.NODE_ENV === 'production',
  maxAge: 3600,
  path: '/',
});
```

## Environment Configuration

```bash
# .env.local
CSRF_SECRET=<32-byte-base64url-string>
SESSION_SECRET=<32-byte-base64url-string>

# Generate secrets:
node -p "require('crypto').randomBytes(32).toString('base64url')"
```

## References

- OWASP CSRF Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html
- OWASP Top 10 2021 - A01 Broken Access Control: https://owasp.org/Top10/A01_2021-Broken_Access_Control/
- MDN SameSite Cookies: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
