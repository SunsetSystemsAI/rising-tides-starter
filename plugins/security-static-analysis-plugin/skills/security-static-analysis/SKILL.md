---
name: security-static-analysis
description: "Use when running static analysis tools. Invoke for Semgrep, CodeQL, SARIF parsing, static analysis, code scanning, vulnerability detection."
---

# codeql

# CodeQL Static Analysis

## When to Use CodeQL

**Ideal scenarios:**
- Source code access with ability to build (for compiled languages)
- Open-source projects or GitHub Advanced Security license
- Need for interprocedural data flow and taint tracking
- Finding complex vulnerabilities requiring AST/CFG analysis
- Comprehensive security audits where analysis time is not critical

**Consider Semgrep instead when:**
- No build capability for compiled languages
- Licensing constraints
- Need fast, lightweight pattern matching
- Simple, single-file analysis is sufficient

### Why Interprocedural Analysis Matters

Simple grep/pattern tools only see one function at a time. Real vulnerabilities often span multiple functions:

```
HTTP Handler → Input Parser → Business Logic → Database Query
     ↓              ↓              ↓              ↓
   source      transforms       passes       sink (SQL)
```

CodeQL tracks data flow across all these steps. A tainted input in the handler can be traced through 5+ function calls to find where it reaches a dangerous sink.

Pattern-based tools miss this because they can't connect `request.param` in file A to `db.execute(query)` in file B.

## When NOT to Use

Do NOT use this skill for:
- Projects that cannot be built (CodeQL requires successful compilation for compiled languages)
- Quick pattern searches (use Semgrep or grep for speed)
- Non-security code quality checks (use linters instead)
- Projects without source code access

## Environment Check

```bash
# Check if CodeQL is installed
command -v codeql >/dev/null 2>&1 && echo "CodeQL: installed" || echo "CodeQL: NOT installed (run install steps below)"
```

## Installation

### CodeQL CLI

```bash
# macOS/Linux (Homebrew)
brew install --cask codeql

# Update
brew upgrade codeql
```

Manual: Download bundle from https://github.com/github/codeql-action/releases

### Trail of Bits Queries (Optional)

Install public ToB security queries for additional coverage:

```bash
# Download ToB query packs
codeql pack download trailofbits/cpp-queries trailofbits/go-queries

# Verify installation
codeql resolve qlpacks | grep trailofbits
```

## Core Workflow

### 1. Create Database

```bash
codeql database create codeql.db --language=<LANG> [--command='<BUILD>'] --source-root=.
```

| Language | `--language=` | Build Required |
|----------|---------------|----------------|
| Python | `python` | No |
| JavaScript/TypeScript | `javascript` | No |
| Go | `go` | No |
| Ruby | `ruby` | No |
| Rust | `rust` | Yes (`--command='cargo build'`) |
| Java/Kotlin | `java` | Yes (`--command='./gradlew build'`) |
| C/C++ | `cpp` | Yes (`--command='make -j8'`) |
| C# | `csharp` | Yes (`--command='dotnet build'`) |
| Swift | `swift` | Yes (macOS only) |

### 2. Run Analysis

```bash
# List available query packs
codeql resolve qlpacks
```

**Run security queries:**

```bash
# SARIF output (recommended)
codeql database analyze codeql.db \
  --format=sarif-latest \
  --output=results.sarif \
  -- codeql/python-queries:codeql-suites/python-security-extended.qls

# CSV output
codeql database analyze codeql.db \
  --format=csv \
  --output=results.csv \
  -- codeql/javascript-queries
```

**With Trail of Bits queries (if installed):**

```bash
codeql database analyze codeql.db \
  --format=sarif-latest \
  --output=results.sarif \
  -- trailofbits/go-queries
```

## Writing Custom Queries

### Query Structure

CodeQL uses SQL-like syntax: `from Type x where P(x) select f(x)`

### Basic Template

```ql
/**
 * @name Find SQL injection vulnerabilities
 * @description Identifies potential SQL injection from user input
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.0
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking

module SqlInjectionConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    // Define taint sources (user input)
    exists(source)
  }

  predicate isSink(DataFlow::Node sink) {
    // Define dangerous sinks (SQL execution)
    exists(sink)
  }
}

module SqlInjectionFlow = TaintTracking::Global<SqlInjectionConfig>;

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "SQL injection from $@.", source.getNode(), "user input"
```

