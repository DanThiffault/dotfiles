---
name: tmux-bell
description: Send a tmux bell when the agent needs user attention so the user knows to switch back from another window/pane. Use when working inside tmux, or when the user says they want a bell on questions or task completion.
---

# Tmux Bell

When you need the user's attention, send a terminal bell by running:

```bash
printf '\a'
```

This causes tmux to highlight the window in the status bar (and ring the terminal bell if configured), alerting the user that something needs their input.

## When to Ring the Bell

Ring the bell **every time** the user might have switched away and needs to come back:

1. **Before asking a question** — The user is waiting for a response but may be in another tmux window. Ring first, then ask.
2. **Before any action requiring confirmation** — If you're about to run a command and need the user to approve it, ring first.
3. **After completing a long-running task** — If a tool execution, test run, or file operation took more than ~15 seconds and the session is now idle waiting for the user, ring the bell.
4. **After a tool or command errors** — If a build fails, tests fail, a command returns non-zero, or any operation errors out and I need direction on how to proceed, ring the bell.
5. **When explicitly requested** — If the user says `/tmux-bell` or "ring the bell," ring it immediately.

## How to Use

Simply run the bell command before your message:

```
printf '\a'
```

Then proceed with your question or statement. The bell is fire-and-forget — you do not need to check if it succeeded.

## Tips

- Ring once per attention event. Multiple bells in quick succession are annoying.
- **Cooldown:** If you already rang the bell within the last ~30 seconds or the last 1-2 turns and the user has not yet responded, do not ring again. The window highlight is already active.
- Do not ring for routine, fast interactions (< 5 seconds) where the user is likely still watching.
- If the user has explicitly disabled bells or is in a non-tmux environment, the command is harmless.
- **Cooldown is cheap.** The cooldown rule adds no meaningful cost — it simply tells the model to skip the bell if it already rang in the last ~30 seconds or the last 1-2 turns. No extra tool calls or state storage needed.
- For extra visibility, you can combine with `tmux display-message` (optional):
  ```bash
  printf '\a' && tmux display-message "Agent needs input" 2>/dev/null || printf '\a'
  ```
