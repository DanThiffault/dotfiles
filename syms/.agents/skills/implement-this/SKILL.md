---
name: implement-this
description: Combines interactive planning and direct implementation without creating GitHub issues. Gathers requirements, pushes back on vague or oversized requests, confirms a precise plan with the user, then immediately implements it in an isolated git worktree using TDD. Invoke when the user says /implement-this or wants to build something right now without ticketing overhead.
---

# Implement This

Plan and implement a single, self-contained piece of work in one continuous session — no GitHub issues, no PRs, no hand-offs.

## When to Use

Invoke this skill when the user says `/implement-this`, "just build it", "make it happen", or any variant that implies immediate implementation without the overhead of creating a GitHub issue.

Also use this skill when the user is already in a planning conversation and asks to "go ahead and implement it" — **do not** skip the planning pushback and ambiguity resolution just because the user is eager.

## Output

- A locally-stored plan (temporary file, no issue created).
- Committed code on a feature branch in an isolated worktree.
- A summary report of what was built.

---

## Step 1: Scan the Current Context

Read the relevant files, conversation history, and any referenced PRs/tickets to understand what work has been discussed. If the codebase is large and the task spans multiple directories, list the key files you read so the plan includes a "Relevant Files" section.

## Step 2: Identify a Single Self-Contained Task

A session produced by this skill must represent **one** piece of work that is:

- **Tracer bullet**: Cuts a narrow but **complete** path through every layer involved (schema, API, UI, tests). It is end-to-end and verifiable on its own — not a horizontal slice of one layer.
- **Self-contained**: Can be implemented start-to-finish without needing other in-flight work. It has clear inputs and outputs.
- **Single context window**: Small enough that an agent can read the plan, examine the relevant existing code, implement the change, run tests, and commit — all in one session. As a rule of thumb:
  - No more than ~3-5 files modified
  - No more than ~200 lines of new/changed code (tests + implementation)
  - No architectural decisions that require cross-team agreement
  - No dependencies on unbuilt infrastructure

### Wide Refactor Exception

A **wide refactor** (rename a column, retype a shared symbol, move a module) has a blast radius that fans across the whole codebase. No vertical slice can land green, so don't force it into the tracer-bullet template. Instead, suggest breaking it into an **expand–contract** sequence and plan only the first batch.

### If the context contains multiple tasks

If the current context describes **multiple** tasks, a large epic, or a vague idea, **do not** write a plan yet. Instead, list the candidate tasks and ask the user to pick one:

```
The context seems to contain several possible tasks:
1. Add email validation to the signup form
2. Switch the signup flow to use OAuth
3. Add rate-limiting to the signup endpoint

Which one should I plan? Or should we break it down further?
```

### If the task is too large

If the context describes a task that is **too large**, push back and propose a smaller slice:

```
"Refactor the entire auth system" is too broad for a single context window.
A more self-contained slice might be:
- Extract password hashing into its own module
- Add session token rotation
- Replace cookie parser with a typed version

Which slice should I plan?
```

## Step 3: Check for Prefactoring Opportunities

Before writing the plan, consider: is there a small prefactoring change (extract a function, add a seam, rename a local, introduce a no-op adapter) that would make this task easier? If so, suggest it as a **prerequisite** — a separate `/implement-this` session to be done first. Prefactoring keeps the main session focused and reduces risk.

## Step 4: Resolve Ambiguity by Asking Questions

Before writing any code, you must resolve every ambiguity. A plan is only as good as its clarity. Ask questions until all of the following are answered:

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

## Step 5: Validate Granularity (Self-Assessment)

Before confirming the plan, self-assess the task against the single-context-window rubric:

- **Files touched:** ≤5?
- **Lines of new/changed code:** ≤200 (implementation + tests)?
- **Single seam:** Does it change one public boundary, or does it reach across many?
- **Demoable on its own:** Can an agent implement, test, and commit this without needing other in-flight work?

If any rubric item is **at risk or violated**, flag it to the user and ask:

> "This task looks like it may touch ~7 files / ~300 lines. Should we split it further?"

If the rubric is satisfied, proceed without asking.

## Step 6: Confirm the Plan with the User

Write the plan to a temporary file (e.g., `/tmp/implement-this-plan.md`) using the template below. Present a **summary** to the user and ask for explicit confirmation before proceeding to implementation.

### Plan Template

