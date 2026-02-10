---
name: react-dev
version: 1.1.0
description: This skill should be used when building React components with TypeScript, typing hooks, handling events, managing UI states (loading, error, empty), optimizing performance, or when React TypeScript, React 19, Server Components are mentioned. Covers type-safe patterns for React 18-19 including generic components, proper event typing, routing integration (TanStack Router, React Router), UI state management, and performance optimization.
mcp: context7
---

# React TypeScript

## MCP Integration: Context7

**Before generating React code**, use context7 to fetch current documentation:

```
Fetch React 19 documentation
Fetch react-dom documentation
```

For library-specific code, also fetch those docs:
- TanStack Router: `Fetch @tanstack/react-router documentation`
- React Hook Form: `Fetch react-hook-form documentation`
- React Query: `Fetch @tanstack/react-query documentation`

**Why?** React evolves quickly. Context7 ensures you use current APIs, not outdated patterns from training data.

---

Type-safe React = compile-time guarantees = confident refactoring.

<when_to_use>

- Building typed React components
- Implementing generic components
- Typing event handlers, forms, refs
- Using React 19 features (Actions, Server Components, use())
- Router integration (TanStack Router, React Router)
- Custom hooks with proper typing
- Handling loading, error, and empty UI states
- Optimizing React/Next.js performance

NOT for: non-React TypeScript, vanilla JS React

</when_to_use>

<react_19_changes>

React 19 breaking changes require migration. Key patterns:

**ref as prop** - forwardRef deprecated:

```typescript
type ButtonProps = {
  ref?: React.Ref<HTMLButtonElement>;
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ ref, children, ...props }: ButtonProps) {
  return <button ref={ref} {...props}>{children}</button>;
}
```

**useActionState** - replaces useFormState:

```typescript
import { useActionState } from 'react';

type FormState = { errors?: string[]; success?: boolean };

function Form() {
  const [state, formAction, isPending] = useActionState(submitAction, {});
  return <form action={formAction}>...</form>;
}
```

**use()** - unwraps promises/context:

```typescript
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise); // Suspends until resolved
  return <div>{user.name}</div>;
}
```

See [react-19-patterns.md](references/react-19-patterns.md) for useOptimistic, useTransition, migration checklist.

</react_19_changes>

<component_patterns>

**Props** - extend native elements:

```typescript
type ButtonProps = {
  variant: 'primary' | 'secondary';
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ variant, children, ...props }: ButtonProps) {
  return <button className={variant} {...props}>{children}</button>;
}
```

**Children typing**:

```typescript
type Props = {
  children: React.ReactNode;          // Anything renderable
  icon: React.ReactElement;           // Single element
  render: (data: T) => React.ReactNode;  // Render prop
};
```

**Discriminated unions** for variant props:

```typescript
type ButtonProps =
  | { variant: 'link'; href: string }
  | { variant: 'button'; onClick: () => void };

function Button(props: ButtonProps) {
  if (props.variant === 'link') {
    return <a href={props.href}>Link</a>;
  }
  return <button onClick={props.onClick}>Button</button>;
}
```

</component_patterns>

<event_handlers>

Use specific event types for accurate target typing:

```typescript
function handleClick(e: React.MouseEvent<HTMLButtonElement>) {
  e.currentTarget.disabled = true;
}

function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const formData = new FormData(e.currentTarget);
}

function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
  console.log(e.target.value);
}

function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
  if (e.key === 'Enter') e.currentTarget.blur();
}
```

See [event-handlers.md](references/event-handlers.md) for focus, drag, clipboard, touch, wheel events.

</event_handlers>

<hooks_typing>

**useState** - explicit for unions/null:

```typescript
const [user, setUser] = useState<User | null>(null);
const [status, setStatus] = useState<'idle' | 'loading'>('idle');
```

**useRef** - null for DOM, value for mutable:

