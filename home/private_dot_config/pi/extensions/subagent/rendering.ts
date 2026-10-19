import * as os from "node:os";
import type { Message } from "@earendil-works/pi-ai";
import type { Theme, ToolDefinition } from "@earendil-works/pi-coding-agent";
import { formatReadLineRange, getMarkdownTheme, keyText } from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Spacer, Text, truncateToWidth } from "@earendil-works/pi-tui";
import { getFinalOutput, isFailed } from "./results.ts";
import type { SubagentParams } from "./schema.ts";
import type { SingleResult, SubagentDetails } from "./types.ts";
import { aggregateUsage } from "./usage.ts";

/** Assistant text or tool calls retained for compact previews and expanded activity. */
type DisplayItem = { type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, unknown> };

/** Tool renderers for call previews and compact or expanded child results. */
export const renderers = {
  /**
   * Render mode, scope, and up to three requested agent names without repeating full task text.
   * @param args Subagent tool parameters.
   * @param theme Current theme.
   * @param _context Tool-call rendering context, unused by this renderer.
   * @returns A compact call-preview component.
   */
  renderCall(args, theme, _context) {
    const scope = args.agentScope ?? "user";
    const tasks = args.chain?.length ? args.chain : args.tasks;
    const mode = args.chain?.length ? "chain" : "parallel";
    const label = tasks?.length
      ? `${mode} · ${tasks.length} ${mode === "chain" ? "steps" : "tasks"}`
      : args.agent || "...";
    const header =
      theme.fg("toolTitle", theme.bold("subagent ")) +
      theme.fg("accent", oneLine(label)) +
      theme.fg("muted", ` · ${scope}`);
    const lines = [header];
    if (tasks?.length) {
      for (const [index, task] of tasks.slice(0, 3).entries()) {
        const step = mode === "chain" ? `${index + 1}. ` : "";
        lines.push(`  ${theme.fg("muted", step)}${theme.fg("accent", oneLine(task.agent))}`);
      }
      if (tasks.length > 3) lines.push(theme.fg("muted", `  … +${tasks.length - 3} more`));
    }
    // Full task text lives in the expanded result instead of repeating it here.
    return compactText(lines.join("\n"));
  },

  /**
   * Render result headers, activity or output, errors, per-agent usage, and grouped totals.
   * @param result Tool result containing child details and model-facing content.
   * @param options Render options controlling expanded detail.
   * @param theme Current theme.
   * @param _context Tool-result rendering context, unused by this renderer.
   * @returns A result component, or plain content when no child details are available.
   */
  renderResult(result, { expanded }, theme, _context) {
    const details = result.details;
    if (!details || details.results.length === 0) {
      const text = result.content[0];
      return new Text(text?.type === "text" ? text.text : "(no output)", 0, 0);
    }

    const container = new Container();
    const grouped = details.mode !== "single";
    if (grouped) container.addChild(compactText(groupHeader(details, theme)));

    for (const [index, r] of details.results.entries()) {
      if (grouped && (expanded || index > 0)) container.addChild(new Spacer(1));
      const header = resultHeader(r, theme, details.mode === "chain");
      container.addChild(expanded ? new Text(header, 0, 0) : compactText(header));
      // Error messages wrap in both views: compactness must not hide a failure.
      addErrors(container, r, theme);

      const displayItems = getDisplayItems(r.messages);
      if (expanded) addExpanded(container, r, displayItems, theme);
      else addPreview(container, r, displayItems, theme);
      addUsage(container, r.usage, theme, expanded, r.model);
    }

    if (grouped) {
      container.addChild(new Spacer(1));
      container.addChild(new Text(theme.fg("muted", "Total"), 0, 0));
      addUsage(container, aggregateUsage(details.results), theme, expanded);
    }
    if (!expanded) {
      const expandKey = keyText("app.tools.expand");
      const hint = expandKey ? `${expandKey} to expand` : "Expand tool output for details";
      container.addChild(compactText(theme.fg("muted", `  ${hint}`)));
    }
    return container;
  },
} satisfies Pick<ToolDefinition<typeof SubagentParams, SubagentDetails>, "renderCall" | "renderResult">;

