import { basename } from "node:path";
import type { Usage } from "@earendil-works/pi-ai";
import type { ContextUsage, CustomEditor, ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { keyText } from "@earendil-works/pi-coding-agent";
import { mixColors, stripTerminalSequences, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type EditorWorkingStatus = Parameters<CustomEditor["setWorkingStatusIndicator"]>[0];

interface SessionUsage {
  input: number;
  output: number;
  cost: number;
}

interface Statusline {
  workingStatus: EditorWorkingStatus;
  directory: string;
  branch: string | null;
  context: ContextUsage | undefined;
  usage: SessionUsage;
  statuses: string[];
}

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

function formatTokens(tokens: number): string {
  if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(1).replace(/\.0$/, "")}M`;
  if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(1).replace(/\.0$/, "")}k`;
  return Math.round(tokens).toString();
}

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

function render(theme: Theme, width: number, data: Statusline): string {
  const context = data.context;
  const percent = context?.percent ?? null;
  const used = context?.tokens == null ? "?" : formatTokens(context.tokens);
  const capacity = context?.contextWindow ? formatTokens(context.contextWindow) : "?";
  const display: DisplayState = {
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

export default function statuslineExtension(pi: ExtensionAPI): void {
  let unsubscribe: (() => void) | undefined;
  let requestRender: (() => void) | undefined;
  let workingStatus: EditorWorkingStatus;
  const unsubscribeStatus = pi.events.on("editor:working-status", (indicator) => {
    workingStatus = indicator as EditorWorkingStatus;
    requestRender?.();
  });

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const rerender = () => tui.requestRender();
      const disposeBranch = footerData.onBranchChange(rerender);
      const dispose = () => {
        disposeBranch();
        if (requestRender === rerender) requestRender = undefined;
      };
      requestRender = rerender;
      unsubscribe = dispose;
      let cachedSessionId: string | undefined;
      let cachedLeafId: string | null | undefined;
      let totals: SessionUsage = { input: 0, output: 0, cost: 0 };

      function getSessionUsage(): SessionUsage {
        const sessionId = ctx.sessionManager.getSessionId();
        const leafId = ctx.sessionManager.getLeafId();
        if (sessionId !== cachedSessionId || leafId !== cachedLeafId) {
          totals = { input: 0, output: 0, cost: 0 };
          for (const entry of ctx.sessionManager.getEntries()) {
            let usage: Usage | undefined;
            if (entry.type === "message") {
              if (entry.message.role === "assistant" || entry.message.role === "toolResult") {
                usage = entry.message.usage;
              }
            } else if (entry.type === "usage" || entry.type === "compaction" || entry.type === "branch_summary") {
              usage = entry.usage;
            }
            if (usage) {
              totals.input += usage.input;
              totals.output += usage.output;
              totals.cost += usage.cost.total;
            }
          }
          cachedSessionId = sessionId;
          cachedLeafId = leafId;
        }
        return totals;
      }

      return {
        dispose,
        invalidate() {},
        render(width: number): string[] {
          const statuses = footerData.getExtensionStatuses();
          return [
            render(theme, width, {
              workingStatus,
              directory: (basename(ctx.cwd) || ctx.cwd).replace(/[\r\n\t]/g, " "),
              branch: footerData.getGitBranch(),
              context: ctx.getContextUsage(),
              usage: getSessionUsage(),
              statuses: [...statuses.values()],
            }),
            "",
          ];
        },
      };
    });
  });

  pi.on("session_shutdown", () => {
    unsubscribeStatus();
    unsubscribe?.();
    unsubscribe = undefined;
    workingStatus = undefined;
    requestRender = undefined;
  });
}
