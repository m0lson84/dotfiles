import { homedir } from "node:os";
import { stripTerminalSequences } from "@earendil-works/pi-tui";

/**
 * Build a compact tool-specific label from command, script, pattern, or path arguments.
 * @param name Tool name controlling label selection.
 * @param args Tool-call arguments.
 * @returns A single-line label with tool-specific defaults and optional line information.
 */
export function callLabel(name: string, args: Record<string, unknown>): string {
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

/**
 * Normalize string input to a single trimmed line.
 * @param value Value to sanitize; nonstrings become empty text.
 * @returns Plain text with whitespace runs collapsed to single spaces.
 */
export function inline(value: unknown): string {
  return plain(value).replace(/\s+/g, " ").trim();
}

/**
 * Normalize a path label and replace a complete home-directory prefix with a tilde.
 * @param value Path value to sanitize.
 * @returns Compact path text, or an empty string for nonstring input.
 */
export function pathLabel(value: unknown): string {
  const path = inline(value);
  const home = homedir();
  return path === home ? "~" : path.startsWith(`${home}/`) ? `~${path.slice(home.length)}` : path;
}

/**
 * Strip terminal sequences and carriage returns, expanding tabs to four spaces.
 * @param value Value to sanitize; nonstrings become empty text.
 * @returns Plain string suitable for labels and output previews.
 */
export function plain(value: unknown): string {
  return typeof value === "string" ? stripTerminalSequences(value).replace(/\r/g, "").replace(/\t/g, "    ") : "";
}

/**
 * Treat a non-null object as a string-keyed record for permissive renderer data access.
 * @param value Unknown argument or result-details value.
 * @returns The original object, including arrays, or an empty record for other values.
 */
export function record(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" ? (value as Record<string, unknown>) : {};
}