/**
 * Add wrapping stop-reason and error text for completed failed children.
 * @param container Container receiving error components.
 * @param result Child result to inspect.
 * @param theme Current theme.
 */
function addErrors(container: Container, result: SingleResult, theme: Theme): void {
  if (result.exitCode === -1 || !isFailed(result)) return;
  if (result.stopReason) container.addChild(new Text(theme.fg("error", `[${result.stopReason}]`), 0, 0));
  if (result.errorMessage) container.addChild(new Text(theme.fg("error", `Error: ${result.errorMessage}`), 0, 0));
}

/**
 * Add the full task, tool-call history, and final output or latest commentary.
 * @param container Container receiving output components.
 * @param result Child result to display.
 * @param displayItems Assistant text and tool-call items in message order.
 * @param theme Current theme.
 */
function addExpanded(container: Container, result: SingleResult, displayItems: DisplayItem[], theme: Theme): void {
  container.addChild(new Spacer(1));
  container.addChild(new Text(theme.fg("muted", "─── Task ───"), 0, 0));
  container.addChild(new Text(theme.fg("dim", result.task), 0, 0));
  container.addChild(new Spacer(1));
  container.addChild(new Text(theme.fg("muted", "─── Output ───"), 0, 0));

  for (const item of displayItems) {
    if (item.type === "toolCall") {
      container.addChild(
        new Text(theme.fg("muted", "→ ") + formatToolCall(item.name, item.args, theme.fg.bind(theme)), 0, 0),
      );
    }
  }
  const finalOutput = getFinalOutput(result.messages);
  if (finalOutput) {
    container.addChild(new Spacer(1));
    container.addChild(new Markdown(finalOutput.trim(), 0, 0, getMarkdownTheme()));
  } else {
    // A running or interrupted agent may have commentary but no final answer yet.
    const latestText = displayItems.filter((item) => item.type === "text").at(-1);
    container.addChild(
      new Text(
        latestText?.type === "text"
          ? theme.fg("toolOutput", latestText.text)
          : theme.fg("muted", result.exitCode === -1 ? "(running…)" : "(no output)"),
        0,
        0,
      ),
    );
  }
  container.addChild(new Spacer(1));
}

/**
 * Add a one-line preview of the latest nonblank text or tool call.
 * @param container Container receiving output components.
 * @param result Child result to display.
 * @param displayItems Assistant text and tool-call items in message order.
 * @param theme Current theme.
 */
function addPreview(container: Container, result: SingleResult, displayItems: DisplayItem[], theme: Theme): void {
  const latest = displayItems.findLast((item) => item.type === "toolCall" || item.text.trim().length > 0);
  const preview = !latest
    ? theme.fg("muted", result.exitCode === -1 ? "(running…)" : "(no output)")
    : latest.type === "text"
      ? theme.fg("toolOutput", oneLine(latest.text))
      : theme.fg("muted", "→ ") + formatToolCall(latest.name, latest.args, theme.fg.bind(theme));
  container.addChild(compactText(`  ${oneLine(preview)}`));
}

/**
 * Add usage text, wrapping in expanded view and truncating each compact row.
 * @param container Container receiving usage components.
 * @param usage Token, cache, cost, and optional turn/context metrics.
 * @param theme Current theme.
 * @param expanded Whether detailed wrapping and cache metrics are enabled.
 * @param model Optional model identifier.
 */
function addUsage(
  container: Container,
  usage: Parameters<typeof formatUsageStats>[0],
  theme: Theme,
  expanded: boolean,
  model?: string,
): void {
  const stats = formatUsageStats(usage, model, expanded);
  if (!stats) return;
  const text = stats
    .split("\n")
    .map((line) => theme.fg("dim", `  ${line}`))
    .join("\n");
  container.addChild(expanded ? new Text(text, 0, 0) : compactText(text));
}

