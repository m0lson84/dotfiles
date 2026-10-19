import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

/** Conversation-only undo: abandoned turns stay in /tree; files are never restored. */
export async function undo(args: string, ctx: ExtensionCommandContext): Promise<void> {
  if (ctx.mode !== "tui") {
    ctx.ui.notify("/undo requires Pi's interactive editor.", "warning");
    return;
  }

  if (args.trim()) {
    ctx.ui.notify("Usage: /undo", "warning");
    return;
  }

  if (!ctx.isIdle() || ctx.hasPendingMessages()) {
    ctx.ui.notify("Stop or finish the current response and clear queued prompts before using /undo.", "warning");
    return;
  }

  if (ctx.ui.getEditorText().trim()) {
    ctx.ui.notify("Save or clear the current editor draft before using /undo.", "warning");
    return;
  }

  const entry = ctx.sessionManager
    .getBranch()
    .findLast((entry) => entry.type === "message" && entry.message.role === "user");

  if (entry?.type !== "message" || entry.message.role !== "user") {
    ctx.ui.notify("No user prompt to undo on the current branch.", "info");
    return;
  }

  if (entry.id === ctx.sessionManager.getLeafId()) {
    ctx.ui.notify("The latest prompt has no following history to rewind yet.", "warning");
    return;
  }

  const result = await ctx.navigateTree(entry.id, { summarize: false });
  if (result.cancelled) return;

  const content = entry.message.content;
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
