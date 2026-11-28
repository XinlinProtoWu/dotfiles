/**
 * auto-router — a virtual model that picks a physical model AND a thinking level per request.
 *
 * Registers `auto/smart`, which routes between the models you have credentials for:
 *
 *   fast    deepseek/deepseek-flash    cheap ($0.30/$1.20), vision, 1M ctx
 *   work    deepseek/deepseek-v4-pro   default ($1.32/$3.96), text only
 *   strong  moonshotai/kimi-k3.1-pro   hard work ($2/$10), vision, 1M ctx
 *
 * Hybrid difficulty:
 * - On the first user message of a fresh session, Pi asks you to rate the difficulty
 *   (Auto / Easy / Medium / Hard). The rating is stored in router state and applies to the
 *   whole session. In print/JSON mode (no UI) it falls back to `auto`.
 * - Task categories refine the automatic score:
 *     notes     (lecture notes, slides, flashcards)  -> easy  (fast / low)
 *     homework  (assignment, problem set, lab)       -> medium (work / high)
 *     other                                          -> scored from length, code fences, verbs
 *
 *   Rating overrides the score: easy -> fast/low, medium -> work/high, hard -> strong/max.
 *
 * - Messages with images never go to `work`, because deepseek-v4-pro is text-only.
 * - Tool follow-ups (`continuation`) stay on the model that answered last, keeping the prompt cache.
 * - Retries stay on the failed model, except on overload / rate limit: then switch provider.
 * - Requests outside the agent loop (compaction summaries, extension calls) go to `fast` at `low`.
 *
 * The footer shows the route, e.g. `auto • high → moonshotai/kimi-k3.1-pro • max`. Ask `/auto`
 * for the table and the last decision.
 */

import type { Message } from "@earendil-works/pi-ai";
import type {
	ExtensionAPI,
	ExtensionContext,
	ModelRoute,
	ModelRouteRequest,
} from "@earendil-works/pi-coding-agent";

type Tier = "fast" | "work" | "strong";
type ThinkingLevel = ModelRoute["thinkingLevel"];
type Rating = "auto" | "easy" | "medium" | "hard";
type Category = "notes" | "homework" | "other";

interface RouterState {
	rating: Rating;
}

const TIERS: Record<Tier, { provider: string; id: string }> = {
	fast: { provider: "deepseek", id: "deepseek-flash" },
	work: { provider: "deepseek", id: "deepseek-v4-pro" },
	strong: { provider: "moonshotai", id: "kimi-k3.1-pro" },
};

/** Order used when the preferred tier's provider has no credentials. */
const FALLBACK_ORDER: Tier[] = ["work", "strong", "fast"];

/** How demanding the work looks. */
const HARD_WORDS =
	/\b(refactor\w*|architect\w*|redesign\w*|debug\w*|diagnos\w*|root cause|race condition|deadlock|concurren\w*|optimi[sz]\w*|migrat\w*|algorithm\w*|complexity|proof|prove|invariant|secur\w*|vulnerab\w*|benchmark\w*|from scratch|review|audit|trade-?offs?)\b/gi;

/** Verbs that mark an actual coding/editing task (vs. a question or chat). */
const TASK_WORDS =
	/\b(write|implement|create|fix|add|build|change|update|modify|refactor|remove|delete|parse|convert|install|upgrade|migrate|extract|generate|rename|configure|setup|set up|debug|optimize|simplify|rewrite|edit|append|insert|port|improve|enhance|translate|compile|run|test|benchmark)\b/gi;

/** Repetitive, low-effort study tasks. */
const NOTES_WORDS =
	/\b(lecture notes|study notes|revision notes|take notes|make notes|notes from|slide deck|slides|flash ?cards?|cheat ?sheets?|study guides?|summar[iy]se (?:the )?(?:slides|deck|lecture|pdf|notes))\b/i;

/** Coursework tasks; the user expects the `work` model for these. */
const HOMEWORK_WORDS =
	/\b(assignments?|homeworks?|hmwk|problem sets?|psets?|lab reports?|worksheets?|exercises? \d|past papers?)\b/i;

