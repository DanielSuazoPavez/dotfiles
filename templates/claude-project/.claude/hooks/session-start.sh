#!/bin/bash

# Get current git branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

cat <<EOF
SESSION START

MANDATORY FIRST ACTIONS (BEFORE ANSWERING THE USER):
1. Read essential memories in parallel:
   - .claude/memories/essential-conventions-code_style.md
   - .claude/memories/essential-preferences-conversational_patterns.md
2. Apply conversational patterns immediately
3. Acknowledge completion briefly

CURRENT CONTEXT:
- Branch: ${CURRENT_BRANCH}
- Main branch: main
EOF

exit 0
