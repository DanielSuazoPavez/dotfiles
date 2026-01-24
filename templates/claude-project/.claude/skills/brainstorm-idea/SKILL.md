Turns fuzzy ideas into clear designs through structured dialogue. Use BEFORE plan mode.

## When to Use

- User has an idea but hasn't defined what to build
- Requirements are unclear or open-ended
- Multiple approaches seem viable

## Process

### Phase 1: Understand the Idea

Ask questions **one at a time** to clarify:
- What problem does this solve?
- Who is it for?
- What does success look like?
- What are the constraints (time, tech, scope)?

Prefer **multiple choice** questions when feasible - easier to answer, faster to converge.

### Phase 2: Explore Approaches

Present **2-3 alternatives** with trade-offs before committing:

| Approach | Pros | Cons |
|----------|------|------|
| A: ... | ... | ... |
| B: ... | ... | ... |

Let the user choose direction.

### Phase 3: Incremental Design

Share design in **200-300 word chunks**:
1. Architecture overview
2. Key components
3. Data flow
4. Error handling
5. Testing approach

**Validate after each section** before moving forward. Catch misalignments early.

## Key Principles

- **YAGNI**: Ruthlessly cut features that aren't essential
- **One question per message**: Don't overwhelm
- **Concrete over abstract**: Show examples, not just concepts
- **Revisit assumptions**: If something feels off, go back

## Output

Save validated design to: `docs/plans/YYYY-MM-DD-<topic>-design.md`

Then either:
- Stop here (design only)
- Proceed to implementation planning (use plan mode)

## Anti-patterns

- Asking 5 questions at once
- Jumping to implementation before design is clear
- Building for hypothetical future requirements
- Skipping validation to "save time"
