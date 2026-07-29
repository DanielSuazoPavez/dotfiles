#!/bin/bash
# uninstall.sh removes every managed symlink, spares links it does not own,
# cleans up dangling ones, and is idempotent.

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/helpers.sh
source "$DIR/helpers.sh"
# shellcheck source=links.sh
source "$REPO_ROOT/links.sh"

echo "test_uninstall.sh"

# --- case 1: total removal -------------------------------------------------
scratch_home || exit 1
stub_path
run_install_sh

# Derived from LINKS, not hardcoded: a literal here would silently rot when a
# config is added.
assert_eq "$(link_set | wc -l)" "$(expected_dests | wc -l)" \
    "install produced the full managed link set"

uninstall_out=$(run_uninstall_sh)
uninstall_status=$?
assert_eq "$uninstall_status" "0" "uninstall exits 0"
assert_eq "$(link_set | wc -l)" "0" "every managed link removed"

# --- case 2: a link the user owns, at a path we manage ---------------------
# uninstall only visits paths named in LINKS, so the probe must sit at a managed
# path; what makes it foreign is the target, not the location. Install links
# ghostty now, so this repoints an existing managed link outside the repo.
run_install_sh
ln -sfn /etc/hostname "$SCRATCH/.config/ghostty/config"

uninstall_out=$(run_uninstall_sh)
assert_contains "$uninstall_out" "not ours, skipped" "foreign link reported as skipped"
assert_link_present "$SCRATCH/.config/ghostty/config" "foreign link survives"
assert_eq "$(readlink "$SCRATCH/.config/ghostty/config")" "/etc/hostname" \
    "foreign link still points where the user put it"
# It was the only survivor: everything managed is gone.
assert_eq "$(link_set | wc -l)" "1" "only the foreign link remains"

# --- case 3: a DANGLING link into the repo --------------------------------
# The bug this whole line of work exists to fix. The guard must test the raw
# readlink target, not a resolved one — gating on [ -e ] would leave exactly
# these behind while appearing to work.
rm -f "$SCRATCH/.config/ghostty/config"
run_install_sh
mkdir -p "$SCRATCH/.config/broot/launcher/bash"
ln -sfn "$REPO_ROOT/.config/broot/launcher/bash/br-GONE" \
    "$SCRATCH/.config/broot/launcher/bash/br"

assert_link_present "$SCRATCH/.config/broot/launcher/bash/br" "probe is a symlink"
assert_absent "$SCRATCH/.config/broot/launcher/bash/br" "probe target does not exist (dangling)"

run_uninstall_sh > /dev/null
assert_link_absent "$SCRATCH/.config/broot/launcher/bash/br" \
    "dangling link into the repo IS removed"

# --- case 4: idempotence (CLAUDE.md principle 1) --------------------------
uninstall_out=$(run_uninstall_sh)
second_status=$?
assert_eq "$second_status" "0" "second uninstall exits 0"
assert_not_contains "$uninstall_out" "Removed symlink:" "second uninstall removes nothing"

finish
