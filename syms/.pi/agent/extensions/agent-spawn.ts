import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

export default function agentSpawnExtension(pi: ExtensionAPI) {
	function validateTmux(ctx: { ui: { notify: (msg: string, type: string) => void } }, commandName: string) {
		const which = spawnSync("which", ["tmux"], { encoding: "utf8" });
		if (which.status !== 0) {
			ctx.ui.notify("tmux not found in PATH", "error");
			return null;
		}

		if (!process.env.TMUX) {
			ctx.ui.notify(`${commandName} requires a tmux session`, "error");
			return null;
		}

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

	function getAgentWindowIndices(session: string): number[] {
		const listResult = spawnSync("tmux", ["list-windows", "-t", session, "-F", "#I"], {
			encoding: "utf8",
		});
		if (listResult.status !== 0) {
			return [];
		}
		return listResult.stdout
			.trim()
			.split("\n")
			.map((s) => parseInt(s.trim(), 10))
			.filter((n) => !isNaN(n) && n >= 10);
	}

	function parseSpawnArgs(args: string): { cwd?: string; message?: string } {
		const trimmed = args.trim();
		if (!trimmed) return {};

		const hereMatch = trimmed.match(/^--here\s+(\S+)\s*(.*)$/);
		if (hereMatch) {
			return { cwd: hereMatch[1], message: hereMatch[2] || undefined };
		}

		return { message: trimmed || undefined };
	}

	pi.registerCommand("agent-spawn", {
		description: "Spawn a new pi agent in a tmux window",
		handler: async (args, ctx) => {
			const session = validateTmux(ctx, "agent-spawn");
			if (!session) return;

			const { cwd: hereCwd, message } = parseSpawnArgs(args);
			const cwd = hereCwd || ctx.cwd;
			const freeIndex = getFreeIndex(session);
			if (freeIndex > 99999) {
				ctx.ui.notify("No free tmux window index ≥10", "error");
				return;
			}

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
				const err = result.stderr?.toString().trim() || "unknown error";
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

			const indices = getAgentWindowIndices(session);

			if (indices.length === 0) {
				ctx.ui.notify("No agent windows running", "info");
				return;
			}

			ctx.ui.notify(`Agent windows: ${indices.join(", ")}`, "info");
		},
	});

	pi.registerCommand("agent-close", {
		description: "Close an agent window or all agent windows",
		handler: async (args, ctx) => {
			const session = validateTmux(ctx, "agent-close");
			if (!session) return;

			const arg = args.trim();
			if (!arg) {
				ctx.ui.notify("Usage: /agent-close \u003Cindex|all\u003E", "error");
				return;
			}

			if (arg === "all") {
				const indices = getAgentWindowIndices(session);
				if (indices.length === 0) {
					ctx.ui.notify("No agent windows to close", "info");
					return;
				}
				for (const index of indices) {
					const result = spawnSync("tmux", ["kill-window", "-t", `${session}:${index}`]);
					if (result.status !== 0) {
						const err = result.stderr?.toString().trim() || "unknown error";
						ctx.ui.notify(`Failed to close window ${index}: ${err}`, "error");
						continue;
					}
				}
				ctx.ui.notify(`Closed ${indices.length} agent window${indices.length === 1 ? "" : "s"}`, "info");
				return;
			}

			const index = parseInt(arg, 10);
			if (isNaN(index) || index < 10) {
				ctx.ui.notify("Agent index must be ≥10", "error");
				return;
			}

			const agentIndices = getAgentWindowIndices(session);
			if (!agentIndices.includes(index)) {
				ctx.ui.notify(`Window ${index} is not an agent window or is already closed`, "info");
				return;
			}

			const result = spawnSync("tmux", ["kill-window", "-t", `${session}:${index}`]);
			if (result.status !== 0) {
				const err = result.stderr?.toString().trim() || "unknown error";
				ctx.ui.notify(`Failed to close window ${index}: ${err}`, "error");
				return;
			}

			ctx.ui.notify(`Closed agent window ${index}`, "info");
		},
	});
}
