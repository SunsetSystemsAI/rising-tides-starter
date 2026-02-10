---
name: nextjs-auth-security
description: "Use when implementing authentication and authorization with Clerk in Next.js. Invoke for route protection, user verification, RBAC, subscription-based access control, session management. security, OWASP, Next.js, authentication, authorization, Clerk, protect route, permissions, session"
---

# Authentication & Authorization with Clerk

## Why We Use Clerk

Building secure auth from scratch requires password hashing, session management, MFA, OAuth, and more. Applications using managed auth services have **73% fewer authentication-related vulnerabilities**.

## Basic Authentication

### Server-Side (API Routes)

```typescript
import { auth } from '@clerk/nextjs/server';
import { handleUnauthorizedError } from '@/lib/errorHandler';

async function handler(request: NextRequest) {
  const { userId } = await auth();
  if (!userId) return handleUnauthorizedError('Authentication required');
  // User is authenticated
}
```

### Protecting Routes with Middleware

```typescript
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isProtectedRoute = createRouteMatcher(['/dashboard(.*)', '/api/protected(.*)']);

export default clerkMiddleware((auth, req) => {
  if (isProtectedRoute(req)) auth().protect();
});
```

## Authorization Patterns

### Resource Ownership
```typescript
if (post.userId !== userId) {
  return handleForbiddenError('Only the post author can delete this post');
}
```

### Role-Based Access Control
```typescript
const role = sessionClaims?.metadata?.role as string;
if (role !== 'admin') return handleForbiddenError('Admin access required');
```

### Subscription-Based Authorization
```typescript
const plan = sessionClaims?.metadata?.plan as string;
if (plan === 'free_user') {
  return NextResponse.json({ error: 'Upgrade required' }, { status: 403 });
}
```

## Security Best Practices

1. **Always verify on server** - Client-side auth checks can be bypassed
2. **Check authorization, not just authentication** - Verify resource ownership
3. **Use middleware for route protection** - Protect entire route sections
4. **Handle session expiration gracefully**

## Clerk Integration Guidelines

- Use `clerkMiddleware()` from `@clerk/nextjs/server` (NOT deprecated `authMiddleware`)
- Wrap app with `<ClerkProvider>` in `app/layout.tsx`
- Use App Router approach only (NOT pages router)
- Import `auth()` from `@clerk/nextjs/server` with async/await

## References

- Clerk Documentation: https://clerk.com/docs
- Clerk Security: https://clerk.com/docs/security
- OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