/**
 * Keep summary rows to one terminal line rather than wrapping into an activity dump.
 * @param text Newline-separated rows to display.
 * @returns A component that truncates each row independently at render time.
 */
function compactText(text: string) {
  return {
    render(width: number): string[] {
      return text.split("\n").map((line) => truncateToWidth(line, Math.max(0, width)));
    },
    invalidate() {},
  };
}

/**
 * Format counts using the renderer's existing integer, k, and M thresholds.
 * @param count Token count to format.
 * @returns Compact token-count text.
 */
function formatTokens(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  return `${(count / 1000000).toFixed(1)}M`;
}

/**
 * Format a short preview using tool-specific path, command, or argument details.
 * @param toolName Child tool name.
 * @param args Tool-call arguments.
 * @param themeFg Bound theme foreground helper.
 * @returns Styled tool-call preview.
 */
function formatToolCall(toolName: string, args: Record<string, unknown>, themeFg: Theme["fg"]): string {
  /**
   * Replace the home-directory prefix with a tilde for display.
   * @param p Path to shorten.
   * @returns The path with its home prefix replaced, or the original path.
   */
  const shortenPath = (p: string) => {
    const home = os.homedir();
    return p.startsWith(home) ? `~${p.slice(home.length)}` : p;
  };

  switch (toolName) {
    case "bash": {
      const command = (args.command as string) || "...";
      const preview = command.length > 60 ? `${command.slice(0, 60)}...` : command;
      return themeFg("muted", "$ ") + themeFg("toolOutput", preview);
    }
    case "read": {
      const rawPath = (args.file_path || args.path || "...") as string;
      const filePath = shortenPath(rawPath);
      const lineRange = formatReadLineRange(args.offset, args.limit);
      let text = themeFg("accent", filePath);
      if (lineRange) {
        text += themeFg("warning", lineRange);
      }
      return themeFg("muted", "read ") + text;
    }
    case "write": {
      const rawPath = (args.file_path || args.path || "...") as string;
      const filePath = shortenPath(rawPath);
      const content = (args.content || "") as string;
      const lines = content.split("\n").length;
      let text = themeFg("muted", "write ") + themeFg("accent", filePath);
      if (lines > 1) text += themeFg("dim", ` (${lines} lines)`);
      return text;
    }
    case "edit": {
      const rawPath = (args.file_path || args.path || "...") as string;
      return themeFg("muted", "edit ") + themeFg("accent", shortenPath(rawPath));
    }
    case "ls": {
      const rawPath = (args.path || ".") as string;
      return themeFg("muted", "ls ") + themeFg("accent", shortenPath(rawPath));
    }
    case "find": {
      const pattern = (args.pattern || "*") as string;
      const rawPath = (args.path || ".") as string;
      return themeFg("muted", "find ") + themeFg("accent", pattern) + themeFg("dim", ` in ${shortenPath(rawPath)}`);
    }
    case "grep": {
      const pattern = (args.pattern || "") as string;
      const rawPath = (args.path || ".") as string;
      return (
        themeFg("muted", "grep ") + themeFg("accent", `/${pattern}/`) + themeFg("dim", ` in ${shortenPath(rawPath)}`)
      );
    }
    default: {
      const argsStr = JSON.stringify(args);
      const preview = argsStr.length > 50 ? `${argsStr.slice(0, 50)}...` : argsStr;
      return themeFg("accent", toolName) + themeFg("dim", ` ${preview}`);
    }
  }
}

/**
 * Format nonzero usage metrics, model/turn metadata, and optional cache details.
 * @param usage Child or aggregate usage counters.
 * @param model Optional model identifier.
 * @param expanded Whether cache metrics should be included.
 * @returns Newline-separated metric groups, or an empty string when no metrics are present.
 */
