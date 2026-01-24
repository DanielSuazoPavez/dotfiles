---
name: list-memories
description: List available memories with their Quick Reference summaries. Use to discover relevant context without loading full files into conversation.
allowed-tools: Bash(for f in *)
---

# List Memories

Preview available memories without loading full content.

## Instructions

Run this command to extract only Quick Reference sections:

```bash
for f in .claude/memories/*.md; do
  echo "### $(basename "$f" .md)"
  sed -n '/^## .*Quick Reference/,/^## /{/^## .*Quick Reference/d;/^## /d;p}' "$f" 2>/dev/null
  echo "---"
done
```

## Decision Tree: What to Load

### By Task Type

| Task | Load | Skip |
|------|------|------|
| **New feature** | `essential-*`, architecture | `idea-*`, unrelated areas |
| **Bug fix** | `essential-*`, affected area only | Everything else |
| **Refactor** | `essential-conventions-*` | `idea-*`, `branch-*` |
| **Quick question** | Just Quick Reference | Don't load full files |
| **Continue branch work** | `branch-*` for that branch | Other branches |

### Prioritization

1. **Essential** - Always relevant (conventions, architecture)
2. **Area-specific** - Only if touching that area
3. **Branch** - Only if continuing that specific work
4. **Idea** - Only if exploring that direction

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| **Load Everything** | Wastes context on irrelevant info | Use Quick Reference to filter |
| **Skip Essential** | Make mistakes the memory prevents | Always check essential-* |
| **Ignore Quick Reference** | Load full file for one fact | Read summary first |
| **Stale Branch Memories** | Loading old branch context | Check if branch still active |

## After Running

Based on Quick References, load only relevant full memories:
```
Read .claude/memories/<memory-name>.md
```
