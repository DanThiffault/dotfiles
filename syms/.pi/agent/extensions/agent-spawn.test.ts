/**
 * Quick smoke test for agent-spawn extension handlers.
 * Run with: npx tsx agent-spawn.test.ts
 *
 * This mocks the ExtensionAPI and exercises command handlers
 * against the live tmux session. It is a manual verification aid,
 * not an automated CI test.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import agentSpawnExtension from "./agent-spawn";

const notifications: { msg: string; type: string }[] = [];

const mockPi: ExtensionAPI = {
	registerCommand: (name: string, cfg: { description: string; handler: (args: string, ctx: any) => Promise<void> }) => {
		(commands as any)[name] = cfg.handler;
	},
} as any;

const commands: Record<string, (args: string, ctx: any) => Promise<void>> = {};

function notify(msg: string, type: string) {
	notifications.push({ msg, type });
	console.log(`[${type}] ${msg}`);
}

async function run() {
	agentSpawnExtension(mockPi);

	const ctx = { ui: { notify }, cwd: process.cwd() };

	// ---- Slice 1: agent-list with no agents ----
	console.log("\n--- Slice 1: agent-list (no agents) ---");
	notifications.length = 0;
	await commands["agent-list"]!("", ctx);

	// ---- Slice 2: agent-close with no args ----
	console.log("\n--- Slice 2: agent-close (no args) ---");
	notifications.length = 0;
	await commands["agent-close"]!("", ctx);

	// ---- Slice 3: agent-close invalid index ----
	console.log("\n--- Slice 3: agent-close (invalid index) ---");
	notifications.length = 0;
	await commands["agent-close"]("5", ctx);

	// ---- Slice 4: agent-close non-existent window ----
	console.log("\n--- Slice 4: agent-close (non-existent) ---");
	notifications.length = 0;
	await commands["agent-close"]("9999", ctx);

	// ---- Slice 5: spawn three agents ----
	console.log("\n--- Slice 5: agent-spawn x3 ---");
	notifications.length = 0;
	await commands["agent-spawn"]("", ctx);
	await commands["agent-spawn"]("", ctx);
	await commands["agent-spawn"]("", ctx);

	// ---- Slice 6: agent-list with agents ----
	console.log("\n--- Slice 6: agent-list (with agents) ---");
	notifications.length = 0;
	await commands["agent-list"]("", ctx);

	// ---- Slice 7: agent-close single (first agent index) ----
	console.log("\n--- Slice 7: agent-close single ---");
	notifications.length = 0;
	const lastList = notifications.find(n => n.msg.startsWith("Agent windows:"));
	const firstIndex = lastList ? lastList.msg.match(/\d+/)?.[0] : null;
	if (firstIndex) {
		await commands["agent-close"](firstIndex, ctx);
	}

	// ---- Slice 8: agent-close all ----
	console.log("\n--- Slice 8: agent-close all ---");
	notifications.length = 0;
	await commands["agent-close"]("all", ctx);

	// ---- Slice 9: agent-close all when none remain ----
	console.log("\n--- Slice 9: agent-close all (empty) ---");
	notifications.length = 0;
	await commands["agent-close"]("all", ctx);

	// ---- Slice 10: agent-spawn --here ----
	console.log("\n--- Slice 10: agent-spawn --here /tmp ---");
	notifications.length = 0;
	await commands["agent-spawn"]("--here /tmp", ctx);

	// ---- Cleanup any remaining agents ----
	console.log("\n--- Cleanup remaining agents ---");
	await commands["agent-close"]("all", ctx);

	console.log("\n=== All smoke tests completed ===");
}

run().catch((err) => {
	console.error(err);
	process.exit(1);
});
