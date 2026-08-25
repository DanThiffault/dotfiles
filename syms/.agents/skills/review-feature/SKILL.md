---
name: review-feature
description: Audit a completed feature by comparing its task PRs against the original feature issue plan. Flags scope gaps and undocumented domain concept changes. Use when the user says /review-feature or wants to validate a feature's implementation against its plan.
---

# Review Feature

Audit a completed feature by comparing its task PRs against the original feature issue plan. Flags scope gaps and undocumented domain concept changes.

## Pre-requisites

- A GitHub feature issue exists with labeled `feature`.
- The feature issue has task sub-issues labeled `task` (created via `plan-feature`).
- All (or most) task issues have linked draft or merged PRs.

## Step 1: Read the Feature Issue

Read the feature issue using the GitHub CLI:

```bash
gh issue view <FEATURE_NUMBER> --json title,body,labels,state,number,url,assignees
```

Extract from the body:
- **Goal** — the single-sentence outcome
- **In Scope** — the deliverables that should be covered by tasks
- **Out of Scope** — what should NOT appear in any PR
- **Task Breakdown** — the table of tasks with deliverables
- **New or Changing Domain Concepts** — planned domain nouns
- **Dependencies** — cross-feature dependencies that should be respected

Verify the issue is labeled `feature`. If not, warn the user and ask for confirmation to proceed.

## Step 2: Collect Task Issues and PRs

### 2a. Find Task Sub-Issues

List sub-issues of the feature:

```bash
gh issue list --parent <FEATURE_NUMBER> --json number,title,state,url,body,labels
```

If `gh issue list --parent` is unavailable, fall back to searching the feature issue body for `Part of #<FEATURE_NUMBER>` references, or scrape the body/comments for task URLs.

### 2b. Find Linked PRs for Each Task

For each task issue, collect linked PRs. Try in order:

1. **Linked-issues search:**
   ```bash
   gh pr list --linked-issues <TASK_NUMBER> --json number,title,body,state,headRefName,url
   ```

2. **Search by branch name or title:**
   ```bash
   gh pr list --search "<task title or branch keyword>" --json number,title,body,state,headRefName,url
   ```

3. **Scrape task issue body/comments:**
   ```bash
   gh issue view <TASK_NUMBER> --json body,comments
   ```
   Search the body and comments for PR URLs (`https://github.com/.../pull/...`).

If a task has **no linked PR**, flag it clearly in the report.

For each PR found, collect:
- PR number, title, body, state (open/merged/closed)
- Commit messages (`gh pr view <PR_NUMBER> --json commits`)
- Branch name

## Step 3: Check Scope Coverage (Gap Analysis)

Map the feature's **In Scope** items to the collected task PRs.

For each In Scope item:
- Does at least one PR title, body, or commit message clearly reference it?
- If yes, note which PR covers it.
- If no, flag it as a **scope gap**.

For each **Out of Scope** item:
- Does any PR title, body, or commit message reference it?
- If yes, flag it as **scope creep**.

### Gap Analysis Checklist Format

```
Scope Coverage
--------------
✅ <In Scope Item 1> — covered by PR #<N>
❌ <In Scope Item 2> — NO PR found (gap)
⚠️ <Out of Scope Item 1> — referenced in PR #<N> (scope creep)
```

## Step 4: Domain Concept Audit (DDD Term Check)

### 4a. Extract Planned Domain Nouns

From the feature issue's **New or Changing Domain Concepts** section, extract every capitalized domain noun (e.g., `NotificationPreference`, `BookingWindow`).

### 4b. Detect Unplanned Domain Nouns

Scan all PR metadata (titles, bodies, commit messages) for capitalized words that look like domain nouns but were **not** listed in the planned concepts.

Heuristic: any capitalized camelCase/PascalCase word that appears more than once across PR metadata and is not a common technology term (e.g., `GitHub`, `API`, `CLI`, `JSON`, `URL`, `HTTP`, `CSS`, `HTML`).

