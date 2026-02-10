---
name: terraform-pro
description: "Use when working with Terraform, OpenTofu, Terragrunt, or infrastructure as code. Invoke for module development, state management, testing strategies, CI/CD pipelines, multi-environment workflows, troubleshooting, and IaC best practices across AWS, Azure, and GCP."
---

# Terraform Pro

Production-grade Terraform and OpenTofu guidance covering module design, state management, testing, Terragrunt, CI/CD, security, and multi-cloud patterns.

## When to Activate

- Creating or refactoring Terraform/OpenTofu/Terragrunt configurations
- Building reusable modules or structuring multi-environment deployments
- Setting up IaC testing (native tests, Terratest, static analysis)
- Managing state, debugging drift, or troubleshooting plan/apply errors
- Implementing CI/CD pipelines for infrastructure code
- Security scanning and compliance for infrastructure code

## Do Not Use For

- Basic HCL syntax (Claude already knows this)
- Provider-specific API reference (link to provider docs)
- Cloud platform questions unrelated to Terraform/OpenTofu

## Core Workflow

1. **Analyze** -- Review requirements, existing code, cloud platforms
2. **Design modules** -- Composable, validated, with clear interfaces
3. **Implement state** -- Remote backends with locking and encryption
4. **Secure** -- Least privilege, encryption, policy checks
5. **Test and validate** -- Plan, lint, security scan, automated tests
6. **Apply** -- Review plan output, apply, verify outputs

### Standard Commands

```bash
terraform init                    # Initialize (or -upgrade for providers)
terraform fmt -recursive          # Format code
terraform validate                # Validate syntax
terraform plan -out=tfplan        # Plan (always review!)
terraform apply tfplan            # Apply saved plan
terraform output                  # Verify outputs
```

## Module Design

### Module Hierarchy

| Type | When to Use | Scope |
|------|-------------|-------|
| **Resource Module** | Single logical group of connected resources | VPC + subnets, SG + rules |
| **Infrastructure Module** | Collection of resource modules for a purpose | Multiple modules in one region |
| **Composition** | Complete infrastructure | Spans regions/accounts |

### Standard Module Structure

```
my-module/
  README.md             # Usage documentation
  main.tf               # Primary resources
  variables.tf          # Input variables with descriptions
  outputs.tf            # Output values
  versions.tf           # Provider version constraints
  examples/
    minimal/            # Minimal working example
    complete/           # Full-featured example
  tests/
    module_test.tftest.hcl
```

### Environment Structure

```
environments/
  dev/
  staging/
  prod/
modules/
  networking/
  compute/
  data/
examples/
  complete/
  minimal/
```

## Naming Conventions

**Resources:**
```hcl
resource "aws_instance" "web_server" { }      # Descriptive, contextual
resource "aws_vpc" "this" { }                  # "this" for singletons in module
```

**Variables:** Prefix with context -- `var.vpc_cidr_block` not `var.cidr`.

**Files:** `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `data.tf` (optional).

## Code Structure Standards

### Resource Block Ordering

1. `count` or `for_each` FIRST (blank line after)
2. Other arguments
3. `tags` as last real argument
4. `depends_on` after tags (if needed)
5. `lifecycle` at the very end (if needed)

```hcl
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}
```

### Variable Block Ordering

1. `description` (ALWAYS required)
2. `type`
3. `default`
4. `validation`
5. `nullable` (when setting to false)

### Count vs For_Each

| Scenario | Use | Why |
|----------|-----|-----|
| Boolean toggle (create or not) | `count = condition ? 1 : 0` | Simple on/off |
| Items may be reordered/removed | `for_each = toset(list)` | Stable addresses |
| Reference by key | `for_each = map` | Named access |
| Fixed numeric replication | `count = 3` | Identical resources |

Prefer `for_each` when list items may change -- removing a middle item with `count` recreates all subsequent resources.

### Locals for Dependency Management

Use locals with `try()` to ensure correct resource deletion order:

```hcl
locals {
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.this[0].vpc_id,
    aws_vpc.this.id,
    ""
  )
}
```

This prevents deletion errors without explicit `depends_on`.

## State Management

### Remote Backend Setup

Always use remote state with locking for shared infrastructure:

```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "env/component/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### State Operations

```bash
terraform state list                              # List all resources
terraform state show aws_instance.web             # Show specific resource
terraform state rm aws_instance.web               # Remove from state (no destroy)
terraform state mv aws_instance.web aws_instance.app  # Rename
terraform import aws_instance.web i-1234567890    # Import existing
```

### Drift Detection

```bash
terraform plan                    # Shows drift as unexpected changes
export TF_LOG=DEBUG               # Enable debug logging
export TF_LOG_PATH=debug.log      # Write to file
```

## Terragrunt Patterns

