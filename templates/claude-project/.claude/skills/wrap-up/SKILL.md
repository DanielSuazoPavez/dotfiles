---
name: wrap-up
description: Use when finishing work on a feature branch or ending a session. Updates changelog, bumps version, updates backlog, commits changes, and optionally creates a handoff document for session continuity.
disable-model-invocation: true
---

Use when finishing a feature branch or ending a session.

## Instructions

### 1. Check for uncommitted code changes
- Run `git status` to check for uncommitted changes
- If there are uncommitted code changes (src/, tests/, etc.):
  - Review the changes with `git diff`
  - Commit them first with an appropriate message (feat:, fix:, refactor:, test:, etc.)
- Skip if only docs files are modified

### 2. Analyze the branch
Review commits since branching from main to understand what was done.

### 3. Determine version bump
Read current version from `pyproject.toml` and increment:
- **Major** (X.0.0): Breaking changes
- **Minor** (0.X.0): New features (default)
- **Patch** (0.0.X): Bug fixes only

### 4. Update `CHANGELOG.md`
Add new entry at the top:
```markdown
## [X.Y.Z] - YYYY-MM-DD - Short Title

### Added
- Feature description

### Changed / Fixed
- Description
```

### 5. Update `pyproject.toml`
Bump the `version` field.

### 6. Update `BACKLOG.md`
- Move completed items to "Recently Completed"
- Add any new backlog items discovered

### 7. Commit documentation changes
```bash
git add CHANGELOG.md pyproject.toml BACKLOG.md uv.lock
git commit -m "docs: update changelog, version X.Y.Z, backlog"
```

### 8. Create session handoff (if ending session)
If this is the end of a work session (not just a feature), create a handoff document:

**Path:** `docs/sessions/YYYY-MM-DD_HHMM_{slug}.md`

```markdown
# Session: {Brief Title}

## Branch
`{branch-name}` - {one-line description}

## Work Completed
- [Bullet points of what was done]

## Current State
- [Where things stand now]
- [Any in-progress items]

## Key Decisions Made
- [Decision]: [Reasoning]

## Next Steps
1. [Immediate next action]
2. [Follow-up items]

## Context for Next Session
- [Critical context the next session needs]
- [Files to look at first]
- [Gotchas or things to remember]
```

### 9. Report summary
Output what was updated and any handoff created.

## Handoff Staleness Guide

When resuming from a handoff:

| Age | Status | Action |
|-----|--------|--------|
| < 24h | Fresh | Resume directly |
| 1-3 days | Slightly stale | Quick context check |
| 3-7 days | Stale | Verify state matches |
| > 7 days | Very stale | Re-analyze before continuing |

## Notes

- Uncommitted code changes are committed first, then docs/version updates
- The `uv-lock` pre-commit hook will auto-update `uv.lock` on version change
- If commit fails due to hooks, re-run the commit
- Handoff documents are optional - use when context preservation matters
