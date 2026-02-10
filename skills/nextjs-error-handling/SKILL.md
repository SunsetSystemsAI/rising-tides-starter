---
name: nextjs-error-handling
description: "Use when implementing secure error handling to prevent information leakage. Invoke for environment-aware error messages, handleApiError, production error responses, stack trace prevention. security, OWASP, Next.js, error handling, information leakage, stack trace, production errors"
---

# Secure Error Handling - Preventing Information Leakage

## The Error Message Problem

In production, detailed errors help attackers more than users. They reveal database structure, file paths, dependencies, and system info.

## Environment-Aware Error Responses

**Development:** Full error with stack trace for debugging
**Production:** Generic "Internal server error" message only

## Available Error Handlers

### 1. handleApiError(error, context) - HTTP 500
```typescript
catch (error) {
  return handleApiError(error, 'payment-processing');
}
```

### 2. handleValidationError(message, details) - HTTP 400
```typescript
return handleValidationError('Validation failed', { email: 'Invalid email format' });
```

### 3. handleForbiddenError(message) - HTTP 403
```typescript
return handleForbiddenError('You do not have access to this resource');
```

### 4. handleUnauthorizedError(message) - HTTP 401
```typescript
return handleUnauthorizedError('Authentication required');
```

### 5. handleNotFoundError(resource) - HTTP 404
```typescript
return handleNotFoundError('Post');
```

## Implementation (lib/errorHandler.ts)

```typescript
import { NextResponse } from 'next/server';

export function handleApiError(error: unknown, context: string) {
  console.error(`[${context}] Error:`, error);
  if (process.env.NODE_ENV === 'production') {
    return NextResponse.json(
      { error: 'Internal server error', message: 'An unexpected error occurred.' },
      { status: 500 }
    );
  } else {
    return NextResponse.json(
      {
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
        context, timestamp: new Date().toISOString()
      },
      { status: 500 }
    );
  }
}
```

## Logging Best Practices

**Safe to Log:** Error type/code, context, user ID, timestamp, request path, HTTP status
**Never Log:** Passwords, credit cards, CVV, API keys, tokens, PII, full request bodies, environment variables

## References

- OWASP Error Handling Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html
- OWASP Top 10 2021 - A04 Insecure Design: https://owasp.org/Top10/A04_2021-Insecure_Design/
