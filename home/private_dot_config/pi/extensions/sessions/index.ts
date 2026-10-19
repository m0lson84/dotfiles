import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { generateTitle } from "./naming.ts";

/**
 * Register background title generation for the first user prompt of a new, unnamed session.
 * @param pi Extension API used to observe lifecycle events and read or set the session name.
 */
export default function sessionsExtension(pi: ExtensionAPI): void {
  let namingEligible = false;
  let pendingNaming: AbortController | undefined;

  /** Abort and clear any pending title request without changing session eligibility. */
  function cancelNaming(): void {
    pendingNaming?.abort();
    pendingNaming = undefined;
  }

  /**
   * Generate and apply a title only if the request still belongs to the current unnamed session.
   * Naming failures are ignored, and completion clears only this request's pending controller.
   * @param prompt First user prompt to summarize.
   * @param ctx Session context providing the model runtime and session identity.
   * @param controller Controller identifying this request among pending or superseding requests.
   * @param signal Combined cancellation and timeout signal, independent of the agent's turn signal.
   */
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
    } finally {
      if (pendingNaming === controller) pendingNaming = undefined;
    }
  }

  pi.on("session_start", (_event, ctx) => {
    cancelNaming();
    namingEligible =
      !pi.getSessionName() &&
      !ctx.sessionManager.getEntries().some((entry) => entry.type === "message" && entry.message.role === "user");
  });

  pi.on("session_shutdown", () => {
    namingEligible = false;
    cancelNaming();
  });

  pi.on("before_agent_start", (event, ctx) => {
    if (event.messageType !== "user" || !namingEligible) return;
    namingEligible = false;
    if (pi.getSessionName() || !ctx.model || !event.prompt.trim()) return;

    const controller = new AbortController();
    pendingNaming = controller;
    const signal = AbortSignal.any([controller.signal, AbortSignal.timeout(30_000)]);

    void nameSession(event.prompt, ctx, controller, signal);
  });
}
