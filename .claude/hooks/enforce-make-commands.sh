#!/usr/bin/env bash
# CC-HOOK: NAME: enforce-make-commands
# CC-HOOK: PURPOSE: Redirect pytest and pre-commit invocations to make targets
# CC-HOOK: EVENTS: PreToolUse(Bash)
# CC-HOOK: DISPATCHED-BY: grouped-bash-guard(Bash)
# CC-HOOK: DISPATCH-FN: grouped-bash-guard=enforce_make_commands
# CC-HOOK: STATUS: stable
# CC-HOOK: PERF-BUDGET-MS: scope_miss=41, scope_hit=41
# CC-HOOK: OPT-IN: none
# CC-HOOK: DUAL-MODE: true
# CC-HOOK: POSTURE: fail-open
#
# CC-DOC-BEGIN
# Blocks bare tool invocations, suggests Make targets.
#
# - Blocks: bare `pytest`, `uv run pytest` (full suite only — targeted `pytest tests/file.py` allowed)
# - Blocks: `uv run ruff`, `uv run pre-commit`, bare `pre-commit`, `ruff check/format`
# - Blocks: `uv sync`, `docker up/down/build`
# - Suggests: `make test`, make lint targets, `make install`, etc.
# CC-DOC-END

_HOOK_SELF_DIR="${BASH_SOURCE[0]%/*}"
[ "$_HOOK_SELF_DIR" = "${BASH_SOURCE[0]}" ] && _HOOK_SELF_DIR=.
source "$_HOOK_SELF_DIR/lib/hook-utils.sh"

match_enforce_make_commands() {
    local re="${_HOOK_VERB_BOUNDARY}(pytest|pre-commit|ruff|uv|docker|docker-compose|python)([[:space:]]|\$)"
    [[ "$COMMAND" =~ $re ]]
}

check_enforce_make_commands() {
    local PATTERNS=(
        "^uv run pytest$:::Use \`make test\` for full suite runs. Check Makefile for available targets."
        "^pytest$:::Use \`make test\` for full suite runs. Check Makefile for available targets."
        "^python.*-m pytest$:::Use \`make test\` for full suite runs. Check Makefile for available targets."
        "uv run (ruff|pre-commit):::Look for a make lint or make format target (\`make help\` to list). Direct tool invocations bypass project conventions."
        "^pre-commit:::Look for a make lint or make format target (\`make help\` to list). Direct tool invocations bypass project conventions."
        "^ruff (check|format):::Look for a make lint or make format target (\`make help\` to list). Direct tool invocations bypass project conventions."
        "^uv sync:::Use \`make install\` instead. See Makefile."
        "^docker(-compose)? (up|down|build|start|stop):::Check Makefile for available docker targets, or ask the user."
    )
    local entry pattern message
    for entry in "${PATTERNS[@]}"; do
        pattern="${entry%%:::*}"
        message="${entry#*:::}"
        if [[ "$COMMAND" =~ $pattern ]]; then
            _BLOCK_REASON="$message"
            return 1
        fi
    done
    return 0
}

main() {
    hook_init "enforce-make-commands" "PreToolUse"
    hook_require_tool "Bash"

    [ -z "$COMMAND" ] && exit 0

    _BLOCK_REASON=""
    if match_enforce_make_commands; then
        if ! check_enforce_make_commands; then
            hook_block "$_BLOCK_REASON"
        fi
    fi
    exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
