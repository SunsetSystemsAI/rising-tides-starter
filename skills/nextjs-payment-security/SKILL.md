---
name: nextjs-payment-security
description: "Use when implementing secure payments with Clerk Billing and Stripe. Invoke for PCI-DSS compliance, subscription payments, webhook verification, payment gating. security, OWASP, Next.js, Stripe, payments, PCI-DSS, Clerk Billing, subscription, webhook, billing"
---

# Payment Security - Clerk Billing + Stripe

## Why We Don't Handle Payments Directly

Storing/processing credit card data requires PCI-DSS compliance ($50K-$200K annually). By using Clerk Billing + Stripe, we **never see, store, or transmit** credit card data.

## Our Payment Architecture

1. Frontend shows Clerk's PricingTable component
2. User clicks subscribe -- Clerk opens Stripe Checkout
3. User enters card on **Stripe's servers** (not ours)
4. Stripe processes payment, notifies Clerk
5. Clerk updates subscription status
6. Our app reads status and grants access

**What never touches our servers:** Credit card numbers, CVV codes, expiration dates.

## Checking Subscription Status

### Server-Side
```typescript
const { userId, sessionClaims } = await auth();
const plan = sessionClaims?.metadata?.plan as string;
if (plan === 'free_user') return handleForbiddenError('Premium subscription required');
```

### Client-Side
```typescript
<Protect
  condition={(has) => !has({ plan: "free_user" })}
  fallback={<UpgradePrompt />}
>
  <PremiumContent />
</Protect>
```

## Webhook Handling

Always verify webhook signatures with Svix:

```typescript
const wh = new Webhook(WEBHOOK_SECRET);
const evt = wh.verify(body, {
  "svix-id": svix_id,
  "svix-timestamp": svix_timestamp,
  "svix-signature": svix_signature,
});
```

## Security Best Practices

1. **Always verify webhooks** - Never trust data without signature verification
2. **Never store payment info** - Only store Stripe IDs
3. **Check subscription on server** - Client-side checks can be bypassed
4. **Implement idempotency** - Handle duplicate webhooks

## Testing with Stripe Test Cards

```
Success: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
3D Secure: 4000 0025 0000 3155
```

## References

- Clerk Billing: https://clerk.com/docs/billing/overview
- Stripe Checkout: https://stripe.com/docs/payments/checkout
- PCI-DSS Standards: https://www.pcisecuritystandards.org/
