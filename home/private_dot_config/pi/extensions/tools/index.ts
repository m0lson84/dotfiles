import { homedir } from "node:os";
import type { ExtensionAPI, Theme, ToolRenderers } from "@earendil-works/pi-coding-agent";
import { createEditToolDefinition } from "@earendil-works/pi-coding-agent";
import type { Component, TuiMouseEvent } from "@earendil-works/pi-tui";
import {
  Box,
  Container,
  stripTerminalSequences,
  Text,
  truncateToWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";

const COMPACT_TOOLS = new Set(["read", "bash", "powershell", "edit", "write", "grep", "find", "ls", "codemode"]);
const PREVIEW_LINES = 3;
const CALL_PREVIEWS = 3;
const DIFF_PREVIEW_LINES = 24;
const SCRIPT_HEADER = /^Script (completed|failed)\nWall time [\d.]+ seconds\nOutput:\n$/;

function record(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" ? (value as Record<string, unknown>) : {};
}

function plain(value: unknown): string {
  return typeof value === "string" ? stripTerminalSequences(value).replace(/\r/g, "").replace(/\t/g, "    ") : "";
}

function inline(value: unknown): string {
  return plain(value).replace(/\s+/g, " ").trim();
}

function pathLabel(value: unknown): string {
  const path = inline(value);
  const home = homedir();
  return path === home ? "~" : path.startsWith(`${home}/`) ? `~${path.slice(home.length)}` : path;
}

abstract class WidthCached implements Component {
  private cachedWidth: number | undefined;
  private cachedLines: string[] | undefined;

  invalidate(): void {
    this.cachedWidth = undefined;
    this.cachedLines = undefined;
  }

  render(width: number): string[] {
    if (width <= 0) return [];
    if (this.cachedWidth === width && this.cachedLines) return this.cachedLines;
    const lines = this.renderLines(width);
    this.cachedWidth = width;
    this.cachedLines = lines;
    return lines;
  }

  protected abstract renderLines(width: number): string[];
}

class OneLine extends WidthCached {
  constructor(private readonly text: string) {
    super();
  }

  protected override renderLines(width: number): string[] {
    return [truncateToWidth(this.text, width)];
  }
}

class NativeEditBody extends Container {
  private cachedWidth: number | undefined;
  private cachedChildren: Component[] | undefined;
  private cachedLines: string[] | undefined;

  constructor(
    private readonly card: Box,
    private readonly theme: Theme,
    private readonly expanded: boolean,
  ) {
    super();
  }

  override invalidate(): void {
    this.cachedLines = undefined;
    this.cachedChildren = undefined;
    this.card.invalidate();
    super.invalidate();
  }

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

class ToolFrame implements Component {
  private cachedWidth: number | undefined;
  private cachedSource: string[] | undefined;
  private cachedLines: string[] | undefined;

  constructor(
    private readonly inner: Component,
    private readonly theme: Theme,
    private readonly padding: number,
    private readonly part: "call" | "result",
    private readonly close: boolean,
  ) {}

  invalidate(): void {
    this.cachedLines = undefined;
    this.cachedSource = undefined;
    this.inner.invalidate();
  }

  private layout(width: number): { padding: number; gutter: number; content: number } {
    const padding = Math.min(Math.max(0, this.padding), Math.max(0, width - 1));
    const available = Math.max(0, width - padding);
    const gutter = available > 3 ? 3 : 0;
    return { padding, gutter, content: Math.max(1, available - gutter) };
  }

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

  handleMouse(event: TuiMouseEvent): ReturnType<NonNullable<Component["handleMouse"]>> {
    const layout = this.layout(event.width);
    const inset = layout.padding + layout.gutter;
    const height = Math.max(0, event.height - (this.close && layout.gutter ? 1 : 0));
    if (event.x < inset || event.y >= height) return undefined;
    return this.inner.handleMouse?.({ ...event, x: event.x - inset, width: layout.content, height });
  }
}

function callLabel(name: string, args: Record<string, unknown>): string {
  switch (name) {
    case "bash":
    case "powershell":
      return inline(args.command) || "…";
    case "codemode": {
      const code = plain(args.code).trim();
      const lines = code ? code.split("\n").length : 0;
      return lines ? `${lines}-line script` : "…";
    }
    case "grep":
    case "find":
      return `${inline(args.pattern) || "…"} in ${pathLabel(args.path) || "."}`;
    default: {
      let label = pathLabel(args.path) || "…";
      if (name === "read" && typeof args.offset === "number") label += `:${args.offset}`;
      if (name === "write" && typeof args.content === "string") label += ` · ${args.content.split("\n").length} lines`;
      return label;
    }
  }
}

interface Preview {
  summary: string;
  output: string;
  calls: string[];
  hiddenCalls: number;
  notices: string[];
  isError: boolean;
  keepEnd: boolean;
}

class CompactResult extends WidthCached {
  constructor(
    private readonly preview: Preview,
    private readonly theme: Theme,
  ) {
    super();
  }

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

export default function toolDisplayExtension(pi: ExtensionAPI): void {
  const nativeEdit = createEditToolDefinition(process.cwd());

  pi.registerToolRenderer((name, next) => {
    const original = next();
    const isNativeEdit =
      name === "edit" &&
      original?.renderShell === nativeEdit.renderShell &&
      original?.renderCall === nativeEdit.renderCall &&
      original?.renderResult === nativeEdit.renderResult;
    // Native edit owns its shell too; only decorate it when the renderer identities match.
    if (!COMPACT_TOOLS.has(name) || (original?.renderShell === "self" && !isNativeEdit)) return original;

    const renderers = {
      ...original,
      renderCall(args, theme, context) {
        if ((isNativeEdit || context.expanded) && original?.renderCall) {
          // Our compact components must never be reused as a native renderer's Container/Text.
          const component = original.renderCall(args, theme, {
            ...context,
            outputPad: isNativeEdit ? 0 : context.outputPad,
            lastComponent: undefined,
          });
          return isNativeEdit && component instanceof Box
            ? new NativeEditBody(component, theme, context.expanded)
            : component;
        }
        const title = theme.fg(context.isError ? "error" : "toolTitle", theme.bold(name));
        if (context.expanded) {
          const argumentsText = name === "codemode" ? plain(record(args).code) : JSON.stringify(args, null, 2);
          return new Text(`${title}\n${theme.fg("toolOutput", argumentsText ?? "")}`, 0, 0);
        }
        return new OneLine(`${title}  ${theme.fg("accent", callLabel(name, record(args)))}`);
      },
      renderResult(result, options, theme, context) {
        // Native edit's result updates the diff held by its call component, even when collapsed.
        if ((isNativeEdit || options.expanded) && original?.renderResult) {
          return original.renderResult(result, options, theme, {
            ...context,
            outputPad: isNativeEdit ? 0 : context.outputPad,
            lastComponent: undefined,
          });
        }

        const content = result.content.filter(
          (block, index) =>
            !(name === "codemode" && index === 0 && block.type === "text" && SCRIPT_HEADER.test(block.text)),
        );
        const output = content
          .filter((block) => block.type === "text")
          .map((block) => plain(block.text))
          .join("\n")
          .trim();
        const details = record(result.details);
        const calls = name === "codemode" && Array.isArray(details.calls) ? details.calls.map(record) : [];
        const failed = calls.filter((call) => call.status === "error" || call.status === "cancelled");
        const isError = context.isError || failed.length > 0;

        if (options.expanded) return new Text(theme.fg(isError ? "error" : "toolOutput", output), 0, 0);

        const counts = [];
        if (calls.length) counts.push(`${calls.length} calls`);
        if (failed.length) counts.push(`${failed.length} failed/cancelled`);
        const diff = name === "edit" ? plain(details.diff) : "";
        if (diff) {
          const lines = diff.split("\n");
          counts.push(`+${lines.filter((line) => line.startsWith("+") && !line.startsWith("+++")).length}`);
          counts.push(`-${lines.filter((line) => line.startsWith("-") && !line.startsWith("---")).length}`);
        } else if (output) {
          counts.push(`${output.split("\n").length} output lines`);
        }
        const images = content.filter((block) => block.type === "image").length;
        if (images) counts.push(`${images} image${images === 1 ? "" : "s"}`);
        if (context.durationMs !== undefined) counts.push(`${(context.durationMs / 1000).toFixed(1)}s`);
        const status = context.isError
          ? "✗ failed"
          : isError
            ? "✗ nested call failures"
            : options.isPartial
              ? "… running"
              : "✓ done";
        const summary = theme.fg(
          isError ? "error" : options.isPartial ? "warning" : "muted",
          [status, ...counts].join(" · "),
        );

        // Surface nested failures even if a codemode script caught them and returned successfully.
        const shownCalls = [...failed, ...calls.filter((call) => !failed.includes(call))].slice(0, CALL_PREVIEWS);
        const callLines = shownCalls.map((call) => {
          const error = call.status === "error" || call.status === "cancelled";
          const icon = error ? "✗" : call.status === "running" ? "…" : "✓";
          const label = `${icon} ${inline(call.name)}${error && call.error ? ` · ${inline(call.error)}` : ""}`;
          return theme.fg(error ? "error" : "muted", label);
        });
        const notices = [];
        if (details.fullOutputPath) notices.push(`Full output: ${plain(details.fullOutputPath)}`);
        if (record(details.truncation).truncated) notices.push("Output was truncated; expand for details.");

        return new CompactResult(
          {
            summary,
            output,
            calls: callLines,
            hiddenCalls: calls.length - shownCalls.length,
            notices,
            isError,
            keepEnd: name === "bash" || name === "powershell",
          },
          theme,
        );
      },
    } satisfies ToolRenderers;
    return {
      renderShell: "self",
      renderCall(args, theme, context) {
        return new ToolFrame(renderers.renderCall(args, theme, context), theme, context.outputPad, "call", false);
      },
      renderResult(result, options, theme, context) {
        return new ToolFrame(
          renderers.renderResult(result, options, theme, context),
          theme,
          context.outputPad,
          "result",
          !options.isPartial,
        );
      },
    };
  });
}
