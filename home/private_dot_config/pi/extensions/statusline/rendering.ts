import type { ContextUsage, CustomEditor, Theme } from "@earendil-works/pi-coding-agent";
import { keyText } from "@earendil-works/pi-coding-agent";
import { mixColors, stripTerminalSequences, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { SessionUsage } from "./usage.ts";

/** Native working indicator received through editor:working-status, or undefined when inactive. */
export type EditorWorkingStatus = Parameters<CustomEditor["setWorkingStatusIndicator"]>[0];

/** Raw session, working-status, and extension-status data collected for one footer render. */
export interface Statusline {
  workingStatus: EditorWorkingStatus;
  directory: string;
  branch: string | null;
  context: ContextUsage | undefined;
  usage: SessionUsage;
  statuses: string[];
}

/** Formatted display values, progressively simplified to fit the available footer width. */
interface DisplayState {
  workingStatus: EditorWorkingStatus;
  directory: string;
  branch: string;
  input: string;
  output: string;
  context: string;
  contextAlert: "warning" | "error" | undefined;
  cost: string;
  statuses: string;
  showCost: boolean;
}

/**
 * Render the footer, progressively dropping optional details to preserve metrics at narrow widths.
 * @param theme Current theme used to style text and mix working-indicator colors.
 * @param width Available terminal columns.
 * @param data Raw footer data for this render.
 * @returns One styled line truncated to fit the available width.
 */
export function render(theme: Theme, width: number, data: Statusline): string {
  const display = getDisplay(data);
  const compact: ((state: DisplayState) => void)[] = [
    (state) => (state.statuses = ""),
    (state) => {
      state.directory = truncateToWidth(state.directory, 12);
      state.branch = truncateToWidth(state.branch, 12);
    },
    (state) => (state.showCost = false),
    (state) => (state.branch = ""),
    (state) => (state.directory = ""),
  ];
  let parts = compose(theme, display, width);
  for (const simplify of compact) {
    if (visibleWidth(parts.left) + visibleWidth(parts.right) + 1 <= width) break;
    simplify(display);
    parts = compose(theme, display, width);
  }

  if (display.workingStatus) {
    parts.left = truncateToWidth(parts.left, Math.max(0, width - visibleWidth(parts.right) - 1), "");
  }
  const gap = Math.max(0, width - visibleWidth(parts.left) - visibleWidth(parts.right));
  const line = parts.left + " ".repeat(gap) + parts.right;
  return truncateToWidth(line, Math.max(0, width), "");
}

/**
 * Compose left-side session details or working status and right-side usage metrics.
 * @param theme Current theme used to style each module.
 * @param display Formatted display state after any width-driven simplifications.
 * @param width Available footer columns passed to the working-status renderer.
 * @returns Styled left and right segments before final padding and truncation.
 */
function compose(theme: Theme, display: Readonly<DisplayState>, width: number): { left: string; right: string } {
  const { directory, branch, statuses, showCost, workingStatus } = display;
  let left = workingStatus ? renderWorkingStatus(theme, workingStatus, width) : "";
  if (!workingStatus) {
    const modules = [
      directory ? theme.style(directory, { fg: "syntaxOperator", bold: true }) : "",
      branch ? theme.style(` ${branch}`, { fg: "accent", bold: true }) : "",
      statuses ? theme.fg("muted", statuses) : "",
    ].filter(Boolean);
    if (modules.length) left = ` ${modules.join(" ")} `;
  }

  const metrics = [
    `${theme.fg("muted", "󰍛")} ${theme.fg(display.contextAlert ?? "syntaxFunction", display.context)}`,
    `${theme.fg("success", display.input)} ${theme.fg("warning", display.output)}`,
  ];
  if (showCost) metrics.push(theme.fg("syntaxType", display.cost));
  return { left, right: ` ${metrics.join("  ")} ` };
}

/**
 * Format token counts using rounded integers or compact k/M suffixes.
 * @param tokens Token count to display.
 * @returns A compact count with at most one decimal place and no trailing .0.
 */
function formatTokens(tokens: number): string {
  if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(1).replace(/\.0$/, "")}M`;
  if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(1).replace(/\.0$/, "")}k`;
  return Math.round(tokens).toString();
}

/**
 * Format raw footer data, including context alerts and sanitized extension-status text.
 * @param data Raw session and status data collected by the footer.
 * @returns A fresh display state with all optional details initially visible.
 */
function getDisplay(data: Statusline): DisplayState {
  const context = data.context;
  const percent = context?.percent ?? null;
  const used = context?.tokens == null ? "?" : formatTokens(context.tokens);
  const capacity = context?.contextWindow ? formatTokens(context.contextWindow) : "?";
  return {
    workingStatus: data.workingStatus,
    directory: truncateToWidth(data.directory, 24),
    branch: data.branch ? truncateToWidth(data.branch, 24) : "",
    input: `↑${formatTokens(data.usage.input)}`,
    output: `↓${formatTokens(data.usage.output)}`,
    context: `${used}/${capacity} · ${percent === null ? "?" : Math.round(percent)}%`,
    contextAlert: percent === null ? undefined : percent >= 90 ? "error" : percent >= 75 ? "warning" : undefined,
    cost: `$${data.usage.cost.toFixed(2)}`,
    statuses: data.statuses.map((status) => stripTerminalSequences(status).replace(/[\r\n\t]/g, " ")).join(" · "),
    showCost: true,
  };
}

/**
 * Render the animated working hint or the native retry/compaction/summary indicator.
 * @param theme Current theme used for the throbber, spinner, hint, and status text.
 * @param indicator Active native working indicator.
 * @param width Available terminal columns.
 * @returns A styled working-status line truncated to the available width.
 */
function renderWorkingStatus(theme: Theme, indicator: NonNullable<EditorWorkingStatus>, width: number): string {
  if (indicator.kind !== "working") {
    const available = Math.max(0, width - 1);
    const line = stripTerminalSequences(indicator.renderInBorder(available));
    const spinner = stripTerminalSequences(indicator.renderSpinnerInBorder(available));
    if (spinner && line.startsWith(spinner)) {
      const color = indicator.kind === "retry" ? "warning" : "accent";
      const message = line.slice(spinner.length).trimStart();
      return truncateToWidth(` ${theme.fg(color, spinner)} ${theme.fg("text", message)}`, width, "");
    }
    return truncateToWidth(` ${theme.fg("text", line)}`, width, "");
  }

  const frame = Math.floor(Date.now() / 80) % 14;
  const head = frame <= 7 ? frame : 14 - frame;
  const throbber = Array.from({ length: 8 }, (_, index) => {
    const brightness = Math.max(0, 1 - Math.abs(index - head) / 4);
    const color = mixColors(theme.colors.borderMuted, theme.colors.accent, brightness);
    return theme.style("▪", { fg: color });
  }).join("");
  const interruptKey = keyText("app.interrupt").replace(/\bescape\b/g, "esc");
  const hint = theme.fg("muted", `${interruptKey} interrupt`);
  return truncateToWidth(` ${throbber}  ${hint}`, width, "");
}