/** Failures where the other provider is worth trying. */
const OVERLOAD = /overload|rate.?limit|429|50[0234]|capacity|timed out|timeout|ECONNRESET|socket hang up/i;

/** Fallback thinking level for sticky paths that lack a recorded one. */
const STICKY_DEFAULT: ThinkingLevel = "high";

let lastDecision = "none yet";

function lastUserMessage(messages: readonly Message[]): Message | undefined {
	for (let i = messages.length - 1; i >= 0; i--) {
		if (messages[i].role === "user") return messages[i];
	}
	return undefined;
}

function userText(messages: readonly Message[]): string {
	const content = lastUserMessage(messages)?.content ?? "";
	if (typeof content === "string") return content;
	return content.flatMap((block) => (block.type === "text" ? [block.text] : [])).join("\n");
}

function hasImages(messages: readonly Message[]): boolean {
	const content = lastUserMessage(messages)?.content;
	if (typeof content === "string" || !Array.isArray(content)) return false;
	return content.some((block) => block.type === "image");
}

/** Rough difficulty score for one user message. */
function score(text: string): number {
	let value = 0;
	const length = text.length;
	if (length > 1500) value += 3;
	else if (length > 600) value += 2;
	else if (length > 250) value += 1;

	const fences = Math.floor((text.match(/```/g)?.length ?? 0) / 2);
	if (fences >= 1) value += 1;
	if (fences >= 3) value += 1;

	const words = new Set((text.match(HARD_WORDS) ?? []).map((word) => word.toLowerCase()));
	value += Math.min(words.size, 2);

	const taskWords = new Set((text.match(TASK_WORDS) ?? []).map((word) => word.toLowerCase()));
	if (taskWords.size >= 1) value += 2;

	if (length < 80 && /\b(hi|hey|hello|thanks|thank you|ty)\b/i.test(text)) value -= 2;
	if (length < 160 && text.trim().endsWith("?")) value -= 1;
	return value;
}

/** Categorize the task to bias the automatic score. */
function categorize(text: string): Category {
	if (NOTES_WORDS.test(text)) return "notes";
	if (HOMEWORK_WORDS.test(text)) return "homework";
	return "other";
}

/** Thinking level chosen automatically for a difficulty score. */
function levelForScore(value: number): ThinkingLevel {
	return value >= 4 ? "max" : value >= 2 ? "high" : "low";
}

/** Final effort score from rating + category + automatic heuristics. */
function targetScore(rating: Rating, category: Category, autoScore: number): number {
	switch (rating) {
		case "easy":
			return 0;
		case "medium":
			return 2;
		case "hard":
			return 4;
		case "auto":
			if (category === "notes") return 0;
			if (category === "homework") return 2;
			return autoScore;
	}
}

/** Pick the tier and thinking level for one user message. */
function chooseRoute(request: ModelRouteRequest, rating: Rating): { tier: Tier; level: ThinkingLevel; why: string } {
	const text = userText(request.messages);
	const category = categorize(text);
	const target = targetScore(rating, category, score(text));
	let tier: Tier = target >= 4 ? "strong" : target >= 2 ? "work" : "fast";
	// deepseek-v4-pro is text-only: send image tasks elsewhere, keeping the difficulty's level.
	if (tier === "work" && hasImages(request.messages)) tier = target >= 4 ? "strong" : "fast";
	return { tier, level: levelForScore(target), why: `category=${category} rating=${rating} score=${target}` };
}

/** Ask the user to rate the session's difficulty. Falls back to `auto` without a UI. */
async function askRating(request: ModelRouteRequest, ctx: ExtensionContext): Promise<Rating> {
	if (!ctx.hasUI) return "auto";
	const text = userText(request.messages).slice(0, 80);
	const hint = categorize(userText(request.messages)) === "homework" ? "medium" : "auto";
	const choice = await ctx.ui.select(`Rate difficulty: “${text}”`, [
		`Auto — decide for me (looks like: ${hint})`,
		"Easy — notes, summaries, quick questions",
		"Medium — homework, features, debugging",
		"Hard — architecture, refactors, research",
	], { signal: request.signal });
	if (choice?.startsWith("Easy")) return "easy";
	if (choice?.startsWith("Medium")) return "medium";
	if (choice?.startsWith("Hard")) return "hard";
	return "auto";
}

function resolveTier(
	ctx: ExtensionContext,
	preferred: Tier,
	exclude?: string,
): { tier: Tier; model: NonNullable<ReturnType<ExtensionContext["modelRegistry"]["find"]>> } {
	for (const tier of [preferred, ...FALLBACK_ORDER.filter((other) => other !== preferred)]) {
		const { provider, id } = TIERS[tier];
		if (`${provider}/${id}` === exclude) continue;
		const model = ctx.modelRegistry.find(provider, id);
		if (model) return { tier, model };
	}
	throw new Error("auto-router: none of the routed models has credentials");
}

function makeRoute(
	ctx: ExtensionContext,
	reason: ModelRouteRequest["reason"],
	tier: Tier,
	level: ThinkingLevel,
	why: string,
): ModelRoute {
	const resolved = resolveTier(ctx, tier);
	lastDecision = `${reason}: ${resolved.tier} → ${resolved.model.provider}/${resolved.model.id} • ${level} (${why})`;
	return { model: resolved.model, thinkingLevel: level };
}

export default function (pi: ExtensionAPI) {
	pi.registerVirtualModel<RouterState>({
		provider: "auto",
		id: "smart",
		name: "Auto (smart)",
		// Single placeholder level: the router ignores the selection and picks thinking itself.
		thinkingLevels: ["high"],
		contextWindow: 262_144,
		maxTokens: 32_768,
		async route(request, ctx): Promise<ModelRoute> {
			// Compaction summaries and extension calls: cheapest model is enough.
			if (request.reason === "direct") return makeRoute(ctx, request.reason, "fast", "low", "direct request");

			// Stay on the model that answered last: keeps the prompt cache and thinking signatures.
			if (request.reason === "continuation" && request.previous) {
				const { model, thinkingLevel } = request.previous;
				lastDecision = `continuation: ${model.provider}/${model.id} • ${thinkingLevel ?? STICKY_DEFAULT} (sticky)`;
				return { model, thinkingLevel: thinkingLevel ?? STICKY_DEFAULT };
			}

			if (request.reason === "retry" && request.failed) {
				const { model, thinkingLevel, message } = request.failed;
				const error = message.errorMessage ?? "";
				if (OVERLOAD.test(error)) {
					const other: Tier = model.provider === "deepseek" ? "strong" : "work";
					const resolved = resolveTier(ctx, other, `${model.provider}/${model.id}`);
					lastDecision = `retry: ${resolved.tier} → ${resolved.model.provider}/${resolved.model.id} • high (${error.slice(0, 60)})`;
					return { model: resolved.model, thinkingLevel: "high" };
				}
				lastDecision = `retry: ${model.provider}/${model.id} • ${thinkingLevel ?? STICKY_DEFAULT} (sticky)`;
				return { model, thinkingLevel: thinkingLevel ?? STICKY_DEFAULT };
			}

			// First user message of a fresh session: ask for a difficulty rating once.
			const rating = request.state?.rating ?? (await askRating(request, ctx));
			const { tier, level, why } = chooseRoute(request, rating);
			const route = makeRoute(ctx, request.reason, tier, level, why);
			return { ...route, state: request.state ?? { rating } };
		},
	});

	pi.registerCommand("auto", {
		description: "Show auto/smart routing and the last decision",
		handler: async (_args, ctx) => {
			ctx.ui.notify(
				`auto/smart — fast: deepseek-flash · work: deepseek-v4-pro · strong: kimi-k3.1-pro — rating asked once per session — last: ${lastDecision}`,
				"info",
			);
		},
	});
}
