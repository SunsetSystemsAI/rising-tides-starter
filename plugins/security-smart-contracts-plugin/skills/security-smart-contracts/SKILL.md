---
name: security-smart-contracts
description: "Use when auditing or building secure smart contracts. Invoke for Solidity, Solana, Cairo, CosmWasm, TON, Substrate, Algorand vulnerability scanning, token integration, secure workflow."
---

# algorand-vulnerability-scanner

# Algorand Vulnerability Scanner

## 1. Purpose

Systematically scan Algorand smart contracts (TEAL and PyTeal) for platform-specific security vulnerabilities documented in Trail of Bits' "Not So Smart Contracts" database. This skill encodes 11 critical vulnerability patterns unique to Algorand's transaction model.

## 2. When to Use This Skill

- Auditing Algorand smart contracts (stateful applications or smart signatures)
- Reviewing TEAL assembly or PyTeal code
- Pre-audit security assessment of Algorand projects
- Validating fixes for reported Algorand vulnerabilities
- Training team on Algorand-specific security patterns

## 3. Platform Detection

### File Extensions & Indicators
- **TEAL files**: `.teal`
- **PyTeal files**: `.py` with PyTeal imports

### Language/Framework Markers
```python
# PyTeal indicators
from pyteal import *
from algosdk import *

# Common patterns
Txn, Gtxn, Global, InnerTxnBuilder
OnComplete, ApplicationCall, TxnType
@router.method, @Subroutine
```

### Project Structure
- `approval_program.py` / `clear_program.py`
- `contract.teal` / `signature.teal`
- References to Algorand SDK or Beaker framework

### Tool Support
- **Tealer**: Trail of Bits static analyzer for Algorand
- Installation: `pip3 install tealer`
- Usage: `tealer contract.teal --detect all`

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for TEAL/PyTeal files
2. **Analyze each file** for the 11 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Run Tealer** (if installed) for automated detection

---

## 5. Example Output

When vulnerabilities are found, you'll get a report like this:

```
=== ALGORAND VULNERABILITY SCAN RESULTS ===

Project: my-algorand-dapp
Files Scanned: 3 (.teal, .py)
Vulnerabilities Found: 2

---

[CRITICAL] Rekeying Attack
File: contracts/approval.py:45
Pattern: Missing RekeyTo validation

Code:
    If(Txn.type_enum() == TxnType.Payment,
        Seq([
            # Missing: Assert(Txn.rekey_to() == Global.zero_address())
            App.globalPut(Bytes("balance"), balance + Txn.amount()),
            Approve()
        ])
    )

Issue: The contract doesn't validate the RekeyTo field, allowing attackers
to change account authorization and bypass restrictions.


---

## 5. Vulnerability Patterns (11 Patterns)

I check for 11 critical vulnerability patterns unique to Algorand. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Rekeying Vulnerability** ⚠️ CRITICAL - Unchecked RekeyTo field
2. **Missing Transaction Verification** ⚠️ CRITICAL - No GroupSize/GroupIndex checks
3. **Group Transaction Manipulation** ⚠️ HIGH - Unsafe group transaction handling
4. **Asset Clawback Risk** ⚠️ HIGH - Missing clawback address checks
5. **Application State Manipulation** ⚠️ MEDIUM - Unsafe global/local state updates
6. **Asset Opt-In Missing** ⚠️ HIGH - No asset opt-in validation
7. **Minimum Balance Violation** ⚠️ MEDIUM - Account below minimum balance
8. **Close Remainder To Check** ⚠️ HIGH - Unchecked CloseRemainderTo field
9. **Application Clear State** ⚠️ MEDIUM - Unsafe clear state program
10. **Atomic Transaction Ordering** ⚠️ HIGH - Assuming transaction order
11. **Logic Signature Reuse** ⚠️ HIGH - Logic sigs without uniqueness constraints

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).
## 5. Scanning Workflow

### Step 1: Platform Identification
1. Confirm file extensions (`.teal`, `.py`)
2. Identify framework (PyTeal, Beaker, pure TEAL)
3. Determine contract type (stateful application vs smart signature)
4. Locate approval and clear state programs

### Step 2: Static Analysis with Tealer
```bash
# Run Tealer on contract
tealer contract.teal --detect all

# Or specific detectors
tealer contract.teal --detect unprotected-rekey,group-size-check,update-application-check
```

### Step 3: Manual Vulnerability Sweep
For each of the 11 vulnerabilities above:
1. Search for relevant transaction field usage
2. Verify validation logic exists
3. Check for bypass conditions
4. Validate inner transaction handling

### Step 4: Transaction Field Validation Matrix
Create checklist for all transaction types used:

**Payment Transactions**:
- [ ] RekeyTo validated
- [ ] CloseRemainderTo validated
- [ ] Fee validated (if smart signature)

**Asset Transfers**:
- [ ] Asset ID validated
- [ ] AssetCloseTo validated
- [ ] RekeyTo validated

**Application Calls**:
- [ ] OnComplete validated
- [ ] Access controls enforced
- [ ] Group size validated

**Inner Transactions**:
- [ ] Fee explicitly set to 0
- [ ] RekeyTo not user-controlled (Teal v6+)
- [ ] All fields validated

### Step 5: Group Transaction Analysis
For atomic transaction groups:
1. Validate `Global.group_size()` checks
2. Review absolute vs relative indexing
3. Check for replay protection (Lease field)
4. Verify OnComplete fields for ApplicationCalls in group

### Step 6: Access Control Review
- [ ] Creator/admin privileges properly enforced
- [ ] Update/delete operations protected
- [ ] Sensitive functions have authorization checks

---

## 6. Reporting Format

### Finding Template
```markdown
## [SEVERITY] Vulnerability Name (e.g., Missing RekeyTo Validation)

**Location**: `contract.teal:45-50` or `approval_program.py:withdraw()`

**Description**:
The contract approves payment transactions without validating the RekeyTo field, allowing an attacker to rekey the account and bypass future authorization checks.

**Vulnerable Code**:
```python
# approval_program.py, line 45
If(Txn.type_enum() == TxnType.Payment,
    Approve()  # Missing RekeyTo check
)
```

**Attack Scenario**:
1. Attacker submits payment transaction with RekeyTo set to attacker's address
2. Contract approves transaction without checking RekeyTo
3. Account authorization is rekeyed to attacker
4. Attacker gains full control of account

**Recommendation**:
Add explicit validation of the RekeyTo field:
```python
If(And(
    Txn.type_enum() == TxnType.Payment,
    Txn.rekey_to() == Global.zero_address()
), Approve(), Reject())
```

**References**:
- building-secure-contracts/not-so-smart-contracts/algorand/rekeying
- Tealer detector: `unprotected-rekey`
```

---

## 7. Priority Guidelines

### Critical (Immediate Fix Required)
- Rekeying attacks
- CloseRemainderTo / AssetCloseTo issues
- Access control bypasses

### High (Fix Before Deployment)
- Unchecked transaction fees
- Asset ID validation issues
- Group size validation
- Clear state transaction checks

### Medium (Address in Audit)
- Inner transaction fee issues
- Time-based replay attacks
- DoS via asset opt-in

---

## 8. Testing Recommendations

### Unit Tests Required
- Test each vulnerability scenario with PoC exploit
- Verify fixes prevent exploitation
- Test edge cases (group size = 0, empty addresses, etc.)

### Tealer Integration
```bash
# Add to CI/CD pipeline
tealer approval.teal --detect all --json > tealer-report.json

# Fail build on critical findings
tealer approval.teal --detect all --fail-on critical,high
```

### Scenario Testing
- Submit transactions with all critical fields manipulated
- Test atomic groups with unexpected sizes
- Attempt access control bypasses
- Verify inner transaction fee handling

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/algorand/`
- **Tealer Documentation**: https://github.com/crytic/tealer
- **Algorand Developer Docs**: https://developer.algorand.org/docs/
- **PyTeal Documentation**: https://pyteal.readthedocs.io/

---

## 10. Quick Reference Checklist

Before completing Algorand audit, verify ALL items checked:

- [ ] RekeyTo validated in all transaction types
- [ ] CloseRemainderTo validated in payment transactions
- [ ] AssetCloseTo validated in asset transfers
- [ ] Transaction fees validated (smart signatures)
- [ ] Group size validated for atomic transactions
- [ ] Lease field used for replay protection (where applicable)
- [ ] Access controls on Update/Delete operations
- [ ] Asset ID validated in all asset operations
- [ ] Asset transfers use pull pattern to avoid DoS
- [ ] Inner transaction fees explicitly set to 0
- [ ] OnComplete field validated for ApplicationCall transactions
- [ ] Tealer scan completed with no critical/high findings
- [ ] Unit tests cover all vulnerability scenarios

# audit-prep-assistant

# Audit Prep Assistant

## Purpose

Helps prepare for a security review using Trail of Bits' checklist. A well-prepared codebase makes the review process smoother and more effective.

**Use this**: 1-2 weeks before your security audit

---

## The Preparation Process

### Step 1: Set Review Goals

Helps define what you want from the review:

**Key Questions**:
- What's the overall security level you're aiming for?
- What areas concern you most?
  - Previous audit issues?
  - Complex components?
  - Fragile parts?
- What's the worst-case scenario for your project?

Documents goals to share with the assessment team.

---

### Step 2: Resolve Easy Issues

Runs static analysis and helps fix low-hanging fruit:

**Run Static Analysis**:

For Solidity:
```bash
slither . --exclude-dependencies
```

For Rust:
```bash
dylint --all
```

For Go:
```bash
golangci-lint run
```

For Go/Rust/C++:
```bash
# CodeQL and Semgrep checks
```

Then I'll:
- Triage all findings
- Help fix easy issues
- Document accepted risks

**Increase Test Coverage**:
- Analyze current coverage
- Identify untested code
- Suggest new tests
- Run full test suite

**Remove Dead Code**:
- Find unused functions/variables
- Identify unused libraries
- Locate stale features
- Suggest cleanup

**Goal**: Clean static analysis report, high test coverage, minimal dead code

---

### Step 3: Ensure Code Accessibility

Helps make code clear and accessible:

**Provide Detailed File List**:
- List all files in scope
- Mark out-of-scope files
- Explain folder structure
- Document dependencies

**Create Build Instructions**:
- Write step-by-step setup guide
- Test on fresh environment
- Document dependencies and versions
- Verify build succeeds

**Freeze Stable Version**:
- Identify commit hash for review
- Create dedicated branch
- Tag release version
- Lock dependencies

**Identify Boilerplate**:
- Mark copied/forked code
- Highlight your modifications
- Document third-party code
- Focus review on your code

---

### Step 4: Generate Documentation

Helps create documentation:

**Flowcharts and Sequence Diagrams**:
- Map primary workflows
- Show component relationships
- Visualize data flow
- Identify critical paths

**User Stories**:
- Define user roles
- Document use cases
- Explain interactions
- Clarify expectations

**On-chain/Off-chain Assumptions**:
- Data validation procedures
- Oracle information
- Bridge assumptions
- Trust boundaries

**Actors and Privileges**:
- List all actors
- Document roles
- Define privileges
- Map access controls

**External Developer Docs**:
- Link docs to code
- Keep synchronized
- Explain architecture
- Document APIs

**Function Documentation**:
- System and function invariants
- Parameter ranges (min/max values)
- Arithmetic formulas and precision loss
- Complex logic explanations
- NatSpec for Solidity

**Glossary**:
- Define domain terms
- Explain acronyms
- Consistent terminology
- Business logic concepts

**Video Walkthroughs** (optional):
- Complex workflows
- Areas of concern
- Architecture overview

---

## How I Work

When invoked, I will:

1. **Help set review goals** - Ask about concerns and document them
2. **Run static analysis** - Execute appropriate tools for your platform
3. **Analyze test coverage** - Identify gaps and suggest improvements
4. **Find dead code** - Search for unused code and libraries
5. **Review accessibility** - Check build instructions and scope clarity
6. **Generate documentation** - Create flowcharts, user stories, glossaries
7. **Create prep checklist** - Track what's done and what's remaining

