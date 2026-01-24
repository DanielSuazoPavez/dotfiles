---
name: list-memories
description: List project memories with their Quick Reference sections. Use to discover available context before reading full memories.
---

# List Memories Skill

## Purpose

Discover and preview project memories without loading full content into context.

## Instructions

When this skill is invoked:

1. **List all memories** in `.claude/memories/` directory
2. **Extract Quick Reference** section from each (the content between `## 1. Quick Reference` and `## 2.`)
3. **Display** memory names with their Quick Reference summaries

## Output Format

For each memory file:
```
### <memory-name>
<Quick Reference content>
---
```

## Implementation

```bash
# List memories and extract Quick Reference sections
for file in .claude/memories/*.md; do
  name=$(basename "$file" .md)
  echo "### $name"
  # Extract content between "## 1. Quick Reference" and "## 2."
  sed -n '/^## 1\. Quick Reference/,/^## 2\./p' "$file" | head -n -1 | tail -n +2
  echo "---"
done
```

## When to Use

- At session start to understand available context
- When unsure which memory contains relevant information
- Before reading a full memory to confirm relevance

## After Running

Based on the Quick References, decide which full memories to read using:
```
Read .claude/memories/<memory-name>.md
```