### Query Metadata

| Field | Description | Values |
|-------|-------------|--------|
| `@kind` | Query type | `problem`, `path-problem` |
| `@problem.severity` | Issue severity | `error`, `warning`, `recommendation` |
| `@security-severity` | CVSS score | `0.0` - `10.0` |
| `@precision` | Confidence | `very-high`, `high`, `medium`, `low` |

### Key Language Features

```ql
// Predicates
predicate isUserInput(DataFlow::Node node) {
  exists(Call c | c.getFunc().(Attribute).getName() = "get" and node.asExpr() = c)
}

// Transitive closure: + (one or more), * (zero or more)
node.getASuccessor+()

// Quantification
exists(Variable v | v.getName() = "password")
forall(Call c | c.getTarget().hasName("dangerous") | hasCheck(c))
```

## Creating Query Packs

```bash
codeql pack init myorg/security-queries
```

Structure:
```
myorg-security-queries/
├── qlpack.yml
├── src/
│   └── SqlInjection.ql
└── test/
    └── SqlInjectionTest.expected
```

**qlpack.yml:**
```yaml
name: myorg/security-queries
version: 1.0.0
dependencies:
  codeql/python-all: "*"
```

## CI/CD Integration (GitHub Actions)

```yaml
name: CodeQL Analysis

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 1'  # Weekly

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      matrix:
        language: ['python', 'javascript']

    steps:
      - uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended,security-and-quality
          # Add custom queries/packs:
          # queries: security-extended,./codeql/custom-queries
          # packs: trailofbits/python-queries

      - uses: github/codeql-action/autobuild@v3

      - uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
```

## Testing Queries

```bash
codeql test run test/
```

Test file format:
```python
def vulnerable():
    user_input = request.args.get("q")  # Source
    cursor.execute("SELECT * FROM users WHERE id = " + user_input)  # Alert: sql-injection

def safe():
    user_input = request.args.get("q")
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_input,))  # OK
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Database creation fails | Clean build environment, verify build command works independently |
| Slow analysis | Use `--threads`, narrow query scope, check query complexity |
| Missing results | Check file exclusions, verify source files were parsed |
| Out of memory | Set `CODEQL_RAM=48000` environment variable (48GB) |
| CMake source path issues | Adjust `--source-root` to point to actual source location |

## Rationalizations to Reject

| Shortcut | Why It's Wrong |
|----------|----------------|
| "No findings means the code is secure" | CodeQL only finds patterns it has queries for; novel vulnerabilities won't be detected |
| "This code path looks safe" | Complex data flow can hide vulnerabilities across 5+ function calls; trace the full path |
| "Small change, low risk" | Small changes can introduce critical bugs; run full analysis on every change |
| "Tests pass so it's safe" | Tests prove behavior, not absence of vulnerabilities; they test expected paths, not attacker paths |
| "The query didn't flag it" | Default query suites don't cover everything; check if custom queries are needed for your domain |

## Resources

- Docs: https://codeql.github.com/docs/
- Query Help: https://codeql.github.com/codeql-query-help/
- Security Lab: https://securitylab.github.com/
- Trail of Bits Queries: https://github.com/trailofbits/codeql-queries
- VSCode Extension: "CodeQL" for query development

# sarif-parsing

# SARIF Parsing Best Practices

You are a SARIF parsing expert. Your role is to help users effectively read, analyze, and process SARIF files from static analysis tools.

## When to Use

Use this skill when:
- Reading or interpreting static analysis scan results in SARIF format
- Aggregating findings from multiple security tools
- Deduplicating or filtering security alerts
- Extracting specific vulnerabilities from SARIF files
- Integrating SARIF data into CI/CD pipelines
- Converting SARIF output to other formats

## When NOT to Use

Do NOT use this skill for:
- Running static analysis scans (use CodeQL or Semgrep skills instead)
- Writing CodeQL or Semgrep rules (use their respective skills)
- Analyzing source code directly (SARIF is for processing existing scan results)
- Triaging findings without SARIF input (use variant-analysis or audit skills)

## SARIF Structure Overview

SARIF 2.1.0 is the current OASIS standard. Every SARIF file has this hierarchical structure:

```
sarifLog
├── version: "2.1.0"
├── $schema: (optional, enables IDE validation)
└── runs[] (array of analysis runs)
    ├── tool
    │   ├── driver
    │   │   ├── name (required)
    │   │   ├── version
    │   │   └── rules[] (rule definitions)
    │   └── extensions[] (plugins)
    ├── results[] (findings)
    │   ├── ruleId
    │   ├── level (error/warning/note)
    │   ├── message.text
    │   ├── locations[]
    │   │   └── physicalLocation
    │   │       ├── artifactLocation.uri
    │   │       └── region (startLine, startColumn, etc.)
    │   ├── fingerprints{}
    │   └── partialFingerprints{}
    └── artifacts[] (scanned files metadata)
