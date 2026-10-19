---
name: piv-run-full-loop
description: Autonomously develops a complete feature from priming through planning, execution, and commit by chaining the four core PIV-loop skills. Use when you want a full hands-off feature build from a single description.
argument-hint: [feature-description]
---

# End-to-End Feature Development

## Artifact location — session workspace

- Resolve `WORKSPACE_ROOT` to the absolute main project workspace root supplied by the current session environment. Exclude auxiliary visualization, cache, and tool directories. Do not substitute the shell's current directory, a nested Git repository, or the installed skill directory.
- If a prior skill already resolved this root in the same session, reuse it. If the environment has no clear main workspace or has multiple ambiguous project roots, ask the user to identify it before writing artifacts.
- Set `DOCS_ROOT` to `<WORKSPACE_ROOT>/docs`. Resolve it once per session and retain it across directory changes and skill handoffs. In a new session, derive it from that session's environment; never hardcode a machine-specific path in this skill.
- All generated document paths below beginning with `docs/` are relative to `WORKSPACE_ROOT`. Use absolute paths for file operations, command arguments, and handoffs; create the required output subdirectory if missing. Honor explicitly supplied artifact paths and destinations, including existing inputs from another workspace.
- Keep application code and Git commands in the target repository. The documentation directory may be outside that repository; only stage artifacts that are inside the repository being committed. Include the resolved artifact paths in the completion summary.


**Feature Description**: $ARGUMENTS

This skill chains the 4 core PIV-loop skills for autonomous feature development.

---

## Step 1: Prime - Load Codebase Context

Execute the priming workflow to understand the codebase.

Run the `prime-codebase` skill (`.claude/skills/prime-codebase/SKILL.md`).

---

## Step 2: Planning - Create Implementation Plan

Create a detailed implementation plan for the feature.

Run the `piv-plan-implementation` skill (`.claude/skills/piv-plan-implementation/SKILL.md`) with the feature description: **$ARGUMENTS**.

**IMPORTANT**: Note the feature name (and plan file path) that the planning step creates. You'll need it for the next step.

---

## Step 3: Execute - Implement the Feature

Implement the feature from the plan document.

Run the `piv-implement` skill (`.claude/skills/piv-implement/SKILL.md`) with the plan file path: `docs/implementation-plan/[feature-name].md`.

Pass the actual absolute plan path returned by Step 2; do not reconstruct it relative to the shell directory.

---

## Step 4: Commit - Save Changes

Create a git commit for all changes.

Run the `piv-commit` skill (`.claude/skills/piv-commit/SKILL.md`).

---

## Final Summary

After completing all 4 steps, provide:

### Feature Implementation Complete

**Original Request**: $ARGUMENTS

**Feature Name**: [feature-name from planning step]

**Steps Executed:**
1. ✅ Prime - Codebase context loaded
2. ✅ Planning - Plan created at `docs/implementation-plan/[feature-name].md`
3. ✅ Execute - Feature implemented and validated
4. ✅ Commit - Changes committed to git

**Outputs:**
- Plan document: `docs/implementation-plan/[feature-name].md`
- Files created/modified: [list]
- Tests added: [list]
- Commit hash: [hash]

**Next Steps:**
- Push to remote: `git push`
- Create pull request (if applicable)
- Continue with next feature
