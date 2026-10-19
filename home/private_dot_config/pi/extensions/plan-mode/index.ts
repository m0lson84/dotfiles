import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";
import { isAllowed } from "./utils.ts";

interface PlanModeState {
  enabled: boolean;
  previousTools?: string[];
}

const PLAN_MODE_TOOLS = ["read", "bash", "grep", "find", "ls", "questionnaire"];
const NORMAL_MODE_TOOLS = ["read", "bash", "edit", "write"];
const PLAN_MODE_DISABLED_TOOLS = new Set(["edit", "write"]);
const PLAN_MANAGED_TOOLS = new Set([...PLAN_MODE_TOOLS, ...NORMAL_MODE_TOOLS]);

export default function planModeExtension(pi: ExtensionAPI): void {
  let enabled = false;
  let previousTools: string[] | undefined;
  let initialTools: string[] | undefined;

  function emitModeChanged(): void {
    pi.events.emit("plan-mode:changed", enabled);
  }

  function restrictTools(): void {
    const activeTools = pi.getActiveTools();
    previousTools ??= activeTools;
    pi.setActiveTools([
      ...new Set([...activeTools.filter((name) => !PLAN_MODE_DISABLED_TOOLS.has(name)), ...PLAN_MODE_TOOLS]),
    ]);
  }

  function restoreTools(): void {
    pi.setActiveTools(
      previousTools ?? [
        ...new Set([...NORMAL_MODE_TOOLS, ...pi.getActiveTools().filter((name) => !PLAN_MANAGED_TOOLS.has(name))]),
      ],
    );
    previousTools = undefined;
  }

  function persistState(): void {
    pi.appendEntry("plan-mode", {
      enabled,
      previousTools,
    });
  }

  function togglePlanMode(ctx: ExtensionContext): void {
    enabled = !enabled;
    if (enabled) {
      restrictTools();
      ctx.ui.notify("Plan mode enabled. Built-in write tools disabled.");
    } else {
      restoreTools();
      ctx.ui.notify("Plan mode disabled. Previous toolset restored.");
    }
    emitModeChanged();
    persistState();
  }

  pi.registerFlag("plan", {
    description: "Start in plan mode (read-only exploration)",
    type: "boolean",
    default: false,
  });

  pi.registerCommand("plan", {
    description: "Toggle plan mode (read-only exploration)",
    handler: async (_args, ctx) => togglePlanMode(ctx),
  });

  pi.registerShortcut(Key.ctrlAlt("p"), {
    description: "Toggle plan mode",
    handler: (ctx) => togglePlanMode(ctx),
  });

  pi.on("tool_call", (event) => {
    if (!enabled || !isToolCallEventType("bash", event)) return;

    const command = event.input.command;
    if (!isAllowed(command)) {
      return {
        block: true,
        reason: `Plan mode: command blocked (not allowlisted). Use /plan to disable plan mode first.\nCommand: ${command}`,
      };
    }
  });

  // Remove this extension's planning instructions when normal operation resumes.
  pi.on("context", (event) => {
    if (enabled) return;
    return {
      messages: event.messages.filter(
        (message) => !("customType" in message && message.customType === "plan-mode-context"),
      ),
    };
  });

  pi.on("before_agent_start", (event) => {
    if (!enabled || event.messageType !== "user") return;
    return {
      message: {
        customType: "plan-mode-context",
        content: `[PLAN MODE ACTIVE]
You are in plan mode. Investigate, ask clarifying questions, and refine the approach with the user.

Restrictions:
- Built-in edit and write tools are disabled
- Other currently active tools remain available
- Bash is restricted to an allowlist of read-only commands

Do not make changes. Continue discussing and refining the plan until the user explicitly disables plan mode.`,
        display: false,
      },
    };
  });

  function restoreState(ctx: ExtensionContext): void {
    const branch = ctx.sessionManager.getBranch();
    const modeIndex = branch.findLastIndex((entry) => entry.type === "custom" && entry.customType === "plan-mode");
    const entry = branch[modeIndex];
    const state = entry?.type === "custom" ? (entry.data as PlanModeState | undefined) : undefined;

    enabled = state?.enabled ?? pi.getFlag("plan") === true;
    previousTools = state?.previousTools;
    initialTools ??= previousTools ?? pi.getActiveTools();

    // Pi restores tool declarations before session_tree. Keep later branch-specific choices,
    // but account for an empty root or a mode change not yet recorded in a model request.
    const toolsIndex = branch.findLastIndex(
      (entry) =>
        (entry.type === "message" &&
          entry.message.role === "system" &&
          (entry.message.toolsAdded !== undefined || entry.message.toolsRemoved !== undefined)) ||
        (entry.type === "compaction" && entry.systemMessage !== undefined),
    );
    if (toolsIndex < 0 || (!enabled && modeIndex > toolsIndex)) {
      const planningEntry = branch.findLast(
        (entry) =>
          entry.type === "custom" &&
          entry.customType === "plan-mode" &&
          (entry.data as PlanModeState | undefined)?.enabled,
      );
      const planningState = planningEntry?.type === "custom" ? (planningEntry.data as PlanModeState) : undefined;
      pi.setActiveTools(previousTools ?? planningState?.previousTools ?? initialTools);
    }
    if (enabled) restrictTools();
    emitModeChanged();
  }

  pi.on("session_start", (_event, ctx) => {
    restoreState(ctx);
    if (!ctx.sessionManager.getBranch().some((entry) => entry.type === "custom" && entry.customType === "plan-mode")) {
      persistState();
    }
  });

  pi.on("session_tree", (_event, ctx) => restoreState(ctx));
}
