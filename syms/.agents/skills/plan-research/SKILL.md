---
name: plan-research
description: Create a scoped, time-boxed research GitHub issue. Captures a technical or domain question to be investigated—not implemented. Invoke when the user says /plan-research or wants to turn a knowledge gap into a trackable research task.
---

# Plan Research

Turn a knowledge gap, technical comparison, or domain question into a single, scoped GitHub issue labeled `research`. The resulting issue is designed to be completed in one short agent session (~5–15 minutes of reading and searching).

## When to Use

Invoke this skill when the user explicitly says `/plan-research` or asks to "research", "compare", "evaluate", or "find out about" something.

Examples of valid research topics:
- Which component libraries are best for a specific use case?
- What are the current best practices for X in 2025?
- How do these three database options compare on latency vs. cost?
- What APIs or standards exist for solving problem Y?

**Not for:**
- Generating a prototype or code spike
- Building a feature or fixing a bug
- Architectural decisions that require team consensus

If the user asks for a prototype, implementation, or feature, redirect them to `/plan-task` instead.

## Output

A single GitHub issue labeled `research`.

No local markdown files. No `docs/plans/` directory.

---

## Step 1: Scan the Current Context

Read relevant files, conversation history, and any referenced issues to understand the background of the research question.

## Step 2: Identify a Single Scoped Research Question

A research issue must be:

- **Answerable in ~5–15 minutes**: One focused question, not a literature review.
- **Specific**: Not "research React state management" but "compare Zustand, Jotai, and Redux Toolkit for a mid-size SPA in 2025, focusing on bundle size and async patterns."
- **Actionable**: The answer should help a future decision (pick a library, choose an approach, validate an assumption).
- **Bounded**: Includes a clear scope of what to look at and what to ignore.

### Push Back on Over-Scope

If the user's request is too broad, push back and propose a narrower slice:

```
"Research frontend frameworks" is too broad for a single research session.
A more scoped research question might be:
- Compare Next.js App Router vs. Remix for a content-heavy site in 2025
- Evaluate React Server Components vs. traditional SSR for our use case
- Research the state of Rust GUI frameworks for desktop apps

Which slice should I plan?
```

### Push Back on Implementation Requests

If the user asks for a prototype, code spike, or implementation disguised as research:

```
This sounds like you want a working prototype, not research. 
Should I reframe this as a /plan-task instead?
```

## Step 3: Resolve Ambiguity by Asking Questions

Before writing the plan, resolve every ambiguity:

| Topic | What to clarify |
|-------|---------------|
| **Question** | What is the exact question to answer? |
| **Scope** | What should be included? What should be explicitly excluded? |
| **Known options** | Are there already-known candidates or approaches to evaluate? |
| **Criteria** | What dimensions matter? (cost, performance, ecosystem, maintenance, etc.) |
| **Context** | What project or codebase will use this answer? Any constraints? |
| **Recency** | How recent must the sources be? (last 6 months, last year, any?) |

Keep asking until the research question is unambiguous.

## Step 4: Validate Scope (Self-Assessment)

Before creating the issue, self-assess:

- **Can this be answered in 5–15 minutes of focused reading/searching?**
- **Does it require code changes?** If yes, redirect to `/plan-task`.
- **Is it a single focused question?** Not a multi-part survey.

If any check fails, flag it to the user and propose a narrower scope.

## Step 5: Create the GitHub Issue

Ensure the `research` label exists, then create the issue.

```bash
gh label create research --description "Scoped research or investigation task" --color 5319E7 --force 2>/dev/null
```

```bash
gh issue create \
  --title "[Research] Short imperative title" \
  --body-file /tmp/research-body.md \
  --label "research"
```

Use this exact template for the issue body:

```markdown
# [Short, imperative title]

**Date:** YYYY-MM-DD
**Author:** [user name or "agent"]

## Research Question

A single, focused question that the research should answer.

> "What are the best options for X in context Y, evaluated on criteria Z?"

## Context

1–2 sentences on why this research is needed. Reference any project context, constraints, or prior decisions.

## Scope

### In Scope
- What to investigate (libraries, approaches, standards, comparisons)
- What criteria to evaluate on (performance, cost, ecosystem, maintenance, etc.)
- Time range for sources (e.g., "last 12 months")

### Out of Scope
- What will NOT be evaluated (prevents scope creep)
- Any implementation or prototyping
- Any changes to existing code

## Known Suggestions

List any options the user already knows about or is considering. These are starting points, not constraints—the research should still look broadly and may discover better alternatives.

- Suggestion 1
- Suggestion 2
- ...

If no suggestions are known, write:
> None — open-ended search.

## Success Criteria

- [ ] The research question is answered with concrete findings
- [ ] At least 3 distinct sources or options are evaluated
- [ ] Findings are summarized in a comment on this issue
- [ ] Recommendation (if applicable) includes trade-offs

## Estimated Complexity

- **Time required:** ~5–15 minutes
- **Risk:** Low
```

Report the issue URL and number to the user.

## Step 6: Double-Check the Plan

After creating the issue, re-read it critically:

1. Could an agent who has never seen this conversation complete this research correctly?
2. Is the question specific enough to be answerable in 5–15 minutes?
3. Does the Out of Scope section clearly exclude implementation work?
4. Are known suggestions framed as hints, not constraints?
5. Is the issue labeled `research` and prefixed with `[Research]`?

If any answer is unsatisfactory, ask follow-up questions and update the issue.

## Rules

- **Never write code or create prototypes.** This skill produces only a GitHub issue.
- **Never modify existing code.**
- **If the user asks for implementation, redirect to `/plan-task`.**
- **If the scope is too broad, push back and propose a narrower slice.**
- **Known suggestions are hints, not constraints.** The research should still search broadly.
