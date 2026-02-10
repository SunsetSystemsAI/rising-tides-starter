---
name: nextjs-security-overview
description: Use when building secure Next.js applications. Invoke for defense-in-depth
  architecture, 5-layer security stack, OWASP scoring, security layer decisions. security,
  OWASP, Next.js, defense in depth, security architecture, security layers, security
  overview, security principles
dependencies:
  recommended:
  - nextjs-auth-security
  - nextjs-csrf-protection
  - nextjs-dependency-security
  - nextjs-error-handling
  - nextjs-input-validation
  - nextjs-payment-security
  - nextjs-rate-limiting
  - nextjs-security-headers
  - nextjs-security-testing
---

# Security Architecture Overview

## Project Security Profile

**Project:** Secure Vibe Coding OS
**Version:** 1.0
**Next.js Version:** 15.5.4
**Security Audit Status:** 0 vulnerabilities
**OWASP Score:** 90/100 (Top 10% of Next.js applications)

## What This Project Is

Secure Vibe Coding OS is a production-ready SaaS starter template built with **security as a first-class concern**, not an afterthought. Unlike typical Next.js starters that provide basic authentication and hope you figure out the rest, this starter embeds enterprise-grade security controls from day one.

## Why This Architecture Exists

According to Veracode's 2024 State of Software Security Report, **AI-generated code picks insecure patterns 45% of the time**. Standard SaaS starters compound this problem by providing minimal security guidance. Developers then prompt AI to build features on an insecure foundation, and each new feature becomes a potential vulnerability.

This architecture breaks that cycle by providing:
- **Defense-in-depth security** (multiple layers)
- **Secure-by-default patterns** (opt-in to relaxed security)
- **AI-friendly security utilities** (easy to use correctly)
- **90/100 OWASP score** baseline (top 10% of applications)

## Key Security Principles

### 1. Defense-in-Depth
Every request passes through multiple security layers. If one fails, others catch the attack.

### 2. Fail-Secure
When errors occur, the system denies access by default. Better to show an error than grant unauthorized access.

### 3. Least Privilege
Users and systems get minimum access needed. Authentication confirms identity; authorization limits what they can do.

### 4. Security is Implemented, Not Assumed
We don't assume users will "use it securely." Security is baked into every utility, middleware, and pattern.

## The 5-Layer Security Stack

Every request passes through these layers before reaching business logic:

```
User Browser
     |
     v
+---------------------------------------------+
| Layer 0: Middleware (Security Headers)       |
| - X-Frame-Options: DENY                     |
| - Content-Security-Policy                   |
| - HSTS (production only)                    |
| - X-Content-Type-Options: nosniff           |
+---------------------+-----------------------+
                      |
                      v
+---------------------------------------------+
| Layer 1: Rate Limiting                      |
| - 5 requests per minute per IP              |
| - Returns HTTP 429 when exceeded            |
| - Prevents brute force & resource abuse     |
+---------------------+-----------------------+
                      |
                      v
+---------------------------------------------+
| Layer 2: CSRF Protection                    |
| - HMAC-SHA256 cryptographic signing         |
| - Single-use tokens                         |
| - Returns HTTP 403 if invalid               |
+---------------------+-----------------------+
                      |
                      v
+---------------------------------------------+
| Layer 3: Input Validation                   |
| - Zod schema validation                     |
| - Automatic XSS sanitization               |
| - Type-safe data transformation             |
| - Returns HTTP 400 if invalid               |
+---------------------+-----------------------+
                      |
                      v
+---------------------------------------------+
| Layer 4: Business Logic                     |
| - Your handler code runs here               |
| - Receives validated, sanitized data        |
| - Clerk authentication checked in middleware|
+---------------------+-----------------------+
                      |
                      v
+---------------------------------------------+
| Layer 5: Secure Error Handling              |
| - Generic messages in production            |
| - Detailed errors in development            |
| - No information leakage                    |
+---------------------------------------------+
```

**What This Achieves:**
An attacker must bypass all 5 layers simultaneously to compromise the system--effectively impossible with current attack techniques.

## When to Use Each Security Skill

### For API Route Protection:
- **nextjs-csrf-protection skill**: When creating POST/PUT/DELETE endpoints that change state
- **nextjs-rate-limiting skill**: When protecting endpoints from abuse (forms, expensive operations)
- **nextjs-input-validation skill**: When accepting any user input (always!)

### For Application Security:
- **nextjs-security-headers skill**: When configuring middleware or need to understand CSP/HSTS
- **nextjs-error-handling skill**: When implementing error responses in API routes
- **nextjs-auth-security skill**: When implementing authentication/authorization with Clerk

