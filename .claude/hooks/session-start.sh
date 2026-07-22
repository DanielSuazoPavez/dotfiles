#!/usr/bin/env bash
# CC-HOOK: NAME: session-start
# CC-HOOK: PURPOSE: Inject git context, detect sync drift, emit actionable items, and write hygiene nudges to the statusline state file
# CC-HOOK: EVENTS: SessionStart
# CC-HOOK: STATUS: stable
# CC-HOOK: PERF-BUDGET-MS: scope_miss=2400, scope_hit=2400
# CC-HOOK: OPT-IN: none
# CC-HOOK: DUAL-MODE: false
# CC-HOOK: POSTURE: fail-open
#
# CC-DOC-BEGIN
# Injects git context, detects sync drift, emits actionable items, and writes user hygiene nudges to a statusline state file at session start.
#
# - Shows current git branch and main branch
# - (Workshop-only) Detects sync drift between `resources/` and `.claude/` mirror; nudges `make sync-self`
# - Hygiene nudges (eval staleness, rule-cluster review staleness, lessons age, toolkit version, legacy learned.json) are written to `.claude/logs/nudge-state.json` for the statusline renderer (`statusline-nudges.sh`) and are not injected into context
# - Outputs guidance text for memory usage
# - Logs each section's byte/token size to `.claude/logs/session-start-sizes.log` (SESSION_ID, timestamp, project, section, bytes, ~tokens)
# - Persists a structured row into `session-start-context.jsonl` (source, git_branch, main_branch, cwd) per firing — consumed by the claude-sessions projector to seed `state_changes` baselines instead of emitting `from_value=NULL` on first-observation rows. Gated by `CLAUDE_TOOLKIT_TRACEABILITY=1` via the same `_hook_log_jsonl` path as `invocations.jsonl`.
# CC-DOC-END

_HOOK_SELF_DIR="${BASH_SOURCE[0]%/*}"
[ "$_HOOK_SELF_DIR" = "${BASH_SOURCE[0]}" ] && _HOOK_SELF_DIR=.
source "$_HOOK_SELF_DIR/lib/hook-utils.sh"
source "$_HOOK_SELF_DIR/../scripts/lib/portability.sh"
source "$_HOOK_SELF_DIR/../scripts/lib/profile.sh"

# Portable batch hash: md5sum if available, per-file fallback otherwise.
# Emits "hash  path" lines matching md5sum output format.
_batch_md5() {
    if command -v md5sum &> /dev/null; then
        md5sum "$@" 2> /dev/null
    else
        local _f
        for _f in "$@"; do
            [ -f "$_f" ] && _portable_md5_short "$_f" | {
                read -r _h
                printf '%s  %s\n' "$_h" "$_f"
            }
        done
    fi
}

# _nudge_add ID TEXT — queue a user-facing hygiene item for the statusline
# state file. Never echoed to stdout; the agent must not see these.
_nudge_add() {
    _NUDGE_ITEMS+=("$1"$'\t'"$2")
}

_ss_settings_integrity() {
    if [ -f "$_HOOK_SELF_DIR/../scripts/lib/settings-integrity.sh" ]; then
        # shellcheck source=../scripts/lib/settings-integrity.sh
        source "$_HOOK_SELF_DIR/../scripts/lib/settings-integrity.sh"
        _SI_OUT=$(settings_integrity_check)
        if [ -n "$_SI_OUT" ]; then
            echo "=== SETTINGS INTEGRITY ==="
            echo "$_SI_OUT"
            echo ""
            ACTIONABLE_ITEMS_INTEGRITY="$_SI_OUT"
        fi
    fi
    _hook_perf_probe "settings_integrity"
}

_ss_git_context() {
    _raw=$(git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null) && MAIN_BRANCH="${_raw##refs/remotes/origin/}" || MAIN_BRANCH=""
    [ -z "$MAIN_BRANCH" ] && MAIN_BRANCH="main"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null || echo 'unknown')
    GIT_OUT="=== GIT CONTEXT ===
    Branch: $CURRENT_BRANCH
    Main: $MAIN_BRANCH"
    hook_log_section "git" "$GIT_OUT"
    hook_log_session_start_context "$CURRENT_BRANCH" "$MAIN_BRANCH" "$PWD"
    echo ""
    echo "$GIT_OUT"
    _hook_perf_probe "git_context"
}