function formatUsageStats(
  usage: {
    input: number;
    output: number;
    cacheRead: number;
    cacheWrite: number;
    cost: number;
    contextTokens?: number;
    turns?: number;
  },
  model?: string,
  expanded = false,
): string {
  const metrics: string[] = [];
  if (usage.input) metrics.push(`↑${formatTokens(usage.input)}`);
  if (usage.output) metrics.push(`↓${formatTokens(usage.output)}`);
  if (usage.contextTokens && usage.contextTokens > 0) metrics.push(`󰍛 ${formatTokens(usage.contextTokens)}`);
  if (usage.cost) metrics.push(`$${usage.cost.toFixed(4)}`);

  const metadata: string[] = [];
  if (usage.turns) metadata.push(`${usage.turns} turn${usage.turns > 1 ? "s" : ""}`);
  if (model) metadata.push(oneLine(model));

  const cache: string[] = [];
  if (expanded && usage.cacheRead) cache.push(`R${formatTokens(usage.cacheRead)}`);
  if (expanded && usage.cacheWrite) cache.push(`W${formatTokens(usage.cacheWrite)}`);
  return [metrics.join("  "), metadata.join(" · "), cache.join("  ")].filter(Boolean).join("\n");
}

/**
 * Collect assistant text and tool calls while preserving their message/content order.
 * @param messages Child conversation messages.
 * @returns Displayable assistant items, excluding other roles and content types.
 */
function getDisplayItems(messages: Message[]): DisplayItem[] {
  const items: DisplayItem[] = [];
  for (const msg of messages) {
    if (msg.role === "assistant") {
      for (const part of msg.content) {
        if (part.type === "text") items.push({ type: "text", text: part.text });
        else if (part.type === "toolCall") items.push({ type: "toolCall", name: part.name, args: part.arguments });
      }
    }
  }
  return items;
}

/**
 * Summarize running, successful, and failed tasks or chain steps.
 * @param details Dispatch mode and current child results.
 * @param theme Current theme.
 * @returns Styled group header with mode and progress.
 */
function groupHeader(details: SubagentDetails, theme: Theme): string {
  const running = details.results.filter((r) => r.exitCode === -1).length;
  const failed = details.results.filter((r) => r.exitCode !== -1 && isFailed(r)).length;
  const success = details.results.length - running - failed;
  const icon = running
    ? theme.fg("warning", "⏳")
    : failed
      ? details.mode === "parallel" && success > 0
        ? theme.fg("warning", "◐")
        : theme.fg("error", "✗")
      : theme.fg("success", "✓");
  const count = details.mode === "chain" ? "steps" : "tasks";
  const status = running
    ? `${success + failed}/${details.results.length} done · ${running} running`
    : `${success}/${details.results.length} ${count}`;
  return `${icon} ${theme.fg("toolTitle", theme.bold(details.mode))} ${theme.fg("accent", status)}`;
}

/**
 * Collapse whitespace for compact summaries and metadata.
 * @param text Text to normalize.
 * @returns Trimmed text with whitespace runs replaced by single spaces.
 */
function oneLine(text: string): string {
  return text.replace(/\s+/g, " ").trim();
}

/**
 * Format a child's status icon, optional chain step, agent name, and source.
 * @param result Child result to label.
 * @param theme Current theme.
 * @param chain Whether to include the chain step number.
 * @returns Styled child header.
 */
function resultHeader(result: SingleResult, theme: Theme, chain: boolean): string {
  const step = chain ? theme.fg("muted", `step ${result.step} · `) : "";
  return (
    `${resultIcon(result, theme)} ` +
    step +
    theme.fg("toolTitle", theme.bold(oneLine(result.agent))) +
    theme.fg("muted", ` · ${result.agentSource}`)
  );
}

/**
 * Choose an icon for a running, failed, or successful child.
 * @param result Child result to inspect.
 * @param theme Current theme.
 * @returns Styled status icon.
 */
function resultIcon(result: SingleResult, theme: Theme): string {
  if (result.exitCode === -1) return theme.fg("warning", "⏳");
  return isFailed(result) ? theme.fg("error", "✗") : theme.fg("success", "✓");
}
