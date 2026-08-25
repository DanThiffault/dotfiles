---
name: implement-task
description: Implement a single task from a task.md plan created by the plan-task skill. Reads the plan, resolves ambiguity, TDDs the implementation on a fresh branch, and reports the branch for user review. Invoke when the user says /implement-task or points to a task.md file.
---

# Implement Task

Implement a single, self-contained task from a plan file produced by the `plan-task` skill.

## Pre-requisites

- A `docs/plans/YYYYMMDD_short-description.md` file exists in the current project.
- Git is initialized and the working tree is clean (or you know what to stash).
- The `tdd` skill is available (loaded automatically or referenced below).

## Step 1: Read the Plan

Read the task file (e.g., `docs/plans/20240823_add-user-auth.md`). Extract:

- Title / goal
- Acceptance criteria
- Scope (in and out)
- Seams / boundaries
- Technical notes
- Error handling requirements
- Testing strategy
- Open questions (this section **must** be empty for a valid plan)
- New or changing domain concepts

## Step 2: Resolve Ambiguity

Before writing any code, scan the plan for ambiguity. Ambiguity includes:

- **Open questions** section is non-empty
- **Acceptance criteria** that can't be verified (vague words like "fast", "better", "improved")
- Missing or unclear interfaces ("update the widget" — what is the widget's API?)
- Undefined data shapes ("store the result" — in what format?)
- Unclear error behavior ("handle errors" — how?)
- Seams that don't match the actual codebase
- Domain concepts that conflict with existing code

If you find ambiguity, **stop**. Ask the user targeted questions. After each answer, append the resolution to the task file under a new `## Resolutions` section (or append to existing `## Open Questions`).

Example:

```markdown
## Resolutions

**Q:** What is the expected error message when the user is not found?
**A:** "User with ID {id} does not exist." (404)

**Q:** Should this be a breaking change to the API?
**A:** No, add a new endpoint and deprecate the old one.
```

Keep asking until the plan is unambiguous. Do not proceed to implementation while ambiguity exists.

## Step 3: Prepare the Branch

Ensure the working tree is clean. Stash or abort if not.

Create a fresh branch from the current HEAD:

```bash
# Use kebab-case based on the task title
git checkout -b task/YYYYMMDD-short-description
```

Example: `task/20240823-add-user-auth`

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

Make one or more commits in the branch. Each commit should be reviewable and pass tests. Every commit message must include a **reverse link** to the plan file so future readers can trace from code back to the plan:

```bash
git add ...
git commit -m "feat: short imperative description

- Plan: docs/plans/standalone_YYYYMM/YYYYMMDD_short-description.md
- Implements: <acceptance criterion 1>"
```

If the task spans multiple seams, consider one commit per seam. Each commit gets the same plan reference.

After the final commit, update the plan file to reflect completion. This is the only post-implementation edit allowed:

1. Change **Status** from `Draft` / `Ready` / `In Progress` to `Done`

Do **not** add commit SHAs, implementation details, or any other section to the plan file. Traceability lives in the commit messages, not the plan.

## Step 6: Report

After the final commit, update the plan file's Status to Done. Then report to the user:

```
Implementation complete on branch: task/YYYYMMDD-short-description

Commits:
- <hash> <subject>
- <hash> <subject>

Plan updated: docs/plans/standalone_YYYYMM/YYYYMMDD_short-description.md (Status: Done)
```

Do **not** push to the remote. The user will review locally and push when ready.

## Rules

- **Never skip ambiguity resolution.** If the plan is ambiguous, ask questions and update the markdown.
- **Never push to the remote.** This skill only creates local branches.
- **Never refactor during red-green.** Refactoring belongs in a follow-up or after review.
- **Always run the full test suite before the final commit.**
- **If acceptance criteria change during implementation, stop and update the plan file before proceeding.**
- **After the final commit, update the plan file's Status to Done.** This is the only post-implementation edit allowed. Do not add commit SHAs or implementation details.
