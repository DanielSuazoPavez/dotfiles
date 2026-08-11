#!/bin/bash
# KDE Plasma desktop settings: dark theme and keyboard layout.
#
# Called by install.sh when the KDE category is accepted. Safe to run directly.
#
# Why a script and not symlinks: Plasma owns these files and rewrites them on
# every settings change. ~/.config/kdeglobals in particular is generated — it
# holds the fully-expanded [Colors:*] blocks derived from the active scheme
# plus a ColorSchemeHash. Symlinking it would have Plasma write through the
# link into the repo on every theme touch. kwriteconfig6 edits in place and is
# idempotent, which is what a config this volatile needs.
#
# Keyboard layout is set at two levels on purpose:
#   localectl -> /etc/X11/xorg.conf.d/00-keyboard.conf, system-wide, so the TTY
#                and the display manager's login screen agree with the session
#   kxkbrc    -> the KDE session's own copy, which Plasma reads at login
# Setting only one leaves the other stale.

set -uo pipefail

FAILED=()

# ============================================================================
# Applicability
#
# Bails rather than failing: install.sh runs this best-effort, and a WSL or
# GNOME machine reaching here is a normal outcome, not an error.
# ============================================================================

if ! command -v kwriteconfig6 &> /dev/null; then
    echo "  - kwriteconfig6 not found; not a KDE Plasma 6 desktop. Skipping."
    exit 0
fi

if grep -qi microsoft /proc/version 2> /dev/null; then
    echo "  - WSL detected; no native desktop to configure. Skipping."
    exit 0
fi

# ============================================================================
# Helpers
#
# Duplicated from install.sh rather than sourced, matching the convention in
# scripts/dev-setup.sh: separate entrypoints, no shared code.
# ============================================================================

try_sudo() {
    if sudo "$@"; then
        return 0
    else
        echo "  ! sudo failed. Run manually: sudo $*"
        return 1
    fi
}

run_step() {
    local label=$1
    shift
    if "$@"; then
        echo "  + $label"
    else
        echo "  x $label"
        FAILED+=("$label")
    fi
}

# ============================================================================
# Theme
# ============================================================================

echo "Applying dark theme..."

# plasma-apply-colorscheme reloads running apps; kwriteconfig alone would need
# a re-login to show up. Absent on a Plasma install missing plasma-workspace,
# so fall back to writing the key directly.
apply_colorscheme() {
    if command -v plasma-apply-colorscheme &> /dev/null; then
        plasma-apply-colorscheme BreezeDark > /dev/null
    else
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme BreezeDark
    fi
}

run_step "color scheme: BreezeDark" apply_colorscheme
run_step "widget style: Breeze" \
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
run_step "icon theme: breeze" \
    kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze

# ============================================================================
# Keyboard layout
#
# US layout, AltGr-international variant: plain ' and " type instantly with no
# dead-key wait, and accents move onto AltGr (AltGr+' then a vowel -> á,
# AltGr+n -> ñ). Suits a Spanish/Latin-American physical keyboard used to type
# mostly English. Documented in docs/BOOTSTRAP.md.
# ============================================================================

echo "Setting keyboard layout (us/altgr-intl)..."

if command -v localectl &> /dev/null; then
    run_step "system-wide layout (localectl)" \
        try_sudo localectl set-x11-keymap us pc105 altgr-intl
else
    echo "  - localectl not found; skipping system-wide layout"
fi

run_step "KDE session layout (kxkbrc)" \
    kwriteconfig6 --file kxkbrc --group Layout --key LayoutList us
run_step "KDE session variant (kxkbrc)" \
    kwriteconfig6 --file kxkbrc --group Layout --key VariantList altgr-intl
# Without Use=true Plasma ignores LayoutList entirely and falls back to the
# X server default.
run_step "KDE layout enabled (kxkbrc)" \
    kwriteconfig6 --file kxkbrc --group Layout --key Use true

# ============================================================================
# Summary
# ============================================================================

echo
if [ ${#FAILED[@]} -eq 0 ]; then
    echo "KDE settings applied. Log out and back in for all changes to take effect."
    exit 0
else
    echo "KDE settings applied with errors:"
    for f in "${FAILED[@]}"; do
        echo "  - $f"
    done
    exit 1
fi
