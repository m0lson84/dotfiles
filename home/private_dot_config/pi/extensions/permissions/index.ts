import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type PermissionRule = {
  tool: string;
  resource: string;
  effect: "allow" | "deny";
};

const permissions: PermissionRule[] = [
  { tool: "bash", resource: "git *", effect: "deny" },
  { tool: "bash", resource: "git (status|diff|log|show|ls-files|rev-parse) *", effect: "allow" },
];

// Add tool input fields here when extending the policy to other tools.
const resourceFields: Record<string, string> = {
  bash: "command",
  read: "path",
  edit: "path",
  write: "path",
};

function escapeLiteral(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

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

export default function permissionsExtension(pi: ExtensionAPI): void {
  pi.on("tool_call", (event) => {
    if (!Object.hasOwn(resourceFields, event.toolName)) return;
    const field = resourceFields[event.toolName];
    const input = event.input as Record<string, unknown>;
    const value = input[field];
    if (typeof value !== "string") {
      throw new Error(`Cannot check permissions: ${event.toolName}.${field} must be a string.`);
    }

    const resource = event.toolName === "bash" ? value.trim() : value;
    const rule = permissions.findLast((rule) => matches(rule.tool, event.toolName) && matches(rule.resource, resource));
    if (rule?.effect === "deny") {
      return {
        block: true,
        reason: `Permission denied: ${event.toolName} matches "${rule.resource}".`,
      };
    }
  });
}
