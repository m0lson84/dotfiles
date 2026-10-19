import type { UserMessage } from "@earendil-works/pi-ai";
import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

/**
 * Rewind the latest user turn and restore its prompt text to the editor.
 * Abandoned turns remain in /tree; files are unchanged and images must be reattached.
 * @param args Command arguments; only whitespace is accepted.
 * @param ctx Context for the current command execution.
 */
export async function undo(args: string, ctx: ExtensionCommandContext): Promise<void> {
  if (!canExecute(args, ctx)) return;

  const entry = getUserMessage(ctx);
  if (!entry) {
    ctx.ui.notify("No user prompt to undo on the current branch.", "info");
    return;
  }

  if (entry.id === ctx.sessionManager.getLeafId()) {
    ctx.ui.notify("The latest prompt has no following history to rewind yet.", "warning");
    return;
  }

  const result = await ctx.navigateTree(entry.id, { summarize: false });
  if (result.cancelled) return;

  restorePrompt(entry.message.content, ctx);
}

/**
 * Check command readiness, notifying the user about the first failed requirement.
 * This does not check whether the current branch contains a turn to rewind.
 * @param args Arguments for the command being executed.
 * @param ctx Context for the current command execution.
 * @returns Whether the command can proceed to inspect the session history.
 */
function canExecute(args: string, ctx: ExtensionCommandContext): boolean {
  if (ctx.mode !== "tui") {
    ctx.ui.notify("/undo requires Pi's interactive editor.", "warning");
    return false;
  }

  if (args.trim()) {
    ctx.ui.notify("Usage: /undo", "warning");
    return false;
  }

  if (!ctx.isIdle() || ctx.hasPendingMessages()) {
    ctx.ui.notify("Stop or finish the current response and clear queued prompts before using /undo.", "warning");
    return false;
  }

  if (ctx.ui.getEditorText().trim()) {
    ctx.ui.notify("Save or clear the current editor draft before using /undo.", "warning");
    return false;
  }

  return true;
}

/**
 * Find the latest user prompt on the current session branch.
 * @param ctx Context for the current command execution.
 * @returns The user message and its entry ID, or undefined if the branch has no user prompt.
 */
function getUserMessage(ctx: ExtensionCommandContext): { id: string; message: UserMessage } | undefined {
  const entry = ctx.sessionManager
    .getBranch()
    .findLast((entry) => entry.type === "message" && entry.message.role === "user");

  if (entry?.type !== "message" || entry.message.role !== "user") return;
  return { id: entry.id, message: entry.message };
}

/**
 * Restore prompt text to the editor and report the rewind, warning if images need reattachment.
 * Text parts are concatenated in order; image content is not restored.
 * @param content Original user prompt, either plain text or an array of text and image parts.
 * @param ctx Context for the current command execution.
 */
function restorePrompt(content: UserMessage["content"], ctx: ExtensionCommandContext): void {
  const text =
    typeof content === "string"
      ? content
      : content
          .filter((part) => part.type === "text")
          .map((part) => part.text)
          .join("");
  ctx.ui.setEditorText(text);

  const hasImages = typeof content !== "string" && content.some((part) => part.type === "image");
  ctx.ui.notify(
    hasImages
      ? "Turn rewound; files unchanged. Prompt text restored, but images must be reattached. History remains in /tree."
      : "Turn rewound; files unchanged. Prompt restored to the editor. History remains in /tree.",
    hasImages ? "warning" : "info",
  );
}
