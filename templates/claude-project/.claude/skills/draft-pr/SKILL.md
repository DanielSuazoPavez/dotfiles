---
name: draft-pr
description: Generate a pull request description. Use after /wrap-up when ready to create a PR. Analyzes branch commits and generates a PR description.
disable-model-invocation: true
---

Generate a pull request description for the current branch.

## Instructions

1. **Analyze the branch**:
   - Review commits since branching from main: `git log main..HEAD --oneline`
   - Check changed files: `git diff main --stat`
   - Read CHANGELOG.md for the latest entry (created by /wrap-up)

2. **Generate PR description** following this structure:

```markdown
## Description
[Concise summary of what this PR does]

## Motivation and Context
[Why this change is needed - problem it solves or feature it adds]

## How has this been tested?
[Testing approach - manual, automated, or N/A with reason]

## Checklist
- [ ] Include changes in the root `CHANGELOG.md`
- [ ] Bumped package version in the `pyproject.toml`
- [ ] Update tests
- [ ] Update documentation
```

3. **Output** the PR description to console (ready to copy/paste into GitHub)

## Notes

- Run `/wrap-up` first to update changelog and version
- Keep description concise - details are in the changelog
- Reference issue numbers if applicable: `Fixes #123`
- Check off completed checklist items with `[x]`
