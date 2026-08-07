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

assert_eq "$install_status" "0" "install.sh exits 0"

# The answer stream is exact-fit: a short stream does not error, it silently
# answers yes (prompt_category treats an empty REPLY from EOF as yes). Pin the
# accepted categories so adding a prompt to install.sh fails here rather than
# passing green with a misaligned stream.
assert_eq "$(accepted_categories | tr '\n' ' ')" \
    "CLI extras Claude Code Ghostty KDE Connect KDE settings Neovim Nerd Fonts Starship Zellij runtimes shell basics zoxide " \
    "exactly the expected categories ran (answer stream still aligned)"

# Exact set comparison, both directions: a missing link and an unexpected one
# are equally wrong. Compared against LINKS, never a hardcoded count.
diff_out=$(diff <(link_set) <(expected_dests) 2>&1)
assert_eq "$diff_out" "" "link set matches LINKS exactly"

# Ghostty is an ordinary group now: prompted and linked like any other.
assert_link_present "$SCRATCH/.config/ghostty/config" "ghostty linked like any other group"

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

# core.excludesfile must be set against the scratch gitconfig. Pinned because
# the guard at install.sh depends on .gitignore_global already being linked —
# an ordering dependency nothing else asserts.
excludes=$(GIT_CONFIG_GLOBAL="$WORK/gitconfig" git config --get core.excludesfile || true)
assert_eq "$excludes" "$SCRATCH/.gitignore_global" "core.excludesfile was set"

finish
