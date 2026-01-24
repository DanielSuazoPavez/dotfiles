# Session: Claude-Project Template Expansion

## Branch
`main` - Expanded claude-project template with agents, skills, and improved workflow

## Work Completed
- Explored 4 repos for Claude tools patterns: claude-plugins-official, minimal-claude-code, get-shit-done, agent-toolkit
- Added 4 agents: debugger (persistent state), verifier (goal-backward), codebase-mapper, pattern-finder
- Added 6 skills: quick-review, mermaid-diagrams, database-schema, naming-analyzer, skill-judge, qa-test-planner
- Added memory: philosophy-reducing_entropy
- Updated session-start hook: auto-injects essential memories, lists others
- Updated list-memories: uses sed to extract Quick Reference only (no full file reads)
- Updated wrap-up: added session handoff with staleness tracking
- Updated draft-pr: simplified to PR description only (matches actual PR template)
- Added .planning/ directory structure (debug/, codebase/)
- Added .github/PULL_REQUEST_TEMPLATE.md
- Renamed .gitignore to template.gitignore to avoid nested ignore issues

## Current State
- 5 commits ahead of origin/main (unpushed)
- Template significantly expanded with patterns from GSD and agent-toolkit
- Memory system redesigned: essentials auto-load, others on-demand via /list-memories

## Key Decisions Made
- **Persistent debug state**: `.planning/debug/{slug}.md` survives context resets
- **3-level verification**: Exists → Substantive → Wired (from GSD verifier)
- **Session-start approach**: Output essential memories directly (no tool calls), list others by name
- **list-memories via sed**: Extract only Quick Reference sections without reading full files
- **template.gitignore**: Renamed to avoid nested .gitignore blocking files in dotfiles repo

## Repos Explored
1. **anthropics/claude-plugins-official** - Official plugin directory, standard plugin structure
2. **Byunk/minimal-claude-code** - Minimal plugin with operator agent, notifications
3. **glittercowboy/get-shit-done** - Spec-driven workflow, multi-agent orchestration, context budget rules
4. **softaworks/agent-toolkit** - 42 skills, 6 agents, session-handoff, reducing-entropy philosophy

## Next Steps
1. Explore obra/superpowers repo (remaining from initial list)
2. Push commits when ready
3. Test the new template in a real project

## Context for Next Session
- Superpowers repo URL: https://github.com/obra/superpowers
- It has 7-phase workflow: brainstorming, git worktree, plan writing, execution, TDD, code review, branch completion
- Focus on: skills library, automatic triggers, autonomous operation patterns
- Compare with what we already added from GSD
