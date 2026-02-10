---
description: Scaffold a new React component with TypeScript, tests, and exports
---

## /react-dev:new-component

### Steps

1. Ask for component name and purpose
2. Detect project conventions:
   - File structure (flat vs nested)
   - Styling approach (CSS modules, Tailwind, styled-components)
   - Test framework (Jest, Vitest, Testing Library)
3. Create component file: `ComponentName.tsx`
   - Use function declaration (not arrow function export)
   - Define props interface: `ComponentNameProps`
   - Add proper TypeScript types
4. Create test file: `ComponentName.test.tsx`
   - Basic render test
   - Props test
5. Add barrel export if project uses them (`index.ts`)
6. Use Context7 MCP to check latest API patterns if using a library

### Rules
- Match existing project conventions exactly
- Never use `any` type — use proper TypeScript types
- Never use default exports unless project convention requires it
- Keep components focused — one responsibility per component
