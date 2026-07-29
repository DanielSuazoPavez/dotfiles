.PHONY: help install update dev-setup check-secrets lint install-hooks clean test backup

help:  ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install dotfiles (run install.sh)
	@./install.sh

update:  ## Pull latest changes from git
	@echo "Updating dotfiles..."
	@git pull origin main
	@echo "Updated! Restart terminal or run: source ~/.bashrc"

dev-setup:  ## Install dev tooling (shellcheck, pre-commit) + git hooks
	@./scripts/dev-setup.sh
	@$(MAKE) install-hooks

check-secrets:  ## Run pre-commit secret detection
	@pre-commit run gitleaks --all-files

lint:  ## Run all pre-commit hooks
	@pre-commit run --all-files

install-hooks:  ## Install pre-commit hooks
	@pre-commit install
	@echo "Pre-commit hooks installed"

clean:  ## Clean backup directories older than 30 days
	@echo "Cleaning old backups..."
	@find ~ -maxdepth 1 -name "dotfiles-backup-*" -type d -mtime +30 -exec rm -rf {} \;
	@echo "Cleanup complete"

test:  ## Run the test harness against a scratch HOME
	@bash -n install.sh && bash -n uninstall.sh && bash -n links.sh
	@echo "Running tests..."
	@for t in tests/test_*.sh; do echo "  → $$t"; bash "$$t" || exit 1; done
	@echo "All tests passed"

backup:  ## Create manual backup of current configs
	@BACKUP_DIR="$$HOME/dotfiles-manual-backup-$$(date +%Y%m%d-%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	cp ~/.bashrc "$$BACKUP_DIR/" 2>/dev/null || true; \
	cp ~/.aliases "$$BACKUP_DIR/" 2>/dev/null || true; \
	echo "Backup created at $$BACKUP_DIR"
