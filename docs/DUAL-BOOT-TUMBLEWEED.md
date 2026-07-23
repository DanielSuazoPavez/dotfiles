# Dual-Boot Guide: Windows + openSUSE Tumbleweed

Machine facts (checked 2026-07-22):

- Kingston NVMe 512 GB, GPT/UEFI ✅
- C: = 456 GB with only ~15 GB free ⚠️ → cleanup required first
- EFI partition: 300 MB (partition 1) — Linux reuses it, don't format
- BitLocker: OFF (verified 2026-07-22, fully decrypted) — no recovery-key concern

Decision: Tumbleweed first (rolling + snapper rollbacks), Fedora as fallback.

---

## Phase 0 — Free ≥50 GB on C: (P0, blocks everything)

Comfortable Tumbleweed install: 40–60 GB (btrfs snapshots eat space; 30 GB floor).

**WSL side** (usually the biggest win):

```powershell
# See vhdx sizes
dir $env:LOCALAPPDATA\Packages\*Ubuntu*\LocalState\ext4.vhdx
# Also check Docker Desktop / other distros under Packages\

# Inside WSL first: clean what you can
#   docker system prune -a        (if docker runs in WSL)
#   sudo apt clean; rm -rf ~/.cache/...

# Then compact (admin PowerShell):
wsl --shutdown
Optimize-VHD -Path <path-to>\ext4.vhdx -Mode Full
# If Optimize-VHD unavailable (no Hyper-V module): wsl --export / --unregister / --import
```

**Windows side:**

- `cleanmgr` → Clean up system files (old updates, temp)
- Settings → Storage → Temporary files
- Downloads folder, old installers
- `powercfg /h off` (admin) also frees hiberfil.sys (several GB) — needed later anyway

Target: ≥50 GB free, then continue.

## Phase 1 — Windows prep

1. ~~BitLocker~~ — verified OFF on this PC (fully decrypted); nothing to do.
2. **Disable Fast Startup**: Control Panel → Power Options → "Choose what power
   buttons do" → uncheck "Turn on fast startup". (Hibernated NTFS confuses Linux.)
3. **Shrink C:** — ⚠️ tried 2026-07-22: Disk Management caps at ~5 GB even with
   144 GB free, pagefile off, hibernation off, zero shadow copies. Blocker is
   NTFS metadata ($UsnJrnl/$MFT zone) — unmovable from inside Windows.
   **Decision: shrink from the openSUSE installer instead** (offline NTFS
   resize handles it). Prep in Windows:
   - `chkdsk C: /scan` (fix + reboot if errors)
   - re-enable pagefile (sysdm.cpl → Virtual memory → automatic)
   - full Restart (not shutdown) into the USB
   In the installer's Guided Setup, resize the Windows partition by 50–60 GB.
4. **Back up** anything you can't lose.

## Phase 2 — Install media

5. Download the **DVD offline ISO** (x86_64): <https://get.opensuse.org/tumbleweed/>
   Verify the checksum.
6. Flash to a ≥8 GB USB with Rufus (<https://rufus.ie>) or Ventoy.

## Phase 3 — Boot & install

7. Reboot → boot menu key (F2/F12/Del, vendor-dependent) → boot the USB.
   **Leave Secure Boot ON** — openSUSE is signed, and it keeps BitLocker calmer.
8. Installer:
   - Role: **Desktop with KDE Plasma**
   - **Partitioning — the step that matters.** Guided Setup should propose
     using the unallocated space. Verify the proposal says:
     - *create* new partitions in the free space
     - *mount* the existing 300 MB EFI partition at `/boot/efi` — **not format**
     - partition 3 (C:) untouched
     If anything looks off, stop and use Expert Partitioner.
   - Keep default **btrfs with snapshots** for `/` (the snapper parachute)
   - Create user; enable online repos if offered
9. Install → reboot → GRUB should list openSUSE and Windows Boot Manager.
   First boot back into Windows may ask for the BitLocker recovery key — enter
   it once, it re-seals.

## Phase 4 — Post-install (inside Tumbleweed)

```bash
# Updates (Tumbleweed is always dup, never up)
sudo zypper dup

# NVIDIA (Secure Boot: next reboot shows a blue MOK screen →
# "Enroll MOK" → enter the password you set during install)
sudo zypper addrepo https://download.nvidia.com/opensuse/tumbleweed nvidia
sudo zypper install-new-recommends --repo nvidia
sudo reboot

# Dev tools (all current versions, no tarballs needed)
sudo zypper in git curl wget unzip gcc make ripgrep ripgrep-bash-completion \
               starship zellij zoxide neovim gh docker docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable --now docker
# log out/in for the docker group

# Claude Code — get the assistant before doing the rest by hand :)
curl -fsSL https://claude.ai/install.sh | bash
# then: claude   (login via browser)

# Playwright chromium (for the Playwright MCP server; needs Node from NVM first)
npx playwright install chromium --with-deps

# GitHub auth + dotfiles
gh auth login
git clone https://github.com/DanielSuazoPavez/dotfiles.git ~/projects/personal/dotfiles
cd ~/projects/personal/dotfiles && ./install.sh
```

Fonts: install JetBrainsMono Nerd Font natively here
(`sudo zypper in jetbrains-mono-fonts` gets the base; for the Nerd Font
patched build, install.sh's font step works — this is native Linux, unlike WSL).

## Escape hatches

- **Update broke something** → reboot → GRUB → "Bootable snapshots" → pick the
  pre-update snapshot → once booted: `sudo snapper rollback` → reboot.
- **Remove Linux entirely** → boot Windows → Disk Management → delete the Linux
  partitions → extend C:. Set Windows Boot Manager first in UEFI firmware (or
  `bcdedit /set {fwbootmgr} displayorder {bootmgr} /addfirst`). Leftover
  `opensuse` folder in the EFI partition is harmless (deletable via
  `mountvol S: /s`).
- **GRUB missing after a Windows update** → boot the USB in rescue mode, or
  firmware boot menu usually still lists "opensuse".

## Fallback plan

If Tumbleweed's flow doesn't click after a couple of weeks: Fedora Workstation
(same dual-boot procedure; NVIDIA via RPM Fusion; `dnf` instead of `zypper`).