```typescript
const inputRef = useRef<HTMLInputElement>(null);  // DOM - use ?.
const countRef = useRef<number>(0);               // Mutable - direct access
```

**useReducer** - discriminated unions for actions:

```typescript
type Action =
  | { type: 'increment' }
  | { type: 'set'; payload: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'set': return { ...state, count: action.payload };
    default: return state;
  }
}
```

**Custom hooks** - tuple returns with as const:

```typescript
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = () => setValue(v => !v);
  return [value, toggle] as const;
}
```

**useContext** - null guard pattern:

```typescript
const UserContext = createContext<User | null>(null);

function useUser() {
  const user = useContext(UserContext);
  if (!user) throw new Error('useUser outside UserProvider');
  return user;
}
```

See [hooks.md](references/hooks.md) for useCallback, useMemo, useImperativeHandle, useSyncExternalStore.

</hooks_typing>

<generic_components>

Generic components infer types from props - no manual annotations at call site.

```typescript
type Column<T> = {
  key: keyof T;
  header: string;
  render?: (value: T[keyof T], item: T) => React.ReactNode;
};

type TableProps<T> = {
  data: T[];
  columns: Column<T>[];
  keyExtractor: (item: T) => string | number;
};

function Table<T>({ data, columns, keyExtractor }: TableProps<T>) {
  return (
    <table>
      <thead>
        <tr>{columns.map(col => <th key={String(col.key)}>{col.header}</th>)}</tr>
      </thead>
      <tbody>
        {data.map(item => (
          <tr key={keyExtractor(item)}>
            {columns.map(col => (
              <td key={String(col.key)}>
                {col.render ? col.render(item[col.key], item) : String(item[col.key])}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

**Constrained generics** for required properties:

```typescript
type HasId = { id: string | number };

function List<T extends HasId>({ items }: { items: T[] }) {
  return <ul>{items.map(item => <li key={item.id}>...</li>)}</ul>;
}
```

See [generic-components.md](examples/generic-components.md) for Select, List, Modal, FormField patterns.

</generic_components>

<ui_states>

**Loading** - only show loading indicator when there is no data to display:

```typescript
const { data, loading, error } = useQuery();

if (error) return <ErrorState error={error} onRetry={refetch} />;
if (loading && !data) return <LoadingState />;
if (!data?.items.length) return <EmptyState />;

return <ItemList items={data.items} />;
```

Use skeletons for known content shapes (lists, cards, page loads). Use spinners for unknown shapes (modals, inline operations).

**Errors** - never swallow silently. Hierarchy: inline field errors, toast for recoverable, banner for partial, full screen for unrecoverable.

```typescript
// Always surface errors to the user
onError: (error) => {
  console.error('operation failed:', error);
  toast.error({ title: 'Operation failed' });
}
```

**Buttons** - always disable during async operations to prevent double-submission:

```tsx
<Button onClick={submit} disabled={loading} isLoading={loading}>
  Submit
</Button>
```

**Empty states** - every list/collection must have one with contextual messaging and a call-to-action when appropriate.

</ui_states>

<server_components>

React 19 Server Components run on server, can be async.

```typescript
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await fetchUser(params.id);
  return <div>{user.name}</div>;
}
```

**Server Actions** - 'use server' for mutations:

```typescript
'use server';

export async function updateUser(userId: string, formData: FormData) {
  await db.user.update({ where: { id: userId }, data: { ... } });
  revalidatePath(`/users/${userId}`);
}
```

**Client + Server Action**:

```typescript
'use client';

import { useActionState } from 'react';
import { updateUser } from '@/actions/user';

function UserForm({ userId }: { userId: string }) {
  const [state, formAction, isPending] = useActionState(
    (prev, formData) => updateUser(userId, formData), {}
  );
  return <form action={formAction}>...</form>;
}
```

**use() for promise handoff** - server passes promise, client unwraps:

```typescript
// Server: pass promise without await
async function Page() {
  const userPromise = fetchUser('123');
  return <UserProfile userPromise={userPromise} />;
}

