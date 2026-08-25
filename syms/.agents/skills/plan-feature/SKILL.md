---
name: plan-feature
description: Break a feature-sized piece of work into a set of task plans. Use when the user describes a feature, epic, or deliverable that spans multiple PRs and would take roughly a week to complete. Produces a feature doc and task plans under docs/plans/<feature-slug>/.
disable-model-invocation: true
---

# Plan Feature

Break a feature-sized deliverable into a set of task plans, each small enough for a single context window, with dependencies declared between them.

## When to Use

Invoke this skill when the user explicitly says `/plan-feature` or describes work that:
- Takes roughly a week of development time
- Spans multiple PRs (soft rule: no more than ~5)
- Can be broken into 3–10 tracer-bullet tasks
- Has inter-task dependencies that need sequencing

If the work is smaller than a feature, redirect to `plan-task`.

## Output

A feature document and its task plans stored under `{project-root}/docs/plans/<feature-slug>/`:

```
docs/plans/
└── user-notifications/
    ├── user-notifications.md        # feature doc
    ├── 20240823_send-welcome-email.md   # task 1
    ├── 20240824_digest-settings.md      # task 2
    └── 20240825_unsubscribe-link.md     # task 3
```

No code changes.

---

## Step 1: Scan the Current Context

Read relevant files, conversation history, and any referenced specs/tickets to understand the full feature scope.

## Step 2: Identify Feature Scope

A feature produced by this skill must be:

- **Deliverable in ~1 week**: Roughly 3–10 task-sized pieces of work
- **Spanning multiple PRs**: Soft rule of no more than ~5 PRs. If it would require more, the feature is too large — push back and propose a smaller feature or split into two features.
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

## Step 5: Write the Feature Doc

Create the directory:

```bash
mkdir -p docs/plans/<feature-slug>
```

Write the feature document at `docs/plans/<feature-slug>/<feature-slug>.md`.

Use this exact template:

```markdown
# [Short, imperative feature title]

**Date:** YYYY-MM-DD
**Author:** [user name or "agent"]
**Status:** Draft

## Context

1-2 sentences on why this feature exists. Reference tickets, PRs, or specs if applicable.

## Goal

> "When [condition], [system/user] can [action] so that [value]."

## Scope

### In Scope
- What the feature delivers

### Out of Scope
- What will NOT be built (prevents scope creep)

## Tasks

| # | Title | Deliverable | Blocked by |
|---|-------|-------------|------------|
| 1 | [Task title] | What it makes work | None |
| 2 | [Task title] | What it makes work | 1 |
| 3 | [Task title] | What it makes work | 1, 2 |

## Task Files

- [Task 1: Title](YYYYMMDD_short-description.md)
- [Task 2: Title](YYYYMMDD_short-description.md)
- [Task 3: Title](YYYYMMDD_short-description.md)

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

## Step 6: Write Task Plans (Delegate to `plan-task`)

For each approved task, create a task plan by following the `plan-task` skill. Write the resulting file to `docs/plans/<feature-slug>/YYYYMMDD_short-description.md`.

When delegating to `plan-task` for a feature task:
- The task runs in **feature-task mode**: it knows it belongs to a feature because the file is placed under `docs/plans/<feature-slug>/`.
- The `## Context` section must reference the feature doc with a relative link: `Part of the [Feature Name](<feature-slug>.md) feature.`
- The `## Blocked by` section is **required** and must list the blocking tasks as resolved in Step 4.

Do not write task files from a custom template. Each task must pass through the full `plan-task` workflow (prefactoring check, ambiguity resolution, self-assessed granularity, template, double-check).

## Step 7: Double-Check the Feature

After writing all files, re-read them critically:

1. Can the entire feature be delivered in roughly one week?
2. Are there no more than ~5 PRs implied?
3. Is each task a valid tracer bullet (complete end-to-end slice)?
4. Are the blocking edges correct? Does each task only depend on tasks that genuinely gate it?
5. Are there any circular dependencies?
6. Is the "Out of Scope" section strong enough to prevent scope creep?
7. Does the feature introduce any new domain concepts? Are they called out?
8. Does every task file exist and pass the `plan-task` double-check?

If any answer is unsatisfactory, **ask the user follow-up questions** and update the files. Do not leave the plan in a half-baked state.

## Step 8: Highlight Domain Concepts

If the feature introduces or changes a domain concept, explicitly tell the user:

```
⚠️ This feature introduces a new domain concept: "NotificationPreference". It represents how and when a user wants to be notified. You may want to communicate this to the team, as it will appear in the API schema, the database, the frontend settings page, and analytics.
```

## Rules

- **Never write code.** This skill produces only markdown plan files.
- **Never modify existing code** to "prepare" for the plan.
- **Maximum ~5 PRs.** If the feature implies more, push back and split.
- **Maximum ~10 tasks.** If more are needed, the feature is probably an epic — push back.
- **The feature doc and all task files must be written before considering the plan complete.**
