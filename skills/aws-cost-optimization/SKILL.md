---
name: aws-cost-optimization
description: "Use when finding unused AWS resources, analyzing Reserved Instance opportunities, detecting cost anomalies, rightsizing instances, evaluating Spot instances, or implementing FinOps practices. Invoke for monthly cost reviews, commitment purchase analysis, instance generation migration, and cloud financial operations."
---

# AWS Cost Optimization & FinOps

Systematic workflows for AWS cost optimization and financial operations management.

## When to Use This Skill

Use this skill when you need to:

- **Find cost savings**: Identify unused resources, rightsizing opportunities, or commitment discounts
- **Analyze spending**: Understand cost trends, detect anomalies, or break down costs
- **Optimize architecture**: Choose cost-effective services, storage tiers, or instance types
- **Implement FinOps**: Set up governance, tagging, budgets, or monthly reviews
- **Make purchase decisions**: Evaluate Reserved Instances, Savings Plans, or Spot instances
- **Troubleshoot costs**: Investigate unexpected bills or cost spikes
- **Plan budgets**: Forecast costs or evaluate impact of new projects

## Cost Optimization Workflow

```
1. DISCOVER    - Run: find_unused_resources.py, cost_anomaly_detector.py
2. ANALYZE     - Run: rightsizing_analyzer.py, detect_old_generations.py, spot_recommendations.py
3. PRIORITIZE  - Quick wins (low risk, high savings) first
4. IMPLEMENT   - Delete unused, rightsize, purchase commitments
5. MONITOR     - Monthly reviews, tag compliance, budget tracking
```

## Core Workflows

### Workflow 1: Monthly Cost Optimization Review

**Step 1: Find Unused Resources**
```bash
python3 scripts/find_unused_resources.py
```

**Step 2: Analyze Cost Anomalies**
```bash
python3 scripts/cost_anomaly_detector.py --days 30
```

**Step 3: Identify Rightsizing Opportunities**
```bash
python3 scripts/rightsizing_analyzer.py --days 30
```

### Workflow 2: Commitment Purchase Analysis (RI/Savings Plans)

```bash
python3 scripts/analyze_ri_recommendations.py --days 60
```

### Workflow 3: Instance Generation Migration

```bash
python3 scripts/detect_old_generations.py
```

### Workflow 4: Spot Instance Evaluation

```bash
python3 scripts/spot_recommendations.py
```

## Quick Reference: Scripts

```bash
# Monthly Review
python3 scripts/find_unused_resources.py
python3 scripts/cost_anomaly_detector.py --days 30
python3 scripts/rightsizing_analyzer.py --days 30

# Quarterly Optimization
python3 scripts/analyze_ri_recommendations.py --days 60
python3 scripts/detect_old_generations.py
python3 scripts/spot_recommendations.py

# Specific Region
python3 scripts/find_unused_resources.py --region us-east-1

# Named AWS Profile
python3 scripts/find_unused_resources.py --profile production
```

**Requirements:** `pip install boto3 tabulate`

## Service-Specific Optimization

- **Compute**: Graviton (20% savings), Spot (70% savings), RIs (40-65% savings)
- **Storage**: gp2 to gp3 (20% savings), S3 lifecycle policies (50-95% savings)
- **Network**: VPC Endpoints vs NAT Gateways, CloudFront for data transfer
- **Database**: Right-size RDS, gp3 storage, Aurora Serverless for variable workloads

## Cost Optimization Checklist

### Quick Wins
- [ ] Delete unattached EBS volumes
- [ ] Delete old EBS snapshots (>90 days)
- [ ] Release unused Elastic IPs
- [ ] Convert gp2 to gp3 volumes
- [ ] Stop/terminate idle EC2 instances
- [ ] Enable S3 Intelligent-Tiering

### Medium Effort
- [ ] Right-size oversized instances
- [ ] Migrate to newer instance generations
- [ ] Purchase Reserved Instances for stable workloads
- [ ] Implement S3 lifecycle policies
- [ ] Implement tagging strategy

### Strategic
- [ ] Migrate to Graviton instances
- [ ] Implement Spot for fault-tolerant workloads
- [ ] Establish monthly cost review process
- [ ] Create FinOps culture and practices

## References

- `references/best_practices.md` - Comprehensive optimization strategies
- `references/service_alternatives.md` - Cost-effective service selection
- `references/finops_governance.md` - Organizational FinOps practices

## Best Practices

1. **Tag Everything** - Consistent tagging enables cost allocation
2. **Monitor Continuously** - Weekly script runs catch waste early
3. **Review Monthly** - Regular reviews prevent cost drift
4. **Right-size Proactively** - Don't wait for cost issues
5. **Use Commitments Wisely** - RIs/SPs for stable workloads only
6. **Test Before Migrating** - Especially for Graviton or Spot
7. **Automate Cleanup** - Scheduled shutdown of dev/test resources