_ss_toolkit_version() {
    if [ -n "${ACTIONABLE_ITEMS_INTEGRITY:-}" ]; then
        while IFS= read -r _line; do
            [ -z "$_line" ] && continue
            ACTIONABLE_ITEMS="${ACTIONABLE_ITEMS}\n- $_line"
        done <<< "$ACTIONABLE_ITEMS_INTEGRITY"
    fi
    if [ -f ".claude-toolkit-version" ] && command -v claude-toolkit &> /dev/null; then
        PROJECT_VER=$(< .claude-toolkit-version) 2> /dev/null || PROJECT_VER=""
        TOOLKIT_VER=$(claude-toolkit version-main 2> /dev/null)
        if [ -n "$TOOLKIT_VER" ] && [ -n "$PROJECT_VER" ] && [ "$PROJECT_VER" != "$TOOLKIT_VER" ]; then
            _nudge_add "toolkit-version" "toolkit ${PROJECT_VER}→${TOOLKIT_VER}"
        fi
    fi
    _hook_perf_probe "toolkit_version"
}

_ss_sync_drift() {
    [ -d "resources/hooks" ] || {
        _hook_perf_probe "sync_drift"
        return
    }
    _DRIFT_FILES=()
    local _metadata="resources/METADATA.json"
    { [ -f "$_metadata" ] && command -v jq > /dev/null 2>&1; } || {
        _hook_perf_probe "sync_drift"
        return
    }

    # Build parallel (source, dest) file lists from the central manifest via one
    # jq pass over the workshop-profile entries. A folder dest (trailing slash,
    # a skill's SKILL.md) expands to <dest><source-basename>; file dests pass
    # through. Emits TAB-separated source<TAB>dest — replaces the deleted
    # dist/workshop/MANIFEST and its find-based directory expansion.
    local _src_files=() _tgt_files=() _rel_keys=()
    local _src _dest
    while IFS=$'\t' read -r _src _dest; do
        [ -z "$_src" ] && continue
        [ -f "$_src" ] || continue
        _src_files+=("$_src")
        _tgt_files+=("$_dest")
        _rel_keys+=("${_dest#.claude/}")
    done < <(jq -r '
        [.[] | to_entries[]] | .[]
        | select(.value.distribution | index("workshop"))
        | .key as $src
        | .value["distribution-path"][]
        | (if endswith("/") then . + ($src | sub(".*/"; "")) else . end) as $dest
        | "\($src)\t\($dest)"
    ' "$_metadata" 2> /dev/null)

    # Add hardcoded copies
    if [ -f "resources/settings.json" ] && [ -f ".claude/settings.json" ]; then
        _src_files+=("resources/settings.json")
        _tgt_files+=(".claude/settings.json")
        _rel_keys+=("settings.json")
    fi

    if [ ${#_src_files[@]} -eq 0 ]; then
        _hook_perf_probe "sync_drift"
        return
    fi

    # Batch hash: two md5sum calls (one per side), then compare in pure bash
    declare -A _src_hashes=() _tgt_hashes=()
    while IFS=' ' read -r _h _p; do
        _src_hashes["$_p"]="$_h"
    done < <(_batch_md5 "${_src_files[@]}")

    # Only hash target files that exist
    local _existing_tgts=()
    for _t in "${_tgt_files[@]}"; do
        [ -f "$_t" ] && _existing_tgts+=("$_t")
    done
    if [ ${#_existing_tgts[@]} -gt 0 ]; then
        while IFS=' ' read -r _h _p; do
            _tgt_hashes["$_p"]="$_h"
        done < <(_batch_md5 "${_existing_tgts[@]}")
    fi

    # Compare: pure bash, no forks
    for ((_i = 0; _i < ${#_src_files[@]}; _i++)); do
        local _sf="${_src_files[$_i]}" _tf="${_tgt_files[$_i]}" _rk="${_rel_keys[$_i]}"
        local _sh="${_src_hashes[$_sf]:-}" _th="${_tgt_hashes[$_tf]:-}"
        if [ -z "$_th" ] || [ "$_sh" != "$_th" ]; then
            _DRIFT_FILES+=("$_rk")
        fi
    done
    unset _src_hashes _tgt_hashes
    if [ ${#_DRIFT_FILES[@]} -gt 0 ]; then
        _DRIFT_COUNT=${#_DRIFT_FILES[@]}
        DRIFT_OUT="=== SYNC DRIFT ===
.claude/ mirror is stale (${_DRIFT_COUNT} file(s) differ) — expected while authoring; checks read resources/ directly. Sync at wrap-up (user-gated in auto-mode); needed sooner only to live-test a mirror-backed resource this session."
        _SHOWN=0
        for _f in "${_DRIFT_FILES[@]}"; do
            if [ $_SHOWN -lt 5 ]; then
                DRIFT_OUT+=$'\n'"  $_f"
                ((_SHOWN++))
            fi
        done
        if [ "$_DRIFT_COUNT" -gt 5 ]; then
            DRIFT_OUT+=$'\n'"  + $((_DRIFT_COUNT - 5)) more"
        fi
        hook_log_section "sync_drift" "$DRIFT_OUT"
        echo ""
        echo "$DRIFT_OUT"
    fi
    _hook_perf_probe "sync_drift"
}

_ss_eval_staleness() {
    # Workshop-only: eval staleness compares authored resources/ against the
    # eval store. The shipped .claude/ mirror is a consumer surface (guardrails
    # for working here, not resources authored here) and has no eval store —
    # scanning it would count foreign synced-in resources as false stales.
    [ "$(detect_profile)" = "toolkit" ] || {
        _hook_perf_probe "eval_staleness"
        return
    }
    _EVAL_DIR="docs/indexes/evaluations"
    _EVAL_TOTAL=0
    declare -A _EVAL_PER_TYPE=()
    if [ -d "$_EVAL_DIR" ] && command -v jq &> /dev/null; then
        for _type in skills hooks agents rules; do
            _store="$_EVAL_DIR/${_type}.latest.json"
            [ -f "$_store" ] || continue
            _EVAL_PER_TYPE[$_type]=0

            declare -A _stored_hashes=()
            declare -A _reviewed_hashes=()
            while IFS=$'\t' read -r _name _hash _rhash; do
                [ -z "$_name" ] && continue
                _stored_hashes["$_name"]="$_hash"
                _reviewed_hashes["$_name"]="$_rhash"
            done < <(jq -r '.resources | to_entries[] | "\(.key)\t\(.value.file_hash // "")\t\(.value.reviewed_hash // "")"' "$_store" 2> /dev/null)

            local _disk_names=() _disk_paths=()
            case "$_type" in
                skills) for _d in resources/skills/*/; do [ -f "$_d/SKILL.md" ] && {
                    local _bn="${_d%/}"
                    _disk_names+=("${_bn##*/}")
                    _disk_paths+=("$_d/SKILL.md")
                }; done ;;
                hooks) for _f in resources/hooks/*.sh; do [ -f "$_f" ] && {
                    local _bn="${_f##*/}"
                    _disk_names+=("${_bn%.sh}")
                    _disk_paths+=("$_f")
                }; done ;;
                agents) for _f in resources/agents/*.md; do [ -f "$_f" ] && {
                    local _bn="${_f##*/}"
                    _disk_names+=("${_bn%.md}")
                    _disk_paths+=("$_f")
                }; done ;;
                rules)
                    while IFS= read -r _f; do
                        local _rel="${_f#resources/rules/}"
                        _disk_names+=("${_rel%.md}")
                        _disk_paths+=("$_f")
                    done < <(find resources/rules -name '*.md' -not -name 'CLAUDE.md' 2> /dev/null | sort)
                    ;;
            esac

            # Only hash files that have a stored hash to compare against;
            # new/unknown files are counted as stale without hashing.
            local _hash_names=() _hash_paths=()
            for ((_i = 0; _i < ${#_disk_names[@]}; _i++)); do
                _name="${_disk_names[$_i]}"
                if [ -z "${_stored_hashes[$_name]+x}" ]; then
                    _EVAL_PER_TYPE[$_type]=$((_EVAL_PER_TYPE[$_type] + 1))
                    _EVAL_TOTAL=$((_EVAL_TOTAL + 1))
                elif [ -n "${_stored_hashes[$_name]}" ]; then
                    _hash_names+=("$_name")
                    _hash_paths+=("${_disk_paths[$_i]}")
                fi
            done

            # Batch-compute hashes only for files needing comparison
            declare -A _current_hashes=()
            if [ ${#_hash_paths[@]} -gt 0 ]; then
                if [ "$_type" = "hooks" ]; then
                    while IFS=' ' read -r _h _p; do
                        local _bn="${_p##*/}"
                        _current_hashes["${_bn%.sh}"]="${_h:0:8}"
                    done < <(_batch_md5 "${_hash_paths[@]}")
                else
                    while IFS=$'\t' read -r _cname _chash; do
                        _current_hashes["$_cname"]="${_chash:0:8}"
                    done < <(
                        for ((_i = 0; _i < ${#_hash_names[@]}; _i++)); do
                            printf '%s\t' "${_hash_names[$_i]}"
                            _strip_nonscore_frontmatter "${_hash_paths[$_i]}" "$_type" | { md5sum 2> /dev/null || md5 -q 2> /dev/null || true; }
                        done
                    )
                fi
            fi

            for ((_i = 0; _i < ${#_hash_names[@]}; _i++)); do
                _name="${_hash_names[$_i]}"
                _hash="${_stored_hashes[$_name]}"
                _rhash="${_reviewed_hashes[$_name]}"
                _current="${_current_hashes[$_name]:-}"
                if [ "$_hash" != "$_current" ] && [ "$_rhash" != "$_current" ]; then
                    _EVAL_PER_TYPE[$_type]=$((_EVAL_PER_TYPE[$_type] + 1))
                    _EVAL_TOTAL=$((_EVAL_TOTAL + 1))
                fi
            done
            unset _stored_hashes _reviewed_hashes _disk_names _disk_paths _current_hashes
        done
    fi
    if [ "$_EVAL_TOTAL" -gt 0 ]; then
        local _breakdown=""
        for _type in skills hooks agents rules; do
            local _c="${_EVAL_PER_TYPE[$_type]:-0}"
            [ "$_c" -gt 0 ] && _breakdown="${_breakdown:+$_breakdown, }$_c $_type"
        done
        _nudge_add "eval-staleness" "evals ${_EVAL_TOTAL} stale (${_breakdown})"
    fi
    unset _EVAL_PER_TYPE
    _hook_perf_probe "eval_staleness"
}

_ss_rule_cluster_staleness() {
    # Workshop-only: the cluster review store only exists where rules are
    # authored. Absent store → clusters were never reviewed; first review
    # creates it, so no nagging before that.
    [ "$(detect_profile)" = "toolkit" ] || {
        _hook_perf_probe "rule_cluster_staleness"
        return
    }
    local _cstore="docs/indexes/evaluations/rule-clusters.latest.json"
    local _rstore="docs/indexes/evaluations/rules.latest.json"
    if [ -f "$_cstore" ] && [ -f "$_rstore" ] && command -v jq &> /dev/null; then
        local _stale_labels="" _label
        # A member is stale when its recorded hash differs from the current
        # file_hash in rules.latest.json, or the key is missing there.
        while IFS= read -r _label; do
            [ -z "$_label" ] && continue
            _stale_labels="${_stale_labels:+$_stale_labels, }$_label"
        done < <(jq -r --slurpfile rules "$_rstore" '
            ($rules[0].resources // {}) as $r
            | .clusters // {} | to_entries[]
            | select(any(.value.members // {} | to_entries[];
                ($r[.key].file_hash // "") != .value))
            | .key' "$_cstore" 2> /dev/null)
        if [ -n "$_stale_labels" ]; then
            _nudge_add "rule-clusters" "rule clusters stale: ${_stale_labels} — /review-rule-cluster"
        fi
    fi
    _hook_perf_probe "rule_cluster_staleness"
}

_ss_lessons() {
    LESSONS_DB="${CLAUDE_ANALYTICS_LESSONS_DB:-$HOME/claude-analytics/lessons.db}"

    if ! hook_feature_enabled lessons; then
        :
    elif [ -f "$LESSONS_DB" ]; then
        DAYS_SINCE=-1
        THRESHOLD_DAYS=7
        ACTIVE_COUNT=0
        _LAST_MANAGE_EXISTS=0

        _DB_RESULT=$(sqlite3 -separator '|' "$LESSONS_DB" "
    SELECT 'M|' || CAST(COALESCE(julianday('now') - julianday(value), -1) AS INTEGER)
      FROM metadata WHERE key = 'last_manage_run';
    SELECT 'T|' || COALESCE(value, '7')
      FROM metadata WHERE key = 'nudge_threshold_days';
    SELECT 'C|' || COUNT(*) FROM lessons WHERE active = 1;
    " 2> /dev/null)
        _DB_EXIT=$?

        if [ "$_DB_EXIT" -ne 0 ]; then
            ACTIONABLE_ITEMS="${ACTIONABLE_ITEMS}\n- lessons.db query failed (exit $_DB_EXIT) — lesson data needs verification"
        fi

        while IFS='|' read -r _prefix _rest; do
            case "$_prefix" in
                M)
                    DAYS_SINCE="${_rest}"
                    [ "$DAYS_SINCE" -ge 0 ] 2> /dev/null && _LAST_MANAGE_EXISTS=1
                    ;;
                T) THRESHOLD_DAYS="${_rest}" ;;
                C) ACTIVE_COUNT="${_rest}" ;;
            esac
        done <<< "$_DB_RESULT"

        _hook_perf_probe "lessons"

        NUDGE=""
        if [ "$_LAST_MANAGE_EXISTS" = 1 ] && [ "$DAYS_SINCE" -ge 0 ] 2> /dev/null; then
            if [ "$DAYS_SINCE" -ge "$THRESHOLD_DAYS" ] 2> /dev/null; then
                NUDGE="${DAYS_SINCE}d since last /manage-lessons"
            fi
        else
            NUDGE="never run /manage-lessons"
        fi

        if [ -n "$NUDGE" ]; then
            _nudge_add "lessons" "${NUDGE} (${ACTIVE_COUNT} lessons)"
        fi
        _hook_perf_probe "nudge"

    elif [ -f ".claude/learned.json" ]; then
        _nudge_add "legacy-learned" "legacy learned.json — delete or migrate"
    fi
}

_ss_write_nudge_state() {
    local _state_dir=".claude/logs" _state_file=".claude/logs/nudge-state.json"
    if command -v jq &> /dev/null && mkdir -p "$_state_dir" 2> /dev/null; then
        printf '%s\n' "${_NUDGE_ITEMS[@]+"${_NUDGE_ITEMS[@]}"}" |
            jq -Rn --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                '{updated_at: $ts, items: [inputs | select(length > 0) | split("\t") | {id: .[0], text: .[1]}]}' \
                > "$_state_file" 2> /dev/null || true
    fi
    _hook_perf_probe "nudge_state"
}

main() {
    hook_init "session-start" "SessionStart"
    _hook_perf_probe "hook_init"

    ACTIONABLE_ITEMS=""
    ACTIONABLE_ITEMS_INTEGRITY=""
    CURRENT_BRANCH=""
    MAIN_BRANCH=""
    _NUDGE_ITEMS=()

    _ss_settings_integrity
    _ss_git_context
    _ss_toolkit_version
    _ss_sync_drift
    _ss_eval_staleness
    _ss_rule_cluster_staleness
    _ss_lessons
    _ss_write_nudge_state

    echo ""
    echo "=== SESSION START ==="
    if [ -n "$ACTIONABLE_ITEMS" ]; then
        echo "MANDATORY: Your FIRST message to the user MUST surface these actionable items — do NOT skip or bury them:"
        echo -e "$ACTIONABLE_ITEMS"
    else
        echo "Session ready."
    fi
    _hook_perf_probe "acknowledgment"

    exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
