import type { Usage } from "@earendil-works/pi-ai";
import type { SessionEntry } from "@earendil-works/pi-coding-agent";

/** Cumulative input/output token counts and total cost across the supplied session entries. */
export interface SessionUsage {
  input: number;
  output: number;
  cost: number;
}

/**
 * Total usage from assistant/tool results and explicit usage, compaction, and branch-summary entries.
 * @param entries All session entries to include, not only those on the active branch.
 * @returns Fresh totals for input tokens, output tokens, and cost; zeroes when no usage is recorded.
 */
export function calculateUsage(entries: SessionEntry[]): SessionUsage {
  const totals: SessionUsage = { input: 0, output: 0, cost: 0 };
  for (const entry of entries) {
    const usage = getUsage(entry);
    if (usage) {
      totals.input += usage.input;
      totals.output += usage.output;
      totals.cost += usage.cost.total;
    }
  }
  return totals;
}

/**
 * Extract usage from an entry type that contributes to session totals.
 * @param entry Session entry to inspect.
 * @returns Recorded usage, or undefined for unsupported entries or entries without usage.
 */
function getUsage(entry: SessionEntry): Usage | undefined {
  if (entry.type === "message") {
    if (entry.message.role === "assistant" || entry.message.role === "toolResult") {
      return entry.message.usage;
    }
  } else if (entry.type === "usage" || entry.type === "compaction" || entry.type === "branch_summary") {
    return entry.usage;
  }
  return undefined;
}
