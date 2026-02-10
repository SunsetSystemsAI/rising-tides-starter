---
name: monitoring-sre
description: "Use when setting up monitoring, logging, metrics, tracing, alerting, SLOs, error budgets, or incident management. Invoke for Prometheus/Grafana, OpenTelemetry, dashboards, chaos engineering, capacity planning, toil reduction, on-call, and Datadog optimization."
---

# Monitoring & SRE

Comprehensive monitoring, observability, and site reliability engineering -- from instrumentation to SLO management to incident response.

## When to Use This Skill

- Setting up monitoring, logging, metrics, or tracing
- Designing alerts and dashboards
- Defining SLIs/SLOs and managing error budgets
- Troubleshooting production performance issues
- Running chaos engineering experiments
- Reducing operational toil through automation
- Capacity planning and resource forecasting
- Managing incidents and writing postmortems
- Choosing or migrating between monitoring tools

## Core Decision Tree

```
New service?          -> Start with "Metrics Strategy" then "Instrument"
Existing issue?       -> Go to "Troubleshooting"
Improving reliability?
  Alerts              -> "Alert Design"
  Dashboards          -> "Dashboards"
  SLOs/budgets        -> "SLO & Error Budgets"
  Tool selection      -> "Tool Selection"
  Incident process    -> "Incidents & Chaos"
  Toil                -> "Toil Reduction"
```

## 1. Metrics Strategy

### Four Golden Signals
1. **Latency** -- Response time (p50, p95, p99)
2. **Traffic** -- Requests per second
3. **Errors** -- Failure rate
4. **Saturation** -- Resource utilization

**RED Method** (request-driven): Rate, Errors, Duration
**USE Method** (infrastructure): Utilization, Saturation, Errors

```promql
# Rate
sum(rate(http_requests_total[5m]))

# Error rate %
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# P95 latency
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

## 2. Instrumentation

**Structured logging checklist:** timestamp, level, message, service, request_id

**Distributed tracing (OpenTelemetry) sampling:**
- Development: 100%
- Staging: 50-100%
- Production: 1-10% (or error-based)

**Use appropriate metric types:** counters for totals, gauges for current values, histograms for distributions.

## 3. Alert Design

**Principles:**
- Every alert must be actionable with a runbook
- Alert on symptoms, not causes
- Tie alerts to SLOs -- use burn-rate alerting
- Avoid alert fatigue: fewer, higher-signal alerts

## 4. Dashboards

Follow RED method for services, USE method for infrastructure. Layer dashboards:
1. **Overview** -- Golden signals across all services
2. **Service** -- Deep dive per service
3. **Infrastructure** -- Node/container resource usage

## 5. SLO & Error Budgets

| Availability | Downtime/Month | Use Case |
|--------------|----------------|----------|
| 99% | 7.2 hours | Internal tools |
| 99.9% | 43.2 minutes | Standard production |
| 99.95% | 21.6 minutes | Critical services |
| 99.99% | 4.3 minutes | High availability |

**Workflow:**
1. Identify SLIs (what users care about: latency, availability, correctness)
2. Set SLO targets with user-impact justification
3. Calculate error budget from target
4. Monitor burn rate -- alert when budget consumed too fast
5. When budget exhausted: freeze features, focus on reliability

## 6. Incidents & Chaos Engineering

**Incident response:** Detect, triage, mitigate, resolve, postmortem.
- Write blameless postmortems for all significant incidents
- Include timeline, root cause, action items with owners

**Chaos engineering:**
1. Define steady state (normal golden signals)
2. Hypothesize what happens under failure
3. Inject failure (network partition, pod kill, latency)
4. Observe and learn
5. Fix weaknesses found

## 7. Toil Reduction

Toil = manual, repetitive, automatable operational work. Target: <50% of SRE time.

**Process:** Measure toil hours, prioritize by frequency and pain, automate with scripts/runbooks/self-healing, track reduction over time.

## 8. Tool Selection

| Solution | Monthly (100 hosts) | Setup | Ops |
|----------|-------------------|--------|-----|
| Prometheus + Loki + Tempo | $1,500 | Medium | Medium |
| Grafana Cloud | $3,000 | Low | Low |
| Datadog | $8,000 | Low | None |
| ELK Stack | $4,000 | High | High |
| CloudWatch | $2,000 | Low | Low |

**Datadog migration:** Move to Prometheus + Grafana (metrics), Loki (logs), Tempo/Jaeger (traces). Estimated savings: 60-77%.

## 9. Troubleshooting

1. Check golden signals for anomalies
2. Correlate across metrics, logs, and traces using request IDs
3. Narrow scope: which service, which endpoint, which dependency
4. Check recent deployments and config changes
5. Validate health check endpoints

## Constraints

### MUST DO
- Use structured logging (JSON) with correlation IDs
- Monitor golden signals on all services
- Define quantitative SLOs with error budgets
- Write actionable runbooks for every alert
- Write blameless postmortems for incidents
- Implement health check endpoints
- Monitor business metrics, not just technical

### MUST NOT DO
- Log sensitive data (passwords, tokens, PII)
- Alert without actionable runbooks (causes alert fatigue)
- Set SLOs without user-impact justification
- Skip postmortems or assign blame
- Ignore error budget exhaustion
- Deploy without capacity planning
- Tolerate >50% toil without automation plan

## Knowledge Reference

Prometheus, Grafana, Loki, Tempo, Jaeger, OpenTelemetry, Datadog, ELK Stack, CloudWatch, k6, Artillery, Chaos Monkey, Gremlin, SLO/SLI design, error budgets, golden signals, RED/USE methods, incident management, blameless postmortems, capacity planning, on-call practices, toil reduction
