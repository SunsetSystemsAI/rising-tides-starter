---
name: nextjs-rate-limiting
description: "Use when protecting endpoints from brute force, spam, and resource abuse. Invoke for rate limiting middleware, API abuse prevention, DoS protection, cost control on expensive operations. security, OWASP, Next.js, rate limiting, brute force, prevent spam, API abuse, 429 error, withRateLimit"
---

# Rate Limiting - Preventing Brute Force & Resource Abuse

## Why Rate Limiting Matters

### The Brute Force Problem

Without rate limiting, attackers can try thousands of passwords per second.

**Without rate limiting:** At 1,000 attempts/second -- Cracked in 5 minutes
**With our rate limiting (5 requests/minute):** At 5 attempts/minute -- Would take 117 years

### Real-World Brute Force Attacks

**Zoom Credential Stuffing (2020):** Attackers made over 500,000 login attempts using stolen credentials.

**The Cost of Resource Abuse:** One startup built an AI feature without rate limiting. A malicious user scripted 10,000 requests -- generating **$200,000+ in charges**.

## Our Rate Limiting Architecture

- **5 requests per minute per IP address**
- **In-memory tracking** - Fast, no database overhead
- **IP-based identification** - Works behind proxies via x-forwarded-for
- **HTTP 429 status** - Standard "Too Many Requests" response

### Implementation Files

- `lib/withRateLimit.ts` - Rate limiting middleware
- `app/api/test-rate-limit/route.ts` - Test endpoint

## How to Use Rate Limiting

### Basic Usage

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { withRateLimit } from '@/lib/withRateLimit';

async function handler(request: NextRequest) {
  return NextResponse.json({ success: true });
}

export const POST = withRateLimit(handler);
export const config = { runtime: 'nodejs' };
```

### Combined with CSRF Protection

```typescript
export const POST = withRateLimit(withCsrf(handler));
```

### When to Apply Rate Limiting

**Always Apply To:** Contact forms, newsletter signup, account creation, password reset, file uploads, search endpoints, AI/API operations, webhooks, bulk operations.

**Usually Not Needed For:** Static assets, simple public GET endpoints, health checks.

## Technical Implementation (lib/withRateLimit.ts)

```typescript
import { NextRequest, NextResponse } from 'next/server';

const rateLimitStore = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_WINDOW = 60 * 1000;
const MAX_REQUESTS = 5;

function getClientIp(request: NextRequest): string {
  const forwarded = request.headers.get('x-forwarded-for');
  if (forwarded) return forwarded.split(',')[0].trim();
  const realIp = request.headers.get('x-real-ip');
  if (realIp) return realIp;
  return request.ip || 'unknown';
}

export function withRateLimit(handler: (request: NextRequest) => Promise<NextResponse>) {
  return async (request: NextRequest) => {
    const clientIp = getClientIp(request);
    const now = Date.now();
    let entry = rateLimitStore.get(clientIp);
    if (!entry || now > entry.resetAt) {
      entry = { count: 0, resetAt: now + RATE_LIMIT_WINDOW };
      rateLimitStore.set(clientIp, entry);
    }
    entry.count++;
    if (entry.count > MAX_REQUESTS) {
      const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
      return NextResponse.json(
        { error: 'Too many requests', retryAfter },
        { status: 429, headers: { 'Retry-After': retryAfter.toString() } }
      );
    }
    const response = await handler(request);
    response.headers.set('X-RateLimit-Remaining', (MAX_REQUESTS - entry.count).toString());
    return response;
  };
}
```

## Production Considerations

For multi-server deployments, use Redis-based rate limiting instead of in-memory storage.

## References

- OWASP API Security - Unrestricted Resource Consumption: https://owasp.org/API-Security/editions/2023/en/0xa4-unrestricted-resource-consumption/
- Rate Limiting Best Practices: https://cloud.google.com/architecture/rate-limiting-strategies-techniques
- HTTP 429 Status Code: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429
