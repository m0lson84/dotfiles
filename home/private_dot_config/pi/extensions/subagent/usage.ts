import type { Message, Usage } from "@earendil-works/pi-ai";
import type { SingleResult, UsageStats } from "./types.ts";

/**
 * Sum display usage across child results without adding their per-child context sizes.
 * @param results Child results whose recorded counters should be combined.
 * @returns Input/output/cache tokens, cost, and turns for grouped rendering.
 */
export function aggregateUsage(results: readonly SingleResult[]): Omit<UsageStats, "contextTokens"> {
  const total = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 };
  for (const r of results) {
    total.input += r.usage.input;
    total.output += r.usage.output;
    total.cacheRead += r.usage.cacheRead;
    total.cacheWrite += r.usage.cacheWrite;
    total.cost += r.usage.cost;
    total.turns += r.usage.turns;
  }
  return total;
}

/**
 * Sum finalized assistant and tool-result usage for reporting nested work to the parent session.
 * @param results Child message collections, including any tool-reported nested usage.
 * @returns Full usage totals including optional cache/reasoning counters, or undefined when no usage exists.
 */
export function getUsage(results: readonly { messages: readonly Message[] }[]): Usage | undefined {
  let total: Usage | undefined;

  for (const result of results) {
    for (const message of result.messages) {
      if (message.role !== "assistant" && message.role !== "toolResult") continue;

      const usage = message.usage;
      if (!usage) continue;

      total ??= {
        input: 0,
        output: 0,
        cacheRead: 0,
        cacheWrite: 0,
        totalTokens: 0,
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
      };

      total.input += usage.input;
      total.output += usage.output;
      total.cacheRead += usage.cacheRead;
      total.cacheWrite += usage.cacheWrite;
      total.totalTokens += usage.totalTokens;

      if (usage.cacheWrite1h !== undefined) total.cacheWrite1h = (total.cacheWrite1h ?? 0) + usage.cacheWrite1h;
      if (usage.reasoning !== undefined) total.reasoning = (total.reasoning ?? 0) + usage.reasoning;

      total.cost.input += usage.cost.input;
      total.cost.output += usage.cost.output;
      total.cost.cacheRead += usage.cost.cacheRead;
      total.cost.cacheWrite += usage.cost.cacheWrite;
      total.cost.total += usage.cost.total;
    }
  }

  return total;
}
