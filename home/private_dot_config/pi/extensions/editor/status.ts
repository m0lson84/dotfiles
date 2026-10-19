import type { CustomEditor } from "@earendil-works/pi-coding-agent";

/**
 * Native editor working indicator, or undefined when no status is active.
 * Used by the panel's status callback and the editor:working-status event payload.
 * Derived from CustomEditor so the type stays aligned with Pi's indicator API.
 */
export type EditorWorkingStatus = Parameters<CustomEditor["setWorkingStatusIndicator"]>[0];
