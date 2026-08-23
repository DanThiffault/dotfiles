---
name: engineering-implement
description: Implement a piece of work based on a spec, PRD, or set of tickets. Use when the user has a clear plan of what to build and wants disciplined, test-driven execution.
disable-model-invocation: true
---

# Engineering Implement

Implement the work described by the user in the spec or tickets.

## Workflow

1. **Understand the scope**
   - Read the spec, PRD, or tickets
   - Identify the pre-agreed seams (boundaries between subsystems) where tests and mocks can be inserted

2. **Test-Driven Development**
   - Use /tdd where possible, writing tests before implementation
   - Focus on one seam at a time
   - Mock/stub at the agreed boundaries

3. **Iterate with fast feedback**
   - Run typechecking regularly
   - Run single test files regularly as you work
   - Run the full test suite once at the end before finishing

4. **Self-review**
   - Once done, use /code-review to review the work

5. **Commit**
   - Commit your work to the current branch with a descriptive message

## Tips

- Do not deviate from the spec unless the user explicitly approves a change
- Keep changes scoped to the agreed work
- Prefer small, reviewable commits over large blobs
