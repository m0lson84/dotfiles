import type { AgentToolResult } from "@earendil-works/pi-agent-core";
import type { Static } from "typebox";
import type { AgentConfig } from "./agents.ts";
import { getFinalOutput, getResultOutput, isFailed } from "./results.ts";
import { runAgent } from "./runner.ts";
import type { SubagentParams } from "./schema.ts";
import type { DispatchDefaults, OnUpdateCallback, SingleResult, SubagentDetails } from "./types.ts";
import { getUsage } from "./usage.ts";

/** Execution context shared by the single, parallel, and chained workflows. */
export interface DispatchOptions {
  defaultCwd: string;
  dispatchDefaults: DispatchDefaults;
  agents: AgentConfig[];
  signal?: AbortSignal;
  onUpdate?: OnUpdateCallback;
  makeDetails: (results: SingleResult[]) => SubagentDetails;
}

/** One task's agent, prompt, and optional working directory, derived from the tool schema. */
type Task = NonNullable<Static<typeof SubagentParams>["tasks"]>[number];

/** Maximum accepted tasks in one parallel dispatch. */
const MAX_PARALLEL_TASKS = 8;
/** Maximum number of child tasks running concurrently. */
const MAX_CONCURRENCY = 4;
/** UTF-8 byte limit for each parallel task's model-facing output; details retain full results. */
const PER_TASK_OUTPUT_CAP = 50 * 1024;

/**
 * Run tasks sequentially, substitute prior output, and stop on the first failed result.
 * @param steps Ordered chain steps; {previous} is replaced with the preceding step's final output.
 * @param options Child execution defaults, discovered agents, cancellation, updates, and detail construction.
 * @returns Model-facing output, full child results, aggregated usage, and any dispatch error status.
 */
export async function runChain(steps: Task[], options: DispatchOptions): Promise<AgentToolResult<SubagentDetails>> {
  const { defaultCwd, dispatchDefaults, agents, signal, onUpdate, makeDetails } = options;
  const results: SingleResult[] = [];
  let previousOutput = "";

  for (let i = 0; i < steps.length; i++) {
    const step = steps[i];
    const taskWithContext = step.task.replace(/\{previous\}/g, previousOutput);

    // Keep completed steps visible while the current child streams updates.
    const chainUpdate: OnUpdateCallback | undefined = onUpdate
      ? (partial) => {
          const currentResult = partial.details?.results[0];
          if (currentResult) {
            const allResults = [...results, currentResult];
            onUpdate({
              content: partial.content,
              details: makeDetails(allResults),
            });
          }
        }
      : undefined;

    const result = await runAgent({
      defaultCwd,
      dispatchDefaults,
      agents,
      agentName: step.agent,
      task: taskWithContext,
      cwd: step.cwd,
      step: i + 1,
      signal,
      onUpdate: chainUpdate,
      makeDetails,
    });
    results.push(result);

    const isError = isFailed(result);
    if (isError) {
      const errorMsg = getResultOutput(result);
      return {
        content: [{ type: "text", text: `Chain stopped at step ${i + 1} (${step.agent}): ${errorMsg}` }],
        details: makeDetails(results),
        usage: getUsage(results),
        isError: true,
      };
    }
    previousOutput = getFinalOutput(result.messages);
  }
  return {
    content: [{ type: "text", text: getFinalOutput(results[results.length - 1].messages) || "(no output)" }],
    details: makeDetails(results),
    usage: getUsage(results),
  };
}

/**
 * Run bounded concurrent tasks, preserving input order and streaming stable progress snapshots.
 * @param tasks Tasks to dispatch, subject to the parallel task limit.
 * @param options Child execution defaults, discovered agents, cancellation, updates, and detail construction.
 * @returns Model-facing output, full child results, aggregated usage, and any dispatch error status.
 */
