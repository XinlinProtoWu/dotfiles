/**
 * balances — shows the credit left on your DeepSeek and Kimi (Moonshot) accounts
 * in Pi's footer, visible on the starting screen.
 *
 * Keys are read from Pi's own `auth.json`, so anything you connected with
 * `/login` is picked up automatically. Values are cached in
 * `state/balances.json` and refreshed in the background on startup (and on
 * demand with `/balance` or Ctrl+… via the command palette).
 *
 * Endpoints:
 *   DeepSeek  GET https://api.deepseek.com/user/balance
 *   Kimi      GET https://api.moonshot.ai/v1/users/me/balance
 */

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const AGENT_DIR = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
const AUTH_FILE = join(AGENT_DIR, "auth.json");
const CACHE_FILE = join(AGENT_DIR, "state", "balances.json");

/** Status entries older than this are refreshed in the background on startup. */
const STALE_MS = 5 * 60 * 1000;
const TIMEOUT_MS = 10_000;
const STATUS_KEY = "balances";

interface Money {
	currency: string; // ISO code, e.g. "USD"
	amount: number;
}

interface ProviderResult {
	label: string;
	balances: Money[];
	extra?: string;
	fetchedAt: number;
	error?: string;
}

interface Cache {
	fetchedAt: number;
	providers: ProviderResult[];
}

const SYMBOLS: Record<string, string> = { USD: "$", CNY: "¥", EUR: "€", JPY: "¥" };

function money(m: Money): string {
	const sym = SYMBOLS[m.currency] ?? `${m.currency} `;
	return `${sym}${m.amount.toFixed(2)}`;
}

/** Read the provider API keys Pi stored via /login. */
async function readKeys(): Promise<Record<string, string>> {
	try {
		const raw = JSON.parse(await readFile(AUTH_FILE, "utf8")) as Record<
			string,
			{ type?: string; key?: string }
		>;
		const out: Record<string, string> = {};
		for (const [id, cred] of Object.entries(raw)) {
			if (cred && typeof cred.key === "string") out[id] = cred.key;
		}
		return out;
	} catch {
		return {};
	}
}

async function getJson(url: string, key: string): Promise<unknown> {
	const resp = await fetch(url, {
		headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
		signal: AbortSignal.timeout(TIMEOUT_MS),
	});
	if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
	return resp.json();
}

async function fetchDeepSeek(key: string): Promise<Money[]> {
	const json = (await getJson("https://api.deepseek.com/user/balance", key)) as {
		balance_infos?: { currency: string; total_balance: string }[];
	};
	return (json.balance_infos ?? []).map((b) => ({
		currency: b.currency,
		amount: Number(b.total_balance),
	}));
}

async function fetchKimi(key: string): Promise<Money[]> {
	const json = (await getJson("https://api.moonshot.ai/v1/users/me/balance", key)) as {
		data?: { available_balance?: number; currency?: string };
	};
	return [{ currency: json.data?.currency ?? "USD", amount: Number(json.data?.available_balance ?? 0) }];
}

const PROVIDERS: {
	id: string;
	label: string;
	fetch: (key: string) => Promise<Money[]>;
}[] = [
	{ id: "deepseek", label: "DeepSeek", fetch: fetchDeepSeek },
	{ id: "moonshotai", label: "Kimi", fetch: fetchKimi },
];

async function loadCache(): Promise<Cache | undefined> {
	try {
		return JSON.parse(await readFile(CACHE_FILE, "utf8")) as Cache;
	} catch {
		return undefined;
	}
}

async function saveCache(cache: Cache): Promise<void> {
	try {
		await mkdir(dirname(CACHE_FILE), { recursive: true });
		await writeFile(CACHE_FILE, JSON.stringify(cache, null, 1) + "\n", "utf8");
	} catch {
		/* cache is best effort */
	}
}

/** Fetch every provider that has a stored key, in parallel. */
async function fetchAll(): Promise<ProviderResult[]> {
	const keys = await readKeys();
	const now = Date.now();
	return Promise.all(
		PROVIDERS.map(async (p) => {
			const key = keys[p.id];
			if (!key) return { label: p.label, balances: [], fetchedAt: now, error: "no API key" };
			try {
				const balances = (await p.fetch(key)).filter((b) => Number.isFinite(b.amount));
				return { label: p.label, balances, fetchedAt: now };
			} catch (err) {
				return {
					label: p.label,
					balances: [],
					fetchedAt: now,
					error: err instanceof Error ? err.message : String(err),
				};
			}
		}),
	);
}

function renderDetail(ctx: ExtensionContext, providers: ProviderResult[]): string {
	const age = providers[0]?.fetchedAt
		? `updated ${Math.round((Date.now() - providers[0].fetchedAt) / 1000)}s ago`
		: "";
	const lines = providers.map((p) => {
		if (p.error) return `${p.label}: ${p.error}`;
		if (!p.balances.length) return `${p.label}: no balance reported`;
		return `${p.label}: ${p.balances.map((b) => `${money(b)} ${b.currency}`).join(", ")}`;
	});
	return [...lines, age].filter(Boolean).join("\n");
}

export default function (pi: ExtensionAPI) {
	let latest: ProviderResult[] = [];

	const publish = (ctx: ExtensionContext, providers: ProviderResult[]) => {
		latest = providers;
		if (ctx.mode !== "tui") return;
		const theme = ctx.ui.theme;
		const text = providers.map((p) => {
			if (p.error) return theme.fg("dim", `${p.label} ?`);
			const value = p.balances.map(money).join(" / ") || "—";
			return `${theme.fg("dim", `${p.label} `)}${theme.fg("accent", value)}`;
		});
		if (text.length) ctx.ui.setStatus(STATUS_KEY, text.join(theme.fg("dim", "  ·  ")));
	};

	const refresh = async (ctx: ExtensionContext) => {
		const providers = await fetchAll();
		await saveCache({ fetchedAt: Date.now(), providers });
		publish(ctx, providers);
		return providers;
	};

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		// Show cached values instantly (no network wait on the starting screen).
		const cached = await loadCache();
		if (cached?.providers?.length) {
			publish(ctx, cached.providers);
			if (Date.now() - cached.fetchedAt < STALE_MS) return;
		}

		// Refresh in the background; ignore failures so startup stays quiet.
		void refresh(ctx).catch(() => undefined);
	});

	pi.registerCommand("balance", {
		description: "Refresh and show remaining DeepSeek / Kimi credit",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle?.().catch(() => undefined);
			try {
				if (ctx.isIdle && !ctx.isIdle()) await ctx.waitForIdle();
				const providers = await refresh(ctx);
				ctx.ui.notify(renderDetail(ctx, providers), "info");
			} catch (err) {
				ctx.ui.notify(`Balance refresh failed: ${err instanceof Error ? err.message : err}`, "error");
			}
		},
	});

	// Keep the footer accurate after a long session without a restart.
	pi.on("turn_end", async (_event, ctx) => {
		if (!latest.length) return;
		if (Date.now() - latest[0].fetchedAt <= STALE_MS) return;
		const providers = await fetchAll();
		latest = providers;
		await saveCache({ fetchedAt: Date.now(), providers });
		publish(ctx, providers);
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		if (ctx.mode === "tui") ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}
