---
name: draft-pr
description: Generate a pull request description. Use after /wrap-up when ready to create a PR. Analyzes branch commits and generates a PR description.
disable-model-invocation: true
---

# Draft PR

Generate a pull request description for the current branch.

## Instructions

1. **Analyze the branch**:
   - Review commits since branching from main: `git log main..HEAD --oneline`
   - Check changed files: `git diff main --stat`
   - Read CHANGELOG.md for the latest entry (created by /wrap-up)

2. **Check PR size** (see sizing guidance below)

3. **Generate PR description** following this structure:

```markdown
## Summary
[2-3 sentences: what and why]

## Changes
- [Key change 1]
- [Key change 2]

## Testing
[How you verified it works]
```

4. **Output** the PR description to console (ready to copy/paste)

## PR Sizing - The Hard Rule

| Lines Changed | Action |
|---------------|--------|
| <200 | Ship it |
| 200-400 | Review scope - can it split? |
| 400-600 | Should split unless tightly coupled |
| >600 | Must split - find the seam |

### How to Split

1. **By layer**: API changes → Backend logic → Frontend
2. **By feature slice**: Core feature → Edge cases → Polish
3. **By risk**: Safe refactors → Behavioral changes
4. **Stacked PRs**: PR1 (base) → PR2 (builds on PR1) → PR3

### Split Decision Tree

```
Is the PR >400 lines?
├─ No → Ship it
└─ Yes → Are all changes tightly coupled?
    ├─ Yes → Document why in PR, ship it
    └─ No → Find the seam:
        ├─ Different files/areas? → Split by area
        ├─ Refactor + feature? → Refactor PR first
        └─ Multiple features? → One feature per PR
```

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **The Mega-PR** | 1500 lines, "it's all connected" | It's not. Find the seam. |
| **The Empty PR** | "Fixed bug" | Add context: what bug, why it happened |
| **The Novel** | 5 paragraphs explaining the diff | Summary should add context, not repeat code |
| **The Commit Dump** | Copy-pasted commit messages | Synthesize into coherent narrative |

## The Test

> Can a reviewer understand the WHY in 30 seconds and review in one sitting?

If no → split or improve description.

## Notes

- Run `/wrap-up` first to update changelog and version
- Reference issue numbers: `Fixes #123`
- Smaller PRs = faster reviews = faster merges
