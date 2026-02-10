---
name: gitops-workflows
description: "Use when setting up GitOps with ArgoCD or Flux, designing repository structures, implementing multi-cluster deployments, managing secrets in Git, or configuring progressive delivery. Invoke for ArgoCD 3.x setup, Flux 2.7 bootstrap, ApplicationSets, SOPS/Sealed Secrets, Argo Rollouts, Flagger canary deployments, and sync troubleshooting."
---

# GitOps Workflows

Comprehensive GitOps workflows for continuous deployment to Kubernetes using ArgoCD 3.x and Flux 2.7+.

## When to Use This Skill

- Setting up GitOps from scratch (ArgoCD or Flux)
- Designing Git repository structures
- Multi-cluster deployments
- Troubleshooting sync/reconciliation issues
- Implementing secrets management
- Progressive delivery (canary, blue-green)
- Migrating between GitOps tools

## Core Workflow Decision Tree

```
Do you have GitOps installed?
+-- NO -> Want UI + easy onboarding? -> ArgoCD
|         Want modularity + platform engineering? -> Flux
+-- YES -> Sync issues? -> Section 7
           Multi-cluster? -> Section 4
           Secrets? -> Section 5
           Progressive delivery? -> Section 6
```

## 1. ArgoCD 3.x Setup

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.9/manifests/install.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Health check:**
```bash
python3 scripts/check_argocd_health.py --server https://argocd.example.com --token $ARGOCD_TOKEN
```

## 2. Flux 2.7 Setup

```bash
flux check --pre
export GITHUB_TOKEN=<your-token>
flux bootstrap github --owner=<org> --repository=fleet-infra --branch=main --path=clusters/production --personal
```

**Health check:**
```bash
python3 scripts/check_flux_health.py --namespace flux-system
```

## 3. Repository Structure

**Monorepo** (small teams, <20 apps):
```
gitops-repo/
+-- apps/
+-- infrastructure/
+-- clusters/
    +-- dev/
    +-- staging/
    +-- production/
```

**Polyrepo** (large orgs, multiple teams):
```
infrastructure-repo/     (Platform team)
app-team-1-repo/        (Team 1)
app-team-2-repo/        (Team 2)
```

**Validate repo structure:**
```bash
python3 scripts/validate_gitops_repo.py /path/to/repo
```

## 4. Multi-Cluster Deployments

**ArgoCD ApplicationSets** for deploying across clusters.

**Generate ApplicationSets:**
```bash
python3 scripts/applicationset_generator.py cluster --name my-apps --repo-url https://github.com/org/repo --output appset.yaml
```

## 5. Secrets Management

| Solution | Complexity | Best For |
|----------|-----------|----------|
| SOPS + age | Medium | Git-centric, flexible |
| External Secrets Operator | Medium | Cloud-native, dynamic |
| Sealed Secrets | Low | Simple, GitOps-first |

**Audit secrets:**
```bash
python3 scripts/secret_audit.py /path/to/repo
```

## 6. Progressive Delivery

**Argo Rollouts** (canary/blue-green with ArgoCD)
**Flagger** (canary with metrics analysis for Flux)

## 7. Troubleshooting

**ArgoCD OutOfSync:**
```bash
argocd app diff my-app
argocd app sync my-app
```

**Flux Not Reconciling:**
```bash
flux get all
flux reconcile kustomization my-app
```

**Detect Drift:**
```bash
python3 scripts/sync_drift_detector.py --argocd --app my-app
python3 scripts/sync_drift_detector.py --flux
```

## Scripts

- `check_argocd_health.py` - Diagnose ArgoCD sync issues
- `check_flux_health.py` - Diagnose Flux reconciliation issues
- `validate_gitops_repo.py` - Validate repository structure
- `sync_drift_detector.py` - Detect drift between Git and cluster
- `secret_audit.py` - Audit secrets management
- `applicationset_generator.py` - Generate ApplicationSet manifests
- `promotion_validator.py` - Validate environment promotion workflows
- `oci_artifact_checker.py` - Validate Flux OCI artifacts

## References

- `references/argocd_vs_flux.md` - Tool comparison and decision matrix
- `references/repo_patterns.md` - Monorepo vs polyrepo patterns
- `references/secret_management.md` - SOPS, Sealed Secrets, ESO
- `references/progressive_delivery.md` - Canary/blue-green patterns
- `references/multi_cluster.md` - Multi-cluster deployment patterns
- `references/troubleshooting.md` - Common sync issues
- `references/best_practices.md` - CNCF GitOps principles
- `references/oci_artifacts.md` - Flux OCI artifacts
