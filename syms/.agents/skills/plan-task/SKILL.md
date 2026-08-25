---
name: plan-task
description: Extract a single, self-contained, unambiguous piece of work from the current context and write it as a markdown plan under docs/plans/. Works standalone or as a task within a feature. Invoke when the user says /plan-task or wants to turn a conversation thread, PR, ticket, or idea into an implementable plan for a single context window.
---

# Plan Task

Turn the current context into a single, self-contained, unambiguous markdown plan that an independent agent or developer could implement in one context window.

Works in two modes:
- **Standalone**: A single independent task.
- **Feature task**: One task within a larger feature plan (see `plan-feature`). If a feature doc exists under `docs/plans/<feature-slug>/`, or if the user names a feature, operate in feature-task mode.

## When to Use

Invoke this skill when the user explicitly says `/plan-task` or asks to "plan this", "write a plan", or "break this into a task".

## Output

A single markdown file at either:
- Standalone: `{project-root}/docs/plans/standalone_YYYYMM/YYYYMMDD_short-description.md`
- Feature task: `{project-root}/docs/plans/<feature-slug>/YYYYMMDD_short-description.md`

Standalone tasks are grouped by month. There is no corresponding `standalone_YYYYMM.md` file.

---

## Step 1: Scan the Current Context

Read the relevant files, conversation history, and any referenced issues/tickets to understand what work has been discussed.

If the codebase is large and the task spans multiple directories, list the key files you read so the plan includes a "Relevant Files" section.

## Step 2: Identify a Single Self-Contained Task

A plan produced by this skill must represent **one** piece of work that is:

- **Tracer bullet**: Cuts a narrow but **complete** path through every layer involved (schema, API, UI, tests). It is end-to-end and verifiable on its own — not a horizontal slice of one layer.
- **Self-contained**: Can be implemented start-to-finish without needing other in-flight work. It has clear inputs and outputs.
- **Single context window**: Small enough that an independent agent can read the plan, examine the relevant existing code, implement the change, run tests, and commit — all in one session. As a rule of thumb:
  - No more than ~3-5 files modified
  - No more than ~200 lines of new/changed code (tests + implementation)
  - No architectural decisions that require cross-team agreement
  - No dependencies on unbuilt infrastructure

### Wide Refactor Exception

A **wide refactor** (rename a column, retype a shared symbol, move a module) has a blast radius that fans across the whole codebase. No vertical slice can land green, so don't force it into the tracer-bullet template. Instead, sequence it as **expand–contract**: first add the new form beside the old, then migrate call sites in batches, finally delete the old form. Each batch is its own plan. If the user describes a wide refactor, suggest breaking it into an expand-contract sequence and plan only the first batch.

If the current context describes **multiple** tasks, a large epic, or a vague idea, **do not** write a plan yet. Instead, list the candidate tasks and ask the user to pick one:

```
The context seems to contain several possible tasks:
1. Add email validation to the signup form
2. Switch the signup flow to use OAuth
3. Add rate-limiting to the signup endpoint

Which one should I plan? Or should we break it down further?
```

If the context describes a task that is **too large**, push back and propose a smaller slice. If it describes a **wide refactor**, suggest the expand-contract approach instead.

```
"Refactor the entire auth system" is too broad for a single context window.
A more self-contained slice might be:
- Extract password hashing into its own module
- Add session token rotation
- Replace cookie parser with a typed version

Which slice should I plan?
```

### Feature-Task Mode

If you are writing this task as part of a feature:
- The overall scope and goal are bounded by the feature doc. The task's scope should be a narrow slice of the feature, not the whole feature.
- The feature doc lives at `docs/plans/<feature-slug>/<feature-slug>.md`. Reference it in Context.

## Step 3: Check for Prefactoring Opportunities

Before writing the plan, consider: is there a small prefactoring change (extract a function, add a seam, rename a local, introduce a no-op adapter) that would make this task easier? If so, suggest it as a separate prerequisite plan. Prefactoring keeps the main plan focused and reduces risk.

## Step 4: Resolve Ambiguity by Asking Questions

Before writing the plan, you must resolve every ambiguity. A plan is only as good as its clarity. Ask questions until all of the following are answered:

| Topic | What to clarify |
|-------|-----------------|
| **Goal** | What does "done" look like? What is the exact user-facing or system-facing outcome? |
| **Scope** | What is explicitly in scope? What is explicitly out of scope? |
| **Interface** | What is the public API, schema, or contract being introduced or changed? |
| **Data** | What data structures, DB migrations, or state changes are involved? |
| **Error cases** | What should happen when things fail? What are the error messages or fallback behaviors? |
| **Tests** | What level of testing is expected (unit, integration, both)? Any existing test patterns to follow? |
| **Seams** | Where does this touch existing code? What are the agreed boundaries? |
| **Dependencies** | Does it depend on other PRs, env vars, packages, or infrastructure? |
| **Rollback** | Can it be reverted cleanly if something goes wrong? |

If this is a feature task, also confirm:
- How does this task's scope fit within the feature's scope?
- Does it overlap with any sibling tasks? If so, resolve the boundary.

Keep asking follow-up questions. Do not assume defaults. Do not fill in gaps with "probably." If the user is unsure, make them decide or mark it as an open question in the plan.

## Step 5: Validate Granularity (Self-Assessment)

Before writing the file, self-assess the task against the single-context-window rubric:

