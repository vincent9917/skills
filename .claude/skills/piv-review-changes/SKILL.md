---
name: piv-review-changes
description: Reviews recent code changes for bugs, security issues, requirements and acceptance criteria, cross-module compatibility, and standards compliance, then writes an evidence-based report. Use before committing, as a pre-commit quality gate.
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
- Relevant user requirements, linked ticket, PRD, acceptance criteria, and implementation plan, when available. Use the latest agreed scope and documented decisions; do not invent missing requirements.

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

Trace changed interfaces and behavior to their relevant callers, dependencies, and downstream consumers, including unchanged files and consumers of deleted code. Follow applicable repository code-navigation rules. Inspect enough surrounding code to establish impact; do not expand into an unrelated whole-system audit. If a consumer is outside the accessible codebase, record the verification limit.

Select checks according to the change's scope and risk. Report defects introduced or exposed by this change; keep unrelated pre-existing issues outside the review verdict.

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

6. **Requirements and Acceptance Criteria**
   - Compare changed behavior with the relevant requirements and acceptance criteria; identify omissions, incorrect behavior, and unintended scope changes.
   - Check that applicable acceptance scenarios are supported by implementation and, where available, tests or other evidence. Plan completion alone is not proof of correct behavior.
   - Respect agreed requirement changes and documented implementation deviations. A deviation is not automatically a defect; still check its impact on requirements and compatibility.
   - If requirements are unavailable or ambiguous, state the gap and mark affected criteria as unverified rather than guessing or claiming full acceptance.

7. **Cross-Module Impact and Compatibility**
   - Trace changed or removed functions, types, APIs, events, and shared components to callers and downstream consumers.
   - Check request/response schemas, error behavior, defaults, and configuration contracts for breaking changes.
   - For database/schema changes, examine existing data compatibility, migration needs, and mixed-version deployment where relevant.
   - Verify affected integrations and existing consumers with targeted checks. Distinguish intentional, coordinated breaking changes from accidental regressions; record inaccessible consumers as unverified.

## Verify Issues Are Real

- For each candidate finding, identify a concrete trigger, affected behavior, impact, and supporting evidence before classifying it.
- Run targeted tests or checks where useful; use a demonstrable code path when execution is unavailable. Record which checks ran, their results, and any verification limits. Do not imply a test ran when it did not.
- Confirm type errors and compatibility concerns against actual callers and contracts.
- Validate security concerns against reachable inputs, trust boundaries, and required privileges; do not classify a hypothetical attack as a confirmed defect.
- Separate **confirmed defects**, **unverified risks**, and **improvement suggestions**. Missing evidence is a reason to qualify a claim, not to promote it to a defect.

## Severity and Review Verdict

Assign severity to confirmed defects based on impact, reachability, exploit prerequisites, affected scope, and recoverability. Security findings use the same scale, not an automatic CRITICAL rating.

| Severity | Guidance |
| --- | --- |
| critical | Reachable conditions can cause catastrophic data loss, broad compromise, or a widespread outage. |
| high | A major function, security boundary, or compatibility contract fails under realistic conditions. |
| medium | A meaningful defect has limited scope or requires less common conditions; a workaround may exist. |
| low | A minor confirmed defect has narrow impact. Style preferences alone are suggestions. |

Use **CHANGES REQUIRED** when confirmed defects need correction, **NEEDS VERIFICATION** when no confirmed defects remain but relevant risks or acceptance criteria are unresolved, and **PASS** when applicable checks reveal no defects or unresolved risks. Suggestions alone do not block a pass. Always state the scope and verification limits; a technical review is not proof of full product acceptance.

## Output Format

Resolve `docs/review-report/` from `WORKSPACE_ROOT` and create it if missing.

Save a new file to `docs/review-report/[appropriate-name].md`

**Stats:**

- Files Modified: 0
- Files Added: 0
- Files Deleted: 0
- New lines: 0
- Deleted lines: 0

**Review context:**

- Reviewed scope and requirement/plan references
- Applicable acceptance criteria: verified, unmet, or unverified, with evidence
- Affected callers, modules, and compatibility contracts
- Checks executed, results, and verification limits
- Overall verdict: PASS | CHANGES REQUIRED | NEEDS VERIFICATION

Group findings under **Confirmed Defects**, **Unverified Risks**, and **Improvement Suggestions**. For each finding:

```text
classification: confirmed-defect|unverified-risk|improvement-suggestion
severity: critical|high|medium|low (confirmed defects only)
file: path/to/file.py
line: 42
issue: [one-line description]
trigger: [input, state, or execution conditions]
impact: [affected behavior, users, data, or consumers]
evidence: [code path with file:line references, contract, test result, or requirement]
detail: [why the behavior is wrong, uncertain, or worth improving]
suggestion: [concrete fix or next verification step]
```

For unverified risks, identify missing evidence and the check needed to resolve them; label potential impact as conditional. For suggestions, explain the benefit without presenting it as an existing failure. Use actual line references where available; do not fabricate locations for missing requirements or inaccessible consumers.

If no confirmed defects are found, say so. Use "Code review passed. No technical issues detected." only for a PASS verdict, and include verification limits.

## Important

- Be specific (line numbers, not vague complaints)
- Focus on real bugs, not style
- Suggest fixes, don't just complain
- Base severity on demonstrated impact and conditions, including for security issues.
- Keep review depth proportional to the change; avoid unrelated audits and speculative findings.