Adapts based on:
- Your platform (Solidity, Rust, Go, etc.)
- Available tools
- Existing documentation
- Review timeline

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "README covers setup, no need for detailed build instructions" | READMEs assume context auditors don't have | Test build on fresh environment, document every dependency version |
| "Static analysis already ran, no need to run again" | Codebase changed since last run | Execute static analysis tools, generate fresh report |
| "Test coverage looks decent" | "Looks decent" isn't measured coverage | Run coverage tools, identify specific untested code paths |
| "Not much dead code to worry about" | Dead code hides during manual review | Use automated detection tools to find unused functions/variables |
| "Architecture is straightforward, no diagrams needed" | Text descriptions miss visual patterns | Generate actual flowcharts and sequence diagrams |
| "Can freeze version right before audit" | Last-minute freezing creates rushed handoff | Identify and document commit hash now, create dedicated branch |
| "Terms are self-explanatory" | Domain knowledge isn't universal | Create comprehensive glossary with all domain-specific terms |
| "I'll do this step later" | Steps build on each other - skipping creates gaps | Complete all 4 steps sequentially, track progress with checklist |

---

## Example Output

When I finish helping you prepare, you'll have concrete deliverables like:

```
=== AUDIT PREP PACKAGE ===

Project: DeFi DEX Protocol
Audit Date: March 15, 2024
Preparation Status: Complete

---

## REVIEW GOALS DOCUMENT

Security Objectives:
- Verify economic security of liquidity pool swaps
- Validate oracle manipulation resistance
- Assess flash loan attack vectors

Areas of Concern:
1. Complex AMM pricing calculation (src/SwapRouter.sol:89-156)
2. Multi-hop swap routing logic (src/Router.sol)
3. Oracle price aggregation (src/PriceOracle.sol:45-78)

Worst-Case Scenario:
- Flash loan attack drains liquidity pools via oracle manipulation

Questions for Auditors:
- Can the AMM pricing model produce negative slippage under edge cases?
- Is the slippage protection sufficient to prevent sandwich attacks?
- How resilient is the system to temporary oracle failures?

---

## STATIC ANALYSIS REPORT

Slither Scan Results:
✓ High: 0 issues
✓ Medium: 0 issues
⚠ Low: 2 issues (triaged - documented in TRIAGE.md)
ℹ Info: 5 issues (code style, acceptable)

Tool: slither . --exclude-dependencies
Date: March 1, 2024
Status: CLEAN (all critical issues resolved)

---

## TEST COVERAGE REPORT

Overall Coverage: 94%
- Statements: 1,245 / 1,321 (94%)
- Branches: 456 / 498 (92%)
- Functions: 89 / 92 (97%)

Uncovered Areas:
- Emergency pause admin functions (tested manually)
- Governance migration path (one-time use)

Command: forge coverage
Status: EXCELLENT

---

## CODE SCOPE

In-Scope Files (8):
✓ src/SwapRouter.sol (456 lines)
✓ src/LiquidityPool.sol (234 lines)
✓ src/PairFactory.sol (389 lines)
✓ src/PriceOracle.sol (167 lines)
✓ src/LiquidityManager.sol (298 lines)
✓ src/Governance.sol (201 lines)
✓ src/FlashLoan.sol (145 lines)
✓ src/RewardsDistributor.sol (178 lines)

Out-of-Scope:
- lib/ (OpenZeppelin, external dependencies)
- test/ (test contracts)
- scripts/ (deployment scripts)

Total In-Scope: 2,068 lines of Solidity

---

## BUILD INSTRUCTIONS

Prerequisites:
- Foundry 0.2.0+
- Node.js 18+
- Git

Setup:
```bash
git clone https://github.com/project/repo.git
cd repo
git checkout audit-march-2024  # Frozen branch
forge install
forge build
forge test
```

Verification:
✓ Build succeeds without errors
✓ All 127 tests pass
✓ No warnings from compiler

---

## DOCUMENTATION

Generated Artifacts:
✓ ARCHITECTURE.md - System overview with diagrams
✓ USER_STORIES.md - 12 user interaction flows
✓ GLOSSARY.md - 34 domain terms defined
✓ docs/diagrams/contract-interactions.png
✓ docs/diagrams/swap-flow.png
✓ docs/diagrams/state-machine.png

NatSpec Coverage: 100% of public functions

---

## DEPLOYMENT INFO

Network: Ethereum Mainnet
Commit: abc123def456 (audit-march-2024 branch)
Deployed Contracts:
- SwapRouter: 0x1234...
- PriceOracle: 0x5678...
[... etc]

---

PACKAGE READY FOR AUDIT ✓
Next Step: Share with Trail of Bits assessment team
```

---

## What You'll Get

**Review Goals Document**:
- Security objectives
- Areas of concern
- Worst-case scenarios
- Questions for auditors

**Clean Codebase**:
- Triaged static analysis (or clean report)
- High test coverage
- No dead code
- Clear scope

**Accessibility Package**:
- File list with scope
- Build instructions
- Frozen commit/branch
- Boilerplate identified

**Documentation Suite**:
- Flowcharts and diagrams
- User stories
- Architecture docs
- Actor/privilege map
- Inline code comments
- Glossary
- Video walkthroughs (if created)

**Audit Prep Checklist**:
- [ ] Review goals documented
- [ ] Static analysis clean/triaged
- [ ] Test coverage >80%
- [ ] Dead code removed
- [ ] Build instructions verified
- [ ] Stable version frozen
- [ ] Flowcharts created
- [ ] User stories documented
- [ ] Assumptions documented
- [ ] Actors/privileges listed
- [ ] Function docs complete
- [ ] Glossary created

---

## Timeline

**2 weeks before audit**:
- Set review goals
- Run static analysis
- Start fixing issues

**1 week before audit**:
- Increase test coverage
- Remove dead code
- Freeze stable version
- Start documentation

**Few days before audit**:
- Complete documentation
- Verify build instructions
- Create final checklist
- Send package to auditors

---

## Ready to Prep

Let me know when you're ready and I'll help you prepare for your security review!

# cairo-vulnerability-scanner

# Cairo/StarkNet Vulnerability Scanner

## 1. Purpose

Systematically scan Cairo smart contracts on StarkNet for platform-specific security vulnerabilities related to arithmetic, cross-layer messaging, and cryptographic operations. This skill encodes 6 critical vulnerability patterns unique to Cairo/StarkNet ecosystem.

## 2. When to Use This Skill

- Auditing StarkNet smart contracts (Cairo)
- Reviewing L1-L2 bridge implementations
- Pre-launch security assessment of StarkNet applications
- Validating cross-layer message handling
- Reviewing signature verification logic
- Assessing L1 handler functions

## 3. Platform Detection

### File Extensions & Indicators
- **Cairo files**: `.cairo`

### Language/Framework Markers
```rust
// Cairo contract indicators
#[contract]
mod MyContract {
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        balance: LegacyMap<ContractAddress, felt252>,
    }

    #[external(v0)]
    fn transfer(ref self: ContractState, to: ContractAddress, amount: felt252) {
        // Contract logic
    }

    #[l1_handler]
    fn handle_deposit(ref self: ContractState, from_address: felt252, amount: u256) {
        // L1 message handler
    }
}

// Common patterns
felt252, u128, u256
ContractAddress, EthAddress
#[external(v0)], #[l1_handler], #[constructor]
get_caller_address(), get_contract_address()
send_message_to_l1_syscall
```

### Project Structure
- `src/contract.cairo` - Main contract implementation
- `src/lib.cairo` - Library modules
- `tests/` - Contract tests
- `Scarb.toml` - Cairo project configuration

### Tool Support
- **Caracal**: Trail of Bits static analyzer for Cairo
- Installation: `pip install caracal`
- Usage: `caracal detect src/`
- **cairo-test**: Built-in testing framework
- **Starknet Foundry**: Testing and development toolkit

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for Cairo files
2. **Analyze each contract** for the 6 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Check L1-L2 interactions** for messaging vulnerabilities

---

## 5. Example Output

When vulnerabilities are found, you'll get a report like this:

```
=== CAIRO/STARKNET VULNERABILITY SCAN RESULTS ===


---

## 5. Vulnerability Patterns (6 Patterns)

I check for 6 critical vulnerability patterns unique to Cairo/Starknet. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Unchecked Arithmetic** ⚠️ CRITICAL - Integer overflow/underflow in felt252
2. **Storage Collision** ⚠️ CRITICAL - Conflicting storage variable hashes
3. **Missing Access Control** ⚠️ CRITICAL - No caller validation on sensitive functions
4. **Improper Felt252 Boundaries** ⚠️ HIGH - Not validating felt252 range
5. **Unvalidated Contract Address** ⚠️ HIGH - Using untrusted contract addresses
6. **Missing Caller Validation** ⚠️ CRITICAL - No get_caller_address() checks

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).
## 5. Scanning Workflow

### Step 1: Platform Identification
1. Verify Cairo language and StarkNet framework
2. Check Cairo version (Cairo 1.0+ vs legacy Cairo 0)
3. Locate contract files (`src/*.cairo`)
4. Identify L1-L2 bridge contracts (if applicable)

### Step 2: Arithmetic Safety Sweep
```bash
# Find felt252 usage in arithmetic
rg "felt252" src/ | rg "[-+*/]"

# Find balance/amount storage using felt252
rg "felt252" src/ | rg "balance|amount|total|supply"

# Should prefer u128, u256 instead
```

### Step 3: L1 Handler Analysis
For each `#[l1_handler]` function:
- [ ] Validates `from_address` parameter
- [ ] Checks address != zero
- [ ] Has proper access control
- [ ] Emits events for monitoring

### Step 4: Signature Verification Review
For signature-based functions:
- [ ] Includes nonce tracking
- [ ] Nonce incremented after use
- [ ] Domain separator includes chain ID and contract address
- [ ] Cannot replay signatures

### Step 5: L1-L2 Bridge Audit
If contract includes bridge functionality:
- [ ] L1 validates address < STARKNET_FIELD_PRIME
- [ ] L1 implements message cancellation
- [ ] L2 validates from_address in handlers
- [ ] Symmetric access controls L1 ↔ L2
- [ ] Test full roundtrip flows

### Step 6: Static Analysis with Caracal
```bash
# Run Caracal detectors
caracal detect src/

# Specific detectors
caracal detect src/ --detectors unchecked-felt252-arithmetic
caracal detect src/ --detectors unchecked-l1-handler-from
caracal detect src/ --detectors missing-nonce-validation
```

---

## 6. Reporting Format

### Finding Template
```markdown
## [CRITICAL] Unchecked from_address in L1 Handler

**Location**: `src/bridge.cairo:145-155` (handle_deposit function)

**Description**:
The `handle_deposit` L1 handler function does not validate the `from_address` parameter. Any L1 contract can send messages to this function and mint tokens for arbitrary users, bypassing the intended L1 bridge access controls.

**Vulnerable Code**:
```rust
// bridge.cairo, line 145
#[l1_handler]
fn handle_deposit(
    ref self: ContractState,
    from_address: felt252,  // Not validated!
    user: ContractAddress,
    amount: u256
) {
    let current_balance = self.balances.read(user);
    self.balances.write(user, current_balance + amount);
}
```

**Attack Scenario**:
1. Attacker deploys malicious L1 contract
2. Malicious contract calls `starknetCore.sendMessageToL2(l2Contract, selector, [attacker_address, 1000000])`
3. L2 handler processes message without checking sender
4. Attacker receives 1,000,000 tokens without depositing any funds
5. Protocol suffers infinite mint vulnerability

**Recommendation**:
Validate `from_address` against authorized L1 bridge:
```rust
#[l1_handler]
fn handle_deposit(
    ref self: ContractState,
    from_address: felt252,
    user: ContractAddress,
    amount: u256
) {
    // Validate L1 sender
    let authorized_l1_bridge = self.l1_bridge_address.read();
    assert(from_address == authorized_l1_bridge, 'Unauthorized L1 sender');

    let current_balance = self.balances.read(user);
    self.balances.write(user, current_balance + amount);
}
```

**References**:
- building-secure-contracts/not-so-smart-contracts/cairo/unchecked_l1_handler_from
- Caracal detector: `unchecked-l1-handler-from`
```

---

## 7. Priority Guidelines

### Critical (Immediate Fix Required)
- Unchecked from_address in L1 handlers (infinite mint)
- L1-L2 address conversion issues (funds to zero address)

### High (Fix Before Deployment)
- Felt252 arithmetic overflow/underflow (balance manipulation)
- Missing signature replay protection (replay attacks)
- L1-L2 message failure without cancellation (locked funds)

### Medium (Address in Audit)
- Overconstrained L1-L2 interactions (trapped funds)

---

