/**
 * Agent discovery and configuration
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { CONFIG_DIR_NAME, getAgentDir, parseFrontmatter } from "@earendil-works/pi-coding-agent";

/** Agent directories included in discovery; project definitions override user names in both scope. */
export type AgentScope = "user" | "project" | "both";

/** Validated agent metadata, prompt body, and source location. */
export interface AgentConfig {
  name: string;
  description: string;
  tools?: string[];
  model?: string;
  systemPrompt: string;
  source: "user" | "project";
  filePath: string;
}

/** Discovered agents and the nearest project agents directory, if present. */
export interface AgentDiscoveryResult {
  agents: AgentConfig[];
  projectAgentsDir: string | null;
}

/**
 * Raw agent frontmatter. Values are `unknown` because `parseFrontmatter` runs a
 * real YAML parser, so any scalar or collection can appear here.
 *
 * A type alias rather than an interface: `parseFrontmatter` constrains its
 * parameter to `Record<string, unknown>`, and only an alias picks up the
 * implicit index signature that satisfies it.
 */
type AgentFrontmatter = {
  name?: unknown;
  description?: unknown;
  tools?: unknown;
  model?: unknown;
};

/**
 * Discover agents in the requested scope, merging names with project precedence in both scope.
 * @param cwd Working directory from which to search ancestors for project agents.
 * @param scope User, project, or combined discovery scope.
 * @returns Selected agents in discovery order and the nearest project agents directory.
 */
export function discoverAgents(cwd: string, scope: AgentScope): AgentDiscoveryResult {
  const userDir = path.join(getAgentDir(), "agents");
  const projectAgentsDir = findProjectDir(cwd);

  const userAgents = scope === "project" ? [] : loadAgentsFromDir(userDir, "user");
  const projectAgents = scope === "user" || !projectAgentsDir ? [] : loadAgentsFromDir(projectAgentsDir, "project");

  const agentMap = new Map<string, AgentConfig>();

  if (scope === "both") {
    for (const agent of userAgents) agentMap.set(agent.name, agent);
    for (const agent of projectAgents) agentMap.set(agent.name, agent);
  } else if (scope === "user") {
    for (const agent of userAgents) agentMap.set(agent.name, agent);
  } else {
    for (const agent of projectAgents) agentMap.set(agent.name, agent);
  }

  return { agents: Array.from(agentMap.values()), projectAgentsDir };
}

/**
 * Format a bounded list of agent names, sources, and descriptions.
 * @param agents Agents in the desired display order.
 * @param maxItems Maximum number of agents to include.
 * @returns List text and the count omitted, or none with zero remaining when empty.
 */
export function formatAgentList(agents: AgentConfig[], maxItems: number): { text: string; remaining: number } {
  if (agents.length === 0) return { text: "none", remaining: 0 };
  const listed = agents.slice(0, maxItems);
  const remaining = agents.length - listed.length;
  return {
    text: listed.map((a) => `${a.name} (${a.source}): ${a.description}`).join("; "),
    remaining,
  };
}

/**
 * Find the nearest agents directory while walking from the working directory to the filesystem root.
 * @param cwd Directory at which to begin the ancestor search.
 * @returns Nearest project agents directory, or null when none exists.
 */
function findProjectDir(cwd: string): string | null {
  let currentDir = cwd;
  while (true) {
    const candidate = path.join(currentDir, CONFIG_DIR_NAME, "agents");
    if (isDirectory(candidate)) return candidate;

    const parentDir = path.dirname(currentDir);
    if (parentDir === currentDir) return null;
    currentDir = parentDir;
  }
}

/**
 * Check whether a path resolves to an accessible directory.
 * @param p Path to inspect, following symlinks.
 * @returns Whether the path is a directory; false when inspection fails.
 */
function isDirectory(p: string): boolean {
  try {
    return fs.statSync(p).isDirectory();
  } catch {
    return false;
  }
}

/**
 * Read and parse one agent file, skipping unreadable files and invalid required metadata.
 * @param filePath Markdown file to read.
 * @param source User or project source assigned to the parsed agent.
 * @returns Agent configuration, or undefined when the file cannot be read or lacks string name/description fields.
 */
function loadAgent(filePath: string, source: "user" | "project"): AgentConfig | undefined {
  let content: string;
  try {
    content = fs.readFileSync(filePath, "utf-8");
  } catch {
    return;
  }

  const { frontmatter, body } = parseFrontmatter<AgentFrontmatter>(content);

  if (typeof frontmatter.name !== "string" || typeof frontmatter.description !== "string") {
    return;
  }

  return {
    name: frontmatter.name,
    description: frontmatter.description,
    tools: parseToolList(frontmatter.tools),
    model: typeof frontmatter.model === "string" ? frontmatter.model : undefined,
    systemPrompt: body,
    source,
    filePath,
  };
}

/**
 * Load Markdown agent files and symlinks from one directory without changing filesystem order.
 * @param dir Directory containing agent definitions.
 * @param source Source assigned to each loaded definition.
 * @returns Valid agents, or an empty list when the directory is absent or unreadable.
 */
function loadAgentsFromDir(dir: string, source: "user" | "project"): AgentConfig[] {
  const agents: AgentConfig[] = [];

  if (!fs.existsSync(dir)) {
    return agents;
  }

  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return agents;
  }

  for (const entry of entries) {
    if (!entry.name.endsWith(".md")) continue;
    if (!entry.isFile() && !entry.isSymbolicLink()) continue;

    const filePath = path.join(dir, entry.name);
    const agent = loadAgent(filePath, source);
    if (agent) agents.push(agent);
  }

  return agents;
}

/**
 * Normalize comma-separated or array-valued tool metadata, discarding nonstrings and blank names.
 * @param value Raw YAML frontmatter tools value.
 * @returns Trimmed tool names, or undefined when no valid names remain.
 */
function parseToolList(value: unknown): string[] | undefined {
  const raw = Array.isArray(value) ? value : typeof value === "string" ? value.split(",") : [];
  const tools = raw
    .filter((t): t is string => typeof t === "string")
    .map((t) => t.trim())
    .filter(Boolean);
  return tools.length > 0 ? tools : undefined;
}