// Client: unwrap with use()
'use client';
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <div>{user.name}</div>;
}
```

See [server-components.md](examples/server-components.md) for parallel fetching, streaming, error boundaries.

</server_components>

<performance>

**Eliminating waterfalls (CRITICAL):**
- `Promise.all()` for independent async operations
- Move `await` into branches where actually used (defer-await)
- Use Suspense boundaries to stream content progressively

**Bundle size (CRITICAL):**
- Import directly from modules, avoid barrel files
- Use `next/dynamic` or `React.lazy` for heavy components
- Defer third-party scripts (analytics, logging) until after hydration
- Preload on hover/focus for perceived speed

**Server-side (HIGH):**
- `React.cache()` for per-request dedup, LRU cache for cross-request
- Minimize data serialized to client components
- Restructure component tree to parallelize fetches

**Re-render optimization (MEDIUM):**
- Extract expensive work into memoized components
- Use primitive dependencies in effects, not objects
- Functional setState for stable callbacks (`setValue(v => v + 1)`)
- `startTransition` for non-urgent updates
- Lazy state init: `useState(() => expensiveComputation())`

</performance>

<routing>

**TanStack Router** - Compile-time type safety with Zod validation:

```typescript
import { createRoute } from '@tanstack/react-router';
import { z } from 'zod';

const userRoute = createRoute({
  path: '/users/$userId',
  component: UserPage,
  loader: async ({ params }) => ({ user: await fetchUser(params.userId) }),
  validateSearch: z.object({
    tab: z.enum(['profile', 'settings']).optional(),
    page: z.number().int().positive().default(1),
  }),
});

function UserPage() {
  const { user } = useLoaderData({ from: userRoute.id });
  const { tab, page } = useSearch({ from: userRoute.id });
}
```

**React Router v7** - Automatic type generation with Framework Mode:

```typescript
import type { Route } from "./+types/user";

export async function loader({ params }: Route.LoaderArgs) {
  return { user: await fetchUser(params.userId) };
}

export default function UserPage({ loaderData }: Route.ComponentProps) {
  const { user } = loaderData;
  return <h1>{user.name}</h1>;
}
```

See [tanstack-router.md](references/tanstack-router.md) and [react-router.md](references/react-router.md) for full patterns.

</routing>

<rules>

ALWAYS:
- Specific event types (MouseEvent, ChangeEvent, etc)
- Explicit useState for unions/null
- ComponentPropsWithoutRef for native element extension
- Discriminated unions for variant props
- as const for tuple returns
- ref as prop in React 19 (no forwardRef)
- useActionState for form actions
- Type-safe routing patterns (see routing section)
- Loading state only when no data exists (never flash on refetch)
- Disable buttons during async operations
- Surface all errors to the user (toast, banner, or inline)
- Empty states for every collection
- Promise.all for independent async operations

NEVER:
- any for event handlers
- JSX.Element for children (use ReactNode)
- forwardRef in React 19+
- useFormState (deprecated)
- Forget null handling for DOM refs
- Mix Server/Client components in same file
- Await promises when passing to use()
- Swallow errors silently (console.log only)
- Show spinner when cached data exists
- Import from barrel files in performance-sensitive paths

</rules>

<references>

- [hooks.md](references/hooks.md) - useState, useRef, useReducer, useContext, custom hooks
- [event-handlers.md](references/event-handlers.md) - all event types, generic handlers
- [react-19-patterns.md](references/react-19-patterns.md) - useActionState, use(), useOptimistic, migration
- [generic-components.md](examples/generic-components.md) - Table, Select, List, Modal patterns
- [server-components.md](examples/server-components.md) - async components, Server Actions, streaming
- [tanstack-router.md](references/tanstack-router.md) - TanStack Router typed routes, search params, navigation
- [react-router.md](references/react-router.md) - React Router v7 loaders, actions, type generation, forms

</references>
