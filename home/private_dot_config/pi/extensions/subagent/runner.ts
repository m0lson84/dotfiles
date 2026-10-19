import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { Message } from "@earendil-works/pi-ai";
import type { JsonAgentSessionEvent } from "@earendil-works/pi-coding-agent";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import type { AgentConfig } from "./agents.ts";
import { getFinalOutput } from "./results.ts";
import type { DispatchDefaults, OnUpdateCallback, SingleResult, SubagentDetails } from "./types.ts";

/** Agent selection, execution defaults, task context, and streaming-result callbacks. */
interface RunOptions {
  defaultCwd: string;
  dispatchDefaults: DispatchDefaults;
  agents: AgentConfig[];
  agentName: string;
  task: string;
  cwd?: string;
  step?: number;
  signal?: AbortSignal;
  onUpdate?: OnUpdateCallback;
  makeDetails: (results: SingleResult[]) => SubagentDetails;
}

/** Process inputs and the mutable result updated as child events arrive. */
interface ProcessOptions {
  args: string[];
  cwd: string;
  result: SingleResult;
  signal?: AbortSignal;
  onUpdate?: OnUpdateCallback;
  makeDetails: RunOptions["makeDetails"];
}

/**
 * Run one discovered agent in an isolated child process and clean up its temporary prompt file.
 * @param options Agent selection, task, process defaults, cancellation, and result callbacks.
 * @returns The completed child result, or a structured unknown-agent or pre-aborted result.
 */
export async function runAgent({
  defaultCwd,
  dispatchDefaults,
  agents,
  agentName,
  task,
  cwd,
  step,
  signal,
  onUpdate,
  makeDetails,
}: RunOptions): Promise<SingleResult> {
  const agent = agents.find((a) => a.name === agentName);

  if (!agent) {
    const available = agents.map((a) => `"${a.name}"`).join(", ") || "none";
    return {
      agent: agentName,
      agentSource: "unknown",
      task,
      exitCode: 1,
      messages: [],
      stderr: `Unknown agent: "${agentName}". Available agents: ${available}.`,
      usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
      step,
    };
  }

  const { args, model } = getArgs(agent, dispatchDefaults);

  let tmpPromptDir: string | null = null;
  let tmpPromptPath: string | null = null;

  const currentResult: SingleResult = {
    agent: agentName,
    agentSource: agent.source,
    task,
    exitCode: -1,
    messages: [],
    stderr: "",
    usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
    model,
    step,
  };

  try {
    if (!signal?.aborted && agent.systemPrompt.trim()) {
      const tmp = await writePrompt(agent.name, agent.systemPrompt);
      tmpPromptDir = tmp.dir;
      tmpPromptPath = tmp.filePath;
      args.push("--append-system-prompt", tmpPromptPath);
    }

    if (signal?.aborted) {
      return { ...currentResult, exitCode: 1, stopReason: "aborted", errorMessage: "Subagent was aborted." };
    }
    args.push(`Task: ${task}`);
    const { exitCode, wasAborted } = await runProcess({
      args,
      cwd: cwd ?? defaultCwd,
      result: currentResult,
      signal,
      onUpdate,
      makeDetails,
    });

    currentResult.exitCode = exitCode;
    if (wasAborted) {
      currentResult.stopReason = "aborted";
      currentResult.errorMessage = "Subagent was aborted.";
    }
    return currentResult;
  } finally {
    if (tmpPromptPath)
      try {
        fs.unlinkSync(tmpPromptPath);
      } catch {
        /* ignore */
      }
    if (tmpPromptDir)
      try {
        fs.rmdirSync(tmpPromptDir);
      } catch {
        /* ignore */
      }
  }
}

/**
 * Build child CLI arguments, inheriting thinking level only when the agent inherits the model.
 * @param agent Agent configuration controlling model and tool overrides.
 * @param defaults Parent model and thinking defaults.
 * @returns Base CLI arguments and the selected model, before prompt-file and task arguments are appended.
 */
function getArgs(agent: AgentConfig, defaults: DispatchDefaults): { args: string[]; model: string | undefined } {
  const args: string[] = ["--mode", "json", "-p", "--no-session"];
  const inheritsModel = !agent.model;
  const model = agent.model ?? defaults.model;
  if (model) args.push("--model", model);
  if (inheritsModel && defaults.thinkingLevel) {
    args.push("--thinking", defaults.thinkingLevel);
  }
  if (agent.tools && agent.tools.length > 0) args.push("--tools", agent.tools.join(","));

  return { args, model };
}

/**
 * Select the current Pi executable, supporting script, bundled runtime, and PATH fallback forms.
 * @param args Child CLI arguments.
 * @returns Executable command and its complete argument list.
 */
function getPiInvocation(args: string[]): { command: string; args: string[] } {
  const currentScript = process.argv[1];
  const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
  if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
    return { command: process.execPath, args: [currentScript, ...args] };
  }

  const execName = path.basename(process.execPath).toLowerCase();
  const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
  if (!isGenericRuntime) {
    return { command: process.execPath, args };
  }

  return { command: "pi", args };
}