## 8. Testing Recommendations

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_felt252_overflow() {
        // Test arithmetic edge cases
    }

    #[test]
    #[should_panic]
    fn test_unauthorized_l1_handler() {
        // Wrong from_address should fail
    }

    #[test]
    fn test_signature_replay_protection() {
        // Same signature twice should fail
    }
}
```

### Integration Tests (with L1)
```rust
// Test full L1-L2 flow
#[test]
fn test_deposit_withdraw_roundtrip() {
    // 1. Deposit on L1
    // 2. Wait for L2 processing
    // 3. Verify L2 balance
    // 4. Withdraw to L1
    // 5. Verify L1 balance restored
}
```

### Caracal CI Integration
```yaml
# .github/workflows/security.yml
- name: Run Caracal
  run: |
    pip install caracal
    caracal detect src/ --fail-on high,critical
```

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/cairo/`
- **Caracal**: https://github.com/crytic/caracal
- **Cairo Documentation**: https://book.cairo-lang.org/
- **StarkNet Documentation**: https://docs.starknet.io/
- **OpenZeppelin Cairo Contracts**: https://github.com/OpenZeppelin/cairo-contracts

---

## 10. Quick Reference Checklist

Before completing Cairo/StarkNet audit:

**Arithmetic Safety (HIGH)**:
- [ ] No felt252 used for balances/amounts (use u128/u256)
- [ ] OR felt252 arithmetic has explicit bounds checking
- [ ] Overflow/underflow scenarios tested

**L1 Handler Security (CRITICAL)**:
- [ ] ALL `#[l1_handler]` functions validate `from_address`
- [ ] from_address compared against stored L1 contract address
- [ ] Cannot bypass by deploying alternate L1 contract

**L1-L2 Messaging (HIGH)**:
- [ ] L1 bridge validates addresses < STARKNET_FIELD_PRIME
- [ ] L1 bridge implements message cancellation
- [ ] L2 handlers check from_address
- [ ] Symmetric validation rules L1 ↔ L2
- [ ] Full roundtrip flows tested

**Signature Security (HIGH)**:
- [ ] Signatures include nonce tracking
- [ ] Nonce incremented after each use
- [ ] Domain separator includes chain ID and contract address
- [ ] Signature replay tested and prevented
- [ ] Cross-chain replay prevented

**Tool Usage**:
- [ ] Caracal scan completed with no critical findings
- [ ] Unit tests cover all vulnerability scenarios
- [ ] Integration tests verify L1-L2 flows
- [ ] Testnet deployment tested before mainnet

# code-maturity-assessor

# Code Maturity Assessor

## Purpose

Systematically assesses codebase maturity using Trail of Bits' 9-category framework. Provides evidence-based ratings and actionable recommendations.

**Framework**: Building Secure Contracts - Code Maturity Evaluation v0.1.0

---

## How This Works

### Phase 1: Discovery
Explores the codebase to understand:
- Project structure and platform
- Contract/module files
- Test coverage
- Documentation availability

### Phase 2: Analysis
For each of 9 categories, I'll:
- **Search the code** for relevant patterns
- **Read key files** to assess implementation
- **Present findings** with file references
- **Ask clarifying questions** about processes I can't see in code
- **Determine rating** based on criteria

### Phase 3: Report
Generates:
- Executive summary
- Maturity scorecard (ratings for all 9 categories)
- Detailed analysis with evidence
- Priority-ordered improvement roadmap

---

## Rating System

- **Missing (0)**: Not present/not implemented
- **Weak (1)**: Several significant improvements needed
- **Moderate (2)**: Adequate, can be improved
- **Satisfactory (3)**: Above average, minor improvements
- **Strong (4)**: Exceptional, only small improvements possible

**Rating Logic**:
- ANY "Weak" criteria → **Weak**
- NO "Weak" + SOME "Moderate" unmet → **Moderate**
- ALL "Moderate" + SOME "Satisfactory" met → **Satisfactory**
- ALL "Satisfactory" + exceptional practices → **Strong**

---

## The 9 Categories

I assess 9 comprehensive categories covering all aspects of code maturity. For detailed criteria, analysis approaches, and rating thresholds, see [ASSESSMENT_CRITERIA.md](resources/ASSESSMENT_CRITERIA.md).

### Quick Reference:

**1. ARITHMETIC**
- Overflow protection mechanisms
- Precision handling and rounding
- Formula specifications
- Edge case testing

**2. AUDITING**
- Event definitions and coverage
- Monitoring infrastructure
- Incident response planning

**3. AUTHENTICATION / ACCESS CONTROLS**
- Privilege management
- Role separation
- Access control testing
- Key compromise scenarios

**4. COMPLEXITY MANAGEMENT**
- Function scope and clarity
- Cyclomatic complexity
- Inheritance hierarchies
- Code duplication

**5. DECENTRALIZATION**
- Centralization risks
- Upgrade control mechanisms
- User opt-out paths
- Timelock/multisig patterns

**6. DOCUMENTATION**
- Specifications and architecture
- Inline code documentation
- User stories
- Domain glossaries

**7. TRANSACTION ORDERING RISKS**
- MEV vulnerabilities
- Front-running protections
- Slippage controls
- Oracle security

**8. LOW-LEVEL MANIPULATION**
- Assembly usage
- Unsafe code sections
- Low-level calls
- Justification and testing

**9. TESTING & VERIFICATION**
- Test coverage
- Fuzzing and formal verification
- CI/CD integration
- Test quality

For complete assessment criteria including what I'll analyze, what I'll ask you, and detailed rating thresholds (WEAK/MODERATE/SATISFACTORY/STRONG), see [ASSESSMENT_CRITERIA.md](resources/ASSESSMENT_CRITERIA.md).

---

## Example Output

When the assessment is complete, you'll receive a comprehensive maturity report including:

- **Executive Summary**: Overall score, top 3 strengths, top 3 gaps, priority recommendations
- **Maturity Scorecard**: Table with all 9 categories rated with scores and notes
- **Detailed Analysis**: Category-by-category breakdown with evidence (file:line references)
- **Improvement Roadmap**: Priority-ordered recommendations (CRITICAL/HIGH/MEDIUM) with effort estimates

For a complete example assessment report, see [EXAMPLE_REPORT.md](resources/EXAMPLE_REPORT.md).

---

## Assessment Process

When invoked, I will:

1. **Explore codebase**
   - Find contract/module files
   - Identify test files
   - Locate documentation

2. **Analyze each category**
   - Search for relevant code patterns
   - Read key implementations
   - Assess against criteria
   - Collect evidence

3. **Interactive assessment**
   - Present my findings with file references
   - Ask about processes I can't see in code
   - Discuss borderline cases
   - Determine ratings together

4. **Generate report**
   - Executive summary
   - Maturity scorecard table
   - Detailed category analysis with evidence
   - Priority-ordered improvement roadmap

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "Found some findings, assessment complete" | Assessment requires evaluating ALL 9 categories | Complete assessment of all 9 categories with evidence for each |
| "I see events, auditing category looks good" | Events alone don't equal auditing maturity | Check logging comprehensiveness, testing, incident response processes |
| "Code looks simple, complexity is low" | Visual simplicity masks composition complexity | Analyze cyclomatic complexity, dependency depth, state machine transitions |
| "Not a DeFi protocol, MEV category doesn't apply" | MEV extends beyond DeFi (governance, NFTs, games) | Verify with transaction ordering analysis before declaring N/A |
| "No assembly found, low-level category is N/A" | Low-level risks include external calls, delegatecall, inline assembly | Search for all low-level patterns before skipping category |
| "This is taking too long" | Thorough assessment requires time per category | Complete all 9 categories, ask clarifying questions about off-chain processes |
| "I can rate this without evidence" | Ratings without file:line references = unsubstantiated claims | Collect concrete code evidence for every category assessment |
| "User will know what to improve" | Vague guidance = no action | Provide priority-ordered roadmap with specific improvements and effort estimates |

---

## Report Format

For detailed report structure and templates, see [REPORT_FORMAT.md](resources/REPORT_FORMAT.md).

### Structure:

1. **Executive Summary**
   - Project name and platform
   - Overall maturity (average rating)
   - Top 3 strengths
   - Top 3 critical gaps
   - Priority recommendations

2. **Maturity Scorecard**
   - Table with all 9 categories
   - Ratings and scores
   - Key findings notes

3. **Detailed Analysis**
   - Per-category breakdown
   - Evidence with file:line references
   - Gaps and improvement actions

4. **Improvement Roadmap**
   - CRITICAL (immediate)
   - HIGH (1-2 months)
   - MEDIUM (2-4 months)
   - Effort estimates and impact

---

## Ready to Begin

**Estimated Time**: 30-40 minutes

**I'll need**:
- Access to full codebase
- Your knowledge of processes (monitoring, incident response, team practices)
- Context about the project (DeFi, NFT, infrastructure, etc.)

Let's assess this codebase!

# cosmos-vulnerability-scanner

# Cosmos Vulnerability Scanner

## 1. Purpose

Systematically scan Cosmos SDK blockchain modules and CosmWasm smart contracts for platform-specific security vulnerabilities that can cause chain halts, consensus failures, or fund loss. This skill encodes 9 critical vulnerability patterns unique to Cosmos-based chains.

## 2. When to Use This Skill

- Auditing Cosmos SDK modules (custom x/ modules)
- Reviewing CosmWasm smart contracts (Rust)
- Pre-launch security assessment of Cosmos chains
- Investigating chain halt incidents
- Validating consensus-critical code changes
- Reviewing ABCI method implementations

## 3. Platform Detection

### File Extensions & Indicators
- **Go files**: `.go`, `.proto`
- **CosmWasm**: `.rs` (Rust with cosmwasm imports)

### Language/Framework Markers
```go
// Cosmos SDK indicators
import (
    "github.com/cosmos/cosmos-sdk/types"
    sdk "github.com/cosmos/cosmos-sdk/types"
    "github.com/cosmos/cosmos-sdk/x/..."
)

// Common patterns
keeper.Keeper
sdk.Msg, GetSigners()
BeginBlocker, EndBlocker
CheckTx, DeliverTx
protobuf service definitions
```

```rust
// CosmWasm indicators
use cosmwasm_std::*;
#[entry_point]
pub fn execute(deps: DepsMut, env: Env, info: MessageInfo, msg: ExecuteMsg)
```

### Project Structure
- `x/modulename/` - Custom modules
- `keeper/keeper.go` - State management
- `types/msgs.go` - Message definitions
- `abci.go` - BeginBlocker/EndBlocker
- `handler.go` - Message handlers (legacy)

### Tool Support
- **CodeQL**: Custom rules for non-determinism and panics
- **go vet**, **golangci-lint**: Basic Go static analysis
- **Manual review**: Critical for consensus issues

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for Cosmos SDK modules
2. **Analyze each module** for the 9 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Check message handlers** for validation issues

---

## 5. Example Output

When vulnerabilities are found, you'll get a report like this:

```
=== COSMOS SDK VULNERABILITY SCAN RESULTS ===

Project: my-cosmos-chain
Files Scanned: 6 (.go)
Vulnerabilities Found: 2

---

[CRITICAL] Incorrect GetSigners()

---

## 5. Vulnerability Patterns (9 Patterns)

I check for 9 critical vulnerability patterns unique to CosmWasm. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Missing Denom Validation** ⚠️ CRITICAL - Accepting arbitrary token denoms
2. **Insufficient Authorization** ⚠️ CRITICAL - Missing sender/admin validation
3. **Missing Balance Check** ⚠️ HIGH - Not verifying sufficient balances
4. **Improper Reply Handling** ⚠️ HIGH - Unsafe submessage reply processing
5. **Missing Reply ID Check** ⚠️ MEDIUM - Not validating reply IDs
6. **Improper IBC Packet Validation** ⚠️ CRITICAL - Unvalidated IBC packets
7. **Unvalidated Execute Message** ⚠️ HIGH - Missing message validation
8. **Integer Overflow** ⚠️ HIGH - Unchecked arithmetic operations
9. **Reentrancy via Submessages** ⚠️ MEDIUM - State changes before submessages

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).
## 5. Scanning Workflow

### Step 1: Platform Identification
1. Identify Cosmos SDK version (`go.mod`)
2. Locate custom modules (`x/*/`)
3. Find ABCI methods (`abci.go`, BeginBlocker, EndBlocker)
4. Identify message types (`types/msgs.go`, `.proto`)

### Step 2: Critical Path Analysis
Focus on consensus-critical code:
- BeginBlocker / EndBlocker implementations
- Message handlers (execute, DeliverTx)
- Keeper methods that modify state
- CheckTx priority logic

### Step 3: Non-Determinism Sweep
**This is the highest priority check for Cosmos chains.**

```bash
# Search for non-deterministic patterns
grep -r "range.*map\[" x/
grep -r "\bint\b\|\buint\b" x/ | grep -v "int32\|int64\|uint32\|uint64"
grep -r "float32\|float64" x/
grep -r "go func\|go routine" x/
grep -r "select {" x/
grep -r "time.Now()" x/
grep -r "rand\." x/
```

For each finding:
1. Verify it's in consensus-critical path
2. Confirm it causes non-determinism
3. Assess severity (chain halt vs data inconsistency)

### Step 4: ABCI Method Analysis
Review BeginBlocker and EndBlocker:
- [ ] Computational complexity bounded?
- [ ] No unbounded iterations?
- [ ] No nested loops over large collections?
- [ ] Panic-prone operations validated?
- [ ] Benchmarked with maximum state?

### Step 5: Message Validation
For each message type:
- [ ] GetSigners() address matches handler usage?
- [ ] All error returns checked?
- [ ] Priority set in CheckTx if critical?
- [ ] Handler registered (or using v0.47+ auto-registration)?

### Step 6: Arithmetic & Bookkeeping
- [ ] sdk.Dec operations use multiply-before-divide?
- [ ] Rounding favors protocol over users?
- [ ] Custom bookkeeping synchronized with x/bank?
- [ ] Invariant checks in place?

---

## 6. Reporting Format

### Finding Template
```markdown
## [CRITICAL] Non-Deterministic Map Iteration in EndBlocker

**Location**: `x/dex/abci.go:45-52`

**Description**:
The EndBlocker iterates over an unordered map to distribute rewards, causing different validators to process users in different orders and produce different state roots. This will halt the chain when validators fail to reach consensus.

**Vulnerable Code**:
```go
// abci.go, line 45
func EndBlocker(ctx sdk.Context, k keeper.Keeper) {
    rewards := k.GetPendingRewards(ctx)  // Returns map[string]sdk.Coins
    for user, amount := range rewards {  // NON-DETERMINISTIC ORDER
        k.bankKeeper.SendCoins(ctx, moduleAcc, user, amount)
    }
}
```

**Attack Scenario**:
1. Multiple users have pending rewards
2. Different validators iterate in different orders due to map randomization
3. If any reward distribution fails mid-iteration, state diverges
4. Validators produce different app hashes
5. Chain halts - cannot reach consensus

**Recommendation**:
Sort map keys before iteration:
```go
func EndBlocker(ctx sdk.Context, k keeper.Keeper) {
    rewards := k.GetPendingRewards(ctx)

    // Collect and sort keys for deterministic iteration
    users := make([]string, 0, len(rewards))
    for user := range rewards {
        users = append(users, user)
    }
    sort.Strings(users)  // Deterministic order

    // Process in sorted order
    for _, user := range users {
        k.bankKeeper.SendCoins(ctx, moduleAcc, user, rewards[user])
    }
}
```

**References**:
- building-secure-contracts/not-so-smart-contracts/cosmos/non_determinism
- Cosmos SDK docs: Determinism
```

---

## 7. Priority Guidelines

### Critical - CHAIN HALT Risk
- Non-determinism (any form)
- ABCI method panics
- Slow ABCI methods
- Incorrect GetSigners (allows unauthorized actions)

### High - Fund Loss Risk
- Missing error handling (bankKeeper.SendCoins)
- Broken bookkeeping (accounting mismatch)
- Missing message priority (oracle/emergency messages)

### Medium - Logic/DoS Risk
- Rounding errors (protocol value leakage)
- Unregistered message handlers (functionality broken)

---

## 8. Testing Recommendations

### Non-Determinism Testing
```bash
# Build for different architectures
GOARCH=amd64 go build
GOARCH=arm64 go build

# Run same operations, compare state roots
# Must be identical across architectures

# Fuzz test with concurrent operations
go test -fuzz=FuzzEndBlocker -parallel=10
```

### ABCI Benchmarking
```go
func BenchmarkBeginBlocker(b *testing.B) {
    ctx := setupMaximalState()  // Worst-case state
    b.ResetTimer()

    for i := 0; i < b.N; i++ {
        BeginBlocker(ctx, keeper)
    }

    // Must complete in < 1 second
    require.Less(b, b.Elapsed()/time.Duration(b.N), time.Second)
}
```

### Invariant Testing
```go
// Run invariants in integration tests
func TestInvariants(t *testing.T) {
    app := setupApp()

    // Execute operations
    app.DeliverTx(...)

    // Check invariants
    _, broken := keeper.AllInvariants()(app.Ctx)
    require.False(t, broken, "invariant violation detected")
}
```

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/cosmos/`
- **Cosmos SDK Docs**: https://docs.cosmos.network/
- **CodeQL for Go**: https://codeql.github.com/docs/codeql-language-guides/codeql-for-go/
- **Cosmos Security Best Practices**: https://github.com/cosmos/cosmos-sdk/blob/main/docs/docs/learn/advanced/17-determinism.md

---

## 10. Quick Reference Checklist

Before completing Cosmos chain audit:

**Non-Determinism (CRITICAL)**:
- [ ] No map iteration in consensus code
- [ ] No platform-dependent types (int, uint, float)
- [ ] No goroutines in message handlers/ABCI
- [ ] No select statements with multiple channels
- [ ] No rand, time.Now(), memory addresses
- [ ] All serialization is deterministic

**ABCI Methods (CRITICAL)**:
- [ ] BeginBlocker/EndBlocker computationally bounded
- [ ] No unbounded iterations
- [ ] No nested loops over large collections
- [ ] All panic-prone operations validated
- [ ] Benchmarked with maximum state

**Message Handling (HIGH)**:
- [ ] GetSigners() matches handler address usage
- [ ] All error returns checked
- [ ] Critical messages prioritized in CheckTx
- [ ] All message types registered

**Arithmetic & Accounting (MEDIUM)**:
- [ ] Multiply before divide pattern used
- [ ] Rounding favors protocol
- [ ] Custom bookkeeping synced with x/bank
- [ ] Invariant checks implemented

**Testing**:
- [ ] Cross-architecture builds tested
- [ ] ABCI methods benchmarked
- [ ] Invariants checked in CI
- [ ] Integration tests cover all messages

# guidelines-advisor

# Guidelines Advisor

## Purpose

Systematically analyzes the codebase and provides guidance based on Trail of Bits' development guidelines:

1. **Generate documentation and specifications** (plain English descriptions, architectural diagrams, code documentation)
2. **Optimize on-chain/off-chain architecture** (only if applicable)
3. **Review upgradeability patterns** (if your project has upgrades)
4. **Check delegatecall/proxy implementations** (if present)
5. **Assess implementation quality** (functions, inheritance, events)
6. **Identify common pitfalls**
7. **Review dependencies**
8. **Evaluate test suite and suggest improvements**

**Framework**: Building Secure Contracts - Development Guidelines

---

## How This Works

### Phase 1: Discovery & Context
Explores the codebase to understand:
- Project structure and platform
- Contract/module files and their purposes
- Existing documentation
- Architecture patterns (proxies, upgrades, etc.)
- Testing setup
- Dependencies

### Phase 2: Documentation Generation
Helps create:
- Plain English system description
- Architectural diagrams (using Slither printers for Solidity)
- Code documentation recommendations (NatSpec for Solidity)

### Phase 3: Architecture Analysis
Analyzes:
- On-chain vs off-chain component distribution (if applicable)
- Upgradeability approach (if applicable)
- Delegatecall proxy patterns (if present)

### Phase 4: Implementation Review
Assesses:
- Function composition and clarity
- Inheritance structure
- Event logging practices
- Common pitfalls presence
- Dependencies quality
- Testing coverage and techniques

### Phase 5: Recommendations
Provides:
- Prioritized improvement suggestions
- Best practice guidance
- Actionable next steps

---

## Assessment Areas

I analyze 11 comprehensive areas covering all aspects of smart contract development. For detailed criteria, best practices, and specific checks, see [ASSESSMENT_AREAS.md](resources/ASSESSMENT_AREAS.md).

### Quick Reference:

1. **Documentation & Specifications**
   - Plain English system descriptions
   - Architectural diagrams
   - NatSpec completeness (Solidity)
   - Documentation gaps identification

2. **On-Chain vs Off-Chain Computation**
   - Complexity analysis
   - Gas optimization opportunities
   - Verification vs computation patterns

3. **Upgradeability**
   - Migration vs upgradeability trade-offs
   - Data separation patterns
   - Upgrade procedure documentation

4. **Delegatecall Proxy Pattern**
   - Storage layout consistency
   - Initialization patterns
   - Function shadowing risks
   - Slither upgradeability checks

5. **Function Composition**
   - Function size and clarity
   - Logical grouping
   - Modularity assessment

6. **Inheritance**
   - Hierarchy depth/width
   - Diamond problem risks
   - Inheritance visualization

7. **Events**
   - Critical operation coverage
   - Event naming consistency
   - Indexed parameters

8. **Common Pitfalls**
   - Reentrancy patterns
   - Integer overflow/underflow
   - Access control issues
   - Platform-specific vulnerabilities

9. **Dependencies**
   - Library quality assessment
   - Version management
   - Dependency manager usage
   - Copied code detection

10. **Testing & Verification**
    - Coverage analysis
    - Fuzzing techniques
    - Formal verification
    - CI/CD integration

11. **Platform-Specific Guidance**
    - Solidity version recommendations
    - Compiler warning checks
    - Inline assembly warnings
    - Platform-specific tools

For complete details on each area including what I'll check, analyze, and recommend, see [ASSESSMENT_AREAS.md](resources/ASSESSMENT_AREAS.md).

---

## Example Output

When the analysis is complete, you'll receive comprehensive guidance covering:

- System documentation with plain English descriptions
- Architectural diagrams and documentation gaps
- Architecture analysis (on-chain/off-chain, upgradeability, proxies)
- Implementation review (functions, inheritance, events, pitfalls)
- Dependencies and testing evaluation
- Prioritized recommendations (CRITICAL, HIGH, MEDIUM, LOW)
- Overall assessment and path to production

For a complete example analysis report, see [EXAMPLE_REPORT.md](resources/EXAMPLE_REPORT.md).

---

## Deliverables

I provide four comprehensive deliverable categories:

### 1. System Documentation
- Plain English descriptions
- Architectural diagrams
- Documentation gaps analysis

### 2. Architecture Analysis
- On-chain/off-chain assessment
- Upgradeability review
- Proxy pattern security review

### 3. Implementation Review
- Function composition analysis
- Inheritance assessment
- Events coverage
- Pitfall identification
- Dependencies evaluation
- Testing analysis

### 4. Prioritized Recommendations
- CRITICAL (address immediately)
- HIGH (address before deployment)
- MEDIUM (address for production quality)
- LOW (nice to have)

For detailed templates and examples of each deliverable, see [DELIVERABLES.md](resources/DELIVERABLES.md).

---

## Assessment Process

When invoked, I will:

1. **Explore the codebase**
   - Identify all contract/module files
   - Find existing documentation
   - Locate test files
   - Check for proxies/upgrades
   - Identify dependencies

2. **Generate documentation**
   - Create plain English system description
   - Generate architectural diagrams (if tools available)
   - Identify documentation gaps

3. **Analyze architecture**
   - Assess on-chain/off-chain distribution (if applicable)
   - Review upgradeability approach (if applicable)
   - Audit proxy patterns (if present)

4. **Review implementation**
   - Analyze functions, inheritance, events
   - Check for common pitfalls
   - Assess dependencies
   - Evaluate testing

5. **Provide recommendations**
   - Present findings with file references
   - Ask clarifying questions about design decisions
   - Suggest prioritized improvements
   - Offer actionable next steps

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "System is simple, description covers everything" | Plain English descriptions miss security-critical details | Complete all 5 phases: documentation, architecture, implementation, dependencies, recommendations |
| "No upgrades detected, skip upgradeability section" | Upgradeability can be implicit (ownable patterns, delegatecall) | Search for proxy patterns, delegatecall, storage collisions before declaring N/A |
| "Not applicable" without verification | Premature scope reduction misses vulnerabilities | Verify with explicit codebase search before skipping any guideline section |
| "Architecture is straightforward, no analysis needed" | Obvious architectures have subtle trust boundaries | Analyze on-chain/off-chain distribution, access control flow, external dependencies |
| "Common pitfalls don't apply to this codebase" | Every codebase has common pitfalls | Systematically check all guideline pitfalls with grep/code search |
| "Tests exist, testing guideline is satisfied" | Test existence ≠ test quality | Check coverage, property-based tests, integration tests, failure cases |
| "I can provide generic best practices" | Generic advice isn't actionable | Provide project-specific findings with file:line references |
| "User knows what to improve from findings" | Findings without prioritization = no action plan | Generate prioritized improvement roadmap with specific next steps |

---

## Notes

- I'll only analyze relevant sections (won't hallucinate about upgrades if not present)
- I'll adapt to your platform (Solidity, Rust, Cairo, etc.)
- I'll use available tools (Slither, etc.) but work without them if unavailable
- I'll provide file references and line numbers for all findings
- I'll ask questions about design decisions I can't infer from code

---

## Ready to Begin

**What I'll need**:
- Access to your codebase
- Context about your project goals
- Any existing documentation or specifications
- Information about deployment plans

Let's analyze your codebase and improve it using Trail of Bits' best practices!

# secure-workflow-guide

# Secure Workflow Guide

## Purpose

Guides through Trail of Bits' secure development workflow - a 5-step process to enhance smart contract security throughout development.

**Use this**: On every check-in, before deployment, or when you want a security review

---

## The 5-Step Workflow

Covers a security workflow including:

### Step 1: Check for Known Security Issues
Run Slither with 70+ built-in detectors to find common vulnerabilities:
- Parse findings by severity
- Explain each issue with file references
- Recommend fixes
- Help triage false positives

**Goal**: Clean Slither report or documented triages

### Step 2: Check Special Features
Detect and validate applicable features:
- **Upgradeability**: slither-check-upgradeability (17 upgrade risks)
- **ERC conformance**: slither-check-erc (6 common specs)
- **Token integration**: Recommend token-integration-analyzer skill
- **Security properties**: slither-prop for ERC20

**Note**: Only runs checks that apply to your codebase

### Step 3: Visual Security Inspection
Generate 3 security diagrams:
- **Inheritance graph**: Identify shadowing and C3 linearization issues
- **Function summary**: Show visibility and access controls
- **Variables and authorization**: Map who can write to state variables

Review each diagram for security concerns

### Step 4: Document Security Properties
Help document critical security properties:
- State machine transitions and invariants
- Access control requirements
- Arithmetic constraints and precision
- External interaction safety
- Standards conformance

Then set up testing:
- **Echidna**: Property-based fuzzing with invariants
- **Manticore**: Formal verification with symbolic execution
- **Custom Slither checks**: Project-specific business logic

**Note**: Most important activity for security

### Step 5: Manual Review Areas
Analyze areas automated tools miss:
- **Privacy**: On-chain secrets, commit-reveal needs
- **Front-running**: Slippage protection, ordering risks, MEV
- **Cryptography**: Weak randomness, signature issues, hash collisions
- **DeFi interactions**: Oracle manipulation, flash loans, protocol assumptions

Search codebase for these patterns and flag risks

For detailed instructions, commands, and explanations for each step, see [WORKFLOW_STEPS.md](resources/WORKFLOW_STEPS.md).

---

## How I Work

When invoked, I will:

1. **Explore your codebase** to understand structure
2. **Run Step 1**: Slither security scan
3. **Detect and run Step 2**: Special feature checks (only what applies)
4. **Generate Step 3**: Visual security diagrams
5. **Guide Step 4**: Security property documentation
6. **Analyze Step 5**: Manual review areas
7. **Provide action plan**: Prioritized fixes and next steps

Adapts based on:
- What tools you have installed
- What's applicable to your project
- Where you are in development

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "Slither not available, I'll check manually" | Manual checking misses 70+ detector patterns | Install and run Slither, or document why it's blocked |
| "Can't generate diagrams, I'll describe the architecture" | Descriptions aren't visual - diagrams reveal patterns text misses | Execute slither --print commands, generate actual visual outputs |
| "No upgrades detected, skip upgradeability checks" | Proxies and upgrades are often implicit or planned | Verify with codebase search before skipping Step 2 checks |
| "Not a token, skip ERC checks" | Tokens can be integrated without obvious ERC inheritance | Check for token interactions, transfers, balances before skipping |
| "Can't set up Echidna now, suggesting it for later" | Property-based testing is Step 4, not optional | Document properties now, set up fuzzing infrastructure |
| "No DeFi interactions, skip oracle/flash loan checks" | DeFi patterns appear in unexpected places (price feeds, external calls) | Complete Step 5 manual review, search codebase for patterns |
| "This step doesn't apply to my project" | "Not applicable" without verification = missed vulnerabilities | Verify with explicit codebase search before declaring N/A |
| "I'll provide generic security advice instead of running workflow" | Generic advice isn't actionable, workflow finds specific issues | Execute all 5 steps, generate project-specific findings with file:line references |

---

## Example Output

When I complete the workflow, you'll get a comprehensive security report covering:

- **Step 1**: Slither findings with severity, file references, and fix recommendations
- **Step 2**: Special feature validation results (upgradeability, ERC conformance, etc.)
- **Step 3**: Visual diagrams analyzing inheritance, functions, and state variable authorization
- **Step 4**: Documented security properties and testing setup (Echidna/Manticore)
- **Step 5**: Manual review findings (privacy, front-running, cryptography, DeFi risks)
- **Action plan**: Critical/high/medium priority tasks with effort estimates
- **Workflow checklist**: Progress on all 5 steps

For a complete example workflow report, see [EXAMPLE_REPORT.md](resources/EXAMPLE_REPORT.md).

---

## What You'll Get

**Security Report**:
- Slither findings with severity and fixes
- Special feature validation results
- Visual diagrams (PNG/PDF)
- Manual review findings

**Action Plan**:
- [ ] Critical issues to fix immediately
- [ ] Security properties to document
- [ ] Testing to set up (Echidna/Manticore)
- [ ] Manual areas to review

**Workflow Checklist**:
- [ ] Clean Slither report
- [ ] Special features validated
- [ ] Visual inspection complete
- [ ] Properties documented
- [ ] Manual review done

---

## Getting Help

**Trail of Bits Resources**:
- Office Hours: Every Tuesday ([schedule](https://meetings.hubspot.com/trailofbits/office-hours))
- Empire Hacking Slack: #crytic and #ethereum channels

**Other Security**:
- Remember: Security is about more than smart contracts
- Off-chain security (owner keys, infrastructure) equally critical

---

## Ready to Start

Let me know when you're ready and I'll run through the workflow with your codebase!

# solana-vulnerability-scanner

# Solana Vulnerability Scanner

## 1. Purpose

Systematically scan Solana programs (native and Anchor framework) for platform-specific security vulnerabilities related to cross-program invocations, account validation, and program-derived addresses. This skill encodes 6 critical vulnerability patterns unique to Solana's account model.

## 2. When to Use This Skill

- Auditing Solana programs (native Rust or Anchor)
- Reviewing cross-program invocation (CPI) logic
- Validating program-derived address (PDA) implementations
- Pre-launch security assessment of Solana protocols
- Reviewing account validation patterns
- Assessing instruction introspection logic

## 3. Platform Detection

### File Extensions & Indicators
- **Rust files**: `.rs`

### Language/Framework Markers
```rust
// Native Solana program indicators
use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    pubkey::Pubkey,
    program::invoke,
    program::invoke_signed,
};

entrypoint!(process_instruction);

// Anchor framework indicators
use anchor_lang::prelude::*;

#[program]
pub mod my_program {
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        // Program logic
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub authority: Signer<'info>,
}

// Common patterns
AccountInfo, Pubkey
invoke(), invoke_signed()
Signer<'info>, Account<'info>
#[account(...)] with constraints
seeds, bump
```

### Project Structure
- `programs/*/src/lib.rs` - Program implementation
- `Anchor.toml` - Anchor configuration
- `Cargo.toml` with `solana-program` or `anchor-lang`
- `tests/` - Program tests

### Tool Support
- **Trail of Bits Solana Lints**: Rust linters for Solana
- Installation: Add to Cargo.toml
- **anchor test**: Built-in testing framework
- **Solana Test Validator**: Local testing environment

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for Solana/Anchor programs
2. **Analyze each program** for the 6 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Check account validation** and CPI security

---

## 5. Example Output

---

## 5. Vulnerability Patterns (6 Patterns)

I check for 6 critical vulnerability patterns unique to Solana. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Arbitrary CPI** ⚠️ CRITICAL - User-controlled program IDs in CPI calls
2. **Improper PDA Validation** ⚠️ CRITICAL - Using create_program_address without canonical bump
3. **Missing Ownership Check** ⚠️ HIGH - Deserializing accounts without owner validation
4. **Missing Signer Check** ⚠️ CRITICAL - Authority operations without is_signer check
5. **Sysvar Account Check** ⚠️ HIGH - Spoofed sysvar accounts (pre-Solana 1.8.1)
6. **Improper Instruction Introspection** ⚠️ MEDIUM - Absolute indexes allowing reuse

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).
## 5. Scanning Workflow

### Step 1: Platform Identification
1. Verify Solana program (native or Anchor)
2. Check Solana version (1.8.1+ for sysvar security)
3. Locate program source (`programs/*/src/lib.rs`)
4. Identify framework (native vs Anchor)

### Step 2: CPI Security Review
```bash
# Find all CPI calls
rg "invoke\(|invoke_signed\(" programs/

# Check for program ID validation before each
# Should see program ID checks immediately before invoke
```

For each CPI:
- [ ] Program ID validated before invocation
- [ ] Cannot pass user-controlled program accounts
- [ ] Anchor: Uses `Program<'info, T>` type

### Step 3: PDA Validation Check
```bash
# Find PDA usage
rg "find_program_address|create_program_address" programs/
rg "seeds.*bump" programs/

# Anchor: Check for seeds constraints
rg "#\[account.*seeds" programs/
```

For each PDA:
- [ ] Uses `find_program_address()` or Anchor `seeds` constraint
- [ ] Bump seed stored and reused
- [ ] Not using user-provided bump

### Step 4: Account Validation Sweep
```bash
# Find account deserialization
rg "try_from_slice|try_deserialize" programs/

# Should see owner checks before deserialization
rg "\.owner\s*==|\.owner\s*!=" programs/
```

For each account used:
- [ ] Owner validated before deserialization
- [ ] Signer check for authority accounts
- [ ] Anchor: Uses `Account<'info, T>` and `Signer<'info>`

### Step 5: Instruction Introspection Review
```bash
# Find instruction introspection usage
rg "load_instruction_at|load_current_index|get_instruction_relative" programs/

# Check for checked versions
rg "load_instruction_at_checked|load_current_index_checked" programs/
```

- [ ] Using checked functions (Solana 1.8.1+)
- [ ] Using relative indexing
- [ ] Proper correlation validation

### Step 6: Trail of Bits Solana Lints
```toml
# Add to Cargo.toml
[dependencies]
solana-program = "1.17"  # Use latest version

[lints.clippy]
# Enable Solana-specific lints
# (Trail of Bits solana-lints if available)
```

---

## 6. Reporting Format

### Finding Template
```markdown
## [CRITICAL] Arbitrary CPI - Unchecked Program ID

**Location**: `programs/vault/src/lib.rs:145-160` (withdraw function)

**Description**:
The `withdraw` function performs a CPI to transfer SPL tokens without validating that the provided `token_program` account is actually the SPL Token program. An attacker can provide a malicious program that appears to perform a transfer but actually steals tokens or performs unauthorized actions.

**Vulnerable Code**:
```rust
// lib.rs, line 145
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let token_program = &ctx.accounts.token_program;

    // WRONG: No validation of token_program.key()!
    invoke(
        &spl_token::instruction::transfer(...),
        &[
            ctx.accounts.vault.to_account_info(),
            ctx.accounts.destination.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            token_program.to_account_info(),  // UNVALIDATED
        ],
    )?;
    Ok(())
}
```

**Attack Scenario**:
1. Attacker deploys malicious "token program" that logs transfer instruction but doesn't execute it
2. Attacker calls withdraw() providing malicious program as token_program
3. Vault's authority signs the transaction
4. Malicious program receives CPI with vault's signature
5. Malicious program can now impersonate vault and drain real tokens

**Recommendation**:
Use Anchor's `Program<'info, Token>` type:
```rust
use anchor_spl::token::{Token, Transfer};

#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut)]
    pub vault: Account<'info, TokenAccount>,
    #[account(mut)]
    pub destination: Account<'info, TokenAccount>,
    pub authority: Signer<'info>,
    pub token_program: Program<'info, Token>,  // Validates program ID automatically
}

pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let cpi_accounts = Transfer {
        from: ctx.accounts.vault.to_account_info(),
        to: ctx.accounts.destination.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };

    let cpi_ctx = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        cpi_accounts,
    );

    anchor_spl::token::transfer(cpi_ctx, amount)?;
    Ok(())
}
```

**References**:
- building-secure-contracts/not-so-smart-contracts/solana/arbitrary_cpi
- Trail of Bits lint: `unchecked-cpi-program-id`
```

---

## 7. Priority Guidelines

### Critical (Immediate Fix Required)
- Arbitrary CPI (attacker-controlled program execution)
- Improper PDA validation (account spoofing)
- Missing signer check (unauthorized access)

### High (Fix Before Launch)
- Missing ownership check (fake account data)
- Sysvar account check (authentication bypass, pre-1.8.1)

### Medium (Address in Audit)
- Improper instruction introspection (logic bypass)

---

## 8. Testing Recommendations

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic]
    fn test_rejects_wrong_program_id() {
        // Provide wrong program ID, should fail
    }

    #[test]
    #[should_panic]
    fn test_rejects_non_canonical_pda() {
        // Provide non-canonical bump, should fail
    }

    #[test]
    #[should_panic]
    fn test_requires_signer() {
        // Call without signature, should fail
    }
}
```

### Integration Tests (Anchor)
```typescript
import * as anchor from "@coral-xyz/anchor";

describe("security tests", () => {
  it("rejects arbitrary CPI", async () => {
    const fakeTokenProgram = anchor.web3.Keypair.generate();

    try {
      await program.methods
        .withdraw(amount)
        .accounts({
          tokenProgram: fakeTokenProgram.publicKey, // Wrong program
        })
        .rpc();

      assert.fail("Should have rejected fake program");
    } catch (err) {
      // Expected to fail
    }
  });
});
```

### Solana Test Validator
```bash
# Run local validator for testing
solana-test-validator

# Deploy and test program
anchor test
```

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/solana/`
- **Trail of Bits Solana Lints**: https://github.com/trailofbits/solana-lints
- **Anchor Documentation**: https://www.anchor-lang.com/
- **Solana Program Library**: https://github.com/solana-labs/solana-program-library
- **Solana Cookbook**: https://solanacookbook.com/

---

## 10. Quick Reference Checklist

Before completing Solana program audit:

**CPI Security (CRITICAL)**:
- [ ] ALL CPI calls validate program ID before `invoke()`
- [ ] Cannot use user-provided program accounts
- [ ] Anchor: Uses `Program<'info, T>` type

**PDA Security (CRITICAL)**:
- [ ] PDAs use `find_program_address()` or Anchor `seeds` constraint
- [ ] Bump seed stored and reused (not user-provided)
- [ ] PDA accounts validated against canonical address

**Account Validation (HIGH)**:
- [ ] ALL accounts check owner before deserialization
- [ ] Native: Validates `account.owner == expected_program_id`
- [ ] Anchor: Uses `Account<'info, T>` type

**Signer Validation (CRITICAL)**:
- [ ] ALL authority accounts check `is_signer`
- [ ] Native: Validates `account.is_signer == true`
- [ ] Anchor: Uses `Signer<'info>` type

**Sysvar Security (HIGH)**:
- [ ] Using Solana 1.8.1+
- [ ] Using checked functions: `load_instruction_at_checked()`
- [ ] Sysvar addresses validated

**Instruction Introspection (MEDIUM)**:
- [ ] Using relative indexes for correlation
- [ ] Proper validation between related instructions
- [ ] Cannot reuse same instruction across multiple calls

**Testing**:
- [ ] Unit tests cover all account validation
- [ ] Integration tests with malicious inputs
- [ ] Local validator testing completed
- [ ] Trail of Bits lints enabled and passing

# substrate-vulnerability-scanner

# Substrate Vulnerability Scanner

## 1. Purpose

Systematically scan Substrate runtime modules (pallets) for platform-specific security vulnerabilities that can cause node crashes, DoS attacks, or unauthorized access. This skill encodes 7 critical vulnerability patterns unique to Substrate/FRAME-based chains.

## 2. When to Use This Skill

- Auditing custom Substrate pallets
- Reviewing FRAME runtime code
- Pre-launch security assessment of Substrate chains (Polkadot parachains, standalone chains)
- Validating dispatchable extrinsic functions
- Reviewing weight calculation functions
- Assessing unsigned transaction validation logic

## 3. Platform Detection

### File Extensions & Indicators
- **Rust files**: `.rs`

### Language/Framework Markers
```rust
// Substrate/FRAME indicators
#[pallet]
pub mod pallet {
    use frame_support::pallet_prelude::*;
    use frame_system::pallet_prelude::*;

    #[pallet::config]
    pub trait Config: frame_system::Config { }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        #[pallet::weight(10_000)]
        pub fn example_function(origin: OriginFor<T>) -> DispatchResult { }
    }
}

// Common patterns
DispatchResult, DispatchError
ensure!, ensure_signed, ensure_root
StorageValue, StorageMap, StorageDoubleMap
#[pallet::storage]
#[pallet::call]
#[pallet::weight]
#[pallet::validate_unsigned]
```

### Project Structure
- `pallets/*/lib.rs` - Pallet implementations
- `runtime/lib.rs` - Runtime configuration
- `benchmarking.rs` - Weight benchmarks
- `Cargo.toml` with `frame-*` dependencies

### Tool Support
- **cargo-fuzz**: Fuzz testing for Rust
- **test-fuzz**: Property-based testing framework
- **benchmarking framework**: Built-in weight calculation
- **try-runtime**: Runtime migration testing

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for Substrate pallets
2. **Analyze each pallet** for the 7 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Check weight calculations** and origin validation

---

## 5. Vulnerability Patterns (7 Critical Patterns)

I check for 7 critical vulnerability patterns unique to Substrate/FRAME. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Arithmetic Overflow** ⚠️ CRITICAL
   - Direct `+`, `-`, `*`, `/` operators wrap in release mode
   - Must use `checked_*` or `saturating_*` methods
   - Affects balance/token calculations, reward/fee math

2. **Don't Panic** ⚠️ CRITICAL - DoS
   - Panics cause node to stop processing blocks
   - No `unwrap()`, `expect()`, array indexing without bounds check
   - All user input must be validated with `ensure!`

3. **Weights and Fees** ⚠️ CRITICAL - DoS
   - Incorrect weights allow spam attacks
   - Fixed weights for variable-cost operations enable DoS
   - Must use benchmarking framework, bound all input parameters

4. **Verify First, Write Last** ⚠️ HIGH (Pre-v0.9.25)
   - Storage writes before validation persist on error (pre-v0.9.25)
   - Pattern: validate → write → emit event
   - Upgrade to v0.9.25+ or use manual `#[transactional]`