```

### Why Fingerprinting Matters

Without stable fingerprints, you can't track findings across runs:

- **Baseline comparison**: "Is this a new finding or did we see it before?"
- **Regression detection**: "Did this PR introduce new vulnerabilities?"
- **Suppression**: "Ignore this known false positive in future runs"

Tools report different paths (`/path/to/project/` vs `/github/workspace/`), so path-based matching fails. Fingerprints hash the *content* (code snippet, rule ID, relative location) to create stable identifiers regardless of environment.

## Tool Selection Guide

| Use Case | Tool | Installation |
|----------|------|--------------|
| Quick CLI queries | jq | `brew install jq` / `apt install jq` |
| Python scripting (simple) | pysarif | `pip install pysarif` |
| Python scripting (advanced) | sarif-tools | `pip install sarif-tools` |
| .NET applications | SARIF SDK | NuGet package |
| JavaScript/Node.js | sarif-js | npm package |
| Go applications | garif | `go get github.com/chavacava/garif` |
| Validation | SARIF Validator | sarifweb.azurewebsites.net |

## Strategy 1: Quick Analysis with jq

For rapid exploration and one-off queries:

```bash
# Pretty print the file
jq '.' results.sarif

# Count total findings
jq '[.runs[].results[]] | length' results.sarif

# List all rule IDs triggered
jq '[.runs[].results[].ruleId] | unique' results.sarif

# Extract errors only
jq '.runs[].results[] | select(.level == "error")' results.sarif

# Get findings with file locations
jq '.runs[].results[] | {
  rule: .ruleId,
  message: .message.text,
  file: .locations[0].physicalLocation.artifactLocation.uri,
  line: .locations[0].physicalLocation.region.startLine
}' results.sarif

# Filter by severity and get count per rule
jq '[.runs[].results[] | select(.level == "error")] | group_by(.ruleId) | map({rule: .[0].ruleId, count: length})' results.sarif

# Extract findings for a specific file
jq --arg file "src/auth.py" '.runs[].results[] | select(.locations[].physicalLocation.artifactLocation.uri | contains($file))' results.sarif
```

## Strategy 2: Python with pysarif

For programmatic access with full object model:

```python
from pysarif import load_from_file, save_to_file

# Load SARIF file
sarif = load_from_file("results.sarif")

# Iterate through runs and results
for run in sarif.runs:
    tool_name = run.tool.driver.name
    print(f"Tool: {tool_name}")

    for result in run.results:
        print(f"  [{result.level}] {result.rule_id}: {result.message.text}")

        if result.locations:
            loc = result.locations[0].physical_location
            if loc and loc.artifact_location:
                print(f"    File: {loc.artifact_location.uri}")
                if loc.region:
                    print(f"    Line: {loc.region.start_line}")

# Save modified SARIF
save_to_file(sarif, "modified.sarif")
```

## Strategy 3: Python with sarif-tools

For aggregation, reporting, and CI/CD integration:

```python
from sarif import loader

# Load single file
sarif_data = loader.load_sarif_file("results.sarif")

# Or load multiple files
sarif_set = loader.load_sarif_files(["tool1.sarif", "tool2.sarif"])

# Get summary report
report = sarif_data.get_report()

# Get histogram by severity
errors = report.get_issue_type_histogram_for_severity("error")
warnings = report.get_issue_type_histogram_for_severity("warning")

# Filter results
high_severity = [r for r in sarif_data.get_results()
                 if r.get("level") == "error"]
```

**sarif-tools CLI commands:**

```bash
# Summary of findings
sarif summary results.sarif

