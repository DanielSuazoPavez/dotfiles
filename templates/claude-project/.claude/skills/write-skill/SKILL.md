Create new skills using test-driven documentation. No skill without a failing test first.

## When to Use

- Adding a new skill to `.claude/skills/`
- Improving an existing skill that isn't working reliably
- Extracting a repeatable pattern into a reusable skill

## Process: Red-Green-Refactor for Skills

### RED: Document the Failure

Before writing the skill:
1. Run the scenario without the skill
2. Document what goes wrong (missed steps, wrong approach, etc.)
3. This is your "failing test" - the gap the skill must fill

### GREEN: Write Minimal Skill

Address only the documented failures:
- Don't over-engineer
- Don't add "nice to have" sections
- Keep it focused on the gap

### REFACTOR: Close Loopholes

Test the skill, find edge cases where it fails, tighten the language.

## Skill Structure

```
.claude/skills/<skill-name>/SKILL.md
```

### Required Sections

1. **First line**: "Use when..." - triggering conditions only
2. **When to Use**: Symptoms that indicate this skill applies
3. **Process/Instructions**: The actual workflow
4. **Anti-patterns** (optional): Common mistakes

### Description Rules

The first line (description) must:
- Start with "Use when..." or action verb
- List only triggering conditions
- Never summarize the workflow

Why? If description summarizes workflow, Claude may follow description instead of reading full content.

## Token Efficiency

| Skill Type | Target |
|------------|--------|
| Getting-started | <150 words |
| Standard | <500 words |
| Complex reference | Use supporting files |

Techniques:
- Cross-reference other skills instead of repeating
- Move heavy examples to separate files
- Compress: show pattern once, not every variation

## Testing Your Skill

Run the original failing scenario with the skill active:
- Does it address the gap?
- Any new edge cases?
- Is it too verbose? Too terse?

## Naming Convention

Two words, hyphenated: `write-skill`, `quick-review`, `brainstorm-idea`
