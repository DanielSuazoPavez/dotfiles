# CLAUDE.md

## Project Overview

[Brief 1-2 sentence description of what this project does]

## Quick Start

```bash
make install              # Install deps, setup hooks
uv run pytest             # Run tests
uv run pre-commit run --all-files  # Run linting
```

## Key Principles

1. **Working Directory**: Always run commands from project root. Never use `cd`.
2. **Package Manager**: Use `uv` (not pip/poetry)
3. **Read before writing**: Understand code before making changes
4. **Run pre-commit** before committing

## Memory System

Memories are stored in `.claude/memories/`. Key memories:
- `essential-conventions-code_style` - Coding conventions
- `essential-preferences-conversational_patterns` - Communication style

## When You're Done with a Task

- Run `pre-commit run` (mandatory)
- Update relevant documentation only

## See Also

- `BACKLOG.md` - Project backlog
- `.claude/memories/` - Detailed context
