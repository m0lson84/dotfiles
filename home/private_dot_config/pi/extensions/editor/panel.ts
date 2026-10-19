import type { ExtensionContext, KeybindingsManager } from "@earendil-works/pi-coding-agent";
import { CustomEditor } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI, TuiMouseEvent, TuiMouseEventResult } from "@earendil-works/pi-tui";
import { parseColor, truncateToWidth } from "@earendil-works/pi-tui";
import type { EditorWorkingStatus } from "./status.ts";

const EDITOR_BACKGROUND = parseColor("#222436");

/** An editor panel with mode/model metadata and native input and autocomplete behavior. */
export class PanelEditor extends CustomEditor {
  private metadataLine = "";
  private metadataRow = -1;
  private nativeRenderHeight = 0;
  private planModeEnabled: boolean;

  private readonly ctx: ExtensionContext;
  private readonly onStatusChange: (indicator: EditorWorkingStatus) => void;

  /**
   * Create a panel around Pi's native editor with embedded working status.
   * @param tui Terminal UI used to request redraws.
   * @param theme Native editor theme.
   * @param keybindings Application keybindings preserved by the native editor.
   * @param ctx Session context providing the current theme, model, and thinking level.
   * @param planModeEnabled Initial mode displayed in the metadata row.
   * @param onStatusChange Callback notified when the working indicator changes or clears.
   */
  constructor(
    tui: TUI,
    theme: EditorTheme,
    keybindings: KeybindingsManager,
    ctx: ExtensionContext,
    planModeEnabled: boolean,
    onStatusChange: (indicator: EditorWorkingStatus) => void,
  ) {
    super(tui, theme, keybindings, { paddingX: 3, embedWorkingStatus: true });
    this.ctx = ctx;
    this.onStatusChange = onStatusChange;
    this.planModeEnabled = planModeEnabled;
  }

  /**
   * Translate panel mouse coordinates into native editor coordinates.
   * @param event Mouse event relative to the rendered panel.
   * @returns The native mouse result, a focus-only result for left clicks on decoration, or undefined.
   */
  override handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
    if (this.metadataRow < 0) return super.handleMouse(event);
    const { leftPadding, panelWidth } = this.getLayout(event.width);
    if (event.x < leftPadding || event.x >= leftPadding + panelWidth) {
      return event.type === "click" && event.button === "left" ? { handled: true, focus: true } : undefined;
    }

