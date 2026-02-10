---
name: "gitlab-stack"
description: "Complete GitLab stack management: create projects, generate service configs, manage Docker secrets, and validate stacks before deployment. Use when creating Docker stack projects, generating nginx/PostgreSQL/Redis configs, managing secrets, validating stack architecture, or ensuring deployment readiness."
---

# GitLab Stack Management

Complete skill for creating, configuring, securing, and validating GitLab stack projects with Docker Compose.

## When to Use This Skill

Activate when the user wants to:
- Create a new GitLab stack project
- Generate service configurations (nginx, PostgreSQL, Redis)
- Manage Docker secrets (create, migrate, rotate, audit)
- Validate a stack before deployment
- Check stack architecture compliance
- Fix security issues in stack configuration

## Core Principles

1. **Configuration in .env**: All variables in .env, configs in ./config
2. **Secrets in ./secrets**: Never in .env or docker-compose.yml environment
3. **Docker secrets mechanism**: Use top-level `secrets:` in compose
4. **No root-owned files**: All files owned by the Docker user
5. **.env sync**: .env and .env.example must always match
6. **No version field**: Modern Docker Compose specification
7. **Entrypoints only when necessary**: Only if container lacks native secret support
8. **No workarounds**: If something fails, stop and ask the user

## Standard Directory Structure

```
project-name/
├── docker-compose.yml        # Main compose file (NO version field)
├── .env                      # Configuration variables (gitignored)
├── .env.example              # Template (must match .env)
├── .gitignore                # Git exclusions
├── .dockerignore             # Docker build exclusions
├── CLAUDE.md                 # Claude Code instructions
├── README.md                 # Project overview
├── config/                   # Service configurations
│   ├── nginx/
│   ├── postgres/
│   └── redis/
├── secrets/                  # Docker secrets (700 permissions, gitignored)
│   └── .gitkeep
├── _temporary/               # Transient files (gitignored)
├── scripts/                  # Validation and utility scripts
│   ├── validate-stack.sh
│   ├── pre-commit
│   └── setup-hooks.sh
└── docs/                     # Documentation
    ├── decisions/
    ├── setup.md
    └── services.md
```

## Stack Creation

### Phase 1: Gather Requirements

Ask the user:
- Project name
- Services needed (nginx, PostgreSQL, Redis, etc.)
- Remote git repository URL (if any)
- Environment (development, staging, production)

Never assume -- always ask if information is missing.

### Phase 2: Initialize Project

1. Create directory structure:
   ```bash
   mkdir -p config secrets _temporary scripts docs/decisions
   touch secrets/.gitkeep
   chmod 700 secrets
   ```

2. Initialize git:
   ```bash
   git init
   git config init.defaultBranch main
   git config pull.ff only
   git config merge.ff only
   git config pull.rebase false
   ```

3. Generate .gitignore:
   ```gitignore
   secrets/*
   !secrets/.gitkeep
   *.key
   *.pem
   *.crt
   .env
   .env.local
   .env.*.local
   _temporary/
   *.tmp
   .vscode/
   .idea/
   *.swp
   .DS_Store
   Thumbs.db
   *.log
   *.bak
   *.backup
   ```

4. Generate .dockerignore:
   ```dockerignore
   .git
   .gitignore
   docs/
   _temporary/
   *.md
   .env
   .env.example
   secrets/
   .vscode/
   .idea/
   ```

### Phase 3: Create Validation Scripts

**scripts/validate-stack.sh** -- Full stack validation:
```bash
#!/usr/bin/env bash
set -euo pipefail
ERRORS=0
echo "=== GitLab Stack Validation ==="

echo "1. Checking structure..."
for dir in config secrets _temporary; do
  [ -d "./$dir" ] && echo "  OK: ./$dir" || { echo "  FAIL: ./$dir missing"; ((ERRORS++)); }
done

echo "2. Checking secrets..."
if find ./secrets -type f ! -name .gitkeep -perm /044 2>/dev/null | grep -q .; then
  echo "  FAIL: Secret files have too-open permissions"; ((ERRORS++))
else
  echo "  OK: Secret permissions"
fi

echo "3. Checking .env sync..."
if [ -f .env ] && [ -f .env.example ]; then
  env_vars=$(grep -E "^[A-Z_]+" .env | cut -d= -f1 | sort)
  example_vars=$(grep -E "^[A-Z_]+" .env.example | cut -d= -f1 | sort)
  if [ "$env_vars" != "$example_vars" ]; then
    echo "  FAIL: .env and .env.example out of sync"; ((ERRORS++))
  else
    echo "  OK: .env synchronized"
  fi
fi

echo "4. Checking for secrets in .env..."
if grep -qiE "(PASSWORD|SECRET|KEY|TOKEN)=" .env 2>/dev/null; then
  echo "  WARN: Potential secrets in .env -- migrate to ./secrets"
fi

echo "5. Checking ownership..."
if find . -user root -not -path "./.git/*" 2>/dev/null | grep -q .; then
  echo "  FAIL: Root-owned files detected"; ((ERRORS++))
else
  echo "  OK: No root-owned files"
fi

[ $ERRORS -gt 0 ] && { echo "FAILED ($ERRORS errors)"; exit 1; }
echo "All checks passed!"
```