5. **Unsigned Transaction Validation** ⚠️ HIGH
   - Insufficient validation allows spam/replay attacks
   - Prefer signed transactions
   - If unsigned: validate parameters, replay protection, authenticate source

6. **Bad Randomness** ⚠️ MEDIUM
   - `pallet_randomness_collective_flip` vulnerable to collusion
   - Must use BABE randomness (`pallet_babe::RandomnessFromOneEpochAgo`)
   - Use `random(subject)` not `random_seed()`

7. **Bad Origin** ⚠️ CRITICAL
   - `ensure_signed` allows any user for privileged operations
   - Must use `ensure_root` or custom origins (ForceOrigin, AdminOrigin)
   - Origin types must be properly configured in runtime

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

---

## 6. Scanning Workflow

### Step 1: Platform Identification
1. Verify Substrate/FRAME framework usage
2. Check Substrate version (v0.9.25+ has transactional storage)
3. Locate pallet implementations (`pallets/*/lib.rs`)
4. Identify runtime configuration (`runtime/lib.rs`)

### Step 2: Dispatchable Analysis
For each `#[pallet::call]` function:
- [ ] Arithmetic: Uses checked/saturating operations?
- [ ] Panics: No unwrap/expect/indexing?
- [ ] Weights: Proportional to cost, bounded inputs?
- [ ] Origin: Appropriate validation level?
- [ ] Validation: All checks before storage writes?

