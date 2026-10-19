import type { ExtensionAPI, ToolCallEvent } from "@earendil-works/pi-coding-agent";

/** A permissions rule for tool usage. */
type PermissionRule = {
  /** The effected tool. */
  tool: string;
  /** The resource / operation to be performed. */
  resource: string;
  /** The effect for the rule. */
  effect: "allow" | "deny";
};

/**
 * Ordered permission rules.
 * The last match wins, and unmatched calls proceed.
 */
const permissions: PermissionRule[] = [
  { tool: "bash", resource: "git *", effect: "deny" },
  { tool: "bash", resource: "git (status|diff|log|show|ls-files|rev-parse) *", effect: "allow" },
];

/**
 * Input fields checked for each supported tool.
 * Tools absent from this table are ignored.
 */
const resourceFields: Record<string, string> = {
  bash: "command",
  read: "path",
  edit: "path",
  write: "path",
};

/**
 * Register permission checks for tool calls using the configured resource fields and rules.
 * @param pi Extension API used to register the tool-call hook.
 */
export default function permissionsExtension(pi: ExtensionAPI): void {
  pi.on("tool_call", (event) => {
    const resource = getResource(event);
    if (resource === undefined) return;

    const rule = permissions.findLast((rule) => matches(rule.tool, event.toolName) && matches(rule.resource, resource));
    if (rule?.effect === "deny") {
      return {
        block: true,
        reason: `Permission denied: ${event.toolName} matches "${rule.resource}".`,
      };
    }
  });
}

/**
 * Escape regular-expression metacharacters so a pattern fragment is matched literally.
 * @param value Literal text to include in a regular expression.
 * @returns The text with regular-expression metacharacters escaped.
 */
function escapeLiteral(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

/**
 * Read the configured resource field, trimming surrounding whitespace only for Bash commands.
 * @param event Tool call whose configured input field must contain a string.
 * @returns The resource string, or undefined when the tool has no configured resource field.
 */
function getResource(event: ToolCallEvent): string | undefined {
  if (!Object.hasOwn(resourceFields, event.toolName)) return;
  const field = resourceFields[event.toolName];
  const input = event.input as Record<string, unknown>;
  const value = input[field];
  if (typeof value !== "string") {
    throw new Error(`Cannot check permissions: ${event.toolName}.${field} must be a string.`);
  }

  return event.toolName === "bash" ? value.trim() : value;
}

/**
 * Match an entire value using *, parenthesized literal alternatives, and optional trailing arguments.
 * A trailing " *" also matches when no arguments follow; all other text is matched literally.
 * @param pattern Permission pattern to match against the value.
 * @param value Tool name or resource string to check.
 * @returns Whether the complete value matches the pattern, including across line breaks.
 */
function matches(pattern: string, value: string): boolean {
  const optionalArguments = pattern.endsWith(" *");
  const body = optionalArguments ? pattern.slice(0, -2) : pattern;
  const expression = body
    .split(/(\([^()]*\)|\*)/u)
    .map((part) => {
      if (part === "*") return ".*";
      if (part.startsWith("(") && part.endsWith(")")) {
        return `(?:${part.slice(1, -1).split("|").map(escapeLiteral).join("|")})`;
      }
      return escapeLiteral(part);
    })
    .join("");

  return new RegExp(`^${expression}${optionalArguments ? "(?: .*)?" : ""}$`, "su").test(value);
}
