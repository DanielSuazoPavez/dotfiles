# Bootstrap: Fresh Machine → Ready for install.sh

Pre-steps for a brand-new machine (Windows + WSL Ubuntu, the primary use case).
Goal: get from "nothing installed" to the point where you can clone this repo
and run `./install.sh`.

`install.sh` only **symlinks configs** — it does not install the tools themselves.
This guide covers installing them.

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

## 4. Tools the dotfiles configure

Install before (or after) running `install.sh` — the shell config detects each
tool and only activates it if present.

```bash
# Starship (prompt)
curl -sS https://starship.rs/install.sh | sh

# Zellij (multiplexer) — prebuilt binary
curl -sL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz \
  | tar -xz && sudo mv zellij /usr/local/bin/

# zoxide (smarter cd — .aliases maps `cd` to it)
curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Neovim (apt version is old; use the official tarball)
curl -sLo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf /tmp/nvim.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# broot (better tree) — optional
# https://dystroy.org/broot/install/

# Claude Code — install early; it helps with the rest of the setup
curl -fsSL https://claude.ai/install.sh | bash

# Playwright chromium — used by the Playwright MCP server
# (.bashrc exports PLAYWRIGHT_BROWSER_PATH pointing into ~/.cache/ms-playwright;
#  update the version in that path if it changes)
npx playwright install chromium --with-deps
```

### Docker + Compose

Docker Engine (native, no Docker Desktop needed — works in WSL2 and bare metal).
The install script includes the Compose v2 plugin (`docker compose`):

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # then log out/in (or `wsl --shutdown`)
```

Verify: `docker run hello-world` and `docker compose version`.
On WSL, systemd (default in current Ubuntu images) starts the daemon automatically.

### Optional language toolchains

`.bashrc` sources these if present; skip what you don't need.

```bash
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node (via NVM)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Go — download from https://go.dev/dl/ and extract to /usr/local/go

# uv (Python)
curl -LsSf https://astral.sh/uv/install.sh | sh
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
