import { basename } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { EditorWorkingStatus } from "./rendering.ts";
import { render } from "./rendering.ts";
import type { SessionUsage } from "./usage.ts";
import { calculateUsage } from "./usage.ts";

/**
 * Install the statusline footer and connect working-status, branch-change, and shutdown events.
 * @param pi Extension API used to register lifecycle hooks and receive working-status events.
 */
export default function statuslineExtension(pi: ExtensionAPI): void {
  let unsubscribe: (() => void) | undefined;
  let requestRender: (() => void) | undefined;
  let workingStatus: EditorWorkingStatus;
  const unsubscribeStatus = pi.events.on("editor:working-status", (indicator) => {
    workingStatus = indicator as EditorWorkingStatus;
    requestRender?.();
  });

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const rerender = () => tui.requestRender();
      const disposeBranch = footerData.onBranchChange(rerender);
      /** Unsubscribe from branch changes and clear this footer's redraw callback if still current. */
      const dispose = () => {
        disposeBranch();
        if (requestRender === rerender) requestRender = undefined;
      };
      requestRender = rerender;
      unsubscribe = dispose;
      let cachedSessionId: string | undefined;
      let cachedLeafId: string | null | undefined;
      let totals: SessionUsage = { input: 0, output: 0, cost: 0 };

      /**
       * Read cached totals, recalculating from all entries when the session or leaf changes.
       * @returns Session token and cost totals cached for the current session ID and leaf ID.
       */
      function getSessionUsage(): SessionUsage {
        const sessionId = ctx.sessionManager.getSessionId();
        const leafId = ctx.sessionManager.getLeafId();
        if (sessionId !== cachedSessionId || leafId !== cachedLeafId) {
          totals = calculateUsage(ctx.sessionManager.getEntries());
          cachedSessionId = sessionId;
          cachedLeafId = leafId;
        }
        return totals;
      }

      return {
        dispose,
        /** No formatted lines are cached; each render reads the current footer data. */
        invalidate() {},
        /**
         * Collect current session data and render the footer.
         * @param width Available terminal columns.
         * @returns The statusline followed by an empty line for vertical spacing.
         */
        render(width: number): string[] {
          const statuses = footerData.getExtensionStatuses();
          return [
            render(theme, width, {
              workingStatus,
              directory: (basename(ctx.cwd) || ctx.cwd).replace(/[\r\n\t]/g, " "),
              branch: footerData.getGitBranch(),
              context: ctx.getContextUsage(),
              usage: getSessionUsage(),
              statuses: [...statuses.values()],
            }),
            "",
          ];
        },
      };
    });
  });

  pi.on("session_shutdown", () => {
    unsubscribeStatus();
    unsubscribe?.();
    unsubscribe = undefined;
    workingStatus = undefined;
    requestRender = undefined;
  });
}