### Step 3: Panic Sweep
```bash
# Search for panic-prone patterns
rg "unwrap\(\)" pallets/
rg "expect\(" pallets/
rg "\[.*\]" pallets/  # Array indexing
rg " as u\d+" pallets/  # Type casts
rg "\.unwrap_or" pallets/
```

### Step 4: Arithmetic Safety Check
```bash
# Find direct arithmetic
rg " \+ |\+=| - |-=| \* |\*=| / |/=" pallets/

# Should find checked/saturating alternatives instead
rg "checked_add|checked_sub|checked_mul|checked_div" pallets/
rg "saturating_add|saturating_sub|saturating_mul" pallets/
```

### Step 5: Weight Analysis
- [ ] Run benchmarking: `cargo test --features runtime-benchmarks`
- [ ] Verify weights match computational cost
- [ ] Check for bounded input parameters
- [ ] Review weight calculation functions

### Step 6: Origin & Privilege Review
```bash
# Find privileged operations
rg "ensure_signed" pallets/ | grep -E "pause|emergency|admin|force|sudo"

# Should use ensure_root or custom origins
rg "ensure_root|ForceOrigin|AdminOrigin" pallets/
```

### Step 7: Testing Review
- [ ] Unit tests cover all dispatchables
- [ ] Fuzz tests for panic conditions
- [ ] Benchmarks for weight calculation
- [ ] try-runtime tests for migrations

---

## 7. Priority Guidelines

### Critical (Immediate Fix Required)
- Arithmetic overflow (token creation, balance manipulation)
- Panic DoS (node crash risk)
- Bad origin (unauthorized privileged operations)

### High (Fix Before Launch)
- Incorrect weights (DoS via spam)
- Verify-first violations (state corruption, pre-v0.9.25)
- Unsigned validation issues (spam, replay attacks)

### Medium (Address in Audit)
- Bad randomness (manipulation possible but limited impact)

---

## 8. Testing Recommendations

### Fuzz Testing
```rust
// Use test-fuzz for property-based testing
#[cfg(test)]
mod tests {
    use test_fuzz::test_fuzz;

    #[test_fuzz]
    fn fuzz_transfer(from: AccountId, to: AccountId, amount: u128) {
        // Should never panic
        let _ = Pallet::transfer(from, to, amount);
    }

    #[test_fuzz]
    fn fuzz_no_panics(call: Call) {
        // No dispatchable should panic
        let _ = call.dispatch(origin);
    }
}
```

### Benchmarking
```bash
# Run benchmarks to generate weights
cargo build --release --features runtime-benchmarks
./target/release/node benchmark pallet \
    --chain dev \
    --pallet pallet_example \
    --extrinsic "*" \
    --steps 50 \
    --repeat 20
```

### try-runtime
```bash
# Test runtime upgrades
cargo build --release --features try-runtime
try-runtime --runtime ./target/release/wbuild/runtime.wasm \
    on-runtime-upgrade live --uri wss://rpc.polkadot.io
```

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/substrate/`
- **Substrate Documentation**: https://docs.substrate.io/
- **FRAME Documentation**: https://paritytech.github.io/substrate/master/frame_support/
- **test-fuzz**: https://github.com/trailofbits/test-fuzz
- **Substrate StackExchange**: https://substrate.stackexchange.com/

---

## 10. Quick Reference Checklist

Before completing Substrate pallet audit:

**Arithmetic Safety (CRITICAL)**:
- [ ] No direct `+`, `-`, `*`, `/` operators in dispatchables
- [ ] All arithmetic uses `checked_*` or `saturating_*`
- [ ] Type conversions use `try_into()` with error handling

**Panic Prevention (CRITICAL)**:
- [ ] No `unwrap()` or `expect()` in dispatchables
- [ ] No direct array/slice indexing without bounds check
- [ ] All user inputs validated with `ensure!`
- [ ] Division operations check for zero divisor

**Weights & DoS (CRITICAL)**:
- [ ] Weights proportional to computational cost
- [ ] Input parameters have maximum bounds
- [ ] Benchmarking used to determine weights
- [ ] No free (zero-weight) expensive operations

**Access Control (CRITICAL)**:
- [ ] Privileged operations use `ensure_root` or custom origins
- [ ] `ensure_signed` only for user-level operations
- [ ] Origin types properly configured in runtime
- [ ] Sudo pallet removed before production

**Storage Safety (HIGH)**:
- [ ] Using Substrate v0.9.25+ OR manual `#[transactional]`
- [ ] Validation before storage writes
- [ ] Events emitted after successful operations

