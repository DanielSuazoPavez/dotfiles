#!/bin/bash
# install.sh produces exactly the link set LINKS describes, pointing into the
# real repo, without touching the machine or dirtying the working tree.

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/helpers.sh
source "$DIR/helpers.sh"
# shellcheck source=links.sh
source "$REPO_ROOT/links.sh"

echo "test_install.sh"

scratch_home || exit 1
stub_path

run_install_sh
install_status=$?
log=$(cat "$WORK/install.log")

assert_eq "$install_status" "0" "install.sh exits 0"

# If headless forcing failed, the prompt sequence shifted and every assertion
# below is answering the wrong questions.
assert_contains "$log" "Headless environment detected" \
    "run was headless (prompt alignment holds)"

# Exact set comparison, both directions: a missing link and an unexpected one
# are equally wrong. Compared against LINKS, never a hardcoded count.
diff_out=$(diff <(link_set) <(expected_dests) 2>&1)
assert_eq "$diff_out" "" "link set matches LINKS exactly"

# Headless means Ghostty is never prompted, so it must never be linked.
assert_absent "$SCRATCH/.config/ghostty/config" "ghostty not linked when headless"

# Every link must resolve into the real repo, not into the scratch tree.
bad_target=""
while IFS= read -r l; do
    target=$(readlink "$l")
    [[ $target == "$REPO_ROOT"/* ]] || bad_target="$bad_target $l->$target"
done < <(find "$SCRATCH" -type l)
assert_eq "$bad_target" "" "every link points into the repo"

# Regression test for the GIT_CONFIG_GLOBAL blocker: install.sh runs
# `git config --global`, and without isolation git follows the ~/.gitconfig
# symlink and writes through it into this repo's tracked file.
gitconfig_state=$(cd "$REPO_ROOT" && git diff --quiet -- .gitconfig && echo clean || echo dirty)
assert_eq "$gitconfig_state" "clean" "repo .gitconfig untouched by the run"

finish