/**
 * Parse one JSON output line and publish finalized messages with their accumulated result.
 * Non-JSON, blank, and unrelated event lines are ignored.
 * @param line Complete child stdout line.
 * @param result Mutable result collecting finalized messages and usage.
 * @param onUpdate Optional callback receiving the current output and result details.
 * @param makeDetails Detail constructor for the current dispatch mode.
 */
function processLine(
  line: string,
  result: SingleResult,
  onUpdate: OnUpdateCallback | undefined,
  makeDetails: RunOptions["makeDetails"],
): void {
  if (!line.trim()) return;
  let event: JsonAgentSessionEvent;
  try {
    event = JSON.parse(line);
  } catch {
    return;
  }

  if (event.type === "message_end" && event.message) {
    recordMessage(event.message as Message, result);
    if (onUpdate) {
      onUpdate({
        content: [{ type: "text", text: getFinalOutput(result.messages) || "(running...)" }],
        details: makeDetails([result]),
      });
    }
  }
}

/**
 * Record a finalized child message and update token, cost, model, and stop metadata.
 * @param msg Finalized child message.
 * @param result Mutable child result receiving the message and usage.
 */
function recordMessage(msg: Message, result: SingleResult): void {
  result.messages.push(msg);

  if (msg.role === "assistant" || msg.role === "toolResult") {
    const usage = msg.usage;
    if (usage) {
      result.usage.input += usage.input;
      result.usage.output += usage.output;
      result.usage.cacheRead += usage.cacheRead;
      result.usage.cacheWrite += usage.cacheWrite;
      result.usage.cost += usage.cost.total;
    }
  }
  if (msg.role === "assistant") {
    result.usage.turns++;
    result.usage.contextTokens = msg.usage?.totalTokens ?? 0;
    if (!result.model && msg.model) result.model = msg.model;
    if (msg.stopReason) result.stopReason = msg.stopReason;
    if (msg.errorMessage) result.errorMessage = msg.errorMessage;
  }
}

/**
 * Spawn the child, buffer JSON lines and stderr, and manage cancellation and process cleanup.
 * @param options Process arguments, working directory, mutable result, cancellation, and callbacks.
 * @returns Exit code and whether cancellation initiated process termination.
 */
function runProcess({
  args,
  cwd,
  result,
  signal,
  onUpdate,
  makeDetails,
}: ProcessOptions): Promise<{ exitCode: number; wasAborted: boolean }> {
  let wasAborted = false;

  return new Promise((resolve) => {
    const invocation = getPiInvocation(args);
    const proc = spawn(invocation.command, invocation.args, {
      cwd,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let buffer = "";
    let exited = false;
    let killTimer: ReturnType<typeof setTimeout> | undefined;

    const cleanup = () => {
      if (killTimer) clearTimeout(killTimer);
      signal?.removeEventListener("abort", killProc);
    };
    const killProc = () => {
      if (exited) return;
      wasAborted = true;
      proc.kill("SIGTERM");
      killTimer = setTimeout(() => {
        if (!exited) proc.kill("SIGKILL");
      }, 5000);
    };

    proc.stdout.setEncoding("utf8");
    proc.stderr.setEncoding("utf8");
    proc.stdout.on("data", (data: string) => {
      buffer += data;
      const lines = buffer.split("\n");
      buffer = lines.pop() || "";
      for (const line of lines) processLine(line, result, onUpdate, makeDetails);
    });

    proc.stderr.on("data", (data: string) => {
      result.stderr += data;
    });

    proc.once("exit", () => {
      exited = true;
      cleanup();
    });
    proc.once("close", (code, exitSignal) => {
      exited = true;
      cleanup();
      if (buffer.trim()) processLine(buffer, result, onUpdate, makeDetails);
      if (exitSignal && !wasAborted) result.errorMessage = `Subagent terminated by ${exitSignal}.`;
      resolve({ exitCode: code ?? 1, wasAborted });
    });
    proc.on("error", (error) => {
      result.errorMessage = error.message;
      if (proc.pid === undefined) {
        exited = true;
        cleanup();
        resolve({ exitCode: 1, wasAborted });
      }
    });

    if (signal?.aborted) killProc();
    else signal?.addEventListener("abort", killProc, { once: true });
  });
}

/**
 * Write an agent's system prompt to a private temporary file through the file-mutation queue.
 * @param agentName Agent name used to form a sanitized filename.
 * @param prompt System prompt appended to the child's normal instructions.
 * @returns Temporary directory and prompt-file paths for invocation and later cleanup.
 */
async function writePrompt(agentName: string, prompt: string): Promise<{ dir: string; filePath: string }> {
  const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-subagent-"));
  const safeName = agentName.replace(/[^\w.-]+/g, "_");
  const filePath = path.join(tmpDir, `prompt-${safeName}.md`);
  await withFileMutationQueue(filePath, async () => {
    await fs.promises.writeFile(filePath, prompt, { encoding: "utf-8", mode: 0o600 });
  });
  return { dir: tmpDir, filePath };
}
