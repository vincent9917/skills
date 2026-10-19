---
name: system-execution-report
description: Generates a structured implementation report reflecting on a just-completed feature — what was done, divergences, challenges. Use right after finishing an implementation, as the input to a system review.
---

# Execution Report

## Artifact location — session workspace

- Resolve `WORKSPACE_ROOT` to the absolute main project workspace root supplied by the current session environment. Exclude auxiliary visualization, cache, and tool directories. Do not substitute the shell's current directory, a nested Git repository, or the installed skill directory.
- If a prior skill already resolved this root in the same session, reuse it. If the environment has no clear main workspace or has multiple ambiguous project roots, ask the user to identify it before writing artifacts.
- Set `DOCS_ROOT` to `<WORKSPACE_ROOT>/docs`. Resolve it once per session and retain it across directory changes and skill handoffs. In a new session, derive it from that session's environment; never hardcode a machine-specific path in this skill.
- All generated document paths below beginning with `docs/` are relative to `WORKSPACE_ROOT`. Use absolute paths for file operations, command arguments, and handoffs; create the required output subdirectory if missing. Honor explicitly supplied artifact paths and destinations, including existing inputs from another workspace.
- Keep application code and Git commands in the target repository. The documentation directory may be outside that repository; only stage artifacts that are inside the repository being committed. Include the resolved artifact paths in the completion summary.


Review and deeply analyze the implementation you just completed.

## Context

You have just finished implementing a feature. Before moving on, reflect on:

- What you implemented
- How it aligns with the plan
- What challenges you encountered
- What diverged and why

## Generate Report

Save to: `docs/implementation-report/[feature-name]-execution-report.md`

### Meta Information

- Plan file: [path to plan that guided this implementation]
- Files added: [list with paths]
- Files modified: [list with paths]
- Lines changed: +X -Y

### Validation Results

- Syntax & Linting: ✓/✗ [details if failed]
- Type Checking: ✓/✗ [details if failed]
- Unit Tests: ✓/✗ [X passed, Y failed]
- Integration Tests: ✓/✗ [X passed, Y failed]

### What Went Well

List specific things that worked smoothly:

- [concrete examples]

### Challenges Encountered

List specific difficulties:

- [what was difficult and why]

### Divergences from Plan

For each divergence, document:

**[Divergence Title]**

- Planned: [what the plan specified]
- Actual: [what was implemented instead]
- Reason: [why this divergence occurred]
- Type: [Better approach found | Plan assumption wrong | Security concern | Performance issue | Other]

### Skipped Items

List anything from the plan that was not implemented:

- [what was skipped]
- Reason: [why it was skipped]

### Recommendations

Based on this implementation, what should change for next time?

- Plan skill improvements: [suggestions]
- Execute skill improvements: [suggestions]
- CLAUDE.md additions: [suggestions]