    const nativeY = this.getMouseRow(event.y);
    if (nativeY === undefined) {
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

  /**
   * Render native editor content inside the panel and record the mouse-mapping boundaries.
   * @param width Available terminal columns, including outer gutters.
   * @returns Rendered panel lines, or an empty array when no columns are available.
   */
  override render(width: number): string[] {
    if (width <= 0) {
      this.metadataRow = -1;
      return [];
    }

    const { leftPadding, panelWidth } = this.getLayout(width);
    const leftGutter = " ".repeat(leftPadding);
    const rightGutter = " ".repeat(width - leftPadding - panelWidth);
    this.borderColor = (text) => this.ctx.ui.theme.fg("borderMuted", text);
    const lines = super.render(panelWidth);
    const nativeMetadataRow = lines.indexOf(this.metadataLine, 1);
    this.nativeRenderHeight = lines.length;
    this.metadataRow = nativeMetadataRow < 0 ? -1 : nativeMetadataRow + 1;
    if (nativeMetadataRow < 0) return lines;

    return this.renderPanel(lines, nativeMetadataRow, panelWidth).map((line) => leftGutter + line + rightGutter);
  }

  /**
   * Apply configured horizontal padding while reserving space for the panel rail.
   * @param padding Requested editor padding in terminal columns.
   * @returns Nothing; updates native padding with a minimum of two columns.
   */
  override setPaddingX(padding: number): void {
    super.setPaddingX(Math.max(2, padding + 2));
  }

  /**
   * Update the displayed mode, requesting a redraw only when it changes.
   * @param enabled Whether plan mode is active.
   * @returns Nothing; updates panel state and schedules a redraw if needed.
   */
  setPlanMode(enabled: boolean): void {
    if (this.planModeEnabled === enabled) return;
    this.planModeEnabled = enabled;
    this.tui.requestRender();
  }

  /**
   * Update the native working indicator and publish it through the supplied callback.
   * @param indicator Working indicator, or undefined to clear it.
   * @returns Nothing; updates native status and notifies the callback.
   */
  override setWorkingStatusIndicator(indicator: EditorWorkingStatus): void {
    super.setWorkingStatusIndicator(indicator);
    this.onStatusChange(indicator);
  }

  /**
   * Replace the native bottom border with metadata, marking the input/menu boundary.
   * @param width Available columns inside the panel.
   * @returns The metadata line, also retained so render can locate it in native output.
   */
  protected override renderBottomBorder(width: number): string {
    this.metadataLine = this.renderMetadata(width);
    return this.metadataLine;
  }

  /**
   * Select the panel accent, giving Bash input precedence over plan/build mode.
   * @returns The semantic theme color for the rail and mode label.
   */
  private getAccent(): "accent" | "warning" | "bashMode" {
    if (this.getText().startsWith("!")) return "bashMode";
    return this.planModeEnabled ? "accent" : "warning";
  }

  /**
   * Reserve outer gutters while preserving at least one panel cell at tiny widths.
   * @param width Available terminal columns.
   * @returns The left gutter width and inner panel width used for rendering and mouse mapping.
   */
  private getLayout(width: number): { leftPadding: number; panelWidth: number } {
    const leftPadding = width > 2 ? 1 : 0;
    const panelWidth = Math.max(1, width - leftPadding - 1);
    return { leftPadding, panelWidth };
  }

  /**
   * Map input and autocomplete rows back to the native editor, excluding panel decoration.
   * @param row Mouse row relative to the rendered panel.
   * @returns The native editor row, or undefined for padding, metadata, or out-of-range rows.
   */
  private getMouseRow(row: number): number | undefined {
    const firstInputRow = 1;
    const lastInputRow = this.metadataRow - 2;
    const firstMenuRow = this.metadataRow + 2;
    if (row >= firstInputRow && row <= lastInputRow) return row;
    if (row >= firstMenuRow && row < this.nativeRenderHeight + 2) {
      // Padding, metadata, and the half-block row add two rows before native autocomplete.
      return row - 2;
    }
    return undefined;
  }

  /**
   * Format the mode, model, and thinking level using the current session theme.
   * @param width Available columns inside the panel.
   * @returns A styled metadata line truncated to fit without an ellipsis.
   */
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

  /**
   * Add the rail, filled background, spacing, and half-block cap around native editor lines.
   * @param lines Native editor output; input gutter cells are replaced in place by the rail.
   * @param metadataRow Index of the metadata line in native output.
   * @param width Inner panel width, excluding outer gutters.
   * @returns Styled panel lines followed by untouched native autocomplete lines, without outer gutters.
   */
  private renderPanel(lines: string[], metadataRow: number, width: number): string[] {
    const rail = this.ctx.ui.theme.fg(this.getAccent(), "▌");
    const spacer = rail + " ".repeat(width - 1);
    // The quadrant cap matches the half-cell rail width; the lower half keeps the terminal background.
    const halfSpacer =
      this.ctx.ui.theme.fg(this.getAccent(), "▘") +
      this.ctx.ui.theme.style("▀".repeat(width - 1), { fg: EDITOR_BACKGROUND });
    const fill = (line: string) =>
      this.ctx.ui.theme.style(truncateToWidth(line, width, "", true), { bg: EDITOR_BACKGROUND });
    for (let index = 1; index < metadataRow; index++) {
      // Replace an existing gutter cell: wrapping and cursor columns stay native.
      if (width > 2 && lines[index].startsWith(" ")) lines[index] = rail + lines[index].slice(1);
    }
    return [
      fill(spacer),
      ...lines.slice(1, metadataRow).map(fill),
      fill(spacer),
      fill(this.metadataLine),
      halfSpacer,
      ...lines.slice(metadataRow + 1),
    ];
  }
}