# List all results with details
sarif ls results.sarif

# Get results by severity
sarif ls --level error results.sarif

# Diff two SARIF files (find new/fixed issues)
sarif diff baseline.sarif current.sarif

# Convert to other formats
sarif csv results.sarif > results.csv
sarif html results.sarif > report.html
```

## Strategy 4: Aggregating Multiple SARIF Files

When combining results from multiple tools:

```python
import json
from pathlib import Path

def aggregate_sarif_files(sarif_paths: list[str]) -> dict:
    """Combine multiple SARIF files into one."""
    aggregated = {
        "version": "2.1.0",
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "runs": []
    }

    for path in sarif_paths:
        with open(path) as f:
            sarif = json.load(f)
            aggregated["runs"].extend(sarif.get("runs", []))

    return aggregated

def deduplicate_results(sarif: dict) -> dict:
    """Remove duplicate findings based on fingerprints."""
    seen_fingerprints = set()

    for run in sarif["runs"]:
        unique_results = []
        for result in run.get("results", []):
            # Use partialFingerprints or create key from location
            fp = None
            if result.get("partialFingerprints"):
                fp = tuple(sorted(result["partialFingerprints"].items()))
            elif result.get("fingerprints"):
                fp = tuple(sorted(result["fingerprints"].items()))
            else:
                # Fallback: create fingerprint from rule + location
                loc = result.get("locations", [{}])[0]
                phys = loc.get("physicalLocation", {})
                fp = (
                    result.get("ruleId"),
                    phys.get("artifactLocation", {}).get("uri"),
                    phys.get("region", {}).get("startLine")
                )

            if fp not in seen_fingerprints:
                seen_fingerprints.add(fp)
                unique_results.append(result)

        run["results"] = unique_results

    return sarif
```

## Strategy 5: Extracting Actionable Data

```python
import json
from dataclasses import dataclass
from typing import Optional

@dataclass
class Finding:
    rule_id: str
    level: str
    message: str
    file_path: Optional[str]
    start_line: Optional[int]
    end_line: Optional[int]
    fingerprint: Optional[str]

def extract_findings(sarif_path: str) -> list[Finding]:
    """Extract structured findings from SARIF file."""
    with open(sarif_path) as f:
        sarif = json.load(f)

    findings = []
    for run in sarif.get("runs", []):
        for result in run.get("results", []):
            loc = result.get("locations", [{}])[0]
            phys = loc.get("physicalLocation", {})
            region = phys.get("region", {})

            findings.append(Finding(
                rule_id=result.get("ruleId", "unknown"),
                level=result.get("level", "warning"),
                message=result.get("message", {}).get("text", ""),
                file_path=phys.get("artifactLocation", {}).get("uri"),
                start_line=region.get("startLine"),
                end_line=region.get("endLine"),
                fingerprint=next(iter(result.get("partialFingerprints", {}).values()), None)
            ))

    return findings

# Filter and prioritize
def prioritize_findings(findings: list[Finding]) -> list[Finding]:
    """Sort findings by severity."""
    severity_order = {"error": 0, "warning": 1, "note": 2, "none": 3}
    return sorted(findings, key=lambda f: severity_order.get(f.level, 99))
```

## Common Pitfalls and Solutions

### 1. Path Normalization Issues

Different tools report paths differently (absolute, relative, URI-encoded):

```python
from urllib.parse import unquote
from pathlib import Path

def normalize_path(uri: str, base_path: str = "") -> str:
    """Normalize SARIF artifact URI to consistent path."""
    # Remove file:// prefix if present
    if uri.startswith("file://"):
        uri = uri[7:]

    # URL decode
    uri = unquote(uri)

    # Handle relative paths
    if not Path(uri).is_absolute() and base_path:
        uri = str(Path(base_path) / uri)

    # Normalize separators
    return str(Path(uri))
