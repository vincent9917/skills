---
name: piv-review-changes
description: Performs a technical code review of recently changed files for bugs, security issues, and standards compliance, then writes a report. Use before committing, as a pre-commit quality gate.
---

# Code Review

## Artifact location — session workspace

- Resolve `WORKSPACE_ROOT` to the absolute main project workspace root supplied by the current session environment. Exclude auxiliary visualization, cache, and tool directories. Do not substitute the shell's current directory, a nested Git repository, or the installed skill directory.
- If a prior skill already resolved this root in the same session, reuse it. If the environment has no clear main workspace or has multiple ambiguous project roots, ask the user to identify it before writing artifacts.
- Set `DOCS_ROOT` to `<WORKSPACE_ROOT>/docs`. Resolve it once per session and retain it across directory changes and skill handoffs. In a new session, derive it from that session's environment; never hardcode a machine-specific path in this skill.
- All generated document paths below beginning with `docs/` are relative to `WORKSPACE_ROOT`. Use absolute paths for file operations, command arguments, and handoffs; create the required output subdirectory if missing. Honor explicitly supplied artifact paths and destinations, including existing inputs from another workspace.
- Keep application code and Git commands in the target repository. The documentation directory may be outside that repository; only stage artifacts that are inside the repository being committed. Include the resolved artifact paths in the completion summary.


Perform technical code review on recently changed files.

## Core Principles

Review Philosophy:

- Simplicity is the ultimate sophistication - every line should justify its existence
- Code is read far more often than it's written - optimize for readability
- The best code is often the code you don't write
- Elegance emerges from clarity of intent and economy of expression

## What to Review

Start by gathering codebase context to understand the codebase standards and patterns.

Start by examining:

- CLAUDE.md
- README.md
- Key files in the core module
- Documented standards in the docs directory (and any `.claude/references/` docs)

After you have a good understanding, run these commands:

```bash
git status
git diff HEAD
git diff --stat HEAD
```

Then check the list of new files:

```bash
git ls-files --others --exclude-standard
```

Read each new file in its entirety. Read each changed file in its entirety (not just the diff) to understand full context.

For each changed file or new file, analyze for:

1. **Logic Errors**
   - Off-by-one errors
   - Incorrect conditionals
   - Missing error handling
   - Race conditions

2. **Security Issues**
   - SQL injection vulnerabilities
   - XSS vulnerabilities
   - Insecure data handling
   - Exposed secrets or API keys

3. **Performance Problems**
   - N+1 queries
   - Inefficient algorithms
   - Memory leaks
   - Unnecessary computations

4. **Code Quality**
   - Violations of DRY principle
   - Overly complex functions
   - Poor naming
   - Missing type hints/annotations

5. **Adherence to Codebase Standards and Existing Patterns**
   - Adherence to standards documented in the docs directory
   - Linting, typing, and formatting standards
   - Logging standards
   - Testing standards

## Verify Issues Are Real

- Run specific tests for issues found
- Confirm type errors are legitimate
- Validate security concerns with context

## Output Format

Resolve `docs/review-report/` from `WORKSPACE_ROOT` and create it if missing.

Save a new file to `docs/review-report/[appropriate-name].md`

**Stats:**

- Files Modified: 0
- Files Added: 0
- Files Deleted: 0
- New lines: 0
- Deleted lines: 0

**For each issue found:**

```
severity: critical|high|medium|low
file: path/to/file.py
line: 42
issue: [one-line description]
detail: [explanation of why this is a problem]
suggestion: [how to fix it]
```

If no issues found: "Code review passed. No technical issues detected."

## Important

- Be specific (line numbers, not vague complaints)
- Focus on real bugs, not style
- Suggest fixes, don't just complain
- Flag security issues as CRITICAL
