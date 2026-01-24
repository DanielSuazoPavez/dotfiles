---
name: qa-test-planner
description: Generate test plans, manual test cases, regression suites, and bug reports. Use when planning testing strategy, writing test cases, building regression suites, or documenting bugs.
disable-model-invocation: true
---

# QA Test Planner

Create comprehensive testing documentation.

## Deliverables

| Task | Output | Time |
|------|--------|------|
| Test Plan | Strategy, scope, schedule, risks | 10-15 min |
| Test Cases | Step-by-step with expected results | 5-10 min each |
| Regression Suite | Smoke tests, critical paths | 15-20 min |
| Bug Report | Reproducible steps, evidence | 5 min |

## Test Case Template

```markdown
## TC-001: [Title]

**Priority:** P0/P1/P2/P3
**Type:** Functional | UI | Integration

### Preconditions
- [Setup requirement]
- [Test data needed]

### Steps
1. [Action]
   **Expected:** [Result]

2. [Action]
   **Expected:** [Result]

### Test Data
- Input: [values]
- User: [test account]
```

## Bug Report Template

```markdown
# BUG-[ID]: [Clear title]

**Severity:** Critical | High | Medium | Low
**Priority:** P0 | P1 | P2 | P3

## Environment
- OS: [Windows 11, macOS, etc.]
- Browser: [Chrome 120, etc.]
- Build: [version]

## Steps to Reproduce
1. [Specific step]
2. [Specific step]

## Expected
[What should happen]

## Actual
[What happens]

## Evidence
- Screenshot: [attached]
- Console errors: [if any]
```

## Severity Definitions

| Level | Criteria | Example |
|-------|----------|---------|
| Critical (P0) | System crash, data loss, security | Payment fails |
| High (P1) | Major feature broken, no workaround | Search broken |
| Medium (P2) | Feature partial, workaround exists | Filter missing option |
| Low (P3) | Cosmetic, rare edge cases | Typo, alignment |

## Regression Suite Types

| Suite | Duration | When | Coverage |
|-------|----------|------|----------|
| Smoke | 15-30 min | Daily | Critical paths |
| Targeted | 30-60 min | Per change | Affected areas |
| Full | 2-4 hours | Weekly/Release | Comprehensive |
| Sanity | 10-15 min | After hotfix | Quick validation |

## Pass/Fail Criteria

**PASS:**
- All P0 tests pass
- 90%+ P1 tests pass
- No critical bugs open

**FAIL (Block Release):**
- Any P0 test fails
- Critical bug discovered
- Security vulnerability

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Vague steps | Specific actions + expected results |
| Missing preconditions | Document all setup |
| No test data | Provide sample data |
| Generic bug titles | Specific: "[Feature] issue when [action]" |
| Skip edge cases | Include boundary values |

## Test Plan Outline

1. **Scope**: In/out of scope
2. **Strategy**: Test types, approach
3. **Environment**: OS, browsers, devices
4. **Entry Criteria**: When to start testing
5. **Exit Criteria**: When testing is done
6. **Risks**: What could go wrong

## Checklist

**Test Plan:**
- [ ] Scope clearly defined
- [ ] Entry/exit criteria specified
- [ ] Risks identified

**Test Cases:**
- [ ] Each step has expected result
- [ ] Preconditions documented
- [ ] Priority assigned

**Bug Reports:**
- [ ] Reproducible steps
- [ ] Environment documented
- [ ] Evidence attached