```

### 2. Fingerprint Mismatch Across Runs

Fingerprints may not match if:
- File paths differ between environments
- Tool versions changed fingerprinting algorithm
- Code was reformatted (changing line numbers)

**Solution:** Use multiple fingerprint strategies:

```python
def compute_stable_fingerprint(result: dict, file_content: str = None) -> str:
    """Compute environment-independent fingerprint."""
    import hashlib

    components = [
        result.get("ruleId", ""),
        result.get("message", {}).get("text", "")[:100],  # First 100 chars
    ]

    # Add code snippet if available
    if file_content and result.get("locations"):
        region = result["locations"][0].get("physicalLocation", {}).get("region", {})
        if region.get("startLine"):
            lines = file_content.split("\n")
            line_idx = region["startLine"] - 1
            if 0 <= line_idx < len(lines):
                # Normalize whitespace
                components.append(lines[line_idx].strip())

    return hashlib.sha256("".join(components).encode()).hexdigest()[:16]
```

### 3. Missing or Incomplete Data

SARIF allows many optional fields. Always use defensive access:

```python
def safe_get_location(result: dict) -> tuple[str, int]:
    """Safely extract file and line from result."""
    try:
        loc = result.get("locations", [{}])[0]
        phys = loc.get("physicalLocation", {})
        file_path = phys.get("artifactLocation", {}).get("uri", "unknown")
        line = phys.get("region", {}).get("startLine", 0)
        return file_path, line
    except (IndexError, KeyError, TypeError):
        return "unknown", 0
```

### 4. Large File Performance

For very large SARIF files (100MB+):

```python
import ijson  # pip install ijson

def stream_results(sarif_path: str):
    """Stream results without loading entire file."""
    with open(sarif_path, "rb") as f:
        # Stream through results arrays
        for result in ijson.items(f, "runs.item.results.item"):
            yield result
```

### 5. Schema Validation

Validate before processing to catch malformed files:

```bash
# Using ajv-cli
npm install -g ajv-cli
ajv validate -s sarif-schema-2.1.0.json -d results.sarif

# Using Python jsonschema
pip install jsonschema
```

```python
from jsonschema import validate, ValidationError
import json

def validate_sarif(sarif_path: str, schema_path: str) -> bool:
    """Validate SARIF file against schema."""
    with open(sarif_path) as f:
        sarif = json.load(f)
    with open(schema_path) as f:
        schema = json.load(f)

    try:
        validate(sarif, schema)
        return True
    except ValidationError as e:
        print(f"Validation error: {e.message}")
        return False
```

## CI/CD Integration Patterns

### GitHub Actions

```yaml
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif

- name: Check for high severity
  run: |
    HIGH_COUNT=$(jq '[.runs[].results[] | select(.level == "error")] | length' results.sarif)
    if [ "$HIGH_COUNT" -gt 0 ]; then
      echo "Found $HIGH_COUNT high severity issues"
      exit 1
    fi
```

### Fail on New Issues

```python
from sarif import loader

def check_for_regressions(baseline: str, current: str) -> int:
    """Return count of new issues not in baseline."""
    baseline_data = loader.load_sarif_file(baseline)
    current_data = loader.load_sarif_file(current)

    baseline_fps = {get_fingerprint(r) for r in baseline_data.get_results()}
    new_issues = [r for r in current_data.get_results()
                  if get_fingerprint(r) not in baseline_fps]

    return len(new_issues)
```

## Key Principles

1. **Validate first**: Check SARIF structure before processing
2. **Handle optionals**: Many fields are optional; use defensive access
3. **Normalize paths**: Tools report paths differently; normalize early
4. **Fingerprint wisely**: Combine multiple strategies for stable deduplication
5. **Stream large files**: Use ijson or similar for 100MB+ files
6. **Aggregate thoughtfully**: Preserve tool metadata when combining files

## Skill Resources

For ready-to-use query templates, see [{baseDir}/resources/jq-queries.md]({baseDir}/resources/jq-queries.md):
- 40+ jq queries for common SARIF operations
- Severity filtering, rule extraction, aggregation patterns

For Python utilities, see [{baseDir}/resources/sarif_helpers.py]({baseDir}/resources/sarif_helpers.py):
- `normalize_path()` - Handle tool-specific path formats
- `compute_fingerprint()` - Stable fingerprinting ignoring paths
- `deduplicate_results()` - Remove duplicates across runs

## Reference Links

- [OASIS SARIF 2.1.0 Specification](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html)
- [Microsoft SARIF Tutorials](https://github.com/microsoft/sarif-tutorials)
- [SARIF SDK (.NET)](https://github.com/microsoft/sarif-sdk)
- [sarif-tools (Python)](https://github.com/microsoft/sarif-tools)
- [pysarif (Python)](https://github.com/Kjeld-P/pysarif)
- [GitHub SARIF Support](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning)
- [SARIF Validator](https://sarifweb.azurewebsites.net/)

# semgrep

# Semgrep Static Analysis

## When to Use Semgrep

**Ideal scenarios:**
- Quick security scans (minutes, not hours)
- Pattern-based bug detection
- Enforcing coding standards and best practices
- Finding known vulnerability patterns
- Single-file analysis without complex data flow
- First-pass analysis before deeper tools

**Consider CodeQL instead when:**
- Need interprocedural taint tracking across files
- Complex data flow analysis required
- Analyzing custom proprietary frameworks

## When NOT to Use

Do NOT use this skill for:
- Complex interprocedural data flow analysis (use CodeQL instead)
- Binary analysis or compiled code without source
- Custom deep semantic analysis requiring AST/CFG traversal
- When you need to track taint across many function boundaries

## Installation

```bash
# pip
python3 -m pip install semgrep

