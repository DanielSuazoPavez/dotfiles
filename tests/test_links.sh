#!/bin/bash
# links.sh invariants. Pure assertions on the sourced array — no script
# execution, so this is the fastest suite and the first to fail when a new
# config entry breaks a documented constraint.

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/helpers.sh
source "$DIR/helpers.sh"
# shellcheck source=links.sh
source "$REPO_ROOT/links.sh"

echo "test_links.sh"

# 1. Entry count
assert_eq "${#LINKS[@]}" "14" "LINKS has 14 entries"

# 2. Groups
groups=$(for e in "${LINKS[@]}"; do echo "${e%%:*}"; done | sort -u | tr '\n' ' ')
assert_eq "$groups" "broot cli-extras core ghostty nvim starship zellij " \
    "groups are exactly the seven expected"

# 3. No colon in any path. links.sh documents this: callers split on IFS=:,
# so a colon in a path would silently truncate rather than fail.
colon_found=""
for e in "${LINKS[@]}"; do
    # A well-formed entry has exactly 3 fields; more means a stray colon.
    field_count=$(awk -F: '{print NF}' <<< "$e")
    [ "$field_count" -eq 3 ] || colon_found="$colon_found $e"
done
assert_eq "$colon_found" "" "no entry contains a stray colon"

# 4. Every src exists in the repo
missing_src=""
for e in "${LINKS[@]}"; do
    IFS=: read -r _ src _ <<< "$e"
    [ -e "$REPO_ROOT/$src" ] || missing_src="$missing_src $src"
done
assert_eq "$missing_src" "" "every src exists in the repo"

# 5. No duplicate dest
dest_total=${#LINKS[@]}
dest_unique=$(for e in "${LINKS[@]}"; do echo "${e##*:}"; done | sort -u | wc -l)
assert_eq "$dest_unique" "$dest_total" "no duplicate dest"

# 6. Every dest is under $HOME
outside_home=""
for e in "${LINKS[@]}"; do
    dest=${e##*:}
    [[ $dest == "$HOME"/* ]] || outside_home="$outside_home $dest"
done
assert_eq "$outside_home" "" "every dest is under \$HOME"

# 7. links_for_group populates via nameref. The caller's array must not be
# named 'out' — bash rejects a nameref pointing at its own name.
broot_entries=()
links_for_group broot broot_entries
assert_eq "${#broot_entries[@]}" "3" "links_for_group broot returns 3 entries"

core_entries=()
links_for_group core core_entries
assert_eq "${#core_entries[@]}" "5" "links_for_group core returns 5 entries"

nomatch_entries=()
links_for_group nosuchgroup nomatch_entries
assert_eq "${#nomatch_entries[@]}" "0" "links_for_group on unknown group is empty"

finish
