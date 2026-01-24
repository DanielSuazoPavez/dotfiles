---
name: next-steps
description: Preserve context before /clear. Generates a continuation file for resuming work in a new session.
---

Use before /clear to preserve context. Generates a continuation file for resuming work in a new session.

## Output

`docs/sessions/YYYY-MM-DD_HHmm_continue.md` - self-contained file to restore context after `/clear`.

## Instructions

### 1. Gather Context

Run these in parallel:
```bash
# Current branch and recent commits
git branch --show-current
git log --oneline -5

# Recent changes (uncommitted)
git status --short

# Recently modified files (last hour)
find . -name "*.py" -o -name "*.md" | xargs ls -lt 2>/dev/null | head -15
```

### 2. Generate the Continuation File

Create `docs/sessions/YYYY-MM-DD_HHmm_continue.md` with this structure:

```markdown
# Continue Session: [Date] [Time]

## Branch
`[branch-name]` - [brief description of what's being worked on]

## Recent Work
- [What was just done in bullet points]
- [Key changes made]

## Key Files
- `path/to/file.py` - [why it's relevant]
- `path/to/other.py` - [why it's relevant]

## Memories to Load
- `essential-preferences-conversational_patterns` - communication style
- [Other relevant memories based on the work]

## Reports/Docs
- `docs/reports/[relevant-report].md` - [what it contains]
- `backlog_[project].md` - active backlog

## Next Steps
1. [Immediate next action]
2. [Following action]
3. [Or: See `backlog_[project].md` section X]

## Context Notes
[Any important context that wouldn't be obvious from files alone]
```

### 3. Guidelines

- **Be concise**: This is a restoration file, not documentation
- **Prioritize actionable info**: What files to read, what to do next
- **Include backlog reference**: Point to specific backlog sections if applicable
- **Skip obvious context**: Don't repeat what's in CLAUDE.md
- **Use relative paths**: Keep it portable

### 4. Output

1. Create directory if needed: `mkdir -p docs/sessions`
2. Write the file to `docs/sessions/YYYY-MM-DD_HHmm_continue.md`
3. Report with copy-paste ready path for new session:

```
Wrote continuation file.

To resume in a new session, paste:
read docs/sessions/YYYY-MM-DD_HHmm_continue.md
```

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **The Novel** | 500+ line continuation file | Focus on actionable context only |
| **Stale Files** | Old continuation files pile up | Delete after resuming |
| **Missing Branch** | Forgot to note current branch | Always include branch name |
| **No Next Steps** | Context but no direction | List 1-3 immediate actions |
