import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { JsonAgentSessionEvent } from "@earendil-works/pi-coding-agent";
import { withFileMutationQueue } from "@earendil-works/pi-coding-agent";
import type { AgentConfig } from "./agents.ts";
import { getFinalOutput } from "./results.ts";
import type { DispatchDefaults, OnUpdateCallback, SingleResult, SubagentDetails } from "./types.ts";

async function writePrompt(agentName: string, prompt: string): Promise<{ dir: string; filePath: string }> {
  const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-subagent-"));
  const safeName = agentName.replace(/[^\w.-]+/g, "_");
  const filePath = path.join(tmpDir, `prompt-${safeName}.md`);
  await withFileMutationQueue(filePath, async () => {
    await fs.promises.writeFile(filePath, prompt, { encoding: "utf-8", mode: 0o600 });
  });
  return { dir: tmpDir, filePath };
}

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

  const args: string[] = ["--mode", "json", "-p", "--no-session"];
  const inheritsModel = !agent.model;
  const model = agent.model ?? dispatchDefaults.model;
  if (model) args.push("--model", model);
  if (inheritsModel && dispatchDefaults.thinkingLevel) {
    args.push("--thinking", dispatchDefaults.thinkingLevel);
  }
  if (agent.tools && agent.tools.length > 0) args.push("--tools", agent.tools.join(","));

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

  const emitUpdate = () => {
    if (onUpdate) {
      onUpdate({
        content: [{ type: "text", text: getFinalOutput(currentResult.messages) || "(running...)" }],
        details: makeDetails([currentResult]),
      });
    }
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
    let wasAborted = false;

    const exitCode = await new Promise<number>((resolve) => {
      const invocation = getPiInvocation(args);
      const proc = spawn(invocation.command, invocation.args, {
        cwd: cwd ?? defaultCwd,
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

      const processLine = (line: string) => {
        if (!line.trim()) return;
        let event: JsonAgentSessionEvent;
        try {
          event = JSON.parse(line);
        } catch {
          return;
        }

        if (event.type === "message_end" && event.message) {
          const msg = event.message as Message;
          currentResult.messages.push(msg);

          if (msg.role === "assistant" || msg.role === "toolResult") {
            const usage = msg.usage;
            if (usage) {
              currentResult.usage.input += usage.input;
              currentResult.usage.output += usage.output;
              currentResult.usage.cacheRead += usage.cacheRead;
              currentResult.usage.cacheWrite += usage.cacheWrite;
              currentResult.usage.cost += usage.cost.total;
            }
          }
          if (msg.role === "assistant") {
            currentResult.usage.turns++;
            currentResult.usage.contextTokens = msg.usage?.totalTokens ?? 0;
            if (!currentResult.model && msg.model) currentResult.model = msg.model;
            if (msg.stopReason) currentResult.stopReason = msg.stopReason;
            if (msg.errorMessage) currentResult.errorMessage = msg.errorMessage;
          }
          emitUpdate();
        }
      };

      proc.stdout.setEncoding("utf8");
      proc.stderr.setEncoding("utf8");
      proc.stdout.on("data", (data: string) => {
        buffer += data;
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";
        for (const line of lines) processLine(line);
      });

      proc.stderr.on("data", (data: string) => {
        currentResult.stderr += data;
      });

      proc.once("exit", () => {
        exited = true;
        cleanup();
      });
      proc.once("close", (code, exitSignal) => {
        exited = true;
        cleanup();
        if (buffer.trim()) processLine(buffer);
        if (exitSignal && !wasAborted) currentResult.errorMessage = `Subagent terminated by ${exitSignal}.`;
        resolve(code ?? 1);
      });
      proc.on("error", (error) => {
        currentResult.errorMessage = error.message;
        if (proc.pid === undefined) {
          exited = true;
          cleanup();
          resolve(1);
        }
      });

      if (signal?.aborted) killProc();
      else signal?.addEventListener("abort", killProc, { once: true });
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
