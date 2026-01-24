# Task Completion Workflow

## Quick Reference

**ONLY READ WHEN:**
- About to complete a task
- Running final checks before marking work as done

---

## Code Quality Checks (Mandatory)

```bash
pre-commit run --all-files
```

---

## Final Checklist

- Pre-commit passes
- Changes follow project conventions
- No breaking changes introduced
- Documentation updated (if applicable)

---

## Bug Fix Guidelines

When fixing bugs:
- Directly replace buggy code with correct implementation
- Do NOT add backward compatibility layers for the broken version
