---
name: piv-implement
description: Executes an implementation plan task-by-task with validation at every step. Use when you have a completed feature plan and want to implement it in one pass.
argument-hint: [path-to-plan]
---

# Execute: Implement from Plan

## Artifact location — session workspace

- Resolve `WORKSPACE_ROOT` to the absolute main project workspace root supplied by the current session environment. Exclude auxiliary visualization, cache, and tool directories. Do not substitute the shell's current directory, a nested Git repository, or the installed skill directory.
- If a prior skill already resolved this root in the same session, reuse it. If the environment has no clear main workspace or has multiple ambiguous project roots, ask the user to identify it before writing artifacts.
- Set `DOCS_ROOT` to `<WORKSPACE_ROOT>/docs`. Resolve it once per session and retain it across directory changes and skill handoffs. In a new session, derive it from that session's environment; never hardcode a machine-specific path in this skill.
- All generated document paths below beginning with `docs/` are relative to `WORKSPACE_ROOT`. Use absolute paths for file operations, command arguments, and handoffs; create the required output subdirectory if missing. Honor explicitly supplied artifact paths and destinations, including existing inputs from another workspace.
- Keep application code and Git commands in the target repository. The documentation directory may be outside that repository; only stage artifacts that are inside the repository being committed. Include the resolved artifact paths in the completion summary.


## Plan to Execute

Read plan file: `$ARGUMENTS`

## Before you start — work on a feature branch

A ticket gets built on its own branch, so it can become one PR. **Ideally you're already on that branch — cut it
before planning — so the plan commit you made is on it and rides into the PR; a plan committed on the base branch
won't be in this branch's PR.** If you're still on base, this step creates the branch now. Detect the base branch
(don't hardcode `main`): `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
(fallback `main`).

- **On the base branch, clean** → create one: `git checkout -b feature/<plan-slug>`.
- **Already on a feature branch or in a worktree** → use it.
- **On the base branch with uncommitted changes** → STOP: commit or stash first.

(One branch per ticket is also what makes parallel worktrees clean later.)

## Execution Instructions

### 1. Read and Understand

- Read the ENTIRE plan carefully
- Understand all tasks and their dependencies
- Note the validation commands to run
- Review the testing strategy

### 2. Execute Tasks in Order

For EACH task in "Step by Step Tasks":

#### a. Navigate to the task
- Identify the file and action required
- Read existing related files if modifying

#### b. Implement the task
- Follow the detailed specifications exactly
- Maintain consistency with existing code patterns
- Include proper type hints and documentation
- Add structured logging where appropriate

#### c. Verify as you go
- After each file change, check syntax
- Ensure imports are correct
- Verify types are properly defined
- **Run the task's own `VALIDATE` command before starting the next task.** Every task in the plan carries one.
  A task is not done until its check passes — if it fails, fix it now rather than carrying the failure forward.
  The full suite still runs at step 4; this is the per-task gate that keeps step 4 from becoming a pile-up.

### 3. Implement Testing Strategy

After completing implementation tasks:

- Create all test files specified in the plan
- Implement all test cases mentioned
- Follow the testing approach outlined
- Ensure tests cover edge cases

### 4. Run Validation Commands

Execute ALL validation commands from the plan in order:

```bash
# Run each command exactly as specified in plan
```

If any command fails:
- Fix the issue
- Re-run the command
- Continue only when it passes

### 5. Final Verification

Before completing:

- ✅ All tasks from plan completed
- ✅ All tests created and passing
- ✅ All validation commands pass
- ✅ Code follows project conventions
- ✅ Documentation added/updated as needed

## Output — write an implementation report

Resolve `docs/implementation-report/` from `WORKSPACE_ROOT` and create it if missing.

Write a short report to `docs/implementation-report/<plan-slug>-report.md` (and print the summary). This is what the PR body
and the `piv-review-pr` gate read — especially the **deviations** (a documented deviation is an *intentional*
decision the reviewer should not flag):

```markdown
# Implementation Report — <feature>

**Plan**: <path>   **Branch**: <feature/...>   **Status**: COMPLETE | PARTIAL

## Summary
{What was built, 2-4 sentences.}

## Tasks completed
- [task] → `path/to/file` (CREATE/UPDATE)

## Tests added
{Test files + cases + results.}

## Validation results
{Type-check / lint / tests / build — pass/fail with counts.}

## Deviations from the plan
{What changed vs the plan and WHY — or "none". This is the reviewer's signal of intent.}

## Issues encountered
{Anything notable, or "none".}
```

### Ready for the next step
- Confirm all changes are complete and validations pass.
- Next: `piv-commit` the work, then `piv-create-pr` to open the PR (the report fills the PR body), then `piv-review-pr`.

## Notes

- If you encounter issues not addressed in the plan, document them
- If you need to deviate from the plan, explain why
- If tests fail, fix implementation until they pass
- Don't skip validation steps
