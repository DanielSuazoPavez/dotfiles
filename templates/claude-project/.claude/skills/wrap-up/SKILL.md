Use when finishing a feature branch. Updates changelog, bumps version, updates backlog, and commits.

## Instructions

1. **Check for uncommitted code changes**:
   - Run `git status` to check for uncommitted changes
   - If there are uncommitted code changes (src/, tests/, etc.):
     - Review the changes with `git diff`
     - Commit them first with an appropriate message (feat:, fix:, refactor:, test:, etc.)
     - This ensures the feature code is committed before the docs/version commit
   - Skip this step if only docs files (CHANGELOG.md, BACKLOG.md, etc.) are modified

2. **Analyze the branch**: Review commits since branching from main to understand what was done.

3. **Determine version bump**:
   - Read current version from `pyproject.toml`
   - Increment based on changes:
     - **Major** (X.0.0): Breaking changes
     - **Minor** (0.X.0): New features (default for feature branches)
     - **Patch** (0.0.X): Bug fixes only

4. **Update `CHANGELOG.md`**:
   - Add new entry at the top (after `# Changelog` header)
   - Format:
     ```markdown
     ## [X.Y.Z] - YYYY-MM-DD - Short Title

     ### Added
     - Feature description

     ### Changed
     - Change description

     ### Fixed
     - Fix description

     ### Usage (if applicable)
     ```bash
     example command
     ```
     ```
   - Only include sections that apply
   - Be specific about what was added/changed

5. **Update `pyproject.toml`**:
   - Bump the `version` field to the new version

6. **Update `BACKLOG.md`**:
   - Move completed items from backlog to "Recently Completed" section
   - Add any new backlog items discovered during implementation
   - Mark completed items with `[x]`

7. **Update `CLAUDE.md`** (if applicable):
   - Add new CLI commands to the Commands section
   - Add new files/modules to Architecture section
   - Note: CLAUDE.md is gitignored, so this is for local reference only

8. **Commit all changes**:
   ```bash
   git add CHANGELOG.md pyproject.toml BACKLOG.md uv.lock
   git commit -m "docs: update changelog, version X.Y.Z, backlog"
   ```

9. **Report** what was updated with a brief summary.

## Notes

- Uncommitted code changes will be committed first (step 1), then docs/version updates
- The `uv-lock` pre-commit hook will auto-update `uv.lock` on version change
- If commit fails due to hooks modifying files, re-run the commit
