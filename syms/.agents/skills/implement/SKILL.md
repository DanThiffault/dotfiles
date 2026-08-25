---
name: implement
description: Implement a single task from a GitHub issue created by the plan-task skill. Reads the issue, resolves ambiguity, TDDs the implementation on a fresh branch, and reports the branch for user review. Invoke when the user says /implement or references an issue number/URL.
---

# Implement Task

Implement a single, self-contained task from a GitHub issue produced by the `plan-task` skill.

## Pre-requisites

- A GitHub issue exists in the current repository (standalone or feature task).
- The issue body contains a valid plan with empty Open Questions.
- Git is initialized and the working tree is clean (or you know what to stash).
- The `tdd` skill is available (loaded automatically or referenced below).

## Step 1: Read the Issue

Read the issue using the GitHub CLI:

```bash
gh issue view <ISSUE_NUMBER> --json title,body,labels,state,number,url
```

Extract from the body:
- Title / goal
- Acceptance criteria
- Scope (in and out)
- Seams / boundaries
- Technical notes
- Error handling requirements
- Testing strategy
- Open questions (this section **must** be empty for a valid plan)
- New or changing domain concepts

If the user provides an issue number, use it directly. If they reference an issue by URL, extract the number.

## Step 2: Resolve Ambiguity

Before writing any code, scan the issue body for ambiguity. Ambiguity includes:

- **Open questions** section is non-empty
- **Acceptance criteria** that can't be verified (vague words like "fast", "better", "improved")
- Missing or unclear interfaces ("update the widget" — what is the widget's API?)
- Undefined data shapes ("store the result" — in what format?)
- Unclear error behavior ("handle errors" — how?)
- Seams that don't match the actual codebase
- Domain concepts that conflict with existing code

If you find ambiguity, **stop**. Ask the user targeted questions. After each answer, post a comment on the issue with the resolution:

```bash
gh issue comment <ISSUE_NUMBER> --body "**Q:** What is the expected error message when the user is not found?

**A:** \"User with ID {id} does not exist.\" (404)"
```

Keep asking until the plan is unambiguous. Do not proceed to implementation while ambiguity exists.

## Step 3: Prepare the Branch

Ensure the working tree is clean. Stash or abort if not.

Create a fresh branch from the current HEAD:

```bash
# Use kebab-case based on the task title
git checkout -b task/<short-kebab-description>
```

Example: `task/add-user-auth`

## Step 4: Implement (TDD)

Follow the `tdd` skill rules:

1. **Identify seams** — Confirm the public interface with the user before writing the first test. Write the seam list in a scratchpad or as a code comment.
2. **Red** — Write a failing test. Run it. Watch it fail for the right reason.
3. **Green** — Write the minimal code to pass. Do not refactor yet.
4. **Repeat** — One vertical slice at a time. One seam, one test, one minimal implementation per cycle.

Consult `tdd` skill for:
- What a good test is (see `tests.md`)
- When to mock (see `mocking.md`)
- Anti-patterns (implementation-coupled, tautological, horizontal slicing)
- Rules of the loop (red before green, one slice at a time, no refactoring during the loop)

Run typechecking and single-file tests regularly. Run the full test suite before committing.

## Step 5: Commit

Make one or more commits in the branch. Each commit should be reviewable and pass tests. Every commit message must include a **reverse link** to the issue so future readers can trace from code back to the plan:

```bash
git add ...
git commit -m "feat: short imperative description

- Issue: #<ISSUE_NUMBER>
- Implements: <acceptance criterion 1>"
```

If the task spans multiple seams, consider one commit per seam. Each commit gets the same issue reference.

After the final commit, close the issue as completed:

```bash
gh issue close <ISSUE_NUMBER> --reason completed --comment \
"Implemented on branch \`task/<branch-name>\`

Commits:
- $(git rev-parse --short HEAD) $(git log -1 --pretty=%s)"
```

## Step 6: Report

After closing the issue, report to the user:

```
Implementation complete on branch: task/<branch-name>

Issue closed: #<ISSUE_NUMBER> (<url>)
Reason: completed

Commits:
- <hash> <subject>
- <hash> <subject>
```

Do **not** push to the remote. The user will review locally and push when ready.

## Rules

- **Never skip ambiguity resolution.** Post resolutions as issue comments.
- **Never push to the remote.** This skill only creates local branches.
- **Never refactor during red-green.** Refactoring belongs in a follow-up or after review.
- **Always run the full test suite before the final commit.**
- **If acceptance criteria change during implementation, stop and post a comment on the issue before proceeding.**
- **After the final commit, close the issue with reason `completed`.**
