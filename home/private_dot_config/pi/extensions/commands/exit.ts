import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

/**
 * Quit Pi gracefully, allowing shutdown hooks and cleanup to run.
 * @param _args Command arguments; unused.
 * @param ctx Context for the current command execution.
 */
export async function exit(_args: string, ctx: ExtensionCommandContext): Promise<void> {
  ctx.shutdown();
}
