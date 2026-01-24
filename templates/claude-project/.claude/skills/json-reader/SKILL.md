---
name: json-reader
description: Process and analyze JSON files using jq commands instead of reading entire files. Use for inspecting, filtering, transforming JSON structures, and extracting specific data without loading large files into context.
---

# JSON Reader Skill

## Purpose

When working with JSON files, use jq for efficient, targeted querying instead of the Read tool.

## Core Instructions

### 1. Default to jq for JSON Operations

When you encounter a JSON file request:
- DON'T use the Read tool on JSON files
- DO use jq commands with Bash
- This applies even if the file seems small

### 2. Progressive Inspection Pattern

```bash
# Step 1: Understand structure
jq 'keys' /path/to/file.json

# Step 2: Check size/shape
jq 'length' /path/to/file.json

# Step 3: Sample data
jq '.[0:3]' /path/to/file.json  # For arrays

# Step 4: Extract what you need
jq '.specific.path' /path/to/file.json
```

### 3. Common Operations

| Task | Command |
|------|---------|
| Pretty-print | `jq '.' file.json` |
| Extract field | `jq '.fieldname' file.json` |
| Get keys | `jq 'keys' file.json` |
| Filter array | `jq '.[] \| select(.status=="active")' file.json` |
| Transform | `jq '{name: .user.name, age: .user.age}' file.json` |
| Count items | `jq 'length' file.json` |
| Get first N | `jq '.[0:5]' file.json` |
| Remove quotes | `jq -r '.field' file.json` |

## When to Use This Skill

- Analyzing JSON configuration files
- Extracting data from JSON APIs
- Filtering large JSON datasets
- Transforming JSON structures
- Validating JSON format
- Any JSON inspection/manipulation task

## Advantages

- Handles large files efficiently (doesn't load entire file into context)
- Precise targeting with jq selectors
- Composable with other Unix tools
- Clear, readable syntax
- Industry-standard tool