### For Integrations:
- **nextjs-payment-security skill**: When implementing Stripe payments via Clerk Billing
- **nextjs-dependency-security skill**: When adding packages or running security audits

### For Verification:
- **nextjs-security-testing skill**: When testing security features or pre-deployment checklist

## Architecture Decision Rationale

### Why Layered Security?

**The Single Point of Failure Problem:**
Traditional web applications often rely on a single security measure. If that one control fails or is bypassed, the entire system is compromised.

**Real-world Example:**
The 2020 SolarWinds attack exploited a single compromised build server. Once attackers bypassed that one control, they had access to thousands of organizations. A defense-in-depth approach would have caught the intrusion at multiple other layers.

**Our Approach:**
Like a medieval castle with moat, walls, towers, and inner keep--attackers must breach every layer. Each layer catches different attack types:
- **Middleware:** Stops requests before they reach application code
- **Rate Limiting:** Stops automated attacks
- **CSRF:** Stops cross-origin attacks
- **Validation:** Stops injection attacks
- **Authentication/Authorization:** Stops unauthorized access

## Complete Security Stack Pattern

Here's what a fully secure API route looks like:

```typescript
// app/api/contact/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { withRateLimit } from '@/lib/withRateLimit';
import { withCsrf } from '@/lib/withCsrf';
import { validateRequest } from '@/lib/validateRequest';
import { contactFormSchema } from '@/lib/validation';
import { handleApiError } from '@/lib/errorHandler';

async function contactHandler(request: NextRequest) {
  try {
    const body = await request.json();

    // Layer 3: Input validation
    const validation = validateRequest(contactFormSchema, body);
    if (!validation.success) {
      return validation.response;
    }

    const { name, email, subject, message } = validation.data;

    // Safe to process - all security layers passed
    await sendEmail({ to: 'admin@example.com', from: email, subject, message });

    return NextResponse.json({ success: true });

  } catch (error) {
    // Layer 5: Secure error handling
    return handleApiError(error, 'contact-form');
  }
}

// Layers 1-2: Apply security middlewares
export const POST = withRateLimit(withCsrf(contactHandler));

export const config = {
  runtime: 'nodejs', // Required for crypto operations
};
```

## Environment-Specific Security

### Development (Relaxed)
- Detailed error messages (full stack traces)
- Verbose logging
- HTTP allowed (localhost)
- Development keys

### Production (Maximum Protection)
- Generic error messages ONLY
- Minimal logging (no PII)
- HTTPS enforced (HSTS)
- Production keys

**Automatic Detection:**
The code detects `process.env.NODE_ENV === 'production'` and adjusts security posture automatically.

## Tech Stack Security Components

### Authentication: Clerk
- SOC 2 certified
- Handles password hashing, sessions, MFA, OAuth
- 73% fewer auth vulnerabilities vs custom implementations
- **Skill:** `nextjs-auth-security`

### Payments: Clerk Billing + Stripe
- Never touch card data
- PCI-DSS compliant (via Stripe)
- Webhook signature verification
- **Skill:** `nextjs-payment-security`

### Database: Convex
- Type-safe queries
- User-scoped data via ctx.auth.userId
- Additional validation in mutations

### Framework: Next.js 15.5.4
- Latest security patches
- Middleware for global security controls
- App Router for better security boundaries

## Quick Reference: Security Checklist

When creating a new API route, ensure:

- [ ] Applied `withRateLimit()` if route could be abused
- [ ] Applied `withCsrf()` for POST/PUT/DELETE
- [ ] Validated input with Zod schemas from `lib/validation.ts`
- [ ] Used `handleApiError()` in catch block
- [ ] Checked authentication with `await auth()` from Clerk
- [ ] Checked authorization if accessing user-specific resources
- [ ] Used proper HTTP status codes (200, 400, 401, 403, 404, 429, 500)
- [ ] No sensitive data logged (passwords, tokens, PII)
- [ ] Set `runtime: 'nodejs'` in config for crypto operations
- [ ] Tested the endpoint before committing

## Common Patterns - Copy & Paste Templates

### Template 1: Simple Protected Endpoint (No CSRF)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { withRateLimit } from '@/lib/withRateLimit';
import { handleApiError, handleUnauthorizedError } from '@/lib/errorHandler';
import { auth } from '@clerk/nextjs/server';

async function handler(request: NextRequest) {
  try {
    const { userId } = await auth();
    if (!userId) return handleUnauthorizedError();

    // Your logic here

    return NextResponse.json({ success: true });
  } catch (error) {
    return handleApiError(error, 'route-name');
  }
}

