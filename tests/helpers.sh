# shellcheck shell=bash
# helpers.sh — shared scaffolding for the test suites in this directory.
# Sourced by each tests/test_*.sh; not executable, do not run it.
#
# Every suite runs install.sh/uninstall.sh against a throwaway HOME. The
# isolation is three independent mechanisms (see run_install_sh) and all three
# are load-bearing — dropping any one lets a test touch the real machine.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FAILURES=0

# Assertions record and continue rather than exiting, so one failure doesn't
# mask the rest of the suite (same posture as install.sh's run_install).
assert_eq() {
    local actual=$1 expected=$2 label=$3
    if [ "$actual" = "$expected" ]; then
        echo "  + $label"
    else
        echo "  x $label" >&2
        echo "      expected: $expected" >&2
        echo "      actual:   $actual" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

assert_contains() {
    local haystack=$1 needle=$2 label=$3
    if [[ $haystack == *"$needle"* ]]; then
        echo "  + $label"
    else
        echo "  x $label (missing substring: $needle)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

assert_not_contains() {
    local haystack=$1 needle=$2 label=$3
    if [[ $haystack != *"$needle"* ]]; then
        echo "  + $label"
    else
        echo "  x $label (unexpected substring: $needle)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

assert_absent() {
    local path=$1 label=$2
    if [ ! -e "$path" ]; then
        echo "  + $label"
    else
        echo "  x $label ($path exists)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

assert_link_absent() {
    local path=$1 label=$2
    if [ ! -L "$path" ]; then
        echo "  + $label"
    else
        echo "  x $label ($path is still a symlink)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

assert_link_present() {
    local path=$1 label=$2
    if [ -L "$path" ]; then
        echo "  + $label"
    else
        echo "  x $label ($path is not a symlink)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

finish() {
    echo
    if [ "$FAILURES" -eq 0 ]; then
        echo "PASS: ${BASH_SOURCE[1]##*/}"
        exit 0
    fi
    echo "FAIL: ${BASH_SOURCE[1]##*/} ($FAILURES assertion(s) failed)" >&2
    exit 1
}

# Create the throwaway HOME. WORK is the parent of everything this suite
# writes; SCRATCH is the fake $HOME inside it.
scratch_home() {
    WORK=$(mktemp -d) || { echo "FATAL: mktemp failed" >&2; return 1; }
    # Guard the cleanup on a non-empty WORK: an unset variable here would make
    # the trap expand to `rm -rf /`.
    if [ -z "$WORK" ]; then
        echo "FATAL: WORK is empty after mktemp" >&2
        return 1
    fi
    SCRATCH="$WORK/home"
    STUB="$WORK/stubs"
    mkdir -p "$SCRATCH" "$STUB"
    # shellcheck disable=SC2064  # expand WORK now, not at trap time
    trap "rm -rf '$WORK'" EXIT
    export WORK SCRATCH STUB
}

# Stub every tool an install_* function guards on. Each installer opens with
# `command -v <tool> && return 0`, so a stub on PATH makes it a no-op — no
# network, no sudo. Deliberately does NOT stub git/find/readlink/sed/grep:
# the harness itself needs those.
stub_path() {
    local t
    for t in starship zellij nvim zoxide rg broot bat trash duckdb \
             uv node npm docker claude; do
        printf '#!/bin/sh\nexit 0\n' > "$STUB/$t"
        chmod +x "$STUB/$t"
    done
}

# Run install.sh fully isolated. Three mechanisms, each necessary:
#   PATH stubs        - installers early-return instead of fetching/sudo-ing
#   GIT_CONFIG_GLOBAL - install.sh runs `git config --global`, and because the
#                       real ~/.gitconfig is a symlink into this repo, git
#                       would otherwise write THROUGH it into the tracked file
#                       even with HOME redirected
#   env -u DISPLAY…   - forces HEADLESS=true, so Ghostty and Nerd Fonts are not
#                       prompted; that fixes the prompt count at 7 and keeps the
#                       bare (un-run_install'd) install_nerd_fonts unreachable
# Answers: starship, neovim, zellij, zoxide, cli-extras, runtimes, claude.
run_install_sh() {
    env -u DISPLAY -u WAYLAND_DISPLAY \
        PATH="$STUB:$PATH" HOME="$SCRATCH" GIT_CONFIG_GLOBAL="$WORK/gitconfig" \
        "$REPO_ROOT/install.sh" <<< $'y\ny\ny\ny\ny\ny\ny\n' \
        > "$WORK/install.log" 2>&1
}

run_uninstall_sh() {
    printf 'y\n' | env HOME="$SCRATCH" "$REPO_ROOT/uninstall.sh" 2>&1
}

# Symlinks under the scratch HOME, as $HOME-relative paths, sorted.
link_set() {
    find "$SCRATCH" -type l | sed "s|^$SCRATCH||" | sort
}

# The dests a headless all-yes run should produce, derived from LINKS so that
# adding a config updates the expectation automatically. Ghostty is excluded:
# headless means it is never prompted, so it is never linked.
expected_dests() {
    local entry group dest
    for entry in "${LINKS[@]}"; do
        group=${entry%%:*}
        dest=${entry##*:}
        case "$group" in
            ghostty) continue ;;
        esac
        echo "${dest#"$HOME"}"
    done | sort
}
