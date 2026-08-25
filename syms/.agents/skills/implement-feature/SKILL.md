---
name: implement-feature
description: Orchestrate parallel implementation of all tasks in an open feature. Finds the active feature, computes which tasks are ready (unblocked, unassigned), assigns them to @me, spawns parallel implement agents in isolated git worktrees via tmux windows, and delegates to review-feature when all tasks have draft PRs.
disable-model-invocation: true
---

# Implement Feature

Orchestrate parallel implementation of all tasks belonging to an open `feature` issue.

## When to Use

Invoke this skill when the user explicitly says `/implement-feature`. It is never auto-triggered.

It requires:
- An open feature issue labeled `feature`
- Task sub-issues labeled `task` (created by `plan-feature`)
- The `implement` and `review-feature` skills installed

## Overview

1. Find the single open feature issue (error if zero or multiple).
2. Check if the feature is already assigned to someone else; if so, ring the bell and ask the user before taking over.
3. Enumerate all task sub-issues via `gh issue view --json subIssues`.
4. For each task, determine its current state by querying GitHub:
   - `completed` — issue closed or PR merged
   - `pr_created` — PR exists, issue still open
   - `assigned` — assigned to `@me`, no PR yet
   - `ready` — open, unassigned, blockers closed
   - `blocked` — open but blockers still open
5. For every `ready` task: assign it to `@me`, create a git worktree, spawn a tmux window running `/implement #<N>`.
6. Print a status report.
7. When all tasks are `completed` or `pr_created`, delegate to `review-feature`.

---

## Step 1: Identify the Active Feature

Find the single open issue labeled `feature`:

```bash
FEATURE_ISSUES=$(gh issue list --label feature --state open --json number,title,assignees)
FEATURE_COUNT=$(echo "$FEATURE_ISSUES" | jq 'length')
```

- If `FEATURE_COUNT == 0`: tell the user there is no open feature. Suggest running `/plan-feature` first.
- If `FEATURE_COUNT == 1`: capture `FEATURE_NUMBER` and `FEATURE_TITLE`.
- If `FEATURE_COUNT > 1`: print the list and ask the user which one to implement.

---

## Step 2: Check Feature Assignment

Read the feature issue:

```bash
gh issue view "$FEATURE_NUMBER" --json number,title,assignees,body,subIssues
```

If the feature is assigned to someone other than `@me`, ring the bell and ask:

```bash
printf '\a'
```

> **Agent:** Feature #<FEATURE_NUMBER> is assigned to <assignee>. Take over and reassign to me?

Proceed only after explicit confirmation. If confirmed:

```bash
gh issue edit "$FEATURE_NUMBER" --add-assignee "@me"
```

---

## Step 3: Enumerate All Tasks

Read the feature issue's `subIssues` JSON. For each sub-issue, collect:

```bash
gh issue view <TASK_NUMBER> --json number,title,state,blockedBy,assignees,closedByPullRequestsReferences
```

Store these fields in a temporary JSON file (e.g., `/tmp/feature-$FEATURE_NUMBER-tasks.json`) for the dependency computation in Step 4.

---

## Step 4: Compute Task States

For each task, determine state:

### State Rules

| State | Condition |
|---|---|
| `completed` | `state == "CLOSED"` AND `closedByPullRequestsReferences` has a PR in `MERGED` state |
| `pr_created` | `state == "OPEN"` AND `closedByPullRequestsReferences` has a PR in `OPEN` state |
| `assigned` | `state == "OPEN"` AND assigned to `@me` AND no open PR |
| `ready` | `state == "OPEN"` AND unassigned AND all `blockedBy` tasks are `completed` |
| `blocked` | `state == "OPEN"` AND at least one `blockedBy` task is NOT `completed` |

### PR Detection

Use `gh issue view <TASK_NUMBER> --json closedByPullRequestsReferences` to find linked PRs. For each PR reference, verify its actual state:

```bash
gh pr view <PR_NUMBER> --json state
```

If `closedByPullRequestsReferences` is empty, also search by branch name pattern:

```bash
gh pr list --state all --search "task-<TASK_NUMBER>" --json number,title,state,headRefName
```

### Dependency Cycle Detection

Build a directed graph from `blockedBy` edges. If a cycle exists, stop, ring the bell, and warn the user.

---

## Step 5: Spawn Agents for Ready Tasks

