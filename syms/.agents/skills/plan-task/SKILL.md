---
name: plan-task
description: Extract a single, self-contained, unambiguous piece of work from the current context and write it as a markdown plan under docs/plans/. Invoke when the user says /plan-task or wants to turn a conversation thread, PR, ticket, or idea into an implementable plan for a single context window.
disable-model-invocation: true
---

# Plan Task

Turn the current context into a single, self-contained, unambiguous markdown plan that an independent agent or developer could implement in one context window.

## When to Use

Invoke this skill when the user explicitly says `/plan-task` or asks to "plan this", "write a plan", or "break this into a task".

## Output

A single markdown file at `{project-root}/docs/plans/YYYYMMDD_short-description.md`, where `{project-root}` is the current working directory where this skill is invoked. No code changes.

---

## Step 1: Scan the Current Context

Read the relevant files, conversation history, and any referenced issues/tickets to understand what work has been discussed.

If the codebase is large and the task spans multiple directories, list the key files you read so the plan includes a "Relevant Files" section.

## Step 2: Identify a Single Self-Contained Task

A plan produced by this skill must represent **one** piece of work that is:

- **Self-contained**: Can be implemented start-to-finish without needing other in-flight work. It has clear inputs and outputs.
- **Single context window**: Small enough that an independent agent can read the plan, examine the relevant existing code, implement the change, run tests, and commit — all in one session. As a rule of thumb:
  - No more than ~3-5 files modified
  - No more than ~200 lines of new/changed code (tests + implementation)
  - No architectural decisions that require cross-team agreement
  - No dependencies on unbuilt infrastructure

If the current context describes **multiple** tasks, a large epic, or a vague idea, **do not** write a plan yet. Instead, list the candidate tasks and ask the user to pick one:

```
The context seems to contain several possible tasks:
1. Add email validation to the signup form
2. Switch the signup flow to use OAuth
3. Add rate-limiting to the signup endpoint

Which one should I plan? Or should we break it down further?
```

If the context describes a task that is **too large**, push back and propose a smaller slice:

```
"Refactor the entire auth system" is too broad for a single context window.
A more self-contained slice might be:
- Extract password hashing into its own module
- Add session token rotation
- Replace cookie parser with a typed version

Which slice should I plan?
```

## Step 3: Resolve Ambiguity by Asking Questions

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

Keep asking follow-up questions. Do not assume defaults. Do not fill in gaps with "probably." If the user is unsure, make them decide or mark it as an open question in the plan.

## Step 4: Write the Plan

Create the directory under the current project if it doesn't exist:

```bash
mkdir -p docs/plans
```

Write the file relative to the project root: `docs/plans/YYYYMMDD_short-description.md`

Use this exact template. Every section is required unless explicitly noted as optional.

```markdown
# [Short, imperative title]

**Date:** YYYY-MM-DD
**Author:** [user name or "agent"]
**Status:** Draft

## Context

1-2 sentences on why this work exists. Reference tickets, PRs, or conversation threads if applicable.

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
List the key files the implementer should read first.

### Seams / Boundaries
Where does this change touch existing code? What interfaces or contracts are involved?

### Implementation Approach
Brief outline of the approach. Do not write pseudocode. Just the strategy: e.g., "Add a new behaviour, implement it for the existing adapter, wire it into the request pipeline."

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

## Step 5: Double-Check the Plan

After writing the file, **re-read it critically** and answer these questions:

1. Could an agent who has never seen this conversation implement this plan correctly?
2. Are there any words that could mean two different things?
3. Are the acceptance criteria testable?
4. Is the "Out of Scope" section strong enough to prevent scope creep?
5. Are there implicit assumptions about data shape, environment, or existing code?
6. Is the task truly self-contained? Does it need any other in-flight work?
7. Does the file path follow the convention `docs/plans/YYYYMMDD_short-description.md` relative to the project root?

If any answer is unsatisfactory, **ask the user follow-up questions** and update the plan. Do not leave the file in a half-baked state.

## Step 6: Highlight Domain Concepts

If the plan introduces or changes a domain concept, explicitly tell the user:

```
⚠️ This plan introduces a new domain concept: "BookingWindow". It represents the time range during which a resource can be reserved. You may want to communicate this to the team, as it will likely appear in API docs, the frontend, and reporting queries.
```

## Rules

- **Never write code.** This skill produces only a markdown plan file.
- **Never modify existing code** to "prepare" for the plan.
- **If the user asks for a plan that is too large**, push back and offer smaller slices.
- **If the user is vague**, keep asking questions until the plan is unambiguous.
- **The Open Questions section must be empty before you consider the plan complete.**
