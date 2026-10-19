/**
 * Subagent Tool - Delegate tasks to specialized agents
 *
 * Spawns a separate `pi` process for each subagent invocation,
 * giving it an isolated context window.
 *
 * Supports three modes:
 *   - Single: { agent: "name", task: "..." }
 *   - Parallel: { tasks: [{ agent: "name", task: "..." }, ...] }
 *   - Chain: { chain: [{ agent: "name", task: "... {previous} ..." }, ...] }
 *
 * Uses JSON mode to capture structured output from subagents.
 */

import * as path from "node:path";
import {
  CONFIG_DIR_NAME,
  defineTool,
  type ExtensionAPI,
  type ExtensionContext,
  getAgentDir,
} from "@earendil-works/pi-coding-agent";
import type { Static } from "typebox";
import { type AgentConfig, type AgentDiscoveryResult, type AgentScope, discoverAgents } from "./agents.ts";
import { runChain, runParallel, runSingle } from "./dispatch.ts";
import { renderers } from "./rendering.ts";
import { SubagentParams } from "./schema.ts";
import type { DispatchDefaults, SingleResult, SubagentDetails } from "./types.ts";

/**
 * Register subagent dispatch and refresh user-agent advertising at session and run boundaries.
 * @param pi Extension API used to register the tool and lifecycle handlers.
 */
export default function subagentExtension(pi: ExtensionAPI): void {
  const tool = defineTool({
    name: "subagent",
    label: "Subagent",
    description: describeSubagents(process.cwd()),
    parameters: SubagentParams,

    async execute(_id, params, signal, onUpdate, ctx) {
      const agentScope: AgentScope = params.agentScope ?? "user";
      const dispatchDefaults: DispatchDefaults = {
        model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined,
        thinkingLevel: ctx.thinkingLevel,
      };
      const discovery = discoverAgents(ctx.cwd, agentScope);
      const agents = discovery.agents;

      const hasChain = (params.chain?.length ?? 0) > 0;
      const hasTasks = (params.tasks?.length ?? 0) > 0;
      const hasSingle = Boolean(params.agent && params.task);
      const modeCount = Number(hasChain) + Number(hasTasks) + Number(hasSingle);

      const makeDetails =
        (mode: "single" | "parallel" | "chain") =>
        (results: SingleResult[]): SubagentDetails => ({
          mode,
          agentScope,
          projectAgentsDir: discovery.projectAgentsDir,
          results,
        });

      if (modeCount !== 1) {
        const available = agents.map((a) => `${a.name} (${a.source})`).join(", ") || "none";
        return {
          content: [
            {
              type: "text",
              text: `Invalid parameters. Provide exactly one mode.\nAvailable agents: ${available}`,
            },
          ],
          details: makeDetails("single")([]),
          isError: true,
        };
      }

      const approval = confirmAgents(params, discovery, ctx);
      if (approval !== true && !(await approval)) {
        return {
          content: [{ type: "text", text: "Canceled: project-local agents not approved." }],
          details: makeDetails(hasChain ? "chain" : hasTasks ? "parallel" : "single")([]),
          isError: true,
        };
      }

      const options = { defaultCwd: ctx.cwd, dispatchDefaults, agents, signal, onUpdate };
      if (params.chain && params.chain.length > 0) {
        return runChain(params.chain, { ...options, makeDetails: makeDetails("chain") });
      }
      if (params.tasks && params.tasks.length > 0) {
        return runParallel(params.tasks, { ...options, makeDetails: makeDetails("parallel") });
      }
      if (params.agent && params.task) {
        return runSingle(
          { agent: params.agent, task: params.task, cwd: params.cwd },
          { ...options, makeDetails: makeDetails("single") },
        );
      }

      const available = agents.map((a) => `${a.name} (${a.source})`).join(", ") || "none";
      return {
        content: [{ type: "text", text: `Invalid parameters. Available agents: ${available}` }],
        details: makeDetails("single")([]),
        isError: true,
      };
    },

    ...renderers,
  });
  pi.registerTool(tool);

  /**
   * Re-register the tool only when the discovered user-agent description changes.
   * @param cwd Working directory used for agent discovery.
   */
  function refreshDescription(cwd: string): void {
    const description = describeSubagents(cwd);
    if (description === tool.description) return;
    tool.description = description;
    // Re-registration rebuilds Pi's loadout, including codemode's tool descriptions.
    pi.registerTool(tool);
  }

  pi.on("session_start", (_event, ctx) => refreshDescription(ctx.cwd));
  pi.on("before_agent_start", (_event, ctx) => refreshDescription(ctx.cwd));
}

/**
 * Confirm requested project agents only when scope, UI availability, and project trust require it.
 * @param params Tool parameters containing requested agents and confirmation preferences.
 * @param discovery Agents and project source directory discovered for this invocation.
 * @param ctx Execution context providing project trust and the confirmation dialog.
 * @returns True when no dialog is needed, or the pending project-agent approval decision.
 */
function confirmAgents(
  params: Static<typeof SubagentParams>,
  discovery: AgentDiscoveryResult,
  ctx: ExtensionContext,
): boolean | Promise<boolean> {
  const agentScope = params.agentScope ?? "user";
  const confirmProjectAgents = params.confirmProjectAgents ?? true;
  const { agents } = discovery;
  if (
    (agentScope === "project" || agentScope === "both") &&
    confirmProjectAgents &&
    ctx.hasUI &&
    !ctx.isProjectTrusted()
  ) {
    const requestedAgentNames = new Set<string>();
    if (params.chain) for (const step of params.chain) requestedAgentNames.add(step.agent);
    if (params.tasks) for (const task of params.tasks) requestedAgentNames.add(task.agent);
    if (params.agent) requestedAgentNames.add(params.agent);

    const projectAgentsRequested = Array.from(requestedAgentNames)
      .map((name) => agents.find((agent) => agent.name === name))
      .filter((agent): agent is AgentConfig => agent?.source === "project");

    if (projectAgentsRequested.length > 0) {
      const names = projectAgentsRequested.map((agent) => agent.name).join(", ");
      const dir = discovery.projectAgentsDir ?? "(unknown)";
      return ctx.ui.confirm(
        "Run project-local agents?",
        `Agents: ${names}\nSource: ${dir}\n\nProject agents are repo-controlled. Only continue for trusted repositories.`,
      );
    }
  }
  return true;
}

/**
 * Describe dispatch modes and advertise sorted user agents without exposing project-agent prompts.
 * @param cwd Working directory passed to user-scope discovery.
 * @returns Model-facing tool description, including an empty-directory fallback.
 */
function describeSubagents(cwd: string): string {
  const { agents } = discoverAgents(cwd, "user");
  const available = agents
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((agent) => `- ${agent.name}: ${agent.description}`);
  return [
    "Delegate tasks to specialized subagents with isolated context.",
    "Modes: single (agent + task), parallel (tasks array), chain (sequential with {previous} placeholder).",
    `Default agent scope is "user" (from ${path.join(getAgentDir(), "agents")}).`,
    `To enable project-local agents in ${CONFIG_DIR_NAME}/agents, set agentScope: "both" (or "project").`,
    "",
    "Available user agents:",
    ...(available.length > 0 ? available : ["- None found. Add agent Markdown files to the user agents directory."]),
  ].join("\n");
}
