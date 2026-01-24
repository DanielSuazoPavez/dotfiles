Use before creating a PR. Generates changelog entry and pull request description drafts.

## Instructions

1. **Analyze the branch**: Review commits, changed files, and the overall purpose of the work done on this branch.

2. **Generate `changelog_entry.md`** following this format:
   ```markdown
   ## X.Y.Z
   **Type**: Short Title

   * **Category** (e.g., Build & Infrastructure, Bug Fixes, Model, etc.):
       - Change description with specific details
       - Another change in same category

   * **Another Category**:
       - Changes in this category
   ```

   Guidelines:
   - Type: Feature, Chore, Fix, Refactor, etc.
   - Use bullet points with specific, actionable descriptions
   - Group related changes under category headers
   - Include "Removed" section if applicable
   - Reference specific files/modules when helpful

3. **Generate `pull_request_entry.md`** following this structure:
   ```markdown
   ## Description
   [Concise summary of what this PR does]

   ## Motivation and Context
   [Why this change is needed]

   ## How has this been tested?
   [Testing approach - manual, automated, or N/A with reason]

   ## Checklist
   - [ ] Include changes in the root `CHANGELOG.md`
   - [ ] Bumped package version in the `pyproject.toml`
   - [ ] Update tests
   - [ ] Update documentation
   ```

4. **Write both files** to `docs/branch/{branch-name}/` where `{branch-name}` is the current git branch name with `/` replaced by `_` (e.g., `feat/add-feature` → `feat_add-feature`).

5. **Report** what was generated with a brief summary.
