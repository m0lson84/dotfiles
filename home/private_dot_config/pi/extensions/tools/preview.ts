import type { AgentToolResult } from "@earendil-works/pi-agent-core";
import type { Theme, ToolRenderResultOptions } from "@earendil-works/pi-coding-agent";
import { inline, plain, record } from "./formatting.ts";

/** Parent execution metadata needed for compact summary status and elapsed time. */
interface PreviewContext {
  isError: boolean;
  durationMs: number | undefined;
}

/** Maximum nested-call rows shown, with failures placed before successful or running calls. */
const CALL_PREVIEWS = 3;
/** Exact codemode metadata block omitted only when it is the first content block. */
const SCRIPT_HEADER = /^Script (completed|failed)\nWall time [\d.]+ seconds\nOutput:\n$/;

/** Prepared compact output, nested-call previews, notices, and head/tail selection. */
export interface Preview {
  summary: string;
  output: string;
  calls: string[];
  hiddenCalls: number;
  notices: string[];
  isError: boolean;
  keepEnd: boolean;
}

/** Parsed result content and nested-call state shared by compact and expanded fallback rendering. */
export interface ResultData {
  content: AgentToolResult<unknown>["content"];
  output: string;
  details: Record<string, unknown>;
  calls: Record<string, unknown>[];
  failed: Record<string, unknown>[];
  isError: boolean;
}

/**
 * Parse displayable content and nested-call failures before choosing expanded or compact output.
 * @param name Tool name controlling codemode header and nested-call handling.
 * @param result Tool result to inspect.
 * @param parentError Whether the parent tool result is an error.
 * @returns Sanitized output, filtered content, permissive details, and nested-call status.
 */
export function getOutput(name: string, result: AgentToolResult<unknown>, parentError: boolean): ResultData {
  const content = result.content.filter(
    (block, index) => !(name === "codemode" && index === 0 && block.type === "text" && SCRIPT_HEADER.test(block.text)),
  );
  const output = content
    .filter((block) => block.type === "text")
    .map((block) => plain(block.text))
    .join("\n")
    .trim();
  const details = record(result.details);
  const calls = name === "codemode" && Array.isArray(details.calls) ? details.calls.map(record) : [];
  const failed = calls.filter((call) => call.status === "error" || call.status === "cancelled");
  const isError = parentError || failed.length > 0;

  return { content, output, details, calls, failed, isError };
}

/**
 * Build compact result metadata without changing parsed output or full result details.
 * @param name Tool name used for diff counts and shell tail-preview selection.
 * @param data Parsed result content, details, and nested-call state.
 * @param options Partial/expanded rendering options.
 * @param theme Current theme.
 * @param context Parent error status and optional execution duration.
 * @returns Styled preview data consumed by the compact result component.
 */
export function getPreview(
  name: string,
  data: ResultData,
  options: ToolRenderResultOptions,
  theme: Theme,
  context: PreviewContext,
): Preview {
  const { output, isError } = data;
  const counts = getCounts(name, data, context.durationMs);
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

  const calls = getCalls(data, theme);
  return {
    summary,
    output,
    calls: calls.lines,
    hiddenCalls: calls.hidden,
    notices: getNotices(data.details),
    isError,
    keepEnd: name === "bash" || name === "powershell",
  };
}

/**
 * Prioritize failed or cancelled nested calls, then format a bounded list of their labels.
 * @param data Parsed calls and their failed subset.
 * @param theme Current theme.
 * @returns Styled call-preview rows and the number of unshown calls.
 */
function getCalls(data: ResultData, theme: Theme): { lines: string[]; hidden: number } {
  const { calls, failed } = data;
  // Surface nested failures even if a codemode script caught them and returned successfully.
  const shownCalls = [...failed, ...calls.filter((call) => !failed.includes(call))].slice(0, CALL_PREVIEWS);
  const callLines = shownCalls.map((call) => {
    const error = call.status === "error" || call.status === "cancelled";
    const icon = error ? "✗" : call.status === "running" ? "…" : "✓";
    const label = `${icon} ${inline(call.name)}${error && call.error ? ` · ${inline(call.error)}` : ""}`;
    return theme.fg(error ? "error" : "muted", label);
  });
  return { lines: callLines, hidden: calls.length - shownCalls.length };
}

/**
 * Count nested calls, failures, diff or output lines, images, and optional elapsed time.
 * @param name Tool name controlling edit-diff counting.
 * @param data Parsed content, output, details, and nested calls.
 * @param durationMs Optional execution duration in milliseconds.
 * @returns Summary count labels in their original display order.
 */
function getCounts(name: string, data: ResultData, durationMs: number | undefined): string[] {
  const { calls, failed, details, output, content } = data;
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
  if (durationMs !== undefined) counts.push(`${(durationMs / 1000).toFixed(1)}s`);
  return counts;
}

/**
 * Extract full-output location and truncation notices from permissive tool details.
 * @param details Tool result details.
 * @returns Notice strings in display order.
 */
function getNotices(details: Record<string, unknown>): string[] {
  const notices = [];
  if (details.fullOutputPath) notices.push(`Full output: ${plain(details.fullOutputPath)}`);
  if (record(details.truncation).truncated) notices.push("Output was truncated; expand for details.");

  return notices;
}
