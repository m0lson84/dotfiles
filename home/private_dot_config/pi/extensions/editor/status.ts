import type { CustomEditor } from "@earendil-works/pi-coding-agent";

export type EditorWorkingStatus = Parameters<CustomEditor["setWorkingStatusIndicator"]>[0];
