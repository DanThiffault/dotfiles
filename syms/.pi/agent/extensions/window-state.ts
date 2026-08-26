import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

/**
 * Pi extension that renames the current tmux window based on agent state.
 *
 * States:
 *   WORKING – assistant is generating or tools are running (no prefix)
 *   BLOCK   – assistant finished, waiting for user input (magenta bg)
 *   DONE    – session ended gracefully (muted grey bg)
 *   ERROR   – response was truncated or an error occurred (red bg)
 */
export default function windowStateExtension(pi: ExtensionAPI) {
	let originalName: string | null = null;
	let pendingTools = 0;
	let debounceTimer: ReturnType<typeof setTimeout> | null = null;
	let warnedTmux = false;

	const isInTmux = !!process.env.TMUX;

	const STYLES = {
		block: "bg=#c678dd,fg=#171717,bold",
		done: "bg=#39404E,fg=#737C90",
		error: "bg=#e67e80,fg=#171717,bold",
	};

	function tmux(args: string[]): { stdout: string } | null {
		const result = spawnSync("tmux", args, { encoding: "utf8" });
		if (result.status !== 0) {
			if (!warnedTmux) {
				console.warn(`[window-state] tmux command failed: tmux ${args.join(" ")}`);
				warnedTmux = true;
			}
			return null;
		}
		return { stdout: result.stdout };
	}

	function getWindowName(): string | null {
		const result = tmux(["display-message", "-p", "#{window_name}"]);
		if (!result) return null;
		// Strip any existing prefix left from a previous session
		return result.stdout.trim().replace(/^(BLOCK|DONE|ERROR):\s*/, "");
	}

	function applyState(prefix: string | null, style: string | null) {
		if (!isInTmux || !originalName) return;

		if (prefix) {
			tmux(["rename-window", `${prefix}: ${originalName}`]);
		} else {
			tmux(["rename-window", originalName]);
		}

		if (style) {
			tmux(["set-window-option", "window-status-style", style]);
		} else {
			tmux(["set-window-option", "-u", "window-status-style"]);
		}
	}

	function setWorking() {
		if (debounceTimer) {
			clearTimeout(debounceTimer);
			debounceTimer = null;
		}
		applyState(null, null);
	}

	function debounceBlock() {
		if (debounceTimer) clearTimeout(debounceTimer);
		debounceTimer = setTimeout(() => {
			applyState("BLOCK", STYLES.block);
		}, 200);
	}

	function setError() {
		if (debounceTimer) {
			clearTimeout(debounceTimer);
			debounceTimer = null;
		}
		applyState("ERROR", STYLES.error);
	}

	function setDone() {
		if (debounceTimer) {
			clearTimeout(debounceTimer);
			debounceTimer = null;
		}
		applyState("DONE", STYLES.done);
	}

	// ── Event hooks ───────────────────────────────────────────────────────

	pi.on("session_start", async () => {
		if (!isInTmux) return;
		originalName = getWindowName();
		pendingTools = 0;
	});

	// Assistant starts generating → working
	pi.on("message_start", async (event) => {
		if (event.message.role === "assistant") {
			setWorking();
		}
	});

	// Assistant message completes
	pi.on("message_end", async (event) => {
		const msg = event.message;
		if (msg.role !== "assistant") return;

		if (msg.stopReason === "length" || msg.stopReason === "error") {
			setError();
		} else if (msg.stopReason !== "toolUse" && pendingTools === 0) {
			debounceBlock();
		}
	});

	// Tool starts → working
	pi.on("tool_execution_start", async () => {
		pendingTools++;
		setWorking();
	});

	// Tool ends
	pi.on("tool_execution_end", async () => {
		pendingTools = Math.max(0, pendingTools - 1);
	});

	// Best-effort cleanup on exit
	process.on("beforeExit", () => {
		setDone();
	});
}
