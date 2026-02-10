---
name: nextjs-dependency-security
description: "Use when auditing dependencies and managing supply chain security. Invoke for npm audit, package vulnerability checks, dependency updates, supply chain attack prevention, typosquatting defense. security, OWASP, Next.js, dependencies, npm audit, supply chain, package security, vulnerability"
---

# Dependency & Supply Chain Security

## The Dependency Risk

**245,000 malicious packages** published to npm in 2023 (Sonatype). Average application has 200+ dependencies, each with ~5 transitive dependencies.

### Real-World Supply Chain Attacks

- **event-stream (2018):** 2M downloads/week, hijacked to steal cryptocurrency wallet keys
- **ua-parser-js (2021):** 8M weekly downloads, compromised with crypto mining malware
- **colors.js/faker.js (2022):** Intentionally corrupted, millions of apps broke

## Running Security Audits

```bash
npm audit                    # Check for vulnerabilities
npm audit --production       # Production dependencies only (run before every deploy)
npm audit fix                # Safe patch/minor updates
npm audit fix --force        # Risky major updates (test thoroughly!)
```

## Dependency Update Strategy

### Monthly Routine (30 minutes)
```bash
npm outdated          # Check what's outdated
npm update            # Update safe packages
npm audit             # Run audit
npm audit fix         # Fix vulnerabilities
npm test && npm run build  # Test everything
```

### Before Every Production Deploy
```bash
npm audit --production    # Must show 0 vulnerabilities
```

## Preventing Supply Chain Attacks

1. **Commit package-lock.json** - Ensures reproducible builds
2. **Verify package integrity** - npm checks checksums automatically
3. **Audit new packages before installing** - Check downloads, maintenance, typosquatting
4. **Use `npm ci` in CI/CD** - Installs from lock file exactly
5. **Enable GitHub Dependabot** - Automated vulnerability alerts and PRs

## Quick Reference

```bash
npm audit --production        # Pre-deploy check
npm outdated                  # Check for updates
npm ci                        # Clean CI/CD install
bash scripts/security-check.sh  # Comprehensive check
```

## References

- npm Audit: https://docs.npmjs.com/cli/v8/commands/npm-audit
- OWASP Dependency Check: https://owasp.org/www-project-dependency-check/
- Sonatype Supply Chain Report: https://www.sonatype.com/state-of-the-software-supply-chain
- Snyk: https://snyk.io/
