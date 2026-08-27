---
name: implement-feature
description: Orchestrate parallel implementation of all tasks in an open feature. Finds the active feature, computes which tasks are ready (unblocked, unassigned), assigns them to @me, spawns parallel implement agents via the agent-spawn extension, and delegates to review-feature when all tasks are completed.
disable-model-invocation: true
---

# Implement Feature

Orchestrate parallel implementation of all tasks belonging to an open `feature` issue.

## When to Use

Invoke this skill when the user explicitly says `/implement-feature`. It is never auto-triggered.

It requires:
- An open feature issue labeled `feature`
- Task sub-issues labeled `task` (created by `plan-feature`)
- The `implement-task`, `research`, and `review-feature` skills installed
- The `agent-spawn` extension installed (provides `/agent-spawn` command)

## Overview

1. Find the single open feature issue (error if zero or multiple).
2. Check if the feature is assigned to someone else or already assigned to `@me`; if so, ring the bell and ask the user before taking over or continuing.
3. Enumerate all task sub-issues via `gh issue view --json subIssues`.
4. For each task, determine its current state by querying GitHub:
   - `completed` — issue closed or PR merged
   - `pr_created` — PR exists, issue still open
   - `assigned` — assigned to `@me`, no PR yet
   - `ready` — open, unassigned, blockers closed
   - `blocked` — open but blockers still open
5. For every `ready` task: detect its issue type, assign it to `@me`, then spawn a focused agent via `/agent-spawn` running the appropriate skill directly (e.g. `/implement-task <N>`, `/research <N>`).
6. Print a status report.
7. When all tasks are `completed`, delegate to `review-feature`.

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

If the feature is assigned to someone other than `@me` **or** already assigned to `@me`, ring the bell and ask:

```bash
printf '\a'
```

> **Agent:** Feature #<FEATURE_NUMBER> is assigned to <assignee> (or already assigned to you). Take over / continue?

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

## Step 5: Detect Issue Type and Spawn Agents for Ready Tasks

For each task in state `ready`:

### 5a. Assign the Issue

Signal "in progress" by assigning to `@me`:

```bash
gh issue edit <TASK_NUMBER> --add-assignee "@me"
```

If the task is already assigned to someone else, ring the bell and ask the user before taking over. Proceed only after explicit confirmation.

### 5b. Detect Issue Type

Read the task issue to determine its type, using the same precedence as the `implement` skill:

```bash
gh issue view <TASK_NUMBER> --json title,labels
```

**Precedence (highest to lowest):**
1. **Feature** — label `feature` present
2. **Research** — label `research` present
3. **Task** — label `task` present
4. **Unknown / fallback** — none of the above → treat as task

### 5c. Spawn the Appropriate Agent

Based on the detected type, spawn the focused skill directly in a subagent via the `agent-spawn` extension.

#### Task (or unknown)

```bash
/agent-spawn /implement-task <TASK_NUMBER>
```

> If `agent-spawn` is not installed, manual fallback:
> ```
> pi /implement-task <TASK_NUMBER>
> ```

#### Research

```bash
/agent-spawn /research <TASK_NUMBER>
```

> If `agent-spawn` is not installed, manual fallback:
> ```
> pi /research <TASK_NUMBER>
> ```

#### Feature

```bash
/agent-spawn /implement-feature
```

> If `agent-spawn` is not installed, manual fallback:
> ```
> pi /implement-feature
> ```

The `agent-spawn` extension creates a tmux window at the next free index (≥10) and runs `pi` with the given message in the current working directory.

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

### All Tasks Completed

If **all** tasks are `completed`:

1. Ring the bell:
   ```bash
   printf '\a'
   ```

2. Print completion message:
   > All tasks for feature #<FEATURE_NUMBER> are complete. Delegating to `review-feature`.

3. Spawn `review-feature` via the `agent-spawn` extension:
   ```bash
   /agent-spawn /review-feature <FEATURE_NUMBER>
   ```

   If `agent-spawn` is not installed, print the manual command instead.

### All Open Tasks Have PRs (But Are Not Yet Closed)

If all remaining open tasks are in state `pr_created` (PR exists but issue not yet closed):

1. Ring the bell:
   ```bash
   printf '\a'
   ```

2. List the PRs to the user:
   > All remaining tasks for feature #<FEATURE_NUMBER> have open PRs, but the issues are not yet closed.
   > PRs:
   > - #<PR_NUMBER> (task #<TASK_NUMBER>)
   >
   > Please review and merge these PRs, then run `/implement-feature` again to proceed to `review-feature`.

### Tasks Still in Progress

If **not all** tasks are done, remind the user:
> Run `/implement-feature` again after PRs are opened or blockers close to pick up newly ready tasks.

---

## Error Handling

| Scenario | Action |
|---|---|
| No open features | Ask user to run `/plan-feature` |
| Multiple open features | List them; ask user to pick one |
| Feature assigned to someone else or already to self | Ring bell; ask user before taking over / continuing |
| Task assigned to someone else | Ring bell; ask user before taking over |
| Dependency cycle detected | Ring bell; stop and warn user |
| `subIssues` empty | Warn user that feature has no tasks |
| `agent-spawn` extension not installed | Print manual `pi /implement-task <N>` or `pi /research <N>` fallback; still assign issues |

## Rules

- **User-invoked only** — Never auto-trigger. Only runs on explicit `/implement-feature`.
- **Assignment is source of truth** — `gh issue edit --add-assignee "@me"` is the canonical "in progress" signal.
- **No code changes in this session** — All implementation work is delegated to spawned focused skill agents (`/implement-task`, `/research`, etc.).
- **Iterative re-invocation** — `/implement-feature` is idempotent. Running it again finds newly unblocked tasks.
- **Confirm before taking over** — Always ask the user before reassigning an issue from another owner, or before continuing when already assigned to self.

## New Domain Concepts

- **Task state machine**: `completed → pr_created → assigned → ready → blocked`. Computed dynamically from GitHub metadata on every invocation.
- **Worktree isolation**: Each task gets its own `.agent-worktrees/task-<N>/` directory and branch, created by the spawned `implement-task` agent (not this orchestrator).
- **Assignment as progress signal**: GitHub issue assignment replaces local tracker files.
