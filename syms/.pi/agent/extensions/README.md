# agent-spawn

Extension for [pi](https://github.com/earendil-works/pi-defender) that manages agent windows inside tmux sessions.

## Installation

Copy `agent-spawn.ts` to `~/.pi/agent/extensions/agent-spawn.ts`, then run `/reload` in pi.

Requires:
- [tmux](https://github.com/tmux/tmux)
- pi running inside a tmux session

## Commands

| Command | Description |
|---|---|
| `/agent-spawn [message]` | Spawn a new pi agent in the lowest free tmux window (index ≥10) |
| `/agent-spawn --here <dir> [message]` | Spawn with a specific working directory |
| `/agent-list` | List all active agent windows |
| `/agent-close <index>` | Close a specific agent window |
| `/agent-close all` | Close all agent windows |

## Examples

```
/agent-spawn review auth PR
/agent-spawn --here ~/projects/api fix the build
/agent-list
/agent-close 10
/agent-close all
```

## Error handling

All errors are shown via pi notifications instead of stack traces:

- **Not in tmux** — `agent-spawn requires a tmux session`
- **tmux not found** — `tmux not found in PATH`
- **No free index** — `No free tmux window index ≥10`
- **Invalid index** — `Agent index must be ≥10`
- **Window already closed** — `Window N is not an agent window or is already closed`