### Project Structure

```
terragrunt-project/
  terragrunt.hcl              # Root config
  account.hcl                 # Account-level vars
  region.hcl                  # Region-level vars
  environments/
    dev/
      env.hcl
      us-east-1/
        vpc/
          terragrunt.hcl
        eks/
          terragrunt.hcl
    prod/
      us-east-1/
        vpc/
        eks/
```

### Dependency Management

```hcl
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id     = "vpc-mock"
    subnet_ids = ["subnet-mock"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids
}
```

### Terragrunt Commands

```bash
terragrunt plan                   # Single module
terragrunt apply
terragrunt run-all plan           # All modules in tree
terragrunt run-all apply
terragrunt run-all destroy
```

## Testing Strategy

### Decision Matrix

| Situation | Approach | Tools | Cost |
|-----------|----------|-------|------|
| Quick syntax check | Static analysis | `validate`, `fmt` | Free |
| Pre-commit validation | Static + lint | `validate`, `tflint`, `trivy`, `checkov` | Free |
| Terraform 1.6+ simple logic | Native test framework | `terraform test` | Free-Low |
| Pre-1.6 or Go expertise | Integration testing | Terratest | Low-Med |
| Security/compliance focus | Policy as code | OPA, Sentinel | Free |
| Cost-sensitive workflow | Mock providers (1.7+) | Native tests + mocking | Free |

### Native Tests (1.6+)

- `command = plan` -- fast, for input validation
- `command = apply` -- required for computed values
- Set-type blocks cannot be indexed with `[0]`; use `for` expressions

## CI/CD Integration

### Recommended Stages

1. **Validate** -- Format + syntax + linting
2. **Test** -- Automated tests (native or Terratest)
3. **Plan** -- Generate and review execution plan
4. **Apply** -- Execute with approvals for production

### Cost Optimization

- Use mocking for PR validation (free)
- Run integration tests only on main branch
- Auto-cleanup orphaned test resources
- Tag all test resources for spend tracking

## Security and Compliance

```bash
trivy config .                    # Security scan
checkov -d .                      # Compliance check
tflint --module                   # Lint
```

### Rules

- Never store secrets in variables -- use Secrets Manager / Parameter Store
- Never use default VPC -- create dedicated VPCs
- Always enable encryption at rest
- Use least-privilege security groups (never 0.0.0.0/0)
- Mark sensitive values with `sensitive = true`
- Tag all resources for cost tracking

## Version Management

| Component | Strategy | Example |
|-----------|----------|---------|
| Terraform | Pin minor | `required_version = "~> 1.9"` |
| Providers | Pin major | `version = "~> 5.0"` |
| Modules (prod) | Pin exact | `version = "5.1.2"` |
| Modules (dev) | Allow patch | `version = "~> 5.1"` |

### Modern Features by Version

| Feature | Version | Use Case |
|---------|---------|----------|
| `try()` | 0.13+ | Safe fallbacks |
| `nullable = false` | 1.1+ | Prevent null values |
| `moved` blocks | 1.1+ | Refactor without destroy |
| `optional()` with defaults | 1.3+ | Optional object attributes |
| Native testing | 1.6+ | Built-in test framework |
| Mock providers | 1.7+ | Cost-free unit testing |
| Provider functions | 1.8+ | Provider-specific transforms |
| Cross-variable validation | 1.9+ | Validate between variables |
| Write-only arguments | 1.11+ | Secrets never in state |

## Troubleshooting

**State locked:**
```bash
terraform force-unlock <lock-id>    # After verifying no one else running
```

**Provider/module cache issues:**
```bash
rm -rf .terraform && terraform init -upgrade
```

**Isolate problem resource:**
```bash
terraform plan -target=aws_instance.web
```

## Constraints

### MUST
- Use remote state with locking for shared infrastructure
- Validate inputs with validation blocks
- Pin provider and Terraform versions
- Tag all resources for cost tracking
- Document module interfaces (terraform-docs)
- Run `terraform fmt` and `validate` before commit
- Test in non-production first

### MUST NOT
- Store secrets in plain text or state (use write-only args in 1.11+)
- Use local state for production
- Hardcode environment-specific values
- Create circular module dependencies
- Commit `.terraform` directories
- Skip code review for production changes
- Mix provider versions without constraints

## Review Checklist

- [ ] All variables have descriptions and types
- [ ] Sensitive values marked as sensitive
- [ ] Outputs have descriptions
- [ ] Resources follow naming conventions
- [ ] No hardcoded values
- [ ] README is complete and current
- [ ] Examples directory exists and works
- [ ] Version constraints specified
- [ ] Security scans pass

## Attribution

Incorporates guidance from [terraform-skill](https://github.com/antonbabenko/terraform-skill) by Anton Babenko (Apache-2.0).
