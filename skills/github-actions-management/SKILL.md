---
name: github-actions-management
description: "Use when working with GitHub Actions CI/CD pipelines. Invoke for listing, triggering, monitoring, debugging, and rerunning workflows."
---

# GitHub Actions Management

## When to Use MCP vs gh CLI

| Task | Use MCP | Use gh CLI |
|------|---------|------------|
| List workflow runs | MCP `list_workflow_runs` | `gh run list` |
| Trigger workflow | MCP `trigger_workflow` | `gh workflow run` |
| Get run details/logs | MCP `get_workflow_run`, `get_run_logs` | `gh run view --log` |
| Rerun failed jobs | MCP `rerun_workflow` | `gh run rerun` |
| List workflows | MCP `list_workflows` | `gh workflow list` |
| Cancel a run | gh CLI preferred | `gh run cancel` |
| Watch live output | gh CLI preferred (streaming) | `gh run watch` |

**Rule of thumb:** Use MCP for programmatic triggering and inspection. Use gh CLI for interactive watching and quick one-off commands.

## Authentication Setup

1. Install gh CLI: `gh auth login` (for CLI operations)
2. Get a PAT for MCP: https://github.com/settings/tokens
3. Token needs `repo` and `actions` scopes
4. Export: `export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...`

## Listing Workflows and Runs

### See available workflows
- MCP: `list_workflows` with owner and repo
- CLI: `gh workflow list`

### See recent runs
- MCP: `list_workflow_runs` with optional status filter
- CLI: `gh run list --limit 10`

### Filter by status
- Filter by: `completed`, `in_progress`, `queued`, `failure`, `success`
- CLI: `gh run list --status failure`

## Triggering Workflows

### Trigger via MCP
Use `trigger_workflow` with:
- `owner` and `repo`
- `workflow_id` (filename like `ci.yml` or numeric ID)
- `ref` (branch name, defaults to main)
- `inputs` (workflow_dispatch inputs as key-value pairs)

### Trigger via CLI
```bash
gh workflow run ci.yml --ref main -f environment=staging
```

### Common patterns
- Deploy to staging: trigger deploy workflow with environment input
- Run tests on a branch: trigger CI workflow with specific ref
- Scheduled re-trigger: trigger workflow that normally runs on cron

## Monitoring Runs

### Check run status
1. Get run ID from `list_workflow_runs`
2. Use MCP `get_workflow_run` for detailed status
3. Check each job's status and conclusion

### Watch live (CLI)
```bash
gh run watch <run-id>
```
This streams live output -- use CLI for this, not MCP.

### Get logs
- MCP: `get_run_logs` for structured log data
- CLI: `gh run view <run-id> --log` for full output
- CLI: `gh run view <run-id> --log-failed` for only failed steps

## Debugging Failed Workflows

### Step-by-step debugging
1. List recent failures: `gh run list --status failure`
2. Get details via MCP `get_workflow_run` or `gh run view <id>`
3. Read logs: MCP `get_run_logs` or `gh run view <id> --log-failed`
4. Common failure causes:
   - **Test failures** — Read test output in logs
   - **Dependency issues** — Check package lock files, cache invalidation
   - **Secrets/env vars** — Verify secrets are set in repo settings
   - **Timeout** — Check if job exceeded time limit
   - **Permission errors** — Check token scopes and GITHUB_TOKEN permissions

### Check workflow file
```bash
gh api repos/{owner}/{repo}/contents/.github/workflows/{file}
```

## Rerunning Workflows

### Rerun all jobs
- MCP: `rerun_workflow` with run ID
- CLI: `gh run rerun <run-id>`

### Rerun only failed jobs
- CLI: `gh run rerun <run-id> --failed`
- Saves time by skipping successful jobs

## Workflow Patterns

### CI workflow structure
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm test
```

### Deploy workflow with environment input
```yaml
name: Deploy
on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [staging, production]
```

### Common debugging additions
```yaml
- name: Debug info
  run: |
    echo "Event: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "SHA: ${{ github.sha }}"
```