```markdown
# Plan: [Short, imperative title]

**Date:** YYYY-MM-DD

## Goal

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

## Technical Notes

### Relevant Files
List the key files the implementer should read first.

### Seams / Boundaries
Where does this change touch existing code? What interfaces or contracts are involved?

### Implementation Approach
Brief outline of the approach. No pseudocode.

## Error Handling

What should happen in failure scenarios?

## Testing Strategy

- What tests to write
- Any test data or fixtures needed
- Patterns to follow from the existing codebase

## Open Questions

List any remaining uncertainties. This section **must be empty** before implementation starts.

## Estimated Complexity

- **Files touched:** ~N
- **Lines of change:** ~N (implementation + tests)
- **Risk:** Low / Medium / High
```

Present the summary and ask:

> **Ready to implement?** This will create a branch and worktree, then build the feature using TDD. Confirm to proceed.

If the user says no, asks for changes, or introduces new ambiguity, update the plan and ask again. **Do not** proceed to implementation without explicit confirmation.

## Step 7: Prepare the Worktree and Branch

Ensure the working tree is clean. Stash or abort if not.

### Ensure `.agent-worktrees/` is gitignored

Before creating worktrees, verify `.agent-worktrees/` is listed in `.gitignore` at the repo root. If it is missing, add it and commit:

```bash
grep -q "\.agent-worktrees/" .gitignore || echo ".agent-worktrees/" >> .gitignore
```

### Worktree detection

Check if you are already inside a git worktree. If so, skip creation and use the current directory:

```bash
git rev-parse --is-inside-work-tree && git worktree list --porcelain | grep -q "worktree $(pwd)" && echo "Already in a worktree"
```

If already in a worktree, proceed directly to implementation in the current directory.

### Create an isolated worktree

Create a new worktree and branch. Use a kebab-case description based on the task title. Include a short timestamp or random suffix if needed to avoid collisions:

```bash
SLUG="<short-kebab-description>"
WORKTREE=".agent-worktrees/implement-this-${SLUG}/"
BRANCH="feat/${SLUG}"
git worktree add -b "$BRANCH" "$WORKTREE"
cd "$WORKTREE"
```

Example:

```bash
git worktree add -b feat/add-email-validation .agent-worktrees/implement-this-add-email-validation/
cd .agent-worktrees/implement-this-add-email-validation/
```

If the worktree path already exists, append a suffix (e.g., `-2`, `-3`) and retry.

## Step 8: Implement (TDD)

Follow the `tdd` skill rules:

1. **Identify seams** — Confirm the public interface with the user before writing the first test. Write the seam list in a scratchpad or as a code comment.
2. **Red** — Write a failing test. Run it. Watch it fail for the right reason.
3. **Green** — Write the minimal code to pass. Do not refactor yet.
4. **Repeat** — One vertical slice at a time. One seam, one test, one minimal implementation per cycle.

Consult the `tdd` skill for:
- What a good test is
- When to mock
- Anti-patterns (implementation-coupled, tautological, horizontal slicing)
- Rules of the loop (red before green, one slice at a time, no refactoring during the loop)

Run typechecking and single-file tests regularly. Run the full test suite before committing.

## Step 9: Commit

Make one or more commits in the branch. Each commit should be reviewable and pass tests. Every commit message must follow the **Conventional Commits** standard.

Allowed prefixes: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`.

```bash
git add ...
git commit -m "feat: short imperative description

- Implements: <acceptance criterion 1>"
```

If the task spans multiple seams, consider one commit per seam.

Run the full test suite before the final commit.

## Step 10: Report and Leave Session Open

Ring the bell to alert the user that implementation is complete:

```bash
printf '\a'
```

Report to the user:

```
Implementation complete on branch: feat/<branch-name>
Worktree: .agent-worktrees/implement-this-<description>/

Commits:
- <hash> <subject>
- <hash> <subject>

No PR was created. Push and open a PR manually when ready.
```

Do **not** push to the remote. The user will review locally and push when ready.

Do **not** exit the session. Leave it open in case the user has follow-up questions or requests changes.

---

## Rules

- **Never create a GitHub issue.** This skill is explicitly issue-free.
- **Never reference an issue number** in commits, branches, messages, or plans.
- **Never skip ambiguity resolution.** If the user is vague, keep asking questions until the plan is unambiguous.
- **Never jump directly to implementation** during an active planning conversation without explicit user confirmation.
- **Push back on oversized requests.** Suggest smaller slices if the work is too large for one context window.
- **Never use `spawn_agent`.** Do all work in the current session.
- **Never refactor during red-green.** Refactoring belongs in a follow-up or after review.
- **Always run the full test suite before the final commit.**
- **If acceptance criteria change during implementation, stop and update the plan file** before proceeding.
- **Always use Conventional Commits.**
