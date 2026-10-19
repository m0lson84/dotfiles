import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component, TuiMouseEvent } from "@earendil-works/pi-tui";
import { type Box, Container, truncateToWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import type { Preview } from "./preview.ts";

/** Maximum wrapped output rows retained by a compact result. */
const PREVIEW_LINES = 3;
/** Maximum native diff rows retained before the collapsed-view omission notice. */
const DIFF_PREVIEW_LINES = 24;

/**
 * Internal width-keyed render cache shared by compact text/result components.
 */
abstract class WidthCached implements Component {
  private cachedWidth: number | undefined;
  private cachedLines: string[] | undefined;

  /**
   * Clear the width-keyed render cache.
   */
  invalidate(): void {
    this.cachedWidth = undefined;
    this.cachedLines = undefined;
  }

  /**
   * Render positive widths, reusing cached lines when the width is unchanged.
   * @param width Available terminal columns.
   * @returns Cached or newly rendered lines, or an empty array when width is nonpositive.
   */
  render(width: number): string[] {
    if (width <= 0) return [];
    if (this.cachedWidth === width && this.cachedLines) return this.cachedLines;
    const lines = this.renderLines(width);
    this.cachedWidth = width;
    this.cachedLines = lines;
    return lines;
  }

  /**
   * Build lines when no cached render exists for this width.
   * @param width Positive number of available terminal columns.
   * @returns Lines to cache for this width.
   */
  protected abstract renderLines(width: number): string[];
}

/**
 * Compact result component with bounded output and nested-call visibility.
 */
export class CompactResult extends WidthCached {
  private readonly preview: Preview;
  private readonly theme: Theme;

  /**
   * Create a compact result view from prepared preview data.
   * @param preview Summary, output, calls, notices, and head/tail selection.
   * @param theme Theme used for output, errors, and notices.
   */
  constructor(preview: Preview, theme: Theme) {
    super();
    this.preview = preview;
    this.theme = theme;
  }

  /**
   * Render summary/calls, bounded wrapped output, hidden-content counts, and notices.
   * @param width Available terminal columns.
   * @returns Compact result rows for the current width.
   */
  protected override renderLines(width: number): string[] {
    const { preview, theme } = this;
    const lines = [
      truncateToWidth(preview.summary, width),
      ...preview.calls.map((line) => truncateToWidth(line, width)),
    ];
    const output = preview.output ? wrapTextWithAnsi(preview.output, Math.max(1, width)) : [];
    const shown = preview.keepEnd ? output.slice(-PREVIEW_LINES) : output.slice(0, PREVIEW_LINES);
    lines.push(...shown.map((line) => theme.fg(preview.isError ? "error" : "toolOutput", line)));
    const hidden = [];
    if (output.length > shown.length) hidden.push(`${output.length - shown.length} more output lines`);
    if (preview.hiddenCalls) hidden.push(`${preview.hiddenCalls} more calls`);
    if (hidden.length)
      lines.push(truncateToWidth(theme.fg("muted", `… ${hidden.join(" · ")} · expand for details`), width));
    lines.push(...preview.notices.map((line) => truncateToWidth(theme.fg("warning", line), width)));
    return lines;
  }
}

/**
 * Native edit-card body cached by width and child identity rather than width alone.
 */
export class NativeEditBody extends Container {
  private cachedWidth: number | undefined;
  private cachedChildren: Component[] | undefined;
  private cachedLines: string[] | undefined;
  private readonly card: Box;
  private readonly expanded: boolean;
  private readonly theme: Theme;

  /**
   * Expose native edit-card children without its outer shell, retaining asynchronous child updates.
   * @param card Native edit renderer's Box.
   * @param theme Theme used for the collapsed-diff notice.
   * @param expanded Whether all native diff rows should remain visible.
   */
  constructor(card: Box, theme: Theme, expanded: boolean) {
    super();
    this.card = card;
    this.expanded = expanded;
    this.theme = theme;
  }

  /**
   * Clear cached lines/child identities and invalidate both the native card and container.
   */
  override invalidate(): void {
    this.cachedLines = undefined;
    this.cachedChildren = undefined;
    this.card.invalidate();
    super.invalidate();
  }

  /**
   * Render native children, refreshing when their identities change and capping collapsed diffs.
   * @param width Available terminal columns.
   * @returns Native diff rows with an omission notice when collapsed, or no rows at nonpositive widths.
   */
  override render(width: number): string[] {
    if (width <= 0) return [];
    // Native preview/result updates replace the public children. Recheck their identities,
    // rather than freezing an asynchronous diff in a width-only cache.
    const children = this.card.children;
    if (
      this.cachedWidth === width &&
      this.cachedLines &&
      this.cachedChildren?.length === children.length &&
      children.every((child, index) => child === this.cachedChildren?.[index])
    ) {
      return this.cachedLines;
    }
    this.children = children;
    const rows = super.render(width);
    const lines =
      !this.expanded && rows.length > DIFF_PREVIEW_LINES
        ? [
            ...rows.slice(0, DIFF_PREVIEW_LINES),
            truncateToWidth(
              this.theme.fg("muted", `… ${rows.length - DIFF_PREVIEW_LINES} more diff rows · expand for details`),
              width,
            ),
          ]
        : rows;
    this.cachedWidth = width;
    this.cachedChildren = children.slice();
    this.cachedLines = lines;
    return lines;
  }
}

/**
 * Immutable single-line tool-call preview.
 */
export class OneLine extends WidthCached {
  private readonly text: string;

  /**
   * Create a single-row text component.
   * @param text Styled text to truncate at render time.
   */
  constructor(text: string) {
    super();
    this.text = text;
  }

  /**
   * Truncate the stored text without wrapping.
   * @param width Available terminal columns.
   * @returns One truncated row.
   */
  protected override renderLines(width: number): string[] {
    return [truncateToWidth(this.text, width)];
  }
}

/**
 * Tool frame preserving native mouse handling and source-sensitive render caching.
 */
export class ToolFrame implements Component {
  private cachedWidth: number | undefined;
  private cachedSource: string[] | undefined;
  private cachedLines: string[] | undefined;
  private readonly close: boolean;
  private readonly inner: Component;
  private readonly padding: number;
  private readonly part: "call" | "result";
  private readonly theme: Theme;

  /**
   * Wrap a call or result component with the tool's gutter and optional closing border.
   * @param inner Component rendered inside the frame.
   * @param theme Theme used for borders.
   * @param padding Requested outer horizontal padding.
   * @param part Whether this frame contains the call header or result body.
   * @param close Whether to append a closing border when a gutter is visible.
   */
  constructor(inner: Component, theme: Theme, padding: number, part: "call" | "result", close: boolean) {
    this.close = close;
    this.inner = inner;
    this.padding = padding;
    this.part = part;
    this.theme = theme;
  }

  /**
   * Forward mouse events inside the content area with adjusted coordinates and height.
   * @param event Mouse event relative to the complete frame.
   * @returns The inner component's result, or undefined for gutter/closing-border events or unsupported input.
   */
  handleMouse(event: TuiMouseEvent): ReturnType<NonNullable<Component["handleMouse"]>> {
    const layout = this.layout(event.width);
    const inset = layout.padding + layout.gutter;
    const height = Math.max(0, event.height - (this.close && layout.gutter ? 1 : 0));
    if (event.x < inset || event.y >= height) return undefined;
    return this.inner.handleMouse?.({ ...event, x: event.x - inset, width: layout.content, height });
  }

  /**
   * Clear frame caches and invalidate the wrapped component.
   */
  invalidate(): void {
    this.cachedLines = undefined;
    this.cachedSource = undefined;
    this.inner.invalidate();
  }

  /**
   * Render framed rows, refreshing when width or the inner source rows change.
   * @param width Available terminal columns, including outer padding and gutter.
   * @returns Framed content and an optional closing row, or no rows at nonpositive widths.
   */
  render(width: number): string[] {
    if (width <= 0) return [];
    const layout = this.layout(width);
    const source = this.inner.render(layout.content);
    if (
      this.cachedWidth === width &&
      this.cachedLines &&
      this.cachedSource?.length === source.length &&
      source.every((row, index) => row === this.cachedSource?.[index])
    ) {
      return this.cachedLines;
    }
    const margin = " ".repeat(layout.padding);
    const rows = source.map((row, index) => {
      const prefix = this.part === "call" && index === 0 ? "┌─ " : "│  ";
      const gutter = layout.gutter ? this.theme.fg("border", prefix) : "";
      return margin + gutter + truncateToWidth(row, layout.content, "");
    });
    if (this.close && layout.gutter) {
      rows.push(margin + this.theme.fg("border", `└${"─".repeat(width - layout.padding - 3)}`));
    }
    this.cachedWidth = width;
    this.cachedSource = source.slice();
    this.cachedLines = rows;
    return rows;
  }

  /**
   * Calculate clamped outer padding, optional three-cell gutter, and inner width.
   * @param width Available terminal columns.
   * @returns Padding, gutter, and a content width of at least one column.
   */
  private layout(width: number): { padding: number; gutter: number; content: number } {
    const padding = Math.min(Math.max(0, this.padding), Math.max(0, width - 1));
    const available = Math.max(0, width - padding);
    const gutter = available > 3 ? 3 : 0;
    return { padding, gutter, content: Math.max(1, available - gutter) };
  }
}