**Other (MEDIUM)**:
- [ ] Unsigned transactions use signed alternative if possible
- [ ] If unsigned: proper validation, replay protection, authentication
- [ ] BABE randomness used (not RandomnessCollectiveFlip)
- [ ] Randomness uses `random(subject)` not `random_seed()`

**Testing**:
- [ ] Unit tests for all dispatchables
- [ ] Fuzz tests to find panics
- [ ] Benchmarks generated and verified
- [ ] try-runtime tests for migrations

# token-integration-analyzer

# Token Integration Analyzer

## Purpose

Systematically analyzes the codebase for token-related security concerns using Trail of Bits' token integration checklist:

1. **Token Implementations**: Analyze if your token follows ERC20/ERC721 standards or has non-standard behavior
2. **Token Integrations**: Analyze how your protocol handles arbitrary tokens, including weird/non-standard tokens
3. **On-chain Analysis**: Query deployed contracts for scarcity, distribution, and configuration
4. **Security Assessment**: Identify risks from 20+ known weird token patterns

**Framework**: Building Secure Contracts - Token Integration Checklist + Weird ERC20 Database

---

## How This Works

### Phase 1: Context Discovery
Determines analysis context:
- **Token implementation**: Are you building a token contract?
- **Token integration**: Does your protocol interact with external tokens?
- **Platform**: Ethereum, other EVM chains, or different platform?
- **Token types**: ERC20, ERC721, or both?

### Phase 2: Slither Analysis (if Solidity)
For Solidity projects, I'll help run:
- `slither-check-erc` - ERC conformity checks
- `slither --print human-summary` - Complexity and upgrade analysis
- `slither --print contract-summary` - Function analysis
- `slither-prop` - Property generation for testing

### Phase 3: Code Analysis
Analyzes:
- Contract composition and complexity
- Owner privileges and centralization risks
- ERC20/ERC721 conformity
- Known weird token patterns
- Integration safety patterns

### Phase 4: On-chain Analysis (if deployed)
If you provide a contract address, I'll query:
- Token scarcity and distribution
- Total supply and holder concentration
- Exchange listings
- On-chain configuration

### Phase 5: Risk Assessment
Provides:
- Identified vulnerabilities
- Non-standard behaviors
- Integration risks
- Prioritized recommendations

---

## Assessment Categories

I check 10 comprehensive categories covering all aspects of token security. For detailed criteria, patterns, and checklists, see [ASSESSMENT_CATEGORIES.md](resources/ASSESSMENT_CATEGORIES.md).

### Quick Reference:

1. **General Considerations** - Security reviews, team transparency, security contacts
2. **Contract Composition** - Complexity analysis, SafeMath usage, function count, entry points
3. **Owner Privileges** - Upgradeability, minting, pausability, blacklisting, team accountability
4. **ERC20 Conformity** - Return values, metadata, decimals, race conditions, Slither checks
5. **ERC20 Extension Risks** - External calls/hooks, transfer fees, rebasing/yield-bearing tokens
6. **Token Scarcity Analysis** - Supply distribution, holder concentration, exchange distribution, flash loan/mint risks
7. **Weird ERC20 Patterns** (24 patterns including):
   - Reentrant calls (ERC777 hooks)
   - Missing return values (USDT, BNB, OMG)
   - Fee on transfer (STA, PAXG)
   - Balance modifications outside transfers (Ampleforth, Compound)
   - Upgradable tokens (USDC, USDT)
   - Flash mintable (DAI)
   - Blocklists (USDC, USDT)
   - Pausable tokens (BNB, ZIL)
   - Approval race protections (USDT, KNC)
   - Revert on approval/transfer to zero address
   - Revert on zero value approvals/transfers
   - Multiple token addresses
   - Low decimals (USDC: 6, Gemini: 2)
   - High decimals (YAM-V2: 24)
   - transferFrom with src == msg.sender
   - Non-string metadata (MKR)
   - No revert on failure (ZRX, EURS)
   - Revert on large approvals (UNI, COMP)
   - Code injection via token name
   - Unusual permit function (DAI, RAI, GLM)
   - Transfer less than amount (cUSDCv3)
   - ERC-20 native currency representation (Celo, Polygon, zkSync)
   - [And more...](resources/ASSESSMENT_CATEGORIES.md#7-weird-erc20-patterns)
8. **Token Integration Safety** - Safe transfer patterns, balance verification, allowlists, wrappers, defensive patterns
9. **ERC721 Conformity** - Transfer to 0x0, safeTransferFrom, metadata, ownerOf, approval clearing, token ID immutability
10. **ERC721 Common Risks** - onERC721Received reentrancy, safe minting, burning approval clearing

---

## Example Output

When analysis is complete, you'll receive a comprehensive report structured as follows:

```
=== TOKEN INTEGRATION ANALYSIS REPORT ===

Project: MultiToken DEX
Token Analyzed: Custom Reward Token + Integration Safety
Platform: Solidity 0.8.20
Analysis Date: March 15, 2024

---

## EXECUTIVE SUMMARY

Token Type: ERC20 Implementation + Protocol Integrating External Tokens
Overall Risk Level: MEDIUM
Critical Issues: 2
High Issues: 3
Medium Issues: 4

**Top Concerns:**
⚠ Fee-on-transfer tokens not handled correctly
⚠ No validation for missing return values (USDT compatibility)
⚠ Owner can mint unlimited tokens without cap

**Recommendation:** Address critical/high issues before mainnet launch.

---

## 1. GENERAL CONSIDERATIONS

✓ Contract audited by CertiK (June 2023)
✓ Team contactable via security@project.com
✗ No security mailing list for critical announcements

**Risk:** Users won't be notified of critical issues
**Action:** Set up security@project.com mailing list

---

## 2. CONTRACT COMPOSITION

### Complexity Analysis

**Slither human-summary Results:**
- 456 lines of code
- Cyclomatic complexity: Average 6, Max 14 (transferWithFee())
- 12 functions, 8 state variables
- Inheritance depth: 3 (moderate)

✓ Contract complexity is reasonable
⚠ transferWithFee() complexity high (14) - consider splitting

### SafeMath Usage

✓ Using Solidity 0.8.20 (built-in overflow protection)
✓ No unchecked blocks found
✓ All arithmetic operations protected

### Non-Token Functions

**Functions Beyond ERC20:**
- setFeeCollector() - Admin function ✓
- setTransferFee() - Admin function ✓
- withdrawFees() - Admin function ✓
- pause()/unpause() - Emergency functions ✓

⚠ 4 non-token functions (acceptable but adds complexity)

### Address Entry Points

✓ Single contract address
✓ No proxy with multiple entry points
✓ No token migration creating address confusion

**Status:** PASS

---

## 3. OWNER PRIVILEGES

### Upgradeability

⚠ Contract uses TransparentUpgradeableProxy
**Risk:** Owner can change contract logic at any time

**Current Implementation:**
- ProxyAdmin: 0x1234... (2/3 multisig) ✓
- Timelock: None ✗

**Recommendation:** Add 48-hour timelock to all upgrades

### Minting Capabilities

❌ CRITICAL: Unlimited minting
File: contracts/RewardToken.sol:89
```solidity
function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);  // No cap!
}
```

**Risk:** Owner can inflate supply arbitrarily
**Fix:** Add maximum supply cap or rate-limited minting

### Pausability

✓ Pausable pattern implemented (OpenZeppelin)
✓ Only owner can pause
⚠ Paused state affects all transfers (including existing holders)

**Risk:** Owner can trap all user funds
**Mitigation:** Use multi-sig for pause function (already implemented ✓)

### Blacklisting

✗ No blacklist functionality
**Assessment:** Good - no centralized censorship risk

### Team Transparency

✓ Team members public (team.md)
✓ Company registered in Switzerland
✓ Accountable and contactable

**Status:** ACCEPTABLE

---

## 4. ERC20 CONFORMITY

### Slither-check-erc Results

Command: slither-check-erc . RewardToken --erc erc20

✓ transfer returns bool
✓ transferFrom returns bool
✓ name, decimals, symbol present
✓ decimals returns uint8 (value: 18)
✓ Race condition mitigated (increaseAllowance/decreaseAllowance)

**Status:** FULLY COMPLIANT

### slither-prop Test Results

Command: slither-prop . --contract RewardToken

**Generated 12 properties, all passed:**
✓ Transfer doesn't change total supply
✓ Allowance correctly updates
✓ Balance updates match transfer amounts
✓ No balance manipulation possible
[... 8 more properties ...]

**Echidna fuzzing:** 50,000 runs, no violations ✓

**Status:** EXCELLENT

---

## 5. WEIRD TOKEN PATTERN ANALYSIS

### Integration Safety Check

**Your Protocol Integrates 5 External Tokens:**
1. USDT (0xdac17f9...)
2. USDC (0xa0b86991...)
3. DAI (0x6b175474...)
4. WETH (0xc02aaa39...)
5. UNI (0x1f9840a8...)

### Critical Issues Found

❌ **Pattern 7.2: Missing Return Values**
**Found in:** USDT integration
File: contracts/Vault.sol:156
```solidity
IERC20(usdt).transferFrom(msg.sender, address(this), amount);
// No return value check! USDT doesn't return bool
```

**Risk:** Silent failures on USDT transfers
**Exploit:** User appears to deposit, but no tokens moved
**Fix:** Use OpenZeppelin SafeERC20 wrapper

---

❌ **Pattern 7.3: Fee on Transfer**
**Risk for:** Any token with transfer fees
File: contracts/Vault.sol:170
```solidity
uint256 balanceBefore = IERC20(token).balanceOf(address(this));
token.transferFrom(msg.sender, address(this), amount);
shares = amount * exchangeRate;  // WRONG! Should use actual received amount
```

**Risk:** Accounting mismatch if token takes fees
**Exploit:** User credited more shares than tokens deposited
**Fix:** Calculate shares from `balanceAfter - balanceBefore`

---

### Known Non-Standard Token Handling

✓ **USDC:** Properly handled (SafeERC20, 6 decimals accounted for)
⚠ **DAI:** permit() function not used (opportunity for gas savings)
✗ **USDT:** Missing return value not handled (CRITICAL)
✓ **WETH:** Standard wrapper, properly handled
⚠ **UNI:** Large approval handling not checked (reverts >= 2^96)

---

[... Additional sections for remaining analysis categories ...]
```

For complete report template and deliverables format, see [REPORT_TEMPLATES.md](resources/REPORT_TEMPLATES.md).

---

## Rationalizations (Do Not Skip)

| Rationalization | Why It's Wrong | Required Action |
|-----------------|----------------|-----------------|
| "Token looks standard, ERC20 checks pass" | 20+ weird token patterns exist beyond ERC20 compliance | Check ALL weird token patterns from database (missing return, revert on zero, hooks, etc.) |
| "Slither shows no issues, integration is safe" | Slither detects some patterns, misses integration logic | Complete manual analysis of all 5 token integration criteria |
| "No fee-on-transfer detected, skip that check" | Fee-on-transfer can be owner-controlled or conditional | Test all transfer scenarios, check for conditional fee logic |
| "Balance checks exist, handling is safe" | Balance checks alone don't protect against all weird tokens | Verify safe transfer wrappers, revert handling, approval patterns |
| "Token is deployed by reputable team, assume standard" | Reputation doesn't guarantee standard behavior | Analyze actual code and on-chain behavior, don't trust assumptions |
| "Integration uses OpenZeppelin, must be safe" | OpenZeppelin libraries don't protect against weird external tokens | Verify defensive patterns around all external token calls |
| "Can't run Slither, skipping automated analysis" | Slither provides critical ERC conformance checks | Manually verify all slither-check-erc criteria or document why blocked |
| "This pattern seems fine" | Intuition misses subtle token integration bugs | Systematically check all 20+ weird token patterns with code evidence |

