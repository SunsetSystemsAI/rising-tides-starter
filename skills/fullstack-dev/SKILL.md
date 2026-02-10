---
name: fullstack-dev
description: Use when building a full-stack application end-to-end. Invoke for new
  project setup, full-stack development, building a web app from scratch, frontend
  + backend + testing + deployment workflow.
dependencies:
  required:
  - api-designer
  - database-pro
  - debugging
  - frontend-design
  - git-workflow
  - react-dev
  - webapp-testing
---

# Full-Stack Development Orchestrator

Coordinates a complete full-stack development workflow by invoking specialized sub-skills in the correct order. Handles frontend, backend, database, testing, and deployment as a unified pipeline.

## When to Use

- User is building a new full-stack web application
- Setting up a project that needs frontend + backend + database + tests
- "Help me build this app end-to-end"
- Coordinating multiple development phases that span the stack

## Sub-Skills (Invocation Order)

| Order | Skill | Purpose | MCP |
|-------|-------|---------|-----|
| 1 | `react-dev` | Component architecture, TypeScript React, hooks, state | context7 |
| 2 | `frontend-design` | UI architecture, layout, responsive design | context7 |
| 3 | `database-pro` | Schema design, queries, migrations | postgres |
| 4 | `api-designer` | REST/GraphQL API design, endpoints, contracts | — |
| 5 | `git-workflow` | Commits, branches, PRs | gh + github |
| 6 | `webapp-testing` | E2E tests, integration tests | playwright |
| 7 | `debugging` | Error investigation, root cause analysis | — |

## Checkpoints

This orchestrator pauses between phases to confirm direction. At each checkpoint, the user can:
- **Review and confirm** — "looks good, continue"
- **Adjust** — "change the schema before moving on"
- **Auto-accept** — "auto-accept" or "just go" to skip all remaining checkpoints

Once auto-accept is enabled, the orchestrator runs through remaining phases without pausing.

## Workflow

### Quick Mode (Targeted)
If the user has a specific need, invoke only the relevant sub-skill(s):
- "Build me a React component" → `react-dev`
- "Design the database" → `database-pro`
- "Write E2E tests" → `webapp-testing`

### Full Build (End-to-End)

**Phase 1: Foundation**
1. **Database & Schema** — Invoke `database-pro` to design the data model
2. **API Layer** — Invoke `api-designer` to define endpoints and contracts

> **Checkpoint:** Confirm schema + API design before building UI

**Phase 2: Frontend**
3. **UI Architecture** — Invoke `frontend-design` for layout, component tree, design tokens
4. **Component Build** — Invoke `react-dev` to implement components with TypeScript

> **Checkpoint:** Confirm UI matches requirements before wiring to API

**Phase 3: Integration & Quality**
5. **Wire Frontend to Backend** — Connect components to API endpoints
6. **Testing** — Invoke `webapp-testing` for E2E tests covering critical user flows
7. **Debug & Fix** — Invoke `debugging` if tests reveal issues

> **Checkpoint:** Confirm all tests pass before committing

**Phase 4: Ship**
8. **Commit** — Invoke `git-workflow` to stage, commit, and optionally create PR

### Output
After completing the workflow, provide a summary:
- Components built
- API endpoints created
- Database tables/migrations
- Test coverage (E2E scenarios)
- Git commits made
- Any remaining TODOs
