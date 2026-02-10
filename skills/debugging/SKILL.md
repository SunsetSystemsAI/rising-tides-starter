---
name: debugging
description: "Systematic root-cause debugging methodology. Use when investigating errors, analyzing stack traces, fixing bugs, or troubleshooting unexpected behavior. Triggers on: 'debug', 'fix bug', 'error', 'not working', 'troubleshoot', 'crash', 'exception', 'stack trace', 'root cause'."
---

# Debugging

Systematic methodology for finding and fixing bugs at their root cause.

## Core Workflow

1. **Reproduce** -- Establish consistent reproduction steps
2. **Isolate** -- Narrow down to smallest failing case
3. **Hypothesize** -- Form testable theories about the cause
4. **Test** -- Verify or disprove each hypothesis
5. **Fix** -- Implement minimal solution for the root cause
6. **Prevent** -- Add tests and safeguards against regression

## Phase 1: Reproduce and Investigate

**Goal:** Understand what is actually happening before changing anything.

- Can you trigger the bug reliably?
- What is expected vs. actual behavior?
- Gather evidence: logs, error messages, stack traces
- Identify scope: when did it start? What changed?
- Trace the data flow through the system

```bash
git log --oneline -20        # Recent changes
git diff HEAD~5              # What changed
grep -r "error" logs/        # Search logs
```

## Phase 2: Isolate and Analyze Patterns

**Goal:** Narrow the search space to reveal the root cause.

- **When** does it happen? Time-based patterns
- **Where** does it happen? Which files, functions, endpoints
- **What inputs** trigger it? User/data patterns
- **What is common** across occurrences?

**Techniques:**
- Binary search through commits (`git bisect`)
- Disable features one by one to isolate
- Compare working vs. broken states
- Review recent changes in affected areas

## Phase 3: Hypothesize and Test

**Goal:** Form a theory and test it with evidence.

1. State the hypothesis clearly: "The bug occurs because X"
2. Predict the outcome: "If X is the cause, then Y should be true"
3. Design a test to verify or falsify
4. Run the test and observe results
5. Iterate: refine or reject based on evidence

**Rules:**
- One hypothesis at a time
- Test must be falsifiable
- Do not skip steps even if you are "sure"

## Phase 4: Fix and Prevent

**Goal:** Fix the root cause, not just the symptom.

1. **Minimal fix** -- Change only what is necessary
2. **Verify** -- Confirm the fix resolves the issue
3. **Check regressions** -- Ensure nothing else broke
4. **Add defense** -- Write a test that would have caught this bug
5. **Clean up** -- Remove all debug code before committing

**Output for every fix:**
- **Root Cause**: What specifically caused the issue
- **Evidence**: Stack trace, logs, or test that proves it
- **Fix**: The code change
- **Prevention**: Test or safeguard added

---

## Anti-Patterns

| Do Not | Do Instead |
|--------|------------|
| Make random changes hoping something works | Form a hypothesis first |
| Fix the symptom | Find the root cause |
| Assume you know the answer | Verify with evidence |
| Make multiple changes at once | Test one hypothesis at a time |
| Skip testing the fix | Always verify |
| Leave debug statements in code | Clean up before committing |
| Debug in production without safeguards | Use staging or feature flags |

---

## Quick Checklist

```
[ ] Can I reproduce the bug reliably?
[ ] Do I have the exact error message/logs?
[ ] Do I know when this started happening?
[ ] Have I traced the data flow?
[ ] Do I have a clear hypothesis?
[ ] Did I test the hypothesis before fixing?
[ ] Did I verify the fix works?
[ ] Did I add a test to prevent regression?
[ ] Did I remove all debug code?
```

---

## When to Use

Any debugging scenario: application crashes, features not working as expected, performance issues, integration failures, flaky tests, production incidents, memory leaks, race conditions, intermittent errors.

The more serious the bug, the more important it is to follow this methodology.
