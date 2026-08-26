---
name: implement
description: "Detect the type of a GitHub issue and delegate to the appropriate focused skill: implement-feature, implement-task, or research. Invoke when the user says /implement or references an issue number/URL."
---

# Implement

Detect the type of a GitHub issue and delegate to the focused implementation skill that handles it.

## Pre-requisites

- A GitHub issue exists in the current repository.
- The issue body contains a valid plan with empty Open Questions.
- The relevant focused skill (`implement-feature`, `implement-task`, or `research`) is installed.

## Step 1: Read the Issue

Read the issue using the GitHub CLI:

```bash
gh issue view <ISSUE_NUMBER> --json title,labels,state,number,url,assignees
```

If the user provides an issue number, use it directly. If they reference an issue by URL, extract the number.

If the issue cannot be read or does not exist, report the error and stop.

## Step 2: Detect Issue Type

Determine the issue type by inspecting labels and title prefix. Use this precedence order (highest to lowest):

1. **Feature** — label `feature` present, OR title starts with `[Feature]`
2. **Research** — label `research` present, OR title starts with `[Research]`
3. **Task** — label `task` present, OR title starts with `[Task]`
4. **Unknown / fallback** — none of the above → treat as task

The precedence rule means a feature label always wins, even if a task or research label is also present.

If the issue has no recognized type label, note the default before delegating:

> **Agent:** No recognized type label found; defaulting to task implementation.

## Step 3: Delegate to the Focused Skill

Ring the tmux bell to alert the user, then report the delegation.

```bash
printf '\a'
```

### Feature

If the issue is a feature:

> **Agent:** Issue #<ISSUE_NUMBER> is a feature. Delegating to `/implement-feature`.

Invoke the feature orchestrator (no issue number is passed — it finds the active open feature itself):

```
/implement-feature
```

### Research

If the issue is a research task:

> **Agent:** Issue #<ISSUE_NUMBER> is a research task. Delegating to `/research #<ISSUE_NUMBER>`.

Invoke the research skill with the issue number:

```
/research #<ISSUE_NUMBER>
```

### Task

If the issue is a task (or unknown / fallback):

> **Agent:** Issue #<ISSUE_NUMBER> is a task. Delegating to `/implement-task #<ISSUE_NUMBER>`.

Invoke the task implementation skill with the issue number:

```
/implement-task #<ISSUE_NUMBER>
```

## Rules

- **Never implement code in this session.** Only read, detect, and delegate.
- **Always ring the bell before delegating.**
- **Always report the detected type and chosen skill to the user.**
- **Precedence is absolute:** `feature` > `research` > `task` > unknown.
