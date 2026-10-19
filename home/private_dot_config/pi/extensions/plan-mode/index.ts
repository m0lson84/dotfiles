import { resolve } from "node:path";
import { Type } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, SessionEntry } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType, withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";
import { isAllowed } from "./policy.ts";
import { PLAN_DIR, savePlan } from "./save.ts";

/** Built-in tools selected in build mode; additional active tools are preserved. */
const BUILD_TOOLS = ["read", "bash", "edit", "write"];
/** Tools selected in plan mode, including the dedicated plan-file write exception. */
const PLAN_TOOLS = ["read", "bash", "grep", "find", "ls", "questionnaire", "save_plan"];

/** Mode state stored in a custom session entry and restored from the current branch. */
interface State {
  /** Whether plan mode is currently enabled. */
  enabled: boolean;
}

/**
 * Register mode controls, branch-state restoration, planning context, and tool restrictions.
 * New branches without stored mode state default to plan mode.
 * @param pi Extension API used to register controls, manage tools, persist state, and publish mode changes.
 */
export default function planModeExtension(pi: ExtensionAPI): void {
  let enabled = true;

  /**
   * Select the current mode's tools while preserving active tools outside both mode tool lists.
   */
  function applyTools(): void {
    const modeTools = enabled ? PLAN_TOOLS : BUILD_TOOLS;
    const additionalTools = pi.getActiveTools().filter((name) => !new Set([...BUILD_TOOLS, ...PLAN_TOOLS]).has(name));
    pi.setActiveTools([...modeTools, ...additionalTools]);
  }

  /**
   * Publish the current mode to extensions listening on plan-mode:changed.
   */
  function emitModeChanged(): void {
    pi.events.emit("plan-mode:changed", enabled);
  }

  /**
   * Append the current mode as session data excluded from model context.
   */
  function persistState(): void {
    pi.appendEntry("plan-mode", { enabled });
  }

  /**
   * Restore the current branch's latest mode, defaulting to enabled when no value is stored.
   * @param ctx Session context providing the current branch.
   */
  function restoreState(ctx: ExtensionContext): void {
    const state = getState(ctx.sessionManager.getBranch());
    enabled = state?.enabled ?? true;

    applyTools();
    emitModeChanged();
  }

  /**
   * Toggle the mode, apply its tools, publish and persist the change, and notify the user.
   * @param ctx Session context used to display the mode-change notification.
   */
  function toggleMode(ctx: ExtensionContext): void {
    enabled = !enabled;

    applyTools();
    emitModeChanged();
    persistState();

    ctx.ui.notify(
      enabled ? `Plan mode enabled. Built-in write tools disabled.` : "Build mode enabled. Default toolset restored.",
    );
  }

  pi.registerCommand("plan", {
    description: "Toggle plan mode (read-only exploration)",
    handler: async (_args, ctx) => toggleMode(ctx),
  });

  pi.registerShortcut(Key.ctrlAlt("p"), {
    description: "Toggle plan mode",
    handler: (ctx) => toggleMode(ctx),
  });

  pi.registerTool({
    name: "save_plan",
    label: "Save plan",
    description: `Save or replace a Markdown plan in ./${PLAN_DIR}/ in the current workspace. Only usable in plan mode. Creates the directory if needed; any .md filename is allowed, without directory components.`,
    defaultActive: false,
    parameters: Type.Object({
      filename: Type.String({ description: "Any filename ending in .md, without directory components." }),
      content: Type.String({
        description: "The complete Markdown plan; replaces any existing plan with this filename.",
      }),
    }),
    async execute(_id, { filename, content }, signal, _onUpdate, ctx) {
      return withFileMutationQueue(resolve(ctx.cwd, PLAN_DIR, filename), async () => {
        if (!enabled) throw new Error("save_plan is only available in plan mode.");
        signal?.throwIfAborted();
        await savePlan(ctx.cwd, filename, content);
        return {
          content: [{ type: "text", text: `Saved plan to ./${PLAN_DIR}/${filename}` }],
          details: undefined,
        };
      });
    },
  });

  pi.on("before_agent_start", (event) => {
    if (!enabled || event.messageType !== "user") return;
    return {
      message: {
        customType: "plan-mode-context",
        content: `[PLAN MODE ACTIVE]
You are in plan mode. Investigate, ask clarifying questions, and refine the approach with the user.
Keep plans and revisions in the conversation by default. Call save_plan only when the user explicitly asks to create or update a plan file. A request to plan, entering or leaving plan mode, user feedback, approval of an approach, or a request to implement it does not authorize saving. A previous save request does not authorize automatic updates after later feedback. If a request is ambiguous about writing a file, clarify before saving.

Restrictions:
- Built-in edit and write tools are disabled
- The sole write exception is save_plan, and only for an explicitly requested plan-file creation or update in ./${PLAN_DIR}/
- save_plan accepts filename and content; choose any .md filename without directory components
- save_plan creates ./${PLAN_DIR}/ if needed and replaces any existing plan with the chosen filename
- Do not write any other file or use Bash or another tool to bypass these restrictions
- Other currently active tools remain available
- Bash is restricted to an allowlist of read-only commands

Do not make changes unless the user explicitly requests saving a plan file with save_plan. Otherwise, present and refine the plan in the conversation. Continue discussing and refining the plan until the user explicitly disables plan mode.`,
        display: false,
      },
    };
  });

  pi.on("context", (event) => {
    if (enabled) return;
    return {
      messages: event.messages.filter(
        (message) => !("customType" in message && message.customType === "plan-mode-context"),
      ),
    };
  });

  pi.on("session_start", (_event, ctx) => {
    restoreState(ctx);
    if (!ctx.sessionManager.getBranch().some((entry) => entry.type === "custom" && entry.customType === "plan-mode")) {
      persistState();
    }
  });

  pi.on("session_tree", (_event, ctx) => restoreState(ctx));

  pi.on("tool_call", (event) => {
    if (!enabled || !isToolCallEventType("bash", event)) return;
    const cmd = event.input.command;
    if (!isAllowed(cmd)) {
      return {
        block: true,
        reason: `Plan mode: command blocked (not allowlisted). Use /plan to disable plan mode first.\nCommand: ${cmd}`,
      };
    }
  });
}

/**
 * Find the latest stored plan-mode state on the supplied session branch.
 * @param branch Entries from the current branch, in history order.
 * @returns The latest plan-mode entry's data, or undefined when no state is stored.
 */
function getState(branch: SessionEntry[]): State | undefined {
  const entry = branch.findLast((entry) => entry.type === "custom" && entry.customType === "plan-mode");
  return entry?.type === "custom" ? (entry.data as State | undefined) : undefined;
}