For each task in state `ready`:

### 5a. Assign the Issue

Signal "in progress" by assigning to `@me`:

```bash
gh issue edit <TASK_NUMBER> --add-assignee "@me"
```

If the task is already assigned to someone else, ring the bell and ask the user before taking over. Proceed only after explicit confirmation.

### 5b. Ensure `.agent-worktrees/` Is Gitignored

At the repo root:

```bash
grep -q "\.agent-worktrees/" .gitignore || echo ".agent-worktrees/" >> .gitignore
```

### 5c. Create a Worktree

```bash
WORKTREE=".agent-worktrees/task-<TASK_NUMBER>/"
BRANCH="feat/<short-kebab-description-from-task-title>"
git worktree add -b "$BRANCH" "$WORKTREE"
```

If the worktree path already exists, skip creation and log the existing path.

### 5d. Spawn a Tmux Window

If `tmux` is available and a session exists:

```bash
tmux new-window -n "implementing #<TASK_NUMBER>" -c "$WORKTREE" "pi /implement <TASK_NUMBER>"
```

> The exact command to run `pi` may vary by environment. Adjust if the local `pi` binary or alias is different.

If tmux is not available, print the manual fallback commands:

```
--- Manual fallback ---
cd <REPO_ROOT>/.agent-worktrees/task-<TASK_NUMBER>/
pi /implement <TASK_NUMBER>
-----------------------
```

---

## Step 6: Status Report

Print a status table for all tasks:

```
Feature #<FEATURE_NUMBER>: <Feature Title>
==================================================
Task  | State       | Title
------|-------------|------------------------------------
#7    | completed   | Update implement skill ...
#8    | completed   | Create review-feature auditor ...
#9    | assigned    | Create implement-feature orchestrator ...
#10   | blocked     | Wire implement skill delegation ...
```

Also print counts by state:

```
Summary: 2 completed, 0 pr_created, 1 assigned, 0 ready, 1 blocked
```

If any tasks are `ready` and were just spawned, note: "Spawned <N> new implement agents."

If any tasks are `blocked`, list the blocking task numbers.

---

## Step 7: Finalize the Feature — Delegate to Review

If **all** tasks are `completed` or `pr_created`:

1. Ring the bell:
   ```bash
   printf '\a'
   ```

2. Print completion message:
   > All tasks for feature #<FEATURE_NUMBER> have PRs. Delegating to `review-feature`.

3. Spawn `review-feature` in a tmux window:
   ```bash
   tmux new-window -n "reviewing #<FEATURE_NUMBER>" "pi /review-feature <FEATURE_NUMBER>"
   ```

   If tmux is not available, print the manual command instead.

If **not all** tasks are done, remind the user:
> Run `/implement-feature` again after PRs are opened or blockers close to pick up newly ready tasks.

---

## Error Handling

| Scenario | Action |
|---|---|
| No open features | Ask user to run `/plan-feature` |
| Multiple open features | List them; ask user to pick one |
| Feature assigned to someone else | Ring bell; ask user before taking over |
| Task assigned to someone else | Ring bell; ask user before taking over |
| `git worktree add` fails (path exists) | Skip and log; do not abort |
| No `tmux` | Print manual commands; still assign issues and create worktrees |
| Dependency cycle detected | Ring bell; stop and warn user |
| `subIssues` empty | Warn user that feature has no tasks |

## Rules

- **User-invoked only** — Never auto-trigger. Only runs on explicit `/implement-feature`.
- **Assignment is source of truth** — `gh issue edit --add-assignee "@me"` is the canonical "in progress" signal.
- **No code changes in this session** — All implementation work is delegated to spawned `/implement` agents.
- **One worktree per task** — Isolation prevents conflicts between parallel agents.
- **Draft PRs, not closed issues** — Issues stay open until `review-feature` confirms closure.
- **Iterative re-invocation** — `/implement-feature` is idempotent. Running it again finds newly unblocked tasks.
- **Confirm before taking over** — Always ask the user before reassigning an issue from another owner.

## New Domain Concepts

- **Task state machine**: `completed → pr_created → assigned → ready → blocked`. Computed dynamically from GitHub metadata on every invocation.
- **Worktree isolation**: Each task gets its own `.agent-worktrees/task-<N>/` directory and branch.
- **Assignment as progress signal**: GitHub issue assignment replaces local tracker files.
