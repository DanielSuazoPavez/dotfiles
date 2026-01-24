# CLI & Make Commands Reference

## Quick Reference

**ONLY READ WHEN:** Need detailed command syntax.

---

## Make Targets

```bash
make install              # Install dotfiles, setup symlinks
make update               # Update dotfiles from repo
make backup               # Backup current dotfiles
```

---

## Pre-commit

```bash
pre-commit run --all-files    # Run all checks
pre-commit install            # Install hooks
```

---

## Template Usage

```bash
# Copy template to new project
cp -r templates/claude-project/.claude /path/to/project/
```
