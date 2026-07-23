# Bootstrap (Ubuntu/WSL): Fresh Machine → Ready for install.sh

Pre-steps for a brand-new machine (Windows + WSL Ubuntu, the primary use case).
Goal: get from "nothing installed" to the point where you can clone this repo
and run `./install.sh`. Tumbleweed machines: see
[DUAL-BOOT-TUMBLEWEED.md](DUAL-BOOT-TUMBLEWEED.md) instead.

`install.sh` installs the tool roster **and** symlinks configs. This guide
covers only what must exist before you can clone and run it: WSL, base
packages, and GitHub access.

## 1. WSL + Ubuntu (Windows only)

From an elevated PowerShell:

```powershell
wsl --install -d Ubuntu-24.04
```

Reboot if prompted, then launch Ubuntu and create your UNIX user.

> **Testing tip**: to try this guide without touching your main distro, create a
> disposable instance: `wsl --install Ubuntu-24.04 --name dotfiles-test`.
> Remove it later with `wsl --unregister dotfiles-test`.

## 2. Base packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip build-essential fontconfig bash-completion ripgrep
```

## 3. GitHub access

The dotfiles repo is private, so authenticate first. Easiest path — GitHub CLI:

```bash
sudo apt install -y gh
gh auth login    # HTTPS, login via browser
```

Or set up an SSH key instead:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub   # add at https://github.com/settings/keys
```

## 4. Not covered by install.sh

install.sh offers Claude Code (default yes); to get it before cloning:
`curl -fsSL https://claude.ai/install.sh | bash`.

### Docker + Compose

install.sh's Runtimes prompt installs Docker Engine via get.docker.com
(includes the Compose v2 plugin) and adds you to the `docker` group —
then log out/in (or `wsl --shutdown`).

Verify: `docker run hello-world` and `docker compose version`.
On WSL, systemd (default in current Ubuntu images) starts the daemon automatically.

### Optional language toolchains

`.bashrc` sources these if present; skip what you don't need. Node is handled
by install.sh (via nvm on Ubuntu); rust and go stay manual:

```bash
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Go — download from https://go.dev/dl/ and extract to /usr/local/go
```

## 5. Fonts (WSL caveat)

Starship/Zellij glyphs need a **Nerd Font in the terminal that renders them**.
On WSL that terminal runs on **Windows**, so install the font on the Windows
side (e.g. JetBrainsMono Nerd Font from <https://www.nerdfonts.com/font-downloads>)
and select it in your terminal's settings. The `install.sh` Nerd Fonts step
targets Linux (`~/.local/share/fonts`) and only matters for native Linux GUIs.

## 6. Keyboard layout (native desktop)

Only relevant on a **native Linux desktop** (KDE/GNOME on real hardware), not
WSL. If the physical keyboard is Spanish/Latin-American but you type in English,
use the US layout with the **AltGr international variant**: plain `'` and `"`
type instantly (no dead-key wait), and accents move onto AltGr —
`AltGr+'` then a vowel → `á`, `AltGr+n` → `ñ`, `AltGr+.` → `·`.

```bash
# Test live (resets on logout):
setxkbmap us -variant altgr-intl

# Persist across reboots (systemd/X11; KDE reads this too):
sudo localectl set-x11-keymap us pc105 altgr-intl
```

The plain `us(intl)` variant makes `'`/`"` **dead keys** (they wait for the next
keypress to compose) — a common surprise on a fresh install. `altgr-intl` avoids
it while keeping the accents a chord away.

## 7. Clone and install

```bash
git clone https://github.com/DanielSuazoPavez/dotfiles.git ~/projects/personal/dotfiles
cd ~/projects/personal/dotfiles
./install.sh
source ~/.bashrc
```

Done. See [dotfiles-setup-guide.md](../dotfiles-setup-guide.md) for the general
dotfiles methodology, and the README for day-to-day usage.