- **Files touched:** ≤5?
- **Lines of new/changed code:** ≤200 (implementation + tests)?
- **Single seam:** Does it change one public boundary, or does it reach across many?
- **Demoable on its own:** Can an agent implement, test, and commit this without needing other in-flight work?

If any rubric item is **at risk or violated**, flag it to the user and ask:

> "This task looks like it may touch ~7 files / ~300 lines. Should we split it further?"

If the rubric is satisfied, proceed without asking. This keeps the loop tight while maintaining the constraint.

## Step 6: Write the Plan

Create the directory under the current project:

```bash
# Standalone — group by month
mkdir -p docs/plans/standalone_YYYYMM

# Feature task
mkdir -p docs/plans/<feature-slug>
```

Write the file: `docs/plans/standalone_YYYYMM/YYYYMMDD_short-description.md` or `docs/plans/<feature-slug>/YYYYMMDD_short-description.md`

Use this exact template. Every section is required unless explicitly noted as optional.

```markdown
# [Short, imperative title]

**Date:** YYYY-MM-DD
**Author:** [user name or "agent"]
**Status:** Draft

## Status

A lightweight tracking field, updated manually by the user or team. Not modified by the `implement-task` skill.

- **Draft** — Plan is written but not yet reviewed or approved
- **Ready** — Ambiguity resolved, approved for implementation
- **In Progress** — Someone has started implementing
- **Done** — Implemented and verified

## Context

1-2 sentences on why this work exists. Reference tickets, PRs, or conversation threads if applicable.

If this task belongs to a feature, mention it here:
> Part of the [Feature Name](<feature-slug>.md) feature.

## Goal

A single sentence describing the exact outcome. Use the format:
> "When [condition], [system/user] can [action] so that [value]."

## Scope

### In Scope
- Bullet list of what will be built or changed

### Out of Scope
- Bullet list of what will NOT be built or changed (this prevents scope creep)

## Acceptance Criteria

- [ ] Criterion 1: verifiable, specific, no ambiguity
- [ ] Criterion 2: verifiable, specific, no ambiguity
- [ ] Criterion 3: verifiable, specific, no ambiguity

Each criterion should be testable. If you can't write a test for it, it's not an acceptance criterion.

## Technical Notes

### Relevant Files (optional)
List the key files the implementer should read first. These are **hints, not contracts** — file paths go stale quickly as the codebase evolves.

### Seams / Boundaries
Where does this change touch existing code? What interfaces or contracts are involved?

### Implementation Approach
Brief outline of the approach. Do not write pseudocode. Just the strategy: e.g., "Add a new behaviour, implement it for the existing adapter, wire it into the request pipeline."

### Blocked by
This section is **required** for all tasks — standalone and feature tasks alike.

List any other tasks or work that must complete before this one can start. Use relative file links if referencing tasks in the same folder:
- [Task title](YYYYMMDD_short-description.md)

If this task depends on a task from another feature or on external work (a PR, package release, infra change), name it explicitly.

If this task has no blockers, write:
> None — can start immediately.

## Error Handling

What should happen in failure scenarios? Be specific about errors, fallbacks, and logging.

## Testing Strategy

- What tests to write (unit, integration, property, etc.)
- Any test data or fixtures needed
- Patterns to follow from the existing codebase

## Open Questions

List any remaining uncertainties. If this section is non-empty, the plan is **not ready**.

## New or Changing Domain Concepts

If this plan introduces a new domain concept or changes the meaning of an existing one, call it out here. Include:
- The term/concept name
- What it means
- Where else in the codebase it might need to be updated or communicated

## Estimated Complexity

- **Files touched:** ~N
- **Lines of change:** ~N (implementation + tests)
- **Risk:** Low / Medium / High
```

## Step 7: Double-Check the Plan

After writing the file, **re-read it critically** and answer these questions:

1. Could an agent who has never seen this conversation implement this plan correctly?
2. Are there any words that could mean two different things?
3. Are the acceptance criteria testable?
4. Is the "Out of Scope" section strong enough to prevent scope creep?
5. Are there implicit assumptions about data shape, environment, or existing code?
6. Is the task truly self-contained? Does it need any other in-flight work?
7. Does the file path follow the convention (`docs/plans/standalone_YYYYMM/` or `docs/plans/<feature-slug>/`) relative to the project root?
8. Is the `Blocked by` section present and populated (even if only "None")?

If this is a **feature task**, also verify:
9. Does the Context correctly reference the feature doc?
10. Does this task's scope align with the feature's scope without overlapping sibling tasks?

If any answer is unsatisfactory, **ask the user follow-up questions** and update the plan. Do not leave the file in a half-baked state.

## Step 8: Highlight Domain Concepts

If the plan introduces or changes a domain concept, explicitly tell the user:

```
⚠️ This plan introduces a new domain concept: "BookingWindow". It represents the time range during which a resource can be reserved. You may want to communicate this to the team, as it will likely appear in API docs, the frontend, and reporting queries.
```

If this is a feature task and introduces a domain concept, the concept should also be listed in the feature doc's "New or Changing Domain Concepts" section. Confirm it is.

## Rules

- **Never write code.** This skill produces only a markdown plan file.
- **Never modify existing code** to "prepare" for the plan.
- **If the user asks for a plan that is too large**, push back and offer smaller slices.
- **If the user is vague**, keep asking questions until the plan is unambiguous.
- **The Open Questions section must be empty before you consider the plan complete.**
