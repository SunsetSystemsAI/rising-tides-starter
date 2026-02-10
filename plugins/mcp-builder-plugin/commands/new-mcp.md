---
description: Scaffold a new MCP server project with tools, resources, and transport
---

## /mcp-builder:new-mcp

### Steps

1. Ask for MCP server name and purpose
2. Ask what tools and resources it should expose
3. Scaffold project structure:
   - `package.json` with MCP SDK dependency
   - `tsconfig.json` for TypeScript
   - `src/index.ts` -- server entry point
   - `src/tools/` -- tool implementations
   - `src/resources/` -- resource handlers (if needed)
4. Implement the server using `@modelcontextprotocol/sdk`
5. Add tool definitions with proper JSON schemas
6. Add error handling and input validation
7. Test locally: `npx tsx src/index.ts`
8. Use Context7 MCP for latest MCP SDK patterns

### Rules
- Always use TypeScript with strict mode
- Every tool must have a description and input schema
- Handle errors gracefully -- never crash the server
- Follow MCP specification for transport (stdio by default)
