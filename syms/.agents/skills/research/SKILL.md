---
name: research
description: Execute a scoped research task from a GitHub issue labeled research. Reads the issue, searches the web and known sources, summarizes findings as a comment, and marks the issue complete. Invoke when the user says /research or references a research issue number/URL.
---

# Research

Execute a scoped, time-boxed research task from a GitHub issue labeled `research`. Complete it in one short session (~5–15 minutes) and post findings as a comment.

## When to Use

Invoke this skill when the user explicitly says `/research` or references a research issue number/URL.

Requires:
- An open GitHub issue labeled `research` (created by `/plan-research`)
- The `tmux-bell` skill available for notifications

## Overview

1. Read the research issue.
2. Assign it to `@me` to signal "in progress."
3. Search known sources and the web for current information.
4. Summarize findings in a structured format.
5. Post the summary as a comment on the issue.
6. Unassign from `@me` to signal "complete."
7. Ring the bell and report to the user.

---

## Step 1: Read the Issue

Read the issue using the GitHub CLI:

```bash
gh issue view <ISSUE_NUMBER> --json title,body,labels,state,number,url,assignees
```

Extract:
- Research question
- Scope (in and out)
- Known suggestions
- Success criteria
- Recency requirements

### Validate the Issue

- Must be labeled `research` (or title prefixed with `[Research]`)
- Must have an empty Open Questions section (or none present)
- If the issue looks like an implementation task (has acceptance criteria about code changes), ring the bell and ask the user if they meant `/implement` instead

### Claim the Issue

Assign to yourself:

```bash
gh issue edit <ISSUE_NUMBER> --add-assignee "@me"
```

If already assigned to someone else, ring the bell and ask:

```bash
printf '\a'
```

> **Agent:** Issue #<ISSUE_NUMBER> is already assigned to <assignee>. Take over and reassign to me?

Proceed only after explicit confirmation.

## Step 2: Resolve Ambiguity

Before researching, scan the issue for ambiguity:

- Vague criteria ("best", "good") — what dimensions define "best"?
- Missing context — what project or constraints apply?
- Unbounded scope — will this take more than 15 minutes?

If ambiguous, ring the bell and ask targeted questions. Post resolutions as issue comments.

## Step 3: Research

Perform the research in a focused, time-boxed manner. Target **5–15 minutes** total.

### 3a. Known Sources First

Use your existing knowledge to:
- Identify major options, libraries, or approaches
- Note any well-known comparisons or benchmarks
- Recall recent developments or deprecations

### 3b. Web Search

Use the `bash` tool to search the web for up-to-date information. Preferred methods (in order):

1. **DuckDuckGo HTML interface** (no API key):
   ```bash
   curl -s -A "Mozilla/5.0" "https://html.duckduckgo.com/html/?q=<URL-ENCODED-QUERY>" | ...
   ```

2. **Search API** if `SEARCH_API_KEY` or similar is available in environment:
   ```bash
   curl -s "https://api.search.example.com/v1?q=<QUERY>" -H "Authorization: Bearer $SEARCH_API_KEY"
   ```

3. **Direct documentation pages** for known options:
   ```bash
   curl -s "https://docs.example.com/..." | ...
   ```

4. **GitHub search** for trending or recently updated projects:
   ```bash
   gh search repos "<QUERY>" --sort updated --limit 10
   ```

### 3c. What to Capture

For each option or source found, note:
- **Name / URL** — what is it and where is it documented?
- **Recency** — last release date, last updated, article date
- **Relevance** — how well does it address the research question?
- **Key findings** — specific facts, numbers, comparisons
- **Trade-offs** — pros and cons relative to the criteria

Stop researching once you have enough to answer the question or hit the time box. Do not chase perfection.

## Step 4: Summarize Findings

Structure the summary as follows:

```markdown
## Research Summary: [Issue Title]

### TL;DR

1–2 sentence bottom-line answer to the research question.

### Options Evaluated

#### Option 1: [Name]
- **Source:** [URL]
- **Recency:** [last updated / release date]
- **Key findings:** [specific facts]
- **Trade-offs:** [pros/cons relative to criteria]

#### Option 2: [Name]
... (repeat for each)

### Comparison Matrix

| Option | Criterion 1 | Criterion 2 | Criterion 3 |
|--------|-------------|-------------|-------------|
| A      | Good        | Poor        | Excellent   |
| B      | ...         | ...         | ...         |

*(Use a matrix only when it adds clarity. Skip if it is redundant.)*

### Recommendation

If a clear recommendation emerges:
> **Recommended:** [Option] because [reasoning with trade-offs].

If no clear winner:
> **No single recommendation.** The choice depends on [factor]. [Option A] is best for [scenario]; [Option B] is best for [scenario].

### Sources

- [URL 1] — [brief description]
- [URL 2] — [brief description]
- ...

### Time Spent

~X minutes
```

## Step 5: Post the Comment

Post the summary as a comment on the issue:

```bash
gh issue comment <ISSUE_NUMBER> --body-file /tmp/research-summary.md
```

## Step 6: Mark Complete

Unassign yourself to signal completion:

```bash
gh issue edit <ISSUE_NUMBER> --remove-assignee "@me"
```

## Step 7: Report and Leave Session Open

Ring the bell to alert the user:

```bash
printf '\a'
```

Report to the user:

```
Research complete for #<ISSUE_NUMBER>: [Issue Title]

Summary posted as a comment.
Time spent: ~X minutes.

Options evaluated: [N]
Recommendation: [yes/no — brief answer]

The issue is now unassigned and ready for your review.
```

Do **not** close the issue. Leave it open for human review.

Do **not** exit the session. Leave it open in case the user has follow-up questions.

## Error Handling

| Scenario | Action |
|---|---|
| Issue not labeled `research` | Warn user; confirm they want to proceed |
| Issue has open questions | Ring bell; ask user to clarify before proceeding |
| Web search unavailable | Fall back to known sources; note limitation in summary |
| No useful sources found after reasonable effort | Post partial findings; note where search failed |
| Issue is already assigned | Ring bell; ask before taking over |

## Rules

- **Time-box strictly.** Stop at ~15 minutes even if imperfect.
- **Never write code or create prototypes.** Research only.
- **Never modify existing code.**
- **Never close the issue.** Post a comment and leave it for human review.
- **Always unassign when done.** Assignment signals "in progress."
- **Always leave the session open** after reporting.
- **If scope explodes during research, stop and comment.** Note what was scoped out and why.
