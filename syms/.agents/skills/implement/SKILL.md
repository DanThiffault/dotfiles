---
name: implement
description: Implement a single task from a GitHub issue created by the plan-task skill. Reads the issue, resolves ambiguity, TDDs the implementation in an isolated git worktree, and opens a draft PR for user review. Invoke when the user says /implement or references an issue number/URL.
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
gh issue view <ISSUE_NUMBER> --json title,body,labels,state,number,url,assignees
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

### Delegate to implement-feature (if applicable)

After reading the issue, determine if it is a **feature** issue:

- Check the `labels` array for a `feature` label
- Check the issue `title` for a `[Feature]` prefix

If either condition is true (feature takes precedence even if a `task` label is also present), do not proceed with the single-task implementation flow. Instead:

1. If the issue is already assigned to someone else, ring the bell and ask the user for confirmation before taking over:

   ```bash
   printf '\a'
   ```

   > **Agent:** Issue #<ISSUE_NUMBER> is already assigned to <assignee>. Take over and reassign to me?

   Proceed only after explicit user confirmation.

2. Ring the tmux bell to alert the user:

   ```bash
   printf '\a'
   ```

3. Report the delegation:

   > **Agent:** Issue #<ISSUE_NUMBER> is a feature, not a task. Delegating to `/implement-feature`.

4. Invoke `/implement-feature` to handle orchestration.

If the issue is not a feature issue, continue to **Claim the Issue**.

### Claim the Issue

Assign the issue to yourself so other agents (and humans) know it is in progress:

```bash
gh issue edit <ISSUE_NUMBER> --add-assignee "@me"
```

If the issue is already assigned to someone else, ring the bell and ask the user for confirmation before taking over:

```bash
printf '\a'
```

> **Agent:** Issue #<ISSUE_NUMBER> is already assigned to <assignee>. Take over and reassign to me?

Proceed only after explicit user confirmation.

## Step 2: Resolve Ambiguity

Before writing any code, scan the issue body for ambiguity. Ambiguity includes:

- **Open questions** section is non-empty
- **Acceptance criteria** that can't be verified (vague words like "fast", "better", "improved")
- Missing or unclear interfaces ("update the widget" — what is the widget's API?)
- Undefined data shapes ("store the result" — in what format?)
- Unclear error behavior ("handle errors" — how?)
- Seams that don't match the actual codebase
- Domain concepts that conflict with existing code

If you find ambiguity, ring the bell to alert the user, then **stop** and ask targeted questions:

```bash
printf '\a'
```

After each answer, post a comment on the issue with the resolution:

```bash
gh issue comment <ISSUE_NUMBER> --body "**Q:** What is the expected error message when the user is not found?

**A:** \"User with ID {id} does not exist.\" (404)"
```

Keep asking until the plan is unambiguous. Do not proceed to implementation while ambiguity exists.

## Step 3: Prepare the Worktree and Branch

Ensure the working tree is clean. Stash or abort if not.

### Ensure `.agent-worktrees/` is gitignored

Before creating worktrees, verify `.agent-worktrees/` is listed in `.gitignore` at the repo root. If it is missing, add it and commit:

```bash
grep -q "\.agent-worktrees/" .gitignore || echo ".agent-worktrees/" >> .gitignore
```

### Worktree detection

Check if you are already inside a git worktree. If so, skip creation and use the current directory:

```bash
git rev-parse --is-inside-work-tree && git worktree list --porcelain | grep -q "worktree $(pwd)" && echo "Already in a worktree"
```

If already in a worktree, proceed directly to implementation in the current directory.

### Create an isolated worktree

Create a new worktree and branch. Use the issue number in the worktree path and a kebab-case description based on the task title for the branch:

```bash
WORKTREE=".agent-worktrees/task-<ISSUE_NUMBER>/"
BRANCH="feat/<short-kebab-description>"
git worktree add -b "$BRANCH" "$WORKTREE"
cd "$WORKTREE"
```

Example:

```bash
git worktree add -b feat/update-implement-parallel-execution .agent-worktrees/task-7/
cd .agent-worktrees/task-7/
```

If the worktree path already exists, report the error and abort.

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

Make one or more commits in the branch. Each commit should be reviewable and pass tests. Every commit message must follow the **Conventional Commits** standard and include a **reverse link** to the issue so future readers can trace from code back to the plan.

Allowed prefixes: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`.

```bash
git add ...
git commit -m "feat: short imperative description

- Issue: #<ISSUE_NUMBER>
- Implements: <acceptance criterion 1>"
```

If the task spans multiple seams, consider one commit per seam. Each commit gets the same issue reference.

Run the full test suite before the final commit.

## Step 6: Create a Draft PR

After the final commit, open a **draft PR** instead of closing the issue. Include `Closes #<ISSUE_NUMBER>` in the PR body so GitHub will close the issue automatically when the PR is merged.

```bash
gh pr create --draft --title "feat: <short description>" --body "Closes #<ISSUE_NUMBER>

## Summary
- <what changed>
- <why>

## Acceptance Criteria
- [ ] <criterion 1>

## Commits
$(git log --oneline main..HEAD)"
```

If `gh pr create` fails, report the branch name and worktree path so the user can push manually:

```
Draft PR creation failed.
- Branch: feat/<branch-name>
- Worktree: .agent-worktrees/task-<ISSUE_NUMBER>/
Push manually when ready.
```

### Unassign the Issue

Once the draft PR is created, unassign yourself to signal the task is awaiting review:

```bash
gh issue edit <ISSUE_NUMBER> --remove-assignee "@me"
```

## Step 7: Report and Leave Session Open

Ring the bell to alert the user that the task is ready for review:

```bash
printf '\a'
```

Report to the user:

```
Implementation complete on branch: feat/<branch-name>
Worktree: .agent-worktrees/task-<ISSUE_NUMBER>/

Draft PR: <url>
Closes: #<ISSUE_NUMBER>

Commits:
- <hash> <subject>
- <hash> <subject>
```

Do **not** push to the remote. The user will review locally and push when ready.

Do **not** exit the session. Leave it open in case the user has follow-up questions or requests changes.

## Rules

- **Never skip ambiguity resolution.** Post resolutions as issue comments.
- **Push only the current branch when creating the draft PR.** Do not force-push or push unrelated branches.
- **Never refactor during red-green.** Refactoring belongs in a follow-up or after review.
- **Always run the full test suite before the final commit.**
- **If acceptance criteria change during implementation, stop and post a comment on the issue before proceeding.**
- **Always use Conventional Commits.**
- **Always create a draft PR instead of closing the issue directly.**
