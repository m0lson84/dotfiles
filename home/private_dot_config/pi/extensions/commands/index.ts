import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { undo } from "./undo.ts";

export default function commandsExtension(pi: ExtensionAPI): void {
  pi.registerCommand("undo", {
    description: "Rewind the latest user turn and restore its prompt text (files unchanged)",
    handler: undo,
  });
}
