import type { ExtensionAPI, ExtensionContext, KeybindingsManager } from "@earendil-works/pi-coding-agent";
import { CustomEditor } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI, TuiMouseEvent, TuiMouseEventResult } from "@earendil-works/pi-tui";
import { parseColor, truncateToWidth } from "@earendil-works/pi-tui";
import type { EditorWorkingStatus } from "./status.ts";

const EDITOR_BACKGROUND = parseColor("#222436");

class PanelEditor extends CustomEditor {
  private metadataLine = "";
  private metadataRow = -1;
  private nativeRenderHeight = 0;

  constructor(
    tui: TUI,
    theme: EditorTheme,
    keybindings: KeybindingsManager,
    private readonly ctx: ExtensionContext,
    private planModeEnabled: boolean,
    private readonly onStatusChange: (indicator: EditorWorkingStatus) => void,
  ) {
    super(tui, theme, keybindings, { paddingX: 3, embedWorkingStatus: true });
  }

  override setPaddingX(padding: number): void {
    super.setPaddingX(Math.max(2, padding + 2));
  }

  setPlanMode(enabled: boolean): void {
    if (this.planModeEnabled === enabled) return;
    this.planModeEnabled = enabled;
    this.tui.requestRender();
  }

  private getAccent(): "accent" | "warning" | "bashMode" {
    if (this.getText().startsWith("!")) return "bashMode";
    return this.planModeEnabled ? "accent" : "warning";
  }

  private renderMetadata(width: number): string {
    const theme = this.ctx.ui.theme;
    const accent = this.getAccent();
    const model = this.ctx.model;

    const metadata = [
      theme.fg(accent, this.planModeEnabled ? "PLAN" : "BUILD"),
      theme.fg("muted", model ? `${model.name || model.id} (${model?.provider})` : "no model"),
      theme.fg("muted", this.ctx.thinkingLevel ?? "off"),
    ].join(theme.fg("dim", " · "));

    return truncateToWidth(`${theme.fg(accent, "▌")}  ${metadata}`, width, "");
  }

  override setWorkingStatusIndicator(indicator: EditorWorkingStatus): void {
    super.setWorkingStatusIndicator(indicator);
    this.onStatusChange(indicator);
  }

  protected override renderBottomBorder(width: number): string {
    // Use the protected border hook to locate the input/menu boundary without reading private editor state.
    this.metadataLine = this.renderMetadata(width);
    return this.metadataLine;
  }

  override render(width: number): string[] {
    if (width <= 0) {
      this.metadataRow = -1;
      return [];
    }

    // Keep both outer cells unfilled so backgrounds and the half-block cap align,
    // without extending into terminal padding. Preserve one panel cell at tiny widths.
    const leftPadding = width > 2 ? 1 : 0;
    const leftGutter = " ".repeat(leftPadding);
    const panelWidth = Math.max(1, width - leftPadding - 1);
    const rightGutter = " ".repeat(width - leftPadding - panelWidth);
    this.borderColor = (text) => this.ctx.ui.theme.fg("borderMuted", text);
    const lines = super.render(panelWidth);
    const nativeMetadataRow = lines.indexOf(this.metadataLine, 1);
    this.nativeRenderHeight = lines.length;
    this.metadataRow = nativeMetadataRow < 0 ? -1 : nativeMetadataRow + 1;
    if (nativeMetadataRow < 0) return lines;

    const rail = this.ctx.ui.theme.fg(this.getAccent(), "▌");
    const spacer = rail + " ".repeat(panelWidth - 1);
    // The quadrant cap matches the half-cell rail width; the lower half keeps the terminal background.
    const halfSpacer =
      this.ctx.ui.theme.fg(this.getAccent(), "▘") +
      this.ctx.ui.theme.style("▀".repeat(panelWidth - 1), { fg: EDITOR_BACKGROUND });
    const fill = (line: string) =>
      this.ctx.ui.theme.style(truncateToWidth(line, panelWidth, "", true), { bg: EDITOR_BACKGROUND });
    for (let index = 1; index < nativeMetadataRow; index++) {
      // Replace an existing gutter cell: wrapping and cursor columns stay native.
      if (panelWidth > 2 && lines[index].startsWith(" ")) lines[index] = rail + lines[index].slice(1);
    }
    return [
      fill(spacer),
      ...lines.slice(1, nativeMetadataRow).map(fill),
      fill(spacer),
      fill(this.metadataLine),
      halfSpacer,
      ...lines.slice(nativeMetadataRow + 1),
    ].map((line) => leftGutter + line + rightGutter);
  }

  override handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
    if (this.metadataRow < 0) return super.handleMouse(event);
    const leftPadding = event.width > 2 ? 1 : 0;
    const panelWidth = Math.max(1, event.width - leftPadding - 1);
    if (event.x < leftPadding || event.x >= leftPadding + panelWidth) {
      return event.type === "click" && event.button === "left" ? { handled: true, focus: true } : undefined;
    }
    const firstInputRow = 1;
    const lastInputRow = this.metadataRow - 2;
    const firstMenuRow = this.metadataRow + 2;
    let nativeY: number;
    if (event.y >= firstInputRow && event.y <= lastInputRow) {
      nativeY = event.y;
    } else if (event.y >= firstMenuRow && event.y < this.nativeRenderHeight + 2) {
      // Padding, metadata, and the half-block row add two rows before native autocomplete.
      nativeY = event.y - 2;
    } else {
      // Clicking padding or metadata focuses the editor without moving its cursor.
      return event.type === "click" && event.button === "left" ? { handled: true, focus: true } : undefined;
    }

    return super.handleMouse({
      ...event,
      x: event.x - leftPadding,
      y: nativeY,
      width: panelWidth,
      height: this.nativeRenderHeight,
    });
  }
}

export default function editorExtension(pi: ExtensionAPI): void {
  let editor: PanelEditor | undefined;
  const unsubscribe = pi.events.on("plan-mode:changed", (enabled) => {
    if (typeof enabled === "boolean") editor?.setPlanMode(enabled);
  });

  function readPlanMode(ctx: ExtensionContext): boolean {
    const entry = ctx.sessionManager
      .getBranch()
      .findLast((entry) => entry.type === "custom" && entry.customType === "plan-mode");
    const state = entry?.type === "custom" ? (entry.data as { enabled?: boolean } | undefined) : undefined;
    return state?.enabled ?? pi.getFlag("plan") === true;
  }

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    const planModeEnabled = readPlanMode(ctx);
    pi.events.emit("editor:working-status", undefined);
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      editor = new PanelEditor(tui, theme, keybindings, ctx, planModeEnabled, (indicator) =>
        pi.events.emit("editor:working-status", indicator),
      );
      return editor;
    });
  });

  pi.on("session_tree", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    editor?.setPlanMode(readPlanMode(ctx));
  });

  pi.on("session_shutdown", () => {
    unsubscribe();
    pi.events.emit("editor:working-status", undefined);
    editor = undefined;
  });
}