# Homebrew
brew install semgrep

# Docker
docker run --rm -v "${PWD}:/src" returntocorp/semgrep semgrep --config auto /src

# Update
pip install --upgrade semgrep
```

## Core Workflow

### 1. Quick Scan

```bash
semgrep --config auto .                    # Auto-detect rules
semgrep --config auto --metrics=off .      # Disable telemetry for proprietary code
```

### 2. Use Rulesets

```bash
semgrep --config p/<RULESET> .             # Single ruleset
semgrep --config p/security-audit --config p/trailofbits .  # Multiple
```

| Ruleset | Description |
|---------|-------------|
| `p/default` | General security and code quality |
| `p/security-audit` | Comprehensive security rules |
| `p/owasp-top-ten` | OWASP Top 10 vulnerabilities |
| `p/cwe-top-25` | CWE Top 25 vulnerabilities |
| `p/r2c-security-audit` | r2c security audit rules |
| `p/trailofbits` | Trail of Bits security rules |
| `p/python` | Python-specific |
| `p/javascript` | JavaScript-specific |
| `p/golang` | Go-specific |

### 3. Output Formats

```bash
semgrep --config p/security-audit --sarif -o results.sarif .   # SARIF
semgrep --config p/security-audit --json -o results.json .     # JSON
semgrep --config p/security-audit --dataflow-traces .          # Show data flow
```

### 4. Scan Specific Paths

```bash
semgrep --config p/python app.py           # Single file
semgrep --config p/javascript src/         # Directory
semgrep --config auto --include='**/test/**' .  # Include tests (excluded by default)
```

## Writing Custom Rules

### Basic Structure

```yaml
rules:
  - id: hardcoded-password
    languages: [python]
    message: "Hardcoded password detected: $PASSWORD"
    severity: ERROR
    pattern: password = "$PASSWORD"
