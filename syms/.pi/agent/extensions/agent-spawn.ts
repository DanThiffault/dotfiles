import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

export default function agentSpawnExtension(pi: ExtensionAPI) {
	function validateTmux(ctx: { ui: { notify: (msg: string, type: string) => void } }, commandName: string) {
		// Check tmux is in PATH
		const which = spawnSync("which", ["tmux"], { encoding: "utf8" });
		if (which.status !== 0) {
			ctx.ui.notify("tmux not found in PATH", "error");
			return null;
		}

		// Check we're inside tmux
		if (!process.env.TMUX) {
			ctx.ui.notify(`${commandName} requires a tmux session`, "error");
			return null;
		}

		// Get current session name
		const sessionResult = spawnSync("tmux", ["display-message", "-p", "#S"], {
			encoding: "utf8",
		});
		if (sessionResult.status !== 0) {
			ctx.ui.notify(`${commandName} requires a tmux session`, "error");
			return null;
		}

		return sessionResult.stdout.trim();
	}

	function getFreeIndex(session: string): number {
		const listResult = spawnSync("tmux", ["list-windows", "-t", session, "-F", "#I"], {
			encoding: "utf8",
		});
		if (listResult.status !== 0) {
			return 10;
		}

		const indices = listResult.stdout
			.trim()
			.split("\n")
			.map((s) => parseInt(s.trim(), 10))
			.filter((n) => !isNaN(n));

		let index = 10;
		while (indices.includes(index)) {
			index++;
		}
		return index;
	}

	pi.registerCommand("agent-spawn", {
		description: "Spawn a new pi agent in a tmux window",
		handler: async (args, ctx) => {
			const session = validateTmux(ctx, "agent-spawn");
			if (!session) return;

			const freeIndex = getFreeIndex(session);
			if (freeIndex > 99999) {
				ctx.ui.notify("No free tmux window index ≥10", "error");
				return;
			}

			const cwd = ctx.cwd;
			const message = args.trim();

			const tmuxArgs = [
				"new-window",
				"-t",
				`${session}:${freeIndex}`,
				"-c",
				cwd,
				"-n",
				`agent-${freeIndex}`,
			];

			if (message) {
				tmuxArgs.push("pi", message);
			} else {
				tmuxArgs.push("pi");
			}

			const result = spawnSync("tmux", tmuxArgs);
			if (result.status !== 0) {
				const err = result.stderr?.trim() || "unknown error";
				ctx.ui.notify(`Failed to spawn agent: ${err}`, "error");
				return;
			}

			ctx.ui.notify(`Agent spawned at window ${freeIndex}`, "info");
		},
	});

	pi.registerCommand("agent-list", {
		description: "List active agent windows",
		handler: async (_args, ctx) => {
			const session = validateTmux(ctx, "agent-list");
			if (!session) return;

			const listResult = spawnSync("tmux", ["list-windows", "-t", session, "-F", "#I:#W"], {
				encoding: "utf8",
			});

			if (listResult.status !== 0) {
				ctx.ui.notify("No active agent windows", "info");
				return;
			}

			const windows = listResult.stdout
				.trim()
				.split("\n")
				.map((line) => line.trim())
				.filter((line) => {
					const index = parseInt(line.split(":")[0], 10);
					return !isNaN(index) && index >= 10;
				});

			if (windows.length === 0) {
				ctx.ui.notify("No active agent windows", "info");
				return;
			}

			ctx.ui.notify(`Agent windows: ${windows.join(", ")}`, "info");
		},
	});
}
