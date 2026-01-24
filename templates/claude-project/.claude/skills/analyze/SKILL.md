Use for research and exploration tasks. Investigates a topic, gathers evidence, and generates a saved report.

## Context

The user provides context after `/analyze` describing what to investigate. Examples:
- `/analyze feasibility of adding real-time alerts`
- `/analyze current test coverage gaps`
- `/analyze over-engineering in the codebase`

## Instructions

1. **Understand the scope**: Parse the user's context to identify what needs analysis.

2. **Explore thoroughly**:
   - Use Glob, Grep, Read to investigate relevant code/docs
   - Use Task tool with Explore agent for broad codebase questions
   - Gather concrete evidence (file paths, line counts, patterns found)

3. **Evaluate objectively**:
   - Assess findings against practical criteria
   - Note trade-offs, not just problems
   - Distinguish facts from opinions
   - Be direct about conclusions

4. **Generate report**: Create a markdown report with:
   - Clear title and date
   - Executive summary (2-3 sentences)
   - Detailed findings with evidence
   - Concrete recommendations (if applicable)
   - Metrics/data where relevant

5. **Save report**:
   - Path: `docs/analysis/<YYYYMMDD_HHMMSS>_<topic>.md`
   - Use a slugified version of the topic for filename
   - Example: `docs/analysis/20260121_143022_test_coverage_gaps.md`

6. **Output to console**:
   - Show the full report content
   - Note the file path where it was saved

## Report Template

```markdown
# [Topic] Analysis Report

**Date**: YYYY-MM-DD HH:MM:SS
**Scope**: [What was analyzed]

---

## Summary

[2-3 sentence executive summary]

---

## Findings

### [Finding 1 Title]

[Description with evidence: file paths, code snippets, metrics]

### [Finding 2 Title]

...

---

## Recommendations

| Priority | Action |
|----------|--------|
| ... | ... |

---

## Metrics (if applicable)

| Metric | Value |
|--------|-------|
| ... | ... |
```

## Notes

- This is exploration and reporting, NOT planning or implementation
- Be factual and evidence-based
- Include file paths and line numbers for traceability
- Keep recommendations actionable but don't implement them
