---
name: saas-setup
description: Use when setting up a SaaS application with auth, payments, database,
  and deployment. Invoke for SaaS project setup, launch a SaaS, build a subscription
  app, set up Stripe + Supabase + Vercel.
dependencies:
  required:
  - oauth-setup
  - saas-starter-setup
  - stripe-integration
  - supabase-guide
  - vercel-deployment
  - webapp-testing
  recommended: [saas-from-scratch]
---

# SaaS Setup Orchestrator

Coordinates the complete setup of a SaaS application — from starter template through auth, payments, database, and production deployment. Invokes specialized sub-skills for each layer.

## When to Use

- User is starting a new SaaS product
- "Help me set up a SaaS with payments and auth"
- "Launch my subscription app"
- Needs the full stack: auth + database + payments + deployment

## Sub-Skills (Invocation Order)

| Order | Skill | Purpose | MCP/CLI |
|-------|-------|---------|---------|
| 1 | `saas-starter-setup` | Scaffold from Next.js SaaS starter template | — |
| 2 | `supabase-guide` | Database, auth, row-level security, edge functions | supabase CLI |
| 3 | `oauth-setup` | Social login providers (Google, GitHub, etc.) | — |
| 4 | `stripe-integration` | Products, pricing, checkout, webhooks, customer portal | stripe CLI |
| 5 | `vercel-deployment` | Deploy, env vars, domains, preview deployments | vercel CLI |
| 6 | `webapp-testing` | E2E tests for auth flows, payment flows, core features | playwright |

## Checkpoints

This orchestrator pauses between phases to confirm direction. At each checkpoint, the user can:
- **Review and confirm** — "looks good, continue"
- **Adjust** — "I want to use Firebase instead of Supabase"
- **Auto-accept** — "auto-accept" or "just go" to skip all remaining checkpoints

Once auto-accept is enabled, the orchestrator runs through remaining phases without pausing.

## Workflow

### Quick Mode (Targeted)
If the user only needs a specific piece:
- "Set up Stripe" → `stripe-integration`
- "Configure Supabase" → `supabase-guide`
- "Deploy to Vercel" → `vercel-deployment`

### Full Setup (End-to-End)

**Phase 1: Scaffold**
1. **Starter Template** — Invoke `saas-starter-setup` to scaffold the project
   - Detect if user wants the official Next.js SaaS starter or custom setup
   - If custom, invoke `saas-from-scratch` instead

> **Checkpoint:** Confirm starter template choice and initial project structure

**Phase 2: Backend Services**
2. **Database & Auth** — Invoke `supabase-guide` to configure:
   - Database schema (users, subscriptions, app-specific tables)
   - Row-level security policies
   - Supabase Auth setup
3. **Social Login** — Invoke `oauth-setup` for Google/GitHub/etc. providers

> **Checkpoint:** Confirm database schema and auth providers before adding payments

**Phase 3: Payments**
4. **Stripe Integration** — Invoke `stripe-integration` to configure:
   - Products and pricing (monthly/annual plans)
   - Checkout sessions
   - Webhook handlers for subscription events
   - Customer portal for self-service

> **Checkpoint:** Confirm Stripe products, pricing tiers, and webhook endpoints

**Phase 4: Deploy & Test**
5. **Deployment** — Invoke `vercel-deployment` to:
   - Set environment variables (Supabase URL, Stripe keys, OAuth secrets)
   - Deploy to preview, verify, then promote to production
   - Configure custom domain if needed
6. **E2E Testing** — Invoke `webapp-testing` for critical flows:
   - Sign up → verify email → log in
   - Subscribe → checkout → access premium features
   - Cancel subscription → lose access

> **Checkpoint:** Confirm deployment works and tests pass

### Output
After completing the setup, provide a summary:
- Starter template used
- Database tables and RLS policies created
- Auth providers configured
- Stripe products and pricing
- Deployment URL (preview and production)
- E2E test results
- Environment variables set (names only, not values)
- Remaining manual steps (DNS, Stripe live mode, etc.)
