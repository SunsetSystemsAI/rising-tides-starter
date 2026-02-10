---
name: nextjs-input-validation
description: "Use when validating and sanitizing user input to prevent XSS, injection attacks. Invoke for Zod schema validation, form validation, input sanitization, cross-site scripting prevention. security, OWASP, Next.js, input validation, XSS, cross-site scripting, sanitize, Zod, injection prevention"
---

# Input Validation & XSS Prevention

## The Universal Truth of Web Security

**Never trust user input.** Every major breach traces back to input validation failures:
- **SQL Injection** - Equifax (147 million records)
- **XSS** - British Airways (380,000 transactions, 20M fine)
- **Command Injection** - Countless others

## Our Input Validation Architecture

### Why Zod?

- Type-safe validation with TypeScript
- Composable schemas
- Automatic transformation and sanitization
- Clear error messages
- Runtime type checking

### The Sanitization Strategy

We remove dangerous characters: `< > " &` while preserving apostrophes for names like O'Neal.

### Implementation Files

- `lib/validation.ts` - 11 pre-built Zod schemas
- `lib/validateRequest.ts` - Validation helper

## How to Use Input Validation

```typescript
import { validateRequest } from '@/lib/validateRequest';
import { safeTextSchema } from '@/lib/validation';

async function handler(request: NextRequest) {
  const body = await request.json();
  const validation = validateRequest(safeTextSchema, body);
  if (!validation.success) return validation.response;
  const sanitizedData = validation.data;
}
```

## Available Validation Schemas

1. **emailSchema** - Email addresses (normalized, lowercase, max 254 chars)
2. **safeTextSchema** - Short text fields (1-100 chars, XSS sanitized)
3. **safeLongTextSchema** - Long text (1-5000 chars, XSS sanitized)
4. **usernameSchema** - Alphanumeric + underscores/hyphens (3-30 chars)
5. **urlSchema** - HTTPS URLs (max 2048 chars)
6. **contactFormSchema** - Complete contact forms
7. **createPostSchema** - Blog posts with title, content, tags
8. **updateProfileSchema** - Profile updates
9. **idSchema** - Database IDs
10. **positiveIntegerSchema** - Positive integers
11. **paginationSchema** - Pagination parameters

## Creating Custom Schemas

```typescript
import { z } from 'zod';

export const myCustomSchema = z.object({
  field: z.string()
    .min(1, 'Required')
    .max(200, 'Too long')
    .trim()
    .transform((val) => val.replace(/[<>"&]/g, '')),
});
```

## Convex Integration

Always validate inputs in Convex mutations -- never insert args directly:

```typescript
export const createItem = mutation({
  handler: async (ctx, args) => {
    const validation = createItemSchema.safeParse(args);
    if (!validation.success) throw new Error("Invalid input");
    await ctx.db.insert("items", {
      title: validation.data.title,
      userId: ctx.auth.userId,
      createdAt: Date.now()
    });
  }
});
```

## References

- OWASP Input Validation Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
- OWASP XSS Prevention: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html
- Zod Documentation: https://zod.dev/
- OWASP Top 10 2021 - A03 Injection: https://owasp.org/Top10/A03_2021-Injection/
