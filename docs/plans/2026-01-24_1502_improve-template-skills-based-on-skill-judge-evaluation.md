# Plan: Improve Template Skills Based on Skill-Judge Evaluation

## Task
Apply skill-judge suggestions to 6 skills: add anti-patterns (high-impact) and frontmatter (quick wins).

## Tracking Table

| Skill | Before | After | Change |
|-------|--------|-------|--------|
| write-memory | B+ (87) | ? | +anti-patterns |
| wrap-up | A- (96) | ? | +anti-patterns |
| mermaid-diagrams | B (85) | ? | +anti-patterns, +decision tree |
| analyze-idea | B- (78) | ? | +frontmatter, +anti-patterns |
| next-steps | B (82) | ? | +frontmatter |
| git-worktrees | B+ (88) | ? | +frontmatter |

## High-Impact Fixes

### 1. write-memory (+anti-patterns)
Add after "Notes" section:
```markdown
## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **One-off Info** | Memory for temporary facts | Use session handoff or inline comment |
| **Duplicate Memory** | Topic already has a memory | Update existing memory instead |
| **No Quick Reference** | Full file must be loaded | Always add Quick Reference section |
| **Wrong Category** | Using `essential-` for WIP | Match category to stability |
| **Giant Memory** | 500+ lines, everything included | Split into focused memories |
```

### 2. wrap-up (+anti-patterns)
Add before "Notes" section:
```markdown
## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **Skip Code Commit** | Docs committed with code changes | Always commit code first, then docs |
| **Wrong Bump** | Patch for new feature | Major=breaking, Minor=feature, Patch=fix |
| **Empty Changelog** | "Updated stuff" | Describe what changed and why |
| **Stale Backlog** | Completed items still in TODO | Move to "Recently Completed" |
| **No Handoff** | Ending multi-day work without context | Create handoff for sessions >2h |
```

### 3. mermaid-diagrams (+anti-patterns, +decision tree)
Add after "Diagram Type Selection" table:
```markdown
## When to Use Which

```
What are you showing?
├─ Data relationships → ERD
├─ Object structure → Class Diagram
├─ Time-based flow → Sequence Diagram
├─ Process/algorithm → Flowchart
├─ System boundaries → C4 Diagram
└─ State transitions → State Diagram
```
```

Add before "Rendering" section:
```markdown
## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **The Kitchen Sink** | 50+ nodes, unreadable | Split into multiple diagrams |
| **Wrong Abstraction** | ERD for process flow | Match diagram type to content |
| **Missing Legend** | Custom notation unexplained | Add `%% Legend:` comment |
| **Dead Diagram** | Code changed, diagram didn't | Store near code, update together |
| **Over-Detailed** | Implementation details in architecture | Match detail level to audience |
```

## Quick Wins

### 4. analyze-idea (+frontmatter)
Add at top:
```markdown
---
name: analyze-idea
description: Research and exploration tasks. Investigates a topic, gathers evidence, and generates a saved report. Use for feasibility analysis, coverage gaps, codebase audits.
---
```

Also add anti-patterns after "Notes":
```markdown
## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **Analysis Paralysis** | Investigating forever | Set scope, timebox, deliver findings |
| **Confirmation Bias** | Only finding evidence for hypothesis | Actively seek counter-evidence |
| **Shallow Investigation** | Surface-level grep | Trace code paths, check tests, read commits |
| **No Evidence** | "I think X is true" | Include file paths, line numbers, metrics |
```

### 5. next-steps (+frontmatter)
Add at top:
```markdown
---
name: next-steps
description: Preserve context before /clear. Generates a continuation file for resuming work in a new session.
---
```

### 6. git-worktrees (+frontmatter)
Add at top:
```markdown
---
name: git-worktrees
description: Reference for git worktrees - setup, usage, and common pitfalls. Use when working on multiple branches simultaneously or setting up parallel agent workflows.
---
```

## Files to Modify

All in `templates/claude-project/.claude/skills/`:
- `write-memory/SKILL.md`
- `wrap-up/SKILL.md`
- `mermaid-diagrams/SKILL.md`
- `analyze-idea/SKILL.md`
- `next-steps/SKILL.md`
- `git-worktrees/SKILL.md`

## Verification

1. After edits, run skill-judge on all 6 modified skills
2. Update tracking table with new scores
3. Commit changes
