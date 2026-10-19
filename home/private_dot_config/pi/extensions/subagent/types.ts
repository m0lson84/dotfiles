import type { AgentToolResult, ThinkingLevel } from "@earendil-works/pi-agent-core";
import type { Message } from "@earendil-works/pi-ai";
import type { AgentScope } from "./agents.ts";

/** Per-child display counters, including the latest assistant context size and accumulated turns. */
export interface UsageStats {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  contextTokens: number;
  turns: number;
}

/** Mutable child execution result; exit code -1 denotes a task still running in progress updates. */
export interface SingleResult {
  agent: string;
  agentSource: "user" | "project" | "unknown";
  task: string;
  exitCode: number;
  messages: Message[];
  stderr: string;
  usage: UsageStats;
  model?: string;
  stopReason?: string;
  errorMessage?: string;
  step?: number;
}

/** Structured dispatch details retained for streaming updates, rendering, and full output access. */
export interface SubagentDetails {
  mode: "single" | "parallel" | "chain";
  agentScope: AgentScope;
  projectAgentsDir: string | null;
  results: SingleResult[];
}

/** Callback receiving a partial model-facing result and its current child details. */
export type OnUpdateCallback = (partial: AgentToolResult<SubagentDetails>) => void;

/** Parent model and thinking settings used when an agent does not override its model. */
export interface DispatchDefaults {
  model?: string;
  thinkingLevel?: ThinkingLevel;
}
