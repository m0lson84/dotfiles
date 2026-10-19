import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { generateTitle } from "./naming.ts";

export default function sessionsExtension(pi: ExtensionAPI): void {
  let namingEligible = false;
  let pendingNaming: AbortController | undefined;

  async function nameSession(
    prompt: string,
    ctx: ExtensionContext,
    controller: AbortController,
    signal: AbortSignal,
  ): Promise<void> {
    const sessionId = ctx.sessionManager.getSessionId();
    try {
      const title = await generateTitle(prompt, ctx, signal);
      if (
        signal.aborted ||
        pendingNaming !== controller ||
        ctx.sessionManager.getSessionId() !== sessionId ||
        pi.getSessionName()
      ) {
        return;
      }
      if (title) pi.setSessionName(title);
    } catch {
      // Naming is best-effort; provider/auth failures must not interrupt the agent.
    } finally {
      if (pendingNaming === controller) pendingNaming = undefined;
    }
  }

  pi.on("session_start", (_event, ctx) => {
    pendingNaming?.abort();
    pendingNaming = undefined;
    // Never retroactively rename resumed sessions, including after /reload.
    namingEligible =
      !pi.getSessionName() &&
      !ctx.sessionManager.getEntries().some((entry) => entry.type === "message" && entry.message.role === "user");
  });

  pi.on("session_shutdown", () => {
    namingEligible = false;
    pendingNaming?.abort();
    pendingNaming = undefined;
  });

  pi.on("before_agent_start", (event, ctx) => {
    if (event.messageType !== "user" || !namingEligible) return;
    namingEligible = false;
    if (pi.getSessionName() || !ctx.model || !event.prompt.trim()) return;

    const controller = new AbortController();
    pendingNaming = controller;
    // Independent of the agent's turn signal: finishing/aborting a turn needn't cancel its title.
    const signal = AbortSignal.any([controller.signal, AbortSignal.timeout(30_000)]);

    // Don't await: naming must not delay the user's actual request.
    void nameSession(event.prompt, ctx, controller, signal);
  });
}
