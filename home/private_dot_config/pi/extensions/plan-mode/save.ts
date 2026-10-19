import { constants } from "node:fs";
import { lstat, mkdir, open, realpath } from "node:fs/promises";
import { join } from "node:path";

/** Workspace-relative directory used for saved Markdown plans. */
export const PLAN_DIR = ".pi/plan";

/**
 * Create or replace a Markdown plan beneath the resolved workspace's plan directory.
 * Directory components must be real directories, and the opened file must be regular with one hard link.
 * The final file is opened without following symlinks and checked before its contents are truncated.
 * @param cwd Workspace directory, resolved to its real path before creating directories or opening the file.
 * @param filename Markdown filename ending in .md, without path separators or null bytes.
 * @param content Complete plan contents; replaces any existing content rather than appending.
 */
export async function savePlan(cwd: string, filename: string, content: string): Promise<void> {
  if (!filename.endsWith(".md") || /[/\\\0]/.test(filename)) {
    throw new Error("Cannot save plan: filename must end in .md and contain no directory separators or null bytes.");
  }

  const workspace = await realpath(cwd);
  await createDir(workspace);

  const file = await open(
    join(workspace, PLAN_DIR, filename),
    constants.O_WRONLY | constants.O_CREAT | constants.O_NOFOLLOW | constants.O_NONBLOCK,
    0o666,
  );

  try {
    const stat = await file.stat();
    if (!stat.isFile() || stat.nlink !== 1) {
      throw new Error(`Cannot save plan: ${PLAN_DIR}/${filename} must be a regular file without hard links.`);
    }
    await file.truncate(0);
    await file.writeFile(content, "utf8");
  } finally {
    await file.close();
  }
}

/**
 * Create missing plan-directory components and reject existing symlinks or non-directory entries.
 * @param workspace Resolved workspace path beneath which .pi and the plan directory are checked.
 */
async function createDir(workspace: string): Promise<void> {
  for (const directory of [".pi", PLAN_DIR]) {
    const path = join(workspace, directory);
    try {
      await mkdir(path);
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== "EEXIST") throw error;
    }

    if (!(await lstat(path)).isDirectory()) {
      throw new Error(`Cannot save plan: ${directory}/ must be a real directory, not a symlink.`);
    }
  }
}