export async function runParallel(tasks: Task[], options: DispatchOptions): Promise<AgentToolResult<SubagentDetails>> {
  const { defaultCwd, dispatchDefaults, agents, signal, onUpdate, makeDetails } = options;
  if (tasks.length > MAX_PARALLEL_TASKS)
    return {
      content: [
        {
          type: "text",
          text: `Too many parallel tasks (${tasks.length}). Max is ${MAX_PARALLEL_TASKS}.`,
        },
      ],
      details: makeDetails([]),
      isError: true,
    };

  // Keep task order stable as children complete concurrently.
  const allResults: SingleResult[] = new Array(tasks.length);
  for (let i = 0; i < tasks.length; i++) {
    allResults[i] = {
      agent: tasks[i].agent,
      agentSource: "unknown",
      task: tasks[i].task,
      exitCode: -1, // -1 = still running
      messages: [],
      stderr: "",
      usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
    };
  }

  const emitParallelUpdate = () => {
    if (onUpdate) {
      const running = allResults.filter((r) => r.exitCode === -1).length;
      const done = allResults.filter((r) => r.exitCode !== -1).length;
      onUpdate({
        content: [{ type: "text", text: `Parallel: ${done}/${allResults.length} done, ${running} running...` }],
        details: makeDetails([...allResults]),
      });
    }
  };

  const results = await mapConcurrent(tasks, MAX_CONCURRENCY, async (t, index) => {
    const result = await runAgent({
      defaultCwd,
      dispatchDefaults,
      agents,
      agentName: t.agent,
      task: t.task,
      cwd: t.cwd,
      signal,
      onUpdate: (partial) => {
        if (partial.details?.results[0]) {
          allResults[index] = partial.details.results[0];
          emitParallelUpdate();
        }
      },
      makeDetails,
    });
    allResults[index] = result;
    emitParallelUpdate();
    return result;
  });

  const successCount = results.filter((r) => !isFailed(r)).length;
  const summaries = results.map((r) => {
    const output = truncateParallelOutput(getResultOutput(r));
    const status = isFailed(r)
      ? `failed${r.stopReason && r.stopReason !== "end" ? ` (${r.stopReason})` : ""}`
      : "completed";
    return `### [${r.agent}] ${status}\n\n${output}`;
  });
  return {
    content: [
      {
        type: "text",
        text: `Parallel: ${successCount}/${results.length} succeeded\n\n${summaries.join("\n\n---\n\n")}`,
      },
    ],
    details: makeDetails(results),
    usage: getUsage(results),
    isError: successCount === 0,
  };
}

/**
 * Run one child agent and format its success or failure for the parent.
 * @param task Agent, task prompt, and optional child working directory.
 * @param options Child execution defaults, discovered agents, cancellation, updates, and detail construction.
 * @returns Model-facing output, full child results, aggregated usage, and any dispatch error status.
 */
export async function runSingle(task: Task, options: DispatchOptions): Promise<AgentToolResult<SubagentDetails>> {
  const { defaultCwd, dispatchDefaults, agents, signal, onUpdate, makeDetails } = options;
  const result = await runAgent({
    defaultCwd,
    dispatchDefaults,
    agents,
    agentName: task.agent,
    task: task.task,
    cwd: task.cwd,
    signal,
    onUpdate,
    makeDetails,
  });
  const isError = isFailed(result);
  if (isError) {
    const errorMsg = getResultOutput(result);
    return {
      content: [{ type: "text", text: `Agent ${result.stopReason || "failed"}: ${errorMsg}` }],
      details: makeDetails([result]),
      usage: getUsage([result]),
      isError: true,
    };
  }
  return {
    content: [{ type: "text", text: getFinalOutput(result.messages) || "(no output)" }],
    details: makeDetails([result]),
    usage: getUsage([result]),
  };
}

/**
 * Map tasks with bounded concurrency while retaining their original result order.
 * @param items Inputs to process.
 * @param concurrency Maximum simultaneous workers, clamped to at least one.
 * @param fn Asynchronous operation receiving each input and its original index.
 * @returns Results in input order once every worker completes.
 */
async function mapConcurrent<TIn, TOut>(
  items: TIn[],
  concurrency: number,
  fn: (item: TIn, index: number) => Promise<TOut>,
): Promise<TOut[]> {
  if (items.length === 0) return [];
  const limit = Math.max(1, Math.min(concurrency, items.length));
  const results: TOut[] = new Array(items.length);
  let nextIndex = 0;
  const workers = new Array(limit).fill(null).map(async () => {
    while (true) {
      const current = nextIndex++;
      if (current >= items.length) return;
      results[current] = await fn(items[current], current);
    }
  });
  await Promise.all(workers);
  return results;
}

/**
 * Cap model-facing parallel output by UTF-8 byte length without changing stored details.
 * @param output Full task output.
 * @returns Original output or a truncated prefix followed by an omitted-byte notice.
 */
function truncateParallelOutput(output: string): string {
  const byteLength = Buffer.byteLength(output, "utf8");
  if (byteLength <= PER_TASK_OUTPUT_CAP) return output;

  let truncated = output.slice(0, PER_TASK_OUTPUT_CAP);
  while (Buffer.byteLength(truncated, "utf8") > PER_TASK_OUTPUT_CAP) {
    truncated = truncated.slice(0, -1);
  }
  return `${truncated}\n\n[Output truncated: ${byteLength - Buffer.byteLength(truncated, "utf8")} bytes omitted. Full output preserved in tool details.]`;
}
