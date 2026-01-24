.PHONY: install test test-unit lint check clean help

# =============================================================================
# Docker + Worktrees Note:
# If using git worktrees with Docker, namespace resources by directory to avoid
# conflicts between worktrees. Add to your docker targets:
#
#   COMPOSE_PROJECT_NAME ?= $(notdir $(CURDIR))
#   export COMPOSE_PROJECT_NAME
#
# See: .claude/skills/git-worktrees/SKILL.md
# =============================================================================

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install dependencies and setup pre-commit hooks
	uv sync --extra dev && uv run pre-commit install

test:  ## Run tests
	uv sync --extra test && uv run pytest tests/ -v

test-unit:  ## Run unit tests
	uv sync --extra test && uv run pytest tests/ -m unit

lint:  ## Run linting
	uv sync --extra lint && uv run pre-commit run --all-files

check: lint test-unit  ## Run lint and unit tests

clean:  ## Clean build artifacts
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .ruff_cache/ .mypy_cache/
	rm -rf .coverage coverage.xml htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