Flag unplanned nouns as **undocumented domain concepts**.

### 4c. Check Naming Consistency

For each planned domain noun, check if it is used consistently across all PR metadata. Flag inconsistencies:
- Different spellings or casing (`NotificationPreference` vs `NotificationPreferences`)
- Synonyms used interchangeably (`BookingWindow` vs `ReservationWindow`)

### Domain Audit Format

```
Domain Concept Audit
--------------------
Planned concepts:
  ✅ NotificationPreference — consistent across PRs #1, #2
  ⚠️  BookingWindow — only found in PR #1, missing in PR #3 (gap)

Undocumented concepts:
  ❌ AuditLog — appears in PR #2 but not in feature plan

Naming inconsistencies:
  ⚠️  NotificationPreference vs NotificationPreferences (PR #1 title vs PR #2 body)
```

## Step 5: Compile the Review Report

Synthesize findings into a structured report:

```
Feature Review: #<FEATURE_NUMBER> — <Feature Title>
==================================================

Task PRs Found:
  #<TASK_1> → PR #<PR_A> (<state>) — <title>
  #<TASK_2> → PR #<PR_B> (<state>) — <title>
  #<TASK_3> → NO PR FOUND

Scope Coverage:
  [gap analysis checklist]

Domain Concept Audit:
  [domain audit findings]

Summary:
  - <N> tasks with PRs, <M> tasks missing PRs
  - <X> scope gaps, <Y> scope creep flags
  - <Z> undocumented domain concepts
```

Print the report to the user. Do not write it to a file unless explicitly asked.

Ring the bell to signal the review is complete:

```bash
printf '\a'
```

## Step 6: Ask for Confirmation (If Invoked by `implement-feature`)

If the review was triggered as the final step of `implement-feature`, the user must explicitly confirm before closing the feature issue.

Present a `[y/N]` prompt:

```
All tasks have been reviewed. Close the feature issue #<FEATURE_NUMBER>?
[y/N]
```

- If the user answers `y` or `yes`, close the feature issue and unassign it.
- If the user answers `n`, `no`, or anything else, leave the issue open and end the session.
- **Never auto-close** the feature issue. Always require explicit confirmation.

### Close and Unassign

If confirmed:

```bash
gh issue close <FEATURE_NUMBER>
gh issue edit <FEATURE_NUMBER> --remove-assignee "@me"
```

## Step 7: Leave Session Open

After reporting (and optionally closing), **do not exit the session**. Leave it open so the user can ask follow-up questions.

If the session is idle awaiting user input, ring the bell again after a reasonable delay:

```bash
printf '\a'
```

## Tmux Window Naming

When this skill is active, set the tmux window name to help the user identify the session:

```bash
tmux rename-window "reviewing #<FEATURE_NUMBER>" 2>/dev/null || true
```

Restore the original window name before exiting if desired (optional).

## Error Handling

| Scenario | Action |
|----------|--------|
| `gh pr list --linked-issues` fails | Fall back to `--search`, then to body scraping |
| `gh pr list --search` also fails | Scrape task issue body and comments for PR URLs |
| Task has no linked PR | Flag clearly in report; do not fail |
| Feature issue has no sub-issues | Warn user and ask if they want to proceed with manual task list |
| PR metadata is ambiguous | Read the PR diff **only** for that specific PR to resolve ambiguity |

## Rules

- **Read-only until close step** — Do not modify code, PRs, or issues during analysis.
- **Metadata first** — Use PR titles, bodies, and commits by default. Read diffs only when metadata is ambiguous.
- **Never auto-close** — Always require explicit `[y/N]` confirmation before closing a feature issue.
- **Bell on attention** — Ring `printf '\a'` when the review is complete and when awaiting user confirmation.
- **Leave session open** — Do not exit after reporting.
- **Unassign on close** — Remove `@me` from the feature issue after closing it.