**scripts/pre-commit** -- Git hook:
```bash
#!/usr/bin/env bash
set -euo pipefail
if git diff --cached --name-only | grep -qE "secrets/.*[^.gitkeep]|\.env$"; then
  echo "ERROR: Attempting to commit secrets or .env!"
  exit 1
fi
if [ -x "./scripts/validate-stack.sh" ]; then
  ./scripts/validate-stack.sh || { echo "Validation failed!"; exit 1; }
fi
```

**scripts/setup-hooks.sh** -- Install hooks:
```bash
#!/usr/bin/env bash
set -euo pipefail
[ ! -d ".git" ] && { echo "ERROR: Not a git repository!"; exit 1; }
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "Git hooks installed."
```

Make all executable: `chmod +x scripts/*.sh scripts/pre-commit`

### Phase 4: Docker and Documentation

1. Generate docker-compose.yml based on selected services (use no `version` field)
2. Generate .env.example with all required variables
3. Generate CLAUDE.md, README.md, docs/setup.md, docs/services.md
4. Run `./scripts/setup-hooks.sh` to install hooks
5. Run full validation before initial commit

Stack creation is complete ONLY when all validation passes with zero errors.

## Service Configuration Generation

### Workflow

For each service:
1. Determine config needs (template or custom, prod or dev)
2. Identify required .env variables
3. Generate config file using `${VAR_NAME}` placeholders
4. Add variables to .env AND .env.example (must stay in sync)
5. Update docker-compose.yml with volume mounts
6. Validate syntax

### Config Rules

- All values from .env via environment variable placeholders
- Never hardcode IPs, hosts, passwords, or tokens
- SSL certificates come from Docker secrets, not config files
- One directory per service under ./config/

### Service Templates

**Nginx**: Simple Reverse Proxy | SSL Termination | Static + Proxy | Custom
**PostgreSQL**: Basic | Production (tuned) | With Extensions | Custom
**Redis**: Cache (no persistence) | Persistent (RDB+AOF) | Pub/Sub | Custom

### Syntax Validation

```bash
# Nginx
docker run --rm -v $(pwd)/config/nginx:/etc/nginx:ro nginx:alpine nginx -t

# Redis
docker run --rm -v $(pwd)/config/redis:/usr/local/etc/redis:ro redis:alpine redis-server --test-memory 1024
```

After generating configs, always scan for secrets:
```bash
grep -r -iE "(password|secret|key|token|api_key)" ./config/
```

## Secrets Management

### Creating Secrets

1. Ensure ./secrets exists with 700 permissions
2. Generate or accept secret value:
   ```bash
   # Alphanumeric (32 chars)
   openssl rand -base64 32 | tr -d '/+=' | head -c 32
   # Hex (64 chars)
   openssl rand -hex 32
   ```
3. Write to file (no trailing newline):
   ```bash
   echo -n "$secret" > ./secrets/secret_name
   chmod 600 ./secrets/secret_name
   ```
4. Add to docker-compose.yml:
   ```yaml
   secrets:
     secret_name:
       file: ./secrets/secret_name
   services:
     myservice:
       secrets:
         - secret_name
   ```
5. Verify .gitignore excludes ./secrets

### Migrating Secrets from .env

When secrets are found in .env or docker-compose.yml environment (this is a critical security issue):

1. Scan: `grep -E "(PASSWORD|SECRET|KEY|TOKEN)" .env`
2. Confirm with user which variables to migrate
3. Extract value, create secret file, update compose
4. If container supports `_FILE` suffix (PostgreSQL, MySQL, Redis): use it
5. If not: create docker-entrypoint.sh to load from /run/secrets/
6. Remove secret from .env and compose environment
7. Verify with validation