---

## Deliverables

When analysis is complete, I'll provide:

1. **Compliance Checklist** - Checkboxes for all assessment categories
2. **Weird Token Pattern Analysis** - Presence/absence of all 24 patterns with risk levels and evidence
3. **On-chain Analysis Report** (if applicable) - Holder distribution, exchange listings, configuration
4. **Integration Safety Assessment** (if applicable) - Safe transfer usage, defensive patterns, weird token handling
5. **Prioritized Recommendations** - CRITICAL/HIGH/MEDIUM/LOW issues with specific fixes

Complete deliverable templates available in [REPORT_TEMPLATES.md](resources/REPORT_TEMPLATES.md).

---

## Ready to Begin

**What I'll need**:
- Your codebase
- Context: Token implementation or integration?
- Token type: ERC20, ERC721, or both?
- Contract address (if deployed and want on-chain analysis)
- RPC endpoint (if querying on-chain)

Let's analyze your token implementation or integration for security risks!

# ton-vulnerability-scanner

# TON Vulnerability Scanner

## 1. Purpose

Systematically scan TON blockchain smart contracts written in FunC for platform-specific security vulnerabilities related to boolean logic, Jetton token handling, and gas management. This skill encodes 3 critical vulnerability patterns unique to TON's architecture.

## 2. When to Use This Skill

- Auditing TON smart contracts (FunC language)
- Reviewing Jetton token implementations
- Validating token transfer notification handlers
- Pre-launch security assessment of TON dApps
- Reviewing gas forwarding logic
- Assessing boolean condition handling

## 3. Platform Detection

### File Extensions & Indicators
- **FunC files**: `.fc`, `.func`

### Language/Framework Markers
```func
;; FunC contract indicators
#include "imports/stdlib.fc";

() recv_internal(int my_balance, int msg_value, cell in_msg_full, slice in_msg_body) impure {
    ;; Contract logic
}

() recv_external(slice in_msg) impure {
    ;; External message handler
}

;; Common patterns
send_raw_message()
load_uint(), load_msg_addr(), load_coins()
begin_cell(), end_cell(), store_*()
transfer_notification operation
op::transfer, op::transfer_notification
.store_uint().store_slice().store_coins()
```

### Project Structure
- `contracts/*.fc` - FunC contract source
- `wrappers/*.ts` - TypeScript wrappers
- `tests/*.spec.ts` - Contract tests
- `ton.config.ts` or `wasm.config.ts` - TON project config

### Tool Support
- **TON Blueprint**: Development framework for TON
- **toncli**: CLI tool for TON contracts
- **ton-compiler**: FunC compiler
- Manual review primarily (limited automated tools)

---

## 4. How This Skill Works

When invoked, I will:

1. **Search your codebase** for FunC/Tact contracts
2. **Analyze each contract** for the 3 vulnerability patterns
3. **Report findings** with file references and severity
4. **Provide fixes** for each identified issue
5. **Check replay protection** and sender validation

---

## 5. Example Output

When vulnerabilities are found, you'll get a report like this:

```
=== TON VULNERABILITY SCAN RESULTS ===

Project: my-ton-contract
Files Scanned: 3 (.fc, .tact)
Vulnerabilities Found: 2

---

[CRITICAL] Missing Replay Protection
File: contracts/wallet.fc:45
Pattern: No sequence number or nonce validation


---

## 5. Vulnerability Patterns (3 Patterns)

I check for 3 critical vulnerability patterns unique to TON. For detailed detection patterns, code examples, mitigations, and testing strategies, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).

### Pattern Summary:

1. **Missing Sender Check** ⚠️ CRITICAL - No sender validation on privileged operations
2. **Integer Overflow** ⚠️ CRITICAL - Unchecked arithmetic in FunC
3. **Improper Gas Handling** ⚠️ HIGH - Insufficient gas reservations

For complete vulnerability patterns with code examples, see [VULNERABILITY_PATTERNS.md](resources/VULNERABILITY_PATTERNS.md).
## 5. Scanning Workflow

### Step 1: Platform Identification
1. Verify FunC language (`.fc` or `.func` files)
2. Check for TON Blueprint or toncli project structure
3. Locate contract source files
4. Identify Jetton-related contracts

### Step 2: Boolean Logic Review
```bash
# Find boolean-like variables
rg "int.*is_|int.*has_|int.*flag|int.*enabled" contracts/

# Check for positive integers used as booleans
rg "= 1;|return 1;" contracts/ | grep -E "is_|has_|flag|enabled|valid"

# Look for NOT operations on boolean-like values
rg "~.*\(|~ " contracts/
```

For each boolean:
- [ ] Uses -1 for true, 0 for false
- [ ] NOT using 1 or other positive integers
- [ ] Logic operations work correctly

### Step 3: Jetton Handler Analysis
```bash
# Find transfer_notification handlers
rg "transfer_notification|op::transfer_notification" contracts/
```

For each Jetton handler:
- [ ] Validates sender address
- [ ] Sender checked against stored Jetton wallet address
- [ ] Cannot trust forward_payload without sender validation
- [ ] Has admin function to set Jetton wallet address

### Step 4: Gas/Forward Amount Review
```bash
# Find forward amount usage
rg "forward_ton_amount|forward_amount" contracts/
rg "load_coins\(\)" contracts/

# Find send_raw_message calls
rg "send_raw_message" contracts/
```

For each outgoing message:
- [ ] Forward amounts are fixed/bounded
- [ ] OR user-provided amounts validated against msg_value
- [ ] Cannot drain contract balance
- [ ] Appropriate send_raw_message flags used

### Step 5: Manual Review
TON contracts require thorough manual review:
- Boolean logic with `~`, `&`, `|` operators
- Message parsing and validation
- Gas economics and fee calculations
- Storage operations and data serialization

---

## 6. Reporting Format

### Finding Template
```markdown
## [CRITICAL] Fake Jetton Contract - Missing Sender Validation

**Location**: `contracts/staking.fc:85-95` (recv_internal, transfer_notification handler)

**Description**:
The `transfer_notification` operation handler does not validate that the sender is the expected Jetton wallet contract. Any attacker can send a fake `transfer_notification` message claiming to have transferred tokens, crediting themselves without actually depositing any Jettons.

**Vulnerable Code**:
```func
// staking.fc, line 85
if (op == op::transfer_notification) {
    int jetton_amount = in_msg_body~load_coins();
    slice from_user = in_msg_body~load_msg_addr();

    ;; WRONG: No validation of sender_address!
    ;; Attacker can claim any jetton_amount

    credit_user(from_user, jetton_amount);
}
```

**Attack Scenario**:
1. Attacker deploys malicious contract
2. Malicious contract sends `transfer_notification` message to staking contract
3. Message claims attacker transferred 1,000,000 Jettons
4. Staking contract credits attacker without checking sender
5. Attacker can now withdraw from contract or gain benefits without depositing

**Proof of Concept**:
```typescript
// Attacker sends fake transfer_notification
const attackerContract = await blockchain.treasury("attacker");

await stakingContract.sendInternalMessage(attackerContract.getSender(), {
  op: OP_CODES.TRANSFER_NOTIFICATION,
  jettonAmount: toNano("1000000"), // Fake amount
  fromUser: attackerContract.address,
});

// Attacker successfully credited without sending real Jettons
const balance = await stakingContract.getUserBalance(attackerContract.address);
expect(balance).toEqual(toNano("1000000")); // Attack succeeded
```

**Recommendation**:
Store expected Jetton wallet address and validate sender:
```func
global slice jetton_wallet_address;

() recv_internal(...) impure {
    load_data();  ;; Load jetton_wallet_address from storage

    slice cs = in_msg_full.begin_parse();
    int flags = cs~load_uint(4);
    slice sender_address = cs~load_msg_addr();

    int op = in_msg_body~load_uint(32);

    if (op == op::transfer_notification) {
        ;; CRITICAL: Validate sender
        throw_unless(error::wrong_jetton_wallet,
            equal_slices(sender_address, jetton_wallet_address));

        int jetton_amount = in_msg_body~load_coins();
        slice from_user = in_msg_body~load_msg_addr();

        ;; Safe to credit user
        credit_user(from_user, jetton_amount);
    }
}
```

**References**:
- building-secure-contracts/not-so-smart-contracts/ton/fake_jetton_contract
```

---

## 7. Priority Guidelines

### Critical (Immediate Fix Required)
- Fake Jetton contract (unauthorized minting/crediting)

### High (Fix Before Launch)
- Integer as boolean (logic errors, broken conditions)
- Forward TON without gas check (balance drainage)

---

## 8. Testing Recommendations

### Unit Tests
```typescript
import { Blockchain } from "@ton/sandbox";
import { toNano } from "ton-core";

describe("Security tests", () => {
  let blockchain: Blockchain;
  let contract: Contract;

  beforeEach(async () => {
    blockchain = await Blockchain.create();
    contract = blockchain.openContract(await Contract.fromInit());
  });

  it("should use correct boolean values", async () => {
    // Test that TRUE = -1, FALSE = 0
    const result = await contract.getFlag();
    expect(result).toEqual(-1n); // True
    expect(result).not.toEqual(1n); // Not 1!
  });

  it("should reject fake jetton transfer", async () => {
    const attacker = await blockchain.treasury("attacker");

    const result = await contract.send(
      attacker.getSender(),
      { value: toNano("0.05") },
      {
        $$type: "TransferNotification",
        query_id: 0n,
        amount: toNano("1000"),
        from: attacker.address,
      }
    );

    expect(result.transactions).toHaveTransaction({
      success: false, // Should reject
    });
  });

  it("should validate gas for forward amount", async () => {
    const result = await contract.send(
      user.getSender(),
      { value: toNano("0.01") }, // Insufficient gas
      {
        $$type: "Transfer",
        to: recipient.address,
        forward_ton_amount: toNano("1"), // Trying to forward 1 TON
      }
    );

    expect(result.transactions).toHaveTransaction({
      success: false,
    });
  });
});
```

### Integration Tests
```typescript
// Test with real Jetton wallet
it("should accept transfer from real jetton wallet", async () => {
  // Deploy actual Jetton minter and wallet
  const jettonMinter = await blockchain.openContract(JettonMinter.create());
  const userJettonWallet = await jettonMinter.getWalletAddress(user.address);

  // Set jetton wallet in contract
  await contract.setJettonWallet(userJettonWallet);

  // Real transfer from Jetton wallet
  const result = await userJettonWallet.sendTransfer(
    user.getSender(),
    contract.address,
    toNano("100"),
    {}
  );

  expect(result.transactions).toHaveTransaction({
    to: contract.address,
    success: true,
  });
});
```

---

## 9. Additional Resources

- **Building Secure Contracts**: `building-secure-contracts/not-so-smart-contracts/ton/`
- **TON Documentation**: https://docs.ton.org/
- **FunC Documentation**: https://docs.ton.org/develop/func/overview
- **TON Blueprint**: https://github.com/ton-org/blueprint
- **Jetton Standard**: https://github.com/ton-blockchain/TEPs/blob/master/text/0074-jettons-standard.md

---

## 10. Quick Reference Checklist

Before completing TON contract audit:

**Boolean Logic (HIGH)**:
- [ ] All boolean values use -1 (true) and 0 (false)
- [ ] NO positive integers (1, 2, etc.) used as booleans
- [ ] Functions returning booleans return -1 for true
- [ ] Boolean logic with `~`, `&`, `|` uses correct values
- [ ] Tests verify boolean operations work correctly

**Jetton Security (CRITICAL)**:
- [ ] `transfer_notification` handler validates sender address
- [ ] Sender checked against stored Jetton wallet address
- [ ] Jetton wallet address stored during initialization
- [ ] Admin function to set/update Jetton wallet
- [ ] Cannot trust forward_payload without sender validation
- [ ] Tests with fake Jetton contracts verify rejection

**Gas & Forward Amounts (HIGH)**:
- [ ] Forward TON amounts are fixed/bounded
- [ ] OR user-provided amounts validated: `msg_value >= tx_fee + forward_amount`
- [ ] Contract balance protected from drainage
- [ ] Appropriate `send_raw_message` flags used
- [ ] Tests verify cannot drain contract with excessive forward amounts

**Testing**:
- [ ] Unit tests for all three vulnerability types
- [ ] Integration tests with real Jetton contracts
- [ ] Gas cost analysis for all operations
- [ ] Testnet deployment before mainnet
