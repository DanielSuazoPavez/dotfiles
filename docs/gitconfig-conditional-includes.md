# Git Conditional Includes

Use `includeIf` in `~/.gitconfig` to apply different configs per directory.

## Setup

```ini
# ~/.gitconfig

[user]
    name = Daniel Suazo Pavez
    email = dsuazop@gmail.com

# Override for work projects
[includeIf "gitdir:~/projects/work/"]
    path = ~/.gitconfig-work

# Override for a specific client
[includeIf "gitdir:~/projects/client-acme/"]
    path = ~/.gitconfig-acme
```

```ini
# ~/.gitconfig-work
[user]
    email = daniel@company.com
[commit]
    gpgsign = true
```

## Notes

- Path **must** end with `/` to match subdirectories
- Only applies inside git repos
- Can override any setting: user, aliases, core, signing keys, etc.
- Use `gitdir/i:` for case-insensitive matching (macOS/Windows)

## Verify

```bash
cd ~/projects/work/some-repo
git config user.email  # Should show overridden email
```

## Useful alias

```ini
[alias]
    whoami = "!git config user.name && git config user.email"
```

Then `git whoami` shows current identity for that repo.
