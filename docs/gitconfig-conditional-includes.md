# Git Multi-Account Setup

Separate GitHub accounts per directory tree, with the right SSH key **and** the
right commit identity. Two independent layers — either can fail without the other
noticing:

- **Auth** (which key pushes) comes from the remote URL → SSH host alias.
- **Authorship** (what email lands on the commit) comes from `includeIf`.

`.gitconfig` is tracked in this repo. The identity files and SSH config are
**not** — they hold real work emails and live only on the machine. A fresh
install needs the manual steps below or work repos silently commit under the
personal identity.

## Layout

| Tree | Account | Identity file |
|---|---|---|
| everything else | `DanielSuazoPavez` | (base `.gitconfig`) |
| `~/projects/work/raiz/` | `DanielSuazoRaiz` | `~/.gitconfig-raiz` |
| `~/projects/work/blumar/` | `Daniel-Suazo_blmr` | `~/.gitconfig-blumar` |

## Manual setup (not covered by install.sh)

### 1. Keys — one per account

```bash
ssh-keygen -t ed25519 -C "dsuazop@gmail.com"       -f ~/.ssh/id_ed25519_hata
ssh-keygen -t ed25519 -C "daniel.suazo@raiz.ai"    -f ~/.ssh/id_ed25519_raiz
ssh-keygen -t ed25519 -C "daniel.suazo@blumar.com" -f ~/.ssh/id_ed25519_blumar
```

Upload each `.pub` to its account as an **Authentication Key** (not a Signing
Key) at <https://github.com/settings/keys> — signed in as that account, so use a
private window when juggling all three.

Via `gh` instead, for an account with the `admin:public_key` scope:

```bash
gh auth switch --user DanielSuazoPavez
gh ssh-key add ~/.ssh/id_ed25519_hata.pub --title "hata-$(hostname)"
```

Work tokens don't need that scope — web UI avoids granting it.

### 2. `~/.ssh/config`

`IdentitiesOnly yes` is load-bearing: without it ssh offers every key in the
agent and GitHub authenticates as whichever matches first.

```
Host github-hata
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_hata
    IdentitiesOnly yes

Host github-raiz
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_raiz
    IdentitiesOnly yes

Host github-blumar
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_blumar
    IdentitiesOnly yes
```

The tracked `.gitconfig` rewrites `git@github.com:` → `git@github-hata:`, so
personal repos break until this file exists.

### 3. Identity files

```bash
cat > ~/.gitconfig-raiz <<'EOF'
[user]
	name = Daniel Suazo rAIz
	email = daniel.suazo@raiz.ai
	useConfigOnly = true
[url "git@github-raiz:"]
	insteadOf = https://github.com/
	insteadOf = git@github.com:
EOF
```

Same shape for `~/.gitconfig-blumar` (`Daniel Suazo Blumar`,
`daniel.suazo@blumar.com`, `github-blumar`).

`useConfigOnly = true` makes git refuse to commit rather than fall back to a
guessed identity — the tripwire for a tree that didn't match.

## Verify

Auth — three different names is the whole point. Two matching means a key went
to the wrong account:

```bash
ssh -T git@github-hata      # Hi DanielSuazoPavez!
ssh -T git@github-raiz      # Hi DanielSuazoRaiz!
ssh -T git@github-blumar    # Hi Daniel-Suazo_blmr!
```

Authorship, from inside a repo:

```bash
git config user.email   # the tree's email
git remote -v           # git@github-<account>:...
```

## Gotchas

- **`gitdir:` paths must end in `/`.**
- **Cloning into a new tree**: `includeIf` matches on `gitdir`, which doesn't
  exist yet during `clone`, so the work `insteadOf` can't apply. Use the alias
  explicitly the first time: `git clone git@github-raiz:org/repo.git`. Everything
  after that resolves on its own.
- **Repos outside the mapped trees fall back to personal identity silently.**
  Keep the directory convention; a misplaced work repo commits as `dsuazop@`.
- **The base config deliberately does *not* rewrite `https://`.** Personal repos
  keep using the `gh` credential helper. A global https→ssh rewrite would also
  catch `go get`, `pip install git+https://…`, and submodules.
- **`gh auth switch` is global state**, not per-repo. Only matters for API calls
  (`gh pr create`); push/pull identity comes from the SSH alias.

## Useful alias

```ini
[alias]
	whoami = "!git config user.name && git config user.email"
```
