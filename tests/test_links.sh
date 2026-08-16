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

# 8. GROUP_FLAGS covers LINKS exactly, both directions. This is what makes
# "add a group = edit links.sh only" safe: a LINKS group with no GROUP_FLAGS entry
# would never link (group_enabled fails closed), and a GROUP_FLAGS entry with no
# LINKS group is dead config.
link_groups_list=$(for e in "${LINKS[@]}"; do echo "${e%%:*}"; done | sort -u)
flag_groups_list=$(for g in "${!GROUP_FLAGS[@]}"; do echo "$g"; done | sort)
assert_eq "$flag_groups_list" "$link_groups_list" \
    "GROUP_FLAGS keys match LINKS groups exactly"

# 9. Sourcing links.sh declares every flag GROUP_FLAGS names, defaulted to false.
# This is what replaces the old string coupling: the declaration is derived from the
# registry, so a typo'd INSTALL_NEOVIN can no longer read as "declared elsewhere,
# currently false" — there is no elsewhere. The file runs `set -u`, so an undeclared
# flag aborts this loop rather than silently passing.
undeclared_flags=""
for g in "${!GROUP_FLAGS[@]}"; do
    for f in ${GROUP_FLAGS[$g]}; do
        [[ -v $f && ${!f} == false ]] || undeclared_flags="$undeclared_flags $g:$f"
    done
done
assert_eq "$undeclared_flags" "" "sourcing links.sh declares every GROUP_FLAGS flag as false"

# 10. group_enabled semantics. The link-gating INSTALL_* flags are defined and
# false here — links.sh declared them when it was sourced — so these cases test
# the default-off behaviour, not undefined-flag behaviour. The `set -u`-abort
# guarantee of ${!flag:-} is proved by the undeclared-flag case below instead.
#
# The INSTALL_* assignments below are read only via group_enabled's ${!flag:-}
# indirect expansion, which shellcheck cannot follow, so each needs SC2034
# suppressed at the assignment itself (a directive covers one line only).
if group_enabled core; then core_on=yes; else core_on=no; fi
assert_eq "$core_on" "yes" "group_enabled core is always on (empty spec)"

if group_enabled starship; then st_on=yes; else st_on=no; fi
assert_eq "$st_on" "no" "group_enabled starship is off at the links.sh default"

if group_enabled nosuchgroup; then ns_on=yes; else ns_on=no; fi
assert_eq "$ns_on" "no" "group_enabled fails closed on an unregistered group"

# A GROUP_FLAGS spec naming a flag nothing declares must read as off, not abort.
# This is what keeps group_enabled's ${!flag:-} honest under `set -u` — the real
# flags are all declared now, so without this case that guard would be untested.
GROUP_FLAGS[phantom]="INSTALL_NOSUCHFLAG"
if group_enabled phantom; then ph_on=yes; else ph_on=no; fi
assert_eq "$ph_on" "no" "group_enabled is off (not aborting) for an undeclared flag"
unset 'GROUP_FLAGS[phantom]'

INSTALL_RIPGREP=true INSTALL_BROOT=false
if group_enabled cli-extras; then or_a=yes; else or_a=no; fi
assert_eq "$or_a" "yes" "cli-extras enabled by INSTALL_RIPGREP alone"

INSTALL_RIPGREP=false INSTALL_BROOT=true
if group_enabled cli-extras; then or_b=yes; else or_b=no; fi
assert_eq "$or_b" "yes" "cli-extras enabled by INSTALL_BROOT alone"

# shellcheck disable=SC2034
INSTALL_RIPGREP=false INSTALL_BROOT=false
if group_enabled cli-extras; then or_c=yes; else or_c=no; fi
assert_eq "$or_c" "no" "cli-extras disabled when both flags are false"

# Truthiness is exact: only the literal `true` enables, guarding against a flag
# set to 1/yes being read as on.
# shellcheck disable=SC2034
INSTALL_STARSHIP=1
if group_enabled starship; then t_on=yes; else t_on=no; fi
assert_eq "$t_on" "no" "only the literal 'true' enables a group"
unset INSTALL_STARSHIP INSTALL_RIPGREP INSTALL_BROOT

finish
