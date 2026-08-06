# Dual-Boot Guide: Windows + openSUSE Tumbleweed

Decision: Tumbleweed first (rolling + snapper rollbacks), Fedora as fallback.

Phases 0–4 are the general procedure. Per-machine facts and the deviations each
one forced live in [Machines](#machines) at the bottom — read the entry for the
box you're on before starting, and add one when you do a new machine.

---

## Phase -1 — Intel VMD / RST check (do this first)

**Symptom if skipped:** the installer boots to a GRUB menu, prints an error, and
drops back to the firmware boot menu — or reaches the partitioner and shows no
disks at all. Easy to misread as a bad USB stick. It isn't.

Intel VMD (Volume Management Device, older firmware calls it RST) hides the NVMe
behind Intel's controller. Windows works because the OEM preloaded the driver;
Linux installers see no disk.

**Check from Windows** — Device Manager → Storage controllers:

- `Intel RST VMD Controller <id>` → VMD is **on**, fix it before anything else
- `Standard NVM Express Controller` → clear, skip to Phase 0

**Fix:** BIOS → find `VMD Controller` / `Intel VMD Technology` / `Volume
Management Device` → Disabled. On Acer the entry is hidden: press **Ctrl+S** on
the Main tab to unhide advanced options (other combos to try: Ctrl+Shift+S,
Ctrl+Alt+F12). Save via the Exit tab, then confirm in Device Manager that the
controller now reads `Standard NVM Express Controller`.

**Windows and VMD:** the standard advice is that disabling VMD bluescreens
Windows (INACCESSIBLE_BOOT_DEVICE) unless you first boot Safe Mode so it loads
the generic NVMe driver — `bcdedit /set {current} safeboot minimal`, flip VMD,
boot, then `bcdedit /deletevalue {current} safeboot`. On the Nitro this was
unnecessary: Windows picked up `stornvme` on its own. **Try the plain BIOS flip
first**, and keep Safe Mode as the fallback.

**If you do use the Safe Mode route, two traps:**

- Safe Mode disables Windows Hello, so **PIN login fails** ("PIN is not
  available") with no obvious password fallback. `safeboot network` does *not*
  fix this. Getting stuck here means clearing the flag from recovery.
- From WinRE (Shift+Restart → Troubleshoot → Advanced options → Command
  Prompt), **`{current}` refers to the recovery environment, not your Windows
  install** — `bcdedit /deletevalue {current} safeboot` returns "element not
  found" while the flag sits under `{default}`. Run `bcdedit /enum`, find the
  Windows Boot Loader block containing `safeboot Minimal`, and use that block's
  identifier.

**Escape hatch:** re-enabling VMD in the BIOS always restores Windows.

**Non-negotiable afterwards:** leave VMD off. Both OSes now depend on it —
turning it back on costs Windows the Safe Mode dance and Linux the disk.

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

# NVIDIA — see "NVIDIA driver" below before running this
sudo zypper install nvidia-open-driver-G07-signed-kmp-meta \
  nvidia-video-G07 nvidia-gl-G07 nvidia-compute-G07 nvidia-compute-utils-G07
sudo reboot

# Prerequisites for install.sh (it installs the rest of the roster itself)
sudo zypper in git curl wget unzip gcc make fontconfig bash-completion gh

# Claude Code + the rest of the roster: ./install.sh handles it

# GitHub auth + dotfiles
gh auth login
git clone https://github.com/DanielSuazoPavez/dotfiles.git ~/projects/personal/dotfiles
cd ~/projects/personal/dotfiles && ./install.sh
```

Fonts: install.sh's Nerd Fonts step works natively here (this is native
Linux, unlike WSL) — no Windows-side font install needed.

### NVIDIA driver — use the open signed kmp from `repo-oss`

**Do not use the G06 packages from `NVIDIA:repo-non-free`.** That repo's kernel
modules lag Tumbleweed's kernel badly — on 2026-08-05 the newest G06 kmp was
built for kernel 6.12.9 while Tumbleweed shipped 7.1.5. The module simply won't
load (`modprobe nvidia` → "module not found").

openSUSE builds its own **open kernel modules** in `repo-oss` and keeps them in
step with the kernel. They ship **prebuilt and signed**, so under Secure Boot
there is **no MOK enrollment screen** — its absence is correct here, not a
failure.

Verify a kmp exists for your running kernel before installing:

```bash
uname -r
zypper se -s nvidia | grep kmp     # look for a matching _kX.Y.Z_ build
```

Install the userspace plus the kmp **meta** package — the meta is what keeps the
module matched across future kernel updates:

```bash
sudo zypper install nvidia-open-driver-G07-signed-kmp-meta \
  nvidia-video-G07 nvidia-gl-G07 nvidia-compute-G07 nvidia-compute-utils-G07
```

Check the transaction summary **removes** any G06 packages — mixed generations
don't work. Want CUDA? Use `nvidia-open-driver-G07-signed-cuda-kmp-default`
instead and match the userspace version to it.

Then reboot and verify:

```bash
nvidia-smi              # should list the card, driver, CUDA version
lsmod | grep nvidia     # empty = module not loaded, see below
```

If `nvidia-smi` says "couldn't communicate with the driver" and `lsmod` is
empty, run `sudo modprobe nvidia` — its error is the diagnosis. "Module not
found" means kernel/kmp mismatch; compare `uname -r` against the `_kX.Y.Z_` in
`rpm -q nvidia-open-driver-G07-signed-kmp-default`.

Note `nvidia-smi` lives in `nvidia-compute-utils-G0X`, not `nvidia-compute-G0X`.

### Trap: booted into a read-only snapshot

**Symptom:** everything you install disappears on reboot. `zypper` succeeds,
the packages are simply gone next boot.

**Cause:** GRUB's default entry points at a read-only snapper snapshot instead
of the live root. Easy to land in by picking a "bootable snapshot" entry once —
it can then persist as the default.

**Tell:**

```bash
sudo btrfs subvolume get-default /   # names .snapshots/N/snapshot
findmnt -no SOURCE /
cat /proc/cmdline                    # rootflags=subvol=@/.snapshots/N/snapshot
```

**Fix** — creates a new *writable* subvolume from the current state and makes it
default:

```bash
sudo snapper rollback
sudo reboot
```

Afterwards `get-default` still shows `@/.snapshots/N/snapshot` with a **new** N.
That is normal and correct: a rolled-back system never returns to a bare `@`.
What matters is that it is writable — confirm with `sudo btrfs property get / ro`
(expect `ro=false`).

**Then redo anything installed while stuck in the snapshot** — it didn't persist.

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

---

## Machines

### Desktop — Kingston 512 GB (done 2026-07-22)

- Kingston NVMe 512 GB, GPT/UEFI
- C: = 456 GB, only ~15 GB free → Phase 0 cleanup was the blocker
- EFI partition: 300 MB (partition 1) — reused, not formatted
- BitLocker: OFF (verified, fully decrypted)
- VMD: not encountered

**Deviation:** Disk Management refused to shrink past ~5 GB even with 144 GB
free, pagefile and hibernation off, no shadow copies — NTFS metadata
(`$UsnJrnl`/`$MFT` zone) is unmovable from inside Windows. Resized from the
openSUSE installer instead (offline NTFS resize handles it). Prep first:
`chkdsk C: /scan`, re-enable pagefile, then a full **Restart** into the USB.

### Acer Nitro V15 — 1 TB (done 2026-08-05)

- 1 TB NVMe, GPT/UEFI, NVIDIA RTX
- Windows was OEM-preinstalled but OOBE never completed — nothing to back up
- Work machine; Windows kept for firmware updates, warranty, and any
  Windows-only corporate software
- Secure Boot: left ON throughout

**Deviation — Intel VMD was on.** Cost most of an evening before diagnosis.
Symptom: installer USB reached a GRUB menu, printed a load error, fell back to
the boot menu. Looked exactly like a bad USB write; the stick was fine. See
[Phase -1](#phase--1--intel-vmd--rst-check-do-this-first). Acer hides the
setting — **Ctrl+S** on the Main tab unhides it.

**Deviations from the desktop's experience:**

- Phase 0 didn't apply — fresh 1 TB disk, no space pressure.
- **Disk Management shrank fine here**, unlike the desktop. Shrink field asks
  how much to *remove*, not how much to keep: 975209 MB − 800000 MB left
  ~171 GB for Windows. No installer-side resize needed.
- Safe Mode was **not** required for the VMD switch — Windows loaded the
  standard NVMe driver by itself after the BIOS flip.

**Partitioning accepted:** 847 GB `/` btrfs + 2 GB swap + existing EFI mounted
(not formatted) at `/boot/efi`. Note 2 GB swap means **no hibernation** —
suspend-to-RAM still works; add a swap file later if hibernation is wanted.

**Post-install snags** (both now documented in Phase 4):

- Booted into read-only snapshot 1 for a while — `zypper dup` and the first
  NVIDIA install both evaporated on reboot before this was spotted.
- G06 from the NVIDIA repo was a dead end (newest kmp `_k6.12.9_` vs running
  kernel 7.1.5). Fixed by switching to `nvidia-open-driver-G07-signed-kmp-meta`
  from `repo-oss`. Result: RTX 5060 Laptop 8 GB, driver 595.84, CUDA 13.2, no
  MOK screen needed.

**Boot order:** GRUB installed correctly but the firmware listed Windows first;
the openSUSE entry showed as a **blank label** in the Acer boot list. F12 →
third (empty) entry reached GRUB. Reordering in the BIOS Boot tab sorted it.