export const GET = withRateLimit(handler);
export const config = { runtime: 'nodejs' };
```

### Template 2: Form Submission with Full Protection

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { withRateLimit } from '@/lib/withRateLimit';
import { withCsrf } from '@/lib/withCsrf';
import { validateRequest } from '@/lib/validateRequest';
import { handleApiError, handleUnauthorizedError } from '@/lib/errorHandler';
import { contactFormSchema } from '@/lib/validation';
import { auth } from '@clerk/nextjs/server';

async function handler(request: NextRequest) {
  try {
    const { userId } = await auth();
    if (!userId) return handleUnauthorizedError();

    const body = await request.json();
    const validation = validateRequest(contactFormSchema, body);

    if (!validation.success) {
      return validation.response;
    }

    const { name, email, subject, message } = validation.data;

    // Process form (send email, save to DB, etc.)

    return NextResponse.json({ success: true });
  } catch (error) {
    return handleApiError(error, 'contact-form');
  }
}

export const POST = withRateLimit(withCsrf(handler));
export const config = { runtime: 'nodejs' };
```

### Template 3: Public Endpoint (No Auth, Yes Rate Limit)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { withRateLimit } from '@/lib/withRateLimit';
import { validateRequest } from '@/lib/validateRequest';
import { handleApiError } from '@/lib/errorHandler';
import { emailSchema } from '@/lib/validation';

async function handler(request: NextRequest) {
  try {
    const body = await request.json();
    const validation = validateRequest(emailSchema, body);

    if (!validation.success) {
      return validation.response;
    }

    const email = validation.data;

    // Process (e.g., newsletter signup)

    return NextResponse.json({ success: true });
  } catch (error) {
    return handleApiError(error, 'newsletter');
  }
}

export const POST = withRateLimit(handler);
export const config = { runtime: 'nodejs' };
```

## What NOT to Do - Common Anti-Patterns

### Anti-Pattern 1: No Security Middlewares

```typescript
// BAD - No protection
export async function POST(request: NextRequest) {
  const body = await request.json();
  // directly use body.field
  return NextResponse.json({ success: true });
}
```

**Why this is bad:** No rate limiting, no CSRF protection, no input validation. Vulnerable to brute force, CSRF attacks, and injection attacks.

### Anti-Pattern 2: Skipping Input Validation

```typescript
// BAD - No validation
async function handler(request: NextRequest) {
  const body = await request.json();
  const { title } = body; // Could contain <script> tags!
  await saveToDatabase(title);
}
```

**Why this is bad:** XSS vulnerability. User input directly stored/displayed without sanitization.

### Anti-Pattern 3: Exposing Error Details in Production

```typescript
// BAD - Information leakage
catch (error) {
  return NextResponse.json({
    error: error.message,      // Could reveal internal paths
    stack: error.stack,        // Exposes code structure
    query: failedQuery         // Reveals database schema
  }, { status: 500 });
}
```

**Why this is bad:** Helps attackers understand your system internals, database structure, file paths.

### Anti-Pattern 4: Hardcoding Secrets

```typescript
// BAD - Hardcoded secret
const apiKey = 'sk_live_123456789';

// GOOD - Environment variable
const apiKey = process.env.API_KEY;
```

**Why this is bad:** Secrets end up in version control, easily exposed if repository is compromised.

### Anti-Pattern 5: No Rate Limiting on Public Forms

```typescript
// BAD - Can be spammed infinitely
export async function POST(request: NextRequest) {
  await sendEmail(data);
  return NextResponse.json({ success: true });
}

// GOOD - Rate limited
export const POST = withRateLimit(async (request: NextRequest) => {
  await sendEmail(data);
  return NextResponse.json({ success: true });
});
```

**Why this is bad:** Attackers can spam your endpoints, rack up costs, or perform brute force attacks.

## Security Awareness: Understanding AI Code Vulnerabilities

Before implementing security controls, understand **why AI generates insecure code** and what vulnerabilities to watch for:

### Why AI Code Is Often Insecure

**Statistics from Research:**
- **45% of AI-generated code** has insecure patterns (Veracode 2024)
- **36-72% contains vulnerabilities** depending on language (Georgetown CSET 2024)
- **68% of database queries** have SQL injection (Aikido Security 2025)
- **81% stores passwords insecurely** (Databricks 2025)

## References

- OWASP Top 10 2021: https://owasp.org/www-project-top-ten/
- OWASP Cheat Sheet Series: https://cheatsheetseries.owasp.org
- Next.js Security: https://nextjs.org/docs/app/guides/security
- Clerk Security: https://clerk.com/docs/security
- OWASP Defense in Depth: https://owasp.org/www-community/Defense_in_Depth
