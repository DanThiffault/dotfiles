---
name: plan-feature
description: Break a feature-sized piece of work into a set of GitHub issues (tasks). Use when the user describes a feature, epic, or deliverable that spans multiple PRs and would take roughly a week to complete. Creates a feature issue with sub-issues on GitHub.
disable-model-invocation: true
---

# Plan Feature

Break a feature-sized deliverable into a set of GitHub issues, each small enough for a single context window, with dependencies declared between them.

## When to Use

Invoke this skill when the user explicitly says `/plan-feature` or describes work that:
- Takes roughly a week of development time
- Spans multiple PRs (soft rule: no more than ~5)
- Can be broken into 3–10 tracer-bullet tasks
- Has inter-task dependencies that need sequencing

If the work is smaller than a feature, redirect to `plan-task`.

## Output

A GitHub issue for the feature with labeled sub-issues for each task.

- **Feature issue**: Labeled `feature`. Contains the feature description, scope, and task breakdown.
- **Task issues**: Labeled `task`. Created as sub-issues of the feature issue via `--parent`.

No local markdown files. No `docs/plans/` directory.

---

## Step 1: Scan the Current Context

Read relevant files, conversation history, and any referenced specs/tickets to understand the full feature scope.

## Step 2: Identify Feature Scope

A feature produced by this skill must be:

- **Deliverable in ~1 week**: Roughly 3–10 task-sized pieces of work
- **Spanning multiple PRs**: Soft rule of no more than ~5 PRs
- **Coherent**: The tasks all serve a single user-facing or system-facing outcome
- **Sequenced**: Tasks have dependency relationships (some must finish before others start)

If the user describes something too vague or too large, list candidate features and ask them to pick one.

## Step 3: Draft Tasks as Vertical Slices

Break the feature into **tracer-bullet** tasks:

- Each slice cuts a narrow but **complete** path through every layer involved (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Each slice fits in a single context window (~3-5 files, ~200 lines)
- Any prefactoring should be done as its own prerequisite task

For each task, determine its **blocking edges**: which other tasks must complete before it can start.

### Wide Refactor Exception

A **wide refactor** (rename a column, retype a shared symbol, move a module) has a blast radius that fans across the whole codebase. Don't force it into a tracer bullet. Instead, sequence it as **expand–contract**: first add the new form beside the old, then migrate call sites in batches, finally delete the old form. Each batch is its own task. When even the batches can't stay green alone, use a shared integration branch.

## Step 4: Quiz the User

Present the proposed breakdown as a numbered list. For each task, show:

- **Title**: short descriptive name
- **Blocked by**: which other tasks (if any) must complete first
- **What it delivers**: the end-to-end behaviour this task makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct?
- Should any tasks be merged or split further?

Iterate until approved.

## Step 5: Create the Feature Issue

Write the feature body to a temporary file, then create the issue via the GitHub CLI.

First ensure the `feature` label exists:

```bash
gh label create feature --description "Feature or epic-level work" --color 5319E7 --force 2>/dev/null
```

Then create the issue:

```bash
FEATURE_ISSUE=$(gh issue create \
  --title "[Feature] Short imperative title" \
  --body-file /tmp/feature-body.md \
  --label "feature" | grep -oE '[0-9]+$')
```

Use this template for the feature body:

```markdown
# [Short, imperative feature title]

**Date:** YYYY-MM-DD
**Author:** [user name or "agent"]

## Context

1-2 sentences on why this feature exists. Reference tickets, PRs, or specs if applicable.

## Goal

> "When [condition], [system/user] can [action] so that [value]."

## Scope

### In Scope
- What the feature delivers

### Out of Scope
- What will NOT be built (prevents scope creep)

## Task Breakdown

| # | Title | Deliverable | Blocked by |
|---|-------|-------------|------------|
| 1 | [Task title] | What it makes work | None |
| 2 | [Task title] | What it makes work | 1 |
| 3 | [Task title] | What it makes work | 1, 2 |

Each task will be created as a labeled sub-issue of this feature issue.

## Dependencies

Describe any cross-feature dependencies (other in-flight features, infrastructure, third-party services) that are NOT captured in the task blocking edges above.

## New or Changing Domain Concepts

If this feature introduces a new domain concept or changes the meaning of an existing one, call it out here. Include:
- The term/concept name
- What it means
- Where else in the codebase it might need to be updated or communicated

## Estimated Timeline

- **Tasks:** ~N
- **PRs:** ~N
- **Duration:** ~N days
- **Risk:** Low / Medium / High
```

Capture the feature issue number from the CLI output. You'll need it in the next step.

## Step 6: Create Task Issues (Delegate to `plan-task`)

For each approved task, delegate to `plan-task`. Pass:

- The feature issue number for `--parent`
- The blocked-by task issue numbers for `--blocked-by` (from already-created tasks)

When creating tasks sequentially, capture each issue number to use in subsequent `--blocked-by` flags.

Example workflow:

```bash
# Task 1 — no blockers
TASK1=$(gh issue create \
  --title "[Task] ..." \
  --body-file /tmp/task1.md \
  --label "task" \
  --parent "$FEATURE_ISSUE" | grep -oE '[0-9]+$')

# Task 2 — blocked by Task 1
TASK2=$(gh issue create \
  --title "[Task] ..." \
  --body-file /tmp/task2.md \
  --label "task" \
  --parent "$FEATURE_ISSUE" \
  --blocked-by "$TASK1" | grep -oE '[0-9]+$')

# Task 3 — blocked by Task 1 and 2
TASK3=$(gh issue create \
  --title "[Task] ..." \
  --body-file /tmp/task3.md \
  --label "task" \
  --parent "$FEATURE_ISSUE" \
  --blocked-by "$TASK1,$TASK2" | grep -oE '[0-9]+$')
```

_Agent note: `gh issue create` outputs the issue URL. Capture the issue number reliably (it is the trailing digits of the returned URL)._

After all tasks are created, update the feature issue body to include the actual sub-issue numbers in the task breakdown table:

```bash
gh issue edit "$FEATURE_ISSUE" --body-file /tmp/updated-feature-body.md
```

## Step 7: Double-Check the Feature

After creating all issues, re-read them critically:

1. Can the entire feature be delivered in roughly one week?
2. Are there no more than ~5 PRs implied?
3. Is each task a valid tracer bullet (complete end-to-end slice)?
4. Are the blocking edges correct? Does each task only depend on tasks that genuinely gate it?
5. Are there any circular dependencies?
6. Is the "Out of Scope" section strong enough to prevent scope creep?
7. Does the feature introduce any new domain concepts? Are they called out?
8. Does every task issue exist and pass the `plan-task` double-check?

If any answer is unsatisfactory, **ask the user follow-up questions** and update the issues. Do not leave the plan in a half-baked state.

## Step 8: Highlight Domain Concepts

If the feature introduces or changes a domain concept, explicitly tell the user:

```
⚠️ This feature introduces a new domain concept: "NotificationPreference". It represents how and when a user wants to be notified. You may want to communicate this to the team, as it will appear in the API schema, the database, the frontend settings page, and analytics.
```

## Rules

- **Never write code.** This skill produces only GitHub issues.
- **Never modify existing code** to "prepare" for the plan.
- **Maximum ~5 PRs.** If the feature implies more, push back and split.
- **Maximum ~10 tasks.** If more are needed, the feature is probably an epic — push back.
- **The feature issue and all task sub-issues must be created before considering the plan complete.**
