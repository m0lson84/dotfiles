import type { ExtensionAPI, ToolRenderers } from "@earendil-works/pi-coding-agent";
import { createEditToolDefinition } from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";
import { CompactResult, NativeEditBody, OneLine, ToolFrame } from "./components.ts";
import { callLabel, plain, record } from "./formatting.ts";
import { getOutput, getPreview } from "./preview.ts";

/** Built-in tool names eligible for compact rendering unless another renderer owns its shell. */
const COMPACT_TOOLS = new Set(["read", "bash", "powershell", "edit", "write", "grep", "find", "ls", "codemode"]);

/**
 * Register compact tool rendering while preserving native delegation and self-rendering tools.
 * @param pi Extension API used to register the renderer resolver.
 */
export default function toolDisplayExtension(pi: ExtensionAPI): void {
  const nativeEdit = createEditToolDefinition(process.cwd());

  pi.registerToolRenderer((name, next) => {
    const original = next();
    const isNativeEdit =
      name === "edit" &&
      original?.renderShell === nativeEdit.renderShell &&
      original?.renderCall === nativeEdit.renderCall &&
      original?.renderResult === nativeEdit.renderResult;
    // Native edit owns its shell too; only decorate it when the renderer identities match.
    if (!COMPACT_TOOLS.has(name) || (original?.renderShell === "self" && !isNativeEdit)) return original;

    const renderers = {
      ...original,
      /**
       * Render compact labels or delegate expanded/native calls without reusing incompatible components.
       * @param args Tool-call arguments.
       * @param theme Current theme.
       * @param context Call state, expansion, error status, and output padding.
       * @returns A compact call component, expanded arguments, or the delegated native component.
       */
      renderCall(args, theme, context) {
        if ((isNativeEdit || context.expanded) && original?.renderCall) {
          // Our compact components must never be reused as a native renderer's Container/Text.
          const component = original.renderCall(args, theme, {
            ...context,
            outputPad: isNativeEdit ? 0 : context.outputPad,
            lastComponent: undefined,
          });
          return isNativeEdit && component instanceof Box
            ? new NativeEditBody(component, theme, context.expanded)
            : component;
        }
        const title = theme.fg(context.isError ? "error" : "toolTitle", theme.bold(name));
        if (context.expanded) {
          const argumentsText = name === "codemode" ? plain(record(args).code) : JSON.stringify(args, null, 2);
          return new Text(`${title}\n${theme.fg("toolOutput", argumentsText ?? "")}`, 0, 0);
        }
        return new OneLine(`${title}  ${theme.fg("accent", callLabel(name, record(args)))}`);
      },
      /**
       * Preserve native edit updates and expanded renderers, falling back to plain or compact output.
       * @param result Tool result to display.
       * @param options Expansion and partial-result options.
       * @param theme Current theme.
       * @param context Result state, parent error status, duration, and output padding.
       * @returns The delegated result component or a fallback output component.
       */
      renderResult(result, options, theme, context) {
        // Native edit's result updates the diff held by its call component, even when collapsed.
        if ((isNativeEdit || options.expanded) && original?.renderResult) {
          return original.renderResult(result, options, theme, {
            ...context,
            outputPad: isNativeEdit ? 0 : context.outputPad,
            lastComponent: undefined,
          });
        }

        const data = getOutput(name, result, context.isError);
        if (options.expanded) return new Text(theme.fg(data.isError ? "error" : "toolOutput", data.output), 0, 0);
        return new CompactResult(getPreview(name, data, options, theme, context), theme);
      },
    } satisfies ToolRenderers;
    return {
      renderShell: "self",
      /**
       * Frame the selected call component without a closing border.
       * @param args Tool-call arguments.
       * @param theme Current theme.
       * @param context Call state and output padding.
       * @returns A framed call component.
       */
      renderCall(args, theme, context) {
        return new ToolFrame(renderers.renderCall(args, theme, context), theme, context.outputPad, "call", false);
      },
      /**
       * Frame the selected result component, closing the border only for completed results.
       * @param result Tool result to display.
       * @param options Expansion and partial-result options.
       * @param theme Current theme.
       * @param context Result state and output padding.
       * @returns A framed result component.
       */
      renderResult(result, options, theme, context) {
        return new ToolFrame(
          renderers.renderResult(result, options, theme, context),
          theme,
          context.outputPad,
          "result",
          !options.isPartial,
        );
      },
    };
  });
}
