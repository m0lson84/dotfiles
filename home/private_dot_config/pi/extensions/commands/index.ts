import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { exit } from "./exit.ts";
import { undo } from "./undo.ts";

/**
 * Register the extension's user-facing commands.
 * @param pi Extension API used to register command handlers.
 */
export default function commandsExtension(pi: ExtensionAPI): void {
  pi.registerCommand("exit", {
    description: "Quit Pi",
    handler: exit,
  });

  pi.registerCommand("undo", {
    description: "Rewind the latest user turn and restore its prompt text (files unchanged)",
    handler: undo,
  });
}
