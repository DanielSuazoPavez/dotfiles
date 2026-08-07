# Brainstorm: Credential handling vs. tooling setup vs. public dotfiles

## Context

Started from: moving files/setup from an old PC to a new one, and whether
`aws-vault`/`rclone`-style tooling belongs in the dotfiles repo. Widened into
a three-way split of concerns, since dotfiles is on a path to going public.

## Decisions

**1. Two repos, not three — credentials is a process, not a repo.**

| # | Name | Test | Public? |
|---|------|------|---------|
| 1 | dotfiles (existing) | "Clone, `./install.sh`, feel at home" — generic mechanism/config only | Yes |
| 2 | machine-setup (working name) | "Now set up everything else" — toggle/checklist installer for tools (DBeaver, AWS CLI, GlobalProtect, multi-GitHub-account values, etc.) | No |

Names are placeholders — explicitly not finalized (see Open Questions).

Revised from an earlier three-repo framing: `rbw` the *tool* is just another
generic package (no personal data in the binary or default config), so
**installing `rbw` belongs in dotfiles proper**, same as any other CLI tool
`install.sh` already sets up. What doesn't belong in either repo is the vault
setup itself — creating the Bitwarden Organization, defining collections,
logging in and unlocking — that's inherently manual, one-time-per-machine,
and carries personal auth state. It's documentation/process, not code.

**2. Credential setup is the manual step between the two repos, not a peer
repo.** Boot order on a fresh machine: dotfiles (`install.sh`, includes
`rbw` install) → manual step: log into Bitwarden, unlock `rbw`, confirm
Organization/collections are visible → machine-setup checklist (now able to
pull secrets via `rbw get`).

**3. Boundary rule for edge cases (e.g. multi-GitHub-account git config):**
the **pattern/mechanism** goes in dotfiles if it's generic (git conditional
includes by directory is a legitimate public dotfiles pattern); the **actual
personal values** (which emails, which usernames) move to machine-setup.

**4. Credential architecture: one Bitwarden account, logically split.**
Use Bitwarden Organizations/collections to separate "personal logins" from
"machine secrets" under a single login — not two separate accounts. Account
separation stays available later if the logical split ever feels insufficient.

**5. CLI access layer: `rbw` (unofficial Rust client) over official `bw`.**
Reasoning: `bw`'s unlocked state (`BW_SESSION`) is shell-process-scoped — a
new terminal tab or Zellij pane needs a fresh unlock. `rbw` runs a background
agent (like `ssh-agent`/`gpg-agent`) so one unlock covers every shell/script
until an idle timeout — matches how multi-pane, script-heavy workflows
actually get used. Trade accepted: unofficial tool, but timeout will be kept
reasonable.

**6. `aws-vault` keeps its existing setup** (file backend, per earlier
changelog notes) — Bitwarden/`rbw` is a candidate future source to *seed*
`aws-vault`, not a replacement for its short-lived STS session model.

## Open Questions

- Final name for the machine-setup repo (working label only).
- Whether the manual credential-setup step gets written down anywhere
  (README section in dotfiles? machine-setup? a personal note?) or stays
  tribal knowledge.
- `rbw` idle-timeout value — "reasonable" was agreed, specific number wasn't.
- Whether AWS CLI needs any generic config stub in dotfiles proper (profile
  *shape* vs. actual profile values), or belongs entirely in machine-setup.
- Full privacy scrub of current dotfiles repo before flipping it public
  (not addressed this session).
