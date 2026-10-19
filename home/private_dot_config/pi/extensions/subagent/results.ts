import type { Message } from "@earendil-works/pi-ai";
import type { SingleResult } from "./types.ts";

/**
 * Find the first text block in the most recent assistant message that contains text.
 * @param messages Child conversation messages in history order.
 * @returns Assistant text, or an empty string when no text block exists.
 */
export function getFinalOutput(messages: Message[]): string {
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    if (msg.role === "assistant") {
      for (const part of msg.content) {
        if (part.type === "text") return part.text;
      }
    }
  }
  return "";
}

/**
 * Choose error details for failures or final assistant output for successful children.
 * @param result Child execution result.
 * @returns Error message, stderr, or final text according to existing precedence, with a no-output fallback.
 */
export function getResultOutput(result: SingleResult): string {
  if (isFailed(result)) {
    return result.errorMessage || result.stderr || getFinalOutput(result.messages) || "(no output)";
  }
  return getFinalOutput(result.messages) || "(no output)";
}

/**
 * Treat nonzero or running exit codes and error/aborted stop reasons as unsuccessful.
 * @param result Child execution result to inspect.
 * @returns Whether the child is not a completed success.
 */
export function isFailed(result: SingleResult): boolean {
  return result.exitCode !== 0 || result.stopReason === "error" || result.stopReason === "aborted";
}