### docker-entrypoint.sh (Only When Necessary)

Only create when the container does not support native Docker secrets:

```bash
#!/bin/bash
set -e
load_secret() {
  local secret_file="/run/secrets/$1"
  [ -f "$secret_file" ] && export "$2=$(cat "$secret_file")" || { echo "ERROR: Secret $1 not found!" >&2; exit 1; }
}
load_secret "db_password" "DB_PASSWORD"
exec "$@"
```

### Security Rules

- Never display actual secret values (show [REDACTED])
- Secret files: 600 permissions, non-root ownership
- Secrets directory: 700 permissions
- Never commit secrets to git
- Always verify .gitignore coverage

## Stack Validation

### Validation Categories

Run these checks systematically when validating a stack:

**1. Directory Structure**
- Required dirs exist: config, secrets, _temporary
- secrets has 700 permissions
- .gitignore excludes secrets, _temporary, .env

**2. Environment Variables**
- .env exists with valid syntax, no duplicates
- .env.example exists
- .env and .env.example are synchronized (critical)
- No secrets in .env

**3. Docker Configuration**
- docker-compose.yml valid syntax
- No `version` field
- Secrets defined in top-level `secrets:` section
- Services reference secrets via `secrets:` key, not environment
- Volume mounts follow patterns

**4. Secrets Management**
- ./secrets exists with restrictive permissions
- All referenced secret files exist with 600 permissions
- No secrets in compose environment variables
- No secrets in config files or shell scripts
- No secrets tracked by git

**5. File Ownership**
- No root-owned files (excluding .git)
- Consistent user/group ownership

**6. Scripts**
- docker-entrypoint.sh only where truly necessary
- Executable permissions set
- No hardcoded secrets in scripts

### Validation Modes

| Mode | Behavior |
|------|----------|
| Standard | Report all issues, fail on critical |
| Strict | Fail on warnings too |
| Permissive | Only fail on critical issues |

### Validation Report Format

```
GitLab Stack Validation Report
================================
Stack: [name]

SUMMARY: X passed, Y warnings, Z critical

FINDINGS:
  Directory Structure: PASS/FAIL
  Environment Variables: PASS/FAIL
  Docker Configuration: PASS/FAIL
  Secrets Management: PASS/FAIL
  File Ownership: PASS/FAIL
  Scripts: PASS/FAIL

[Details for each failure/warning]

RECOMMENDED ACTIONS:
1. [Most critical fix first]
2. [Next fix]
```

### Must-Pass Criteria (Production)

1. .env and .env.example fully synchronized
2. No secrets in .env or compose environment
3. ./secrets exists with restrictive permissions
4. All referenced secrets exist
5. secrets and _temporary in .gitignore
6. No root-owned files
7. docker-compose.yml valid
8. No secrets in git

## Error Handling

- **Validation fails**: Stop, report clearly, ask user how to proceed
- **Git issues**: Never force push, rebase, or modify history without permission
- **Permission issues**: Report and ask user to fix ownership
- **Never use workarounds**: If the direct approach fails, stop and ask

## Example Workflows

### Create a New Stack

```
User: "Create a stack with nginx and PostgreSQL"

1. Ask: project name, remote URL, environment
2. Create directory structure
3. Initialize git with main branch, ff-only
4. Generate docker-compose.yml with both services
5. Generate nginx config (ask: which template?)
6. Generate PostgreSQL config (ask: which template?)
7. Set up secrets for database password
8. Create validation scripts, install hooks
9. Generate documentation
10. Run full validation -- must pass with zero errors
11. Initial commit
```

### Validate an Existing Stack

```
User: "Validate my stack"

1. Check directory structure
2. Validate .env sync with .env.example
3. Validate docker-compose.yml
4. Check secrets management
5. Scan for exposed secrets
6. Check file ownership
7. Generate report with findings and recommended actions
```

### Migrate Secrets

```
User: "Set up secrets for my database"

1. Scan .env and compose for secrets
2. Report findings (e.g., DB_PASSWORD in .env)
3. Confirm migration plan with user
4. Create secret files in ./secrets
5. Update compose to use Docker secrets
6. Remove secrets from .env/compose
7. Validate -- confirm no secrets remain exposed
```

---

*This skill manages the full lifecycle of GitLab stack projects: creation, configuration, secrets, and validation.*
