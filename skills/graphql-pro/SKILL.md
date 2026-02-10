---
name: graphql-pro
description: "Use when designing GraphQL schemas, writing queries/mutations, working with Apollo (Server or Client), Federation, codegen, DataLoader, subscriptions, cache updates, or optimistic responses."
triggers:
  - GraphQL
  - Apollo Federation
  - GraphQL schema
  - Apollo Client
  - Apollo Server
  - GraphQL resolvers
  - DataLoader
  - GraphQL subscriptions
  - GraphQL codegen
  - GraphQL mutations
  - GraphQL fragments
role: architect
scope: full-stack
output-format: schema
---

# GraphQL Pro

Full-stack GraphQL expertise: schema design, Apollo Federation, resolvers with DataLoader, client-side codegen workflows, cache management, and real-time subscriptions.

## When to Use This Skill

- Designing GraphQL schemas and type systems
- Implementing Apollo Federation architectures
- Building resolvers with DataLoader optimization
- Writing queries and mutations with Apollo Client
- Setting up codegen workflows (.gql files + generated hooks)
- Creating real-time GraphQL subscriptions
- Optimizing query complexity and caching

## Core Workflow (Server-Side)

1. **Domain Modeling** - Map business domains to GraphQL type system
2. **Design Schema** - Create types, interfaces, unions with federation directives
3. **Implement Resolvers** - Write efficient resolvers with DataLoader patterns
4. **Secure** - Add query complexity limits, depth limiting, field-level auth
5. **Optimize** - Caching, persisted queries, monitoring

## Client-Side Rules

1. **NEVER inline `gql` literals** - Create `.gql` files
2. **ALWAYS run codegen** after creating/modifying `.gql` files
3. **ALWAYS add `onError` handler** to mutations
4. **Use generated hooks** - Never write raw Apollo hooks

## File Structure (Client)

```
src/
├── components/
│   └── ItemList/
│       ├── ItemList.tsx
│       ├── GetItems.gql           # Query definition
│       └── GetItems.generated.ts  # Auto-generated (don't edit)
└── graphql/
    ├── fragments/
    │   └── ItemFields.gql         # Reusable fragments
    └── mutations/
        └── CreateItem.gql         # Shared mutations
```

## Query Pattern

### 1. Create .gql file

```graphql
# src/components/ItemList/GetItems.gql
query GetItems($limit: Int, $offset: Int) {
  items(limit: $limit, offset: $offset) {
    ...ItemFields
  }
}
```

### 2. Run codegen, then use generated hook

```bash
npm run gql:typegen
```

```typescript
import { useGetItemsQuery } from './GetItems.generated';

const ItemList = () => {
  const { data, loading, error, refetch } = useGetItemsQuery({
    variables: { limit: 20, offset: 0 },
  });

  if (error) return <ErrorState error={error} onRetry={refetch} />;
  if (loading && !data) return <LoadingSkeleton />;
  if (!data?.items.length) return <EmptyState />;

  return <List items={data.items} />;
};
```

## Mutation Pattern

```typescript
import { useCreateItemMutation } from 'graphql/mutations/CreateItem.generated';

const [createItem, { loading }] = useCreateItemMutation({
  onCompleted: (data) => {
    toast.success({ title: 'Item created' });
  },
  // ERROR HANDLING IS REQUIRED
  onError: (error) => {
    console.error('createItem failed:', error);
    toast.error({ title: 'Failed to create item' });
  },
  // Cache update
  update: (cache, { data }) => {
    if (data?.createItem) {
      cache.modify({
        fields: {
          items: (existing = []) => [...existing, data.createItem],
        },
      });
    }
  },
});

// Every mutation trigger MUST: disable during loading, show loading state
<Button
  onPress={() => createItem({ variables: { input: formValues } })}
  isDisabled={!isValid || loading}
  isLoading={loading}
>
  Create
</Button>
```

## Optimistic Updates

For instant UI feedback on simple toggles:

```typescript
const [toggleFavorite] = useToggleFavoriteMutation({
  optimisticResponse: {
    toggleFavorite: { __typename: 'Item', id: itemId, isFavorite: !currentState },
  },
  onError: (error) => {
    console.error('toggleFavorite failed:', error);
    toast.error({ title: 'Failed to update' });
  },
});
```

**Skip optimistic updates for:** validation-dependent ops, server-generated values, destructive ops, multi-user ops.

## Fetch Policies

| Policy | Use When |
|--------|----------|
| `cache-first` | Data rarely changes |
| `cache-and-network` | Want fast + fresh (default) |
| `network-only` | Always need latest |
| `no-cache` | Never cache (rare) |

## Fragments

```graphql
# src/graphql/fragments/ItemFields.gql
fragment ItemFields on Item {
  id
  name
  description
  createdAt
  updatedAt
}
```

## Constraints

### MUST DO
- Schema-first design approach
- Proper nullable field patterns
- DataLoader for batching and caching (prevent N+1)
- Query complexity analysis and depth limiting
- Document all types and fields
- GraphQL naming conventions (camelCase)
- Federation directives used correctly
- Error handlers on every mutation
- Disable buttons during mutations

### MUST NOT DO
- Inline `gql` template literals (use .gql files)
- Skip query depth limiting
- Expose internal implementation details
- Use REST patterns in GraphQL
- Return null for non-nullable fields
- Skip error handling in resolvers or mutations
- Hardcode authorization logic
- Write raw Apollo hooks (use codegen)

## Anti-Patterns

```typescript
// WRONG - Inline gql
const GET_ITEMS = gql`query GetItems { items { id } }`;
// CORRECT - Use .gql file + generated hook
import { useGetItemsQuery } from './GetItems.generated';

// WRONG - No error handler
const [mutate] = useMutation(MUTATION);
// CORRECT
const [mutate] = useMutation(MUTATION, {
  onError: (error) => {
    console.error('mutation failed:', error);
    toast.error({ title: 'Operation failed' });
  },
});
```

## Codegen Commands

```bash
npm run gql:typegen      # Generate types from .gql files
npm run sync-types       # Download schema + generate types
```

## Related Skills

- **Backend Developer** - Resolver implementation and data access
- **Frontend Developer** - Client query optimization
- **Database Optimizer** - Query efficiency and N+1 prevention
