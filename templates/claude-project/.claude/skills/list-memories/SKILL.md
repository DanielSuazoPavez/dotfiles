---
name: list-memories
description: List available memories with their Quick Reference summaries. Use to discover relevant context without loading full files into conversation.
allowed-tools: Bash(for f in *), Bash(sed *)
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

## Output

Shows each memory name with its Quick Reference summary:

```
### essential-conventions-code_style
- Use snake_case for functions
- Classes use PascalCase
- ...
---
### philosophy-reducing_entropy
- Measure final code amount, not effort
- ...
---
```

## After Running

Based on the Quick References, decide which full memories to read:
```
Read .claude/memories/<memory-name>.md
```

Only load full memories when their Quick Reference indicates relevance to the current task.
