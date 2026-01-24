# Task Completion Workflow

## Quick Reference

Verify change works → run tests → run pre-commit → check conventions.

---

## Completion Steps

### 1. Verify the Change Works
- Test the actual functionality you modified
- Confirm expected behavior with concrete evidence

### 2. Run Tests
```bash
# Project-specific test command (e.g., pytest, npm test, make test)
```

### 3. Run Pre-commit
```bash
pre-commit run --all-files
```

**PLR09XX errors (too many branches/statements):**
- If genuinely complex logic: add `# noqa: PLR09XX` with comment explaining why
- If refactorable: simplify the code instead of suppressing

### 4. Final Checklist
- [ ] Change works as intended
- [ ] Tests pass
- [ ] Pre-commit passes
- [ ] No breaking changes introduced
- [ ] Documentation updated (see below)

---

## When to Update Documentation

**Update when:** API changes, config changes, architectural changes

**Do NOT:** Create proactive READMEs, document unchanged code
