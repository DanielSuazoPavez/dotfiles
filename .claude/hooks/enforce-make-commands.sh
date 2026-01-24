#!/bin/bash
# Pre-Bash hook: enforce make commands instead of direct commands

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Linting - use make lint
if [[ "$COMMAND" =~ ^pre-commit\ run ]]; then
    echo '{"decision": "block", "reason": "Use `make lint` instead. See Makefile."}'
    exit 0
fi

# Secret detection - use make check-secrets
if [[ "$COMMAND" =~ detect-secrets ]]; then
    echo '{"decision": "block", "reason": "Use `make check-secrets` instead. See Makefile."}'
    exit 0
fi

exit 0
