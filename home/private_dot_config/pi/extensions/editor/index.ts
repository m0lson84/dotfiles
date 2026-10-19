import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { PanelEditor } from "./panel.ts";

/**
 * Install the editor panel and connect session lifecycle and mode/status events.
 * @param pi Extension API used to register handlers and communicate through the event bus.
 */
export default function editorExtension(pi: ExtensionAPI): void {
  let editor: PanelEditor | undefined;
  const unsubscribe = pi.events.on("plan-mode:changed", (enabled) => {
    if (typeof enabled === "boolean") editor?.setPlanMode(enabled);
  });

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    const planModeEnabled = readPlanMode(ctx, pi);
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
    editor?.setPlanMode(readPlanMode(ctx, pi));
  });

  pi.on("session_shutdown", () => {
    unsubscribe();
    pi.events.emit("editor:working-status", undefined);
    editor = undefined;
  });
}

/**
 * Read the latest plan-mode state on the current branch, falling back to the plan flag.
 * @param ctx Session context providing the current branch.
 * @param pi Extension API used to read the fallback flag when no enabled state is stored.
 * @returns Whether plan mode is enabled for the current branch.
 */
function readPlanMode(ctx: ExtensionContext, pi: ExtensionAPI): boolean {
  const entry = ctx.sessionManager
    .getBranch()
    .findLast((entry) => entry.type === "custom" && entry.customType === "plan-mode");
  const state = entry?.type === "custom" ? (entry.data as { enabled?: boolean } | undefined) : undefined;
  return state?.enabled ?? pi.getFlag("plan") === true;
}
