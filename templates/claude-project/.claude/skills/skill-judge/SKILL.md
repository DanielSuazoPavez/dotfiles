---
name: skill-judge
description: Evaluate Agent Skill design quality against specifications and best practices. Use when reviewing, auditing, or improving SKILL.md files. Provides multi-dimensional scoring and actionable improvements.
disable-model-invocation: true
---

# Skill Judge

Evaluate skill design quality against best practices.

## Core Philosophy

**What is a Skill?** A knowledge externalization mechanism, not a tutorial.

**The Formula:** `Good Skill = Expert-only Knowledge − What Claude Already Knows`

Value = knowledge delta. Skills should contain decision trees, trade-offs, edge cases, domain frameworks—not basics Claude already understands.

## Three Knowledge Types

| Type | Action | Example |
|------|--------|---------|
| **Expert** | Keep | Non-obvious decision trees, trade-offs |
| **Activation** | Keep sparingly | Brief reminders of known concepts |
| **Redundant** | Delete | Basic concepts Claude knows |

## Evaluation Dimensions (120 points)

### D1: Knowledge Delta (20 pts) - Most Critical
Does it add genuine expert knowledge?
- Red flags: "What is X" sections, generic best practices
- Green flags: Non-obvious decisions, expert trade-offs

### D2: Mindset + Procedures (15 pts)
Does it transfer expert thinking AND domain-specific workflows?

### D3: Anti-Pattern Quality (15 pts)
Are anti-patterns specific with reasoning, not vague warnings?

### D4: Specification Compliance (15 pts)
Is the description clear about WHAT, WHEN, and KEYWORDS for triggering?

### D5: Progressive Disclosure (15 pts)
- Metadata: Always in memory
- Body: Loaded when triggered
- References: On-demand
- Target: Under 500 lines

### D6: Freedom Calibration (15 pts)
- Creative tasks → High freedom (principles)
- Fragile operations → Low freedom (exact scripts)

### D7: Pattern Recognition (10 pts)
Does it follow established patterns?
- Mindset (~50 lines)
- Navigation (~30 lines)
- Philosophy (~150 lines)
- Process (~200 lines)
- Tool (~300 lines)

### D8: Practical Usability (15 pts)
Decision trees, working examples, error handling, edge cases?

## Grading Scale

| Grade | Score | Status |
|-------|-------|--------|
| A | 90%+ (108+) | Production-ready |
| B | 80-89% | Minor improvements |
| C | 70-79% | Clear improvement path |
| D | 60-69% | Significant issues |
| F | <60% | Needs redesign |

## Common Failures

1. **The Tutorial** - Explains basics Claude knows
2. **The Dump** - 800+ lines, everything included
3. **The Invisible Skill** - Great content, vague description
4. **The Freedom Mismatch** - Rigid for creative, vague for fragile

## Evaluation Protocol

1. Read completely, mark sections as [E]xpert, [A]ctivation, [R]edundant
2. Analyze structure: frontmatter, line count, pattern
3. Score each dimension with evidence
4. Calculate total, assign grade
5. Generate report with critical issues and top 3 improvements

## The Meta-Question

> "Would an expert say this captures knowledge requiring years to learn?"

If yes → genuine value. If no → it's compressing what Claude already knows.