```

### Pattern Syntax

| Syntax | Description | Example |
|--------|-------------|---------|
| `...` | Match anything | `func(...)` |
| `$VAR` | Capture metavariable | `$FUNC($INPUT)` |
| `<... ...>` | Deep expression match | `<... user_input ...>` |

### Pattern Operators

| Operator | Description |
|----------|-------------|
| `pattern` | Match exact pattern |
| `patterns` | All must match (AND) |
| `pattern-either` | Any matches (OR) |
| `pattern-not` | Exclude matches |
| `pattern-inside` | Match only inside context |
| `pattern-not-inside` | Match only outside context |
| `pattern-regex` | Regex matching |
| `metavariable-regex` | Regex on captured value |
| `metavariable-comparison` | Compare values |

### Combining Patterns

```yaml
rules:
  - id: sql-injection
    languages: [python]
    message: "Potential SQL injection"
    severity: ERROR
    patterns:
      - pattern-either:
          - pattern: cursor.execute($QUERY)
          - pattern: db.execute($QUERY)
      - pattern-not:
          - pattern: cursor.execute("...", (...))
      - metavariable-regex:
          metavariable: $QUERY
          regex: .*\+.*|.*\.format\(.*|.*%.*
```

### Taint Mode (Data Flow)

Simple pattern matching finds obvious cases:

```python
# Pattern `os.system($CMD)` catches this:
os.system(user_input)  # Found
```

But misses indirect flows:

```python
# Same pattern misses this:
cmd = user_input
processed = cmd.strip()
os.system(processed)  # Missed - no direct match
```

Taint mode tracks data through assignments and transformations:
- **Source**: Where untrusted data enters (`user_input`)
- **Propagators**: How it flows (`cmd = ...`, `processed = ...`)
- **Sanitizers**: What makes it safe (`shlex.quote()`)
- **Sink**: Where it becomes dangerous (`os.system()`)

```yaml
rules:
  - id: command-injection
    languages: [python]
    message: "User input flows to command execution"
    severity: ERROR
    mode: taint
    pattern-sources:
      - pattern: request.args.get(...)
      - pattern: request.form[...]
      - pattern: request.json
    pattern-sinks:
      - pattern: os.system($SINK)
      - pattern: subprocess.call($SINK, shell=True)
      - pattern: subprocess.run($SINK, shell=True, ...)
    pattern-sanitizers:
      - pattern: shlex.quote(...)
      - pattern: int(...)
```

### Full Rule with Metadata

```yaml
rules:
  - id: flask-sql-injection
    languages: [python]
    message: "SQL injection: user input flows to query without parameterization"
    severity: ERROR
    metadata:
      cwe: "CWE-89: SQL Injection"
      owasp: "A03:2021 - Injection"
      confidence: HIGH
    mode: taint
    pattern-sources:
      - pattern: request.args.get(...)
      - pattern: request.form[...]
      - pattern: request.json
    pattern-sinks:
      - pattern: cursor.execute($QUERY)
      - pattern: db.execute($QUERY)
    pattern-sanitizers:
      - pattern: int(...)
    fix: cursor.execute($QUERY, (params,))
```

## Testing Rules

### Test File Format

```python
# test_rule.py
def test_vulnerable():
    user_input = request.args.get("id")
    # ruleid: flask-sql-injection
    cursor.execute("SELECT * FROM users WHERE id = " + user_input)

def test_safe():
    user_input = request.args.get("id")
    # ok: flask-sql-injection
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_input,))
```

```bash
semgrep --test rules/
```

## CI/CD Integration (GitHub Actions)

```yaml
name: Semgrep

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 1 * *'  # Monthly

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container:
      image: returntocorp/semgrep

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for diff-aware scanning

      - name: Run Semgrep
        run: |
          if [ "${{ github.event_name }}" = "pull_request" ]; then
            semgrep ci --baseline-commit ${{ github.event.pull_request.base.sha }}
          else
            semgrep ci
          fi
        env:
          SEMGREP_RULES: >-
            p/security-audit
            p/owasp-top-ten
            p/trailofbits
```

## Configuration

### .semgrepignore

```
tests/fixtures/
**/testdata/
generated/
vendor/
node_modules/
```

### Suppress False Positives

```python
password = get_from_vault()  # nosemgrep: hardcoded-password
dangerous_but_safe()  # nosemgrep
```

## Performance

```bash
semgrep --config rules/ --time .    # Check rule performance
ulimit -n 4096                       # Increase file descriptors for large codebases
```

### Path Filtering in Rules

```yaml
rules:
  - id: my-rule
    paths:
      include: [src/]
      exclude: [src/generated/]
```

## Third-Party Rules

```bash
pip install semgrep-rules-manager
semgrep-rules-manager --dir ~/semgrep-rules download
semgrep -f ~/semgrep-rules .
```

## Rationalizations to Reject

| Shortcut | Why It's Wrong |
|----------|----------------|
| "Semgrep found nothing, code is clean" | Semgrep is pattern-based; it can't track complex data flow across functions |
| "I wrote a rule, so we're covered" | Rules need testing with `semgrep --test`; false negatives are silent |
| "Taint mode catches injection" | Only if you defined all sources, sinks, AND sanitizers correctly |
| "Pro rules are comprehensive" | Pro rules are good but not exhaustive; supplement with custom rules for your codebase |
| "Too many findings = noisy tool" | High finding count often means real problems; tune rules, don't disable them |

## Resources

- Registry: https://semgrep.dev/explore
- Playground: https://semgrep.dev/playground
- Docs: https://semgrep.dev/docs/
- Trail of Bits Rules: https://github.com/trailofbits/semgrep-rules
- Blog: https://semgrep.dev/blog/
