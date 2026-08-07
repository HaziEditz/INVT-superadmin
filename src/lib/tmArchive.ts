/**
 * TM soft-delete / archive helpers (status-based, recoverable).
 */

export const STATUS_ARCHIVED = 'archived';

export function isArchivedStatus(status: string | null | undefined): boolean {
  return String(status || '').trim().toLowerCase() === STATUS_ARCHIVED;
}

export type ArchiveActor = string;

export function archivePatch(
  fromStatus: string | null | undefined,
  by: ArchiveActor,
  note?: string | null,
): Record<string, unknown> {
  const prior = String(fromStatus || 'submitted').trim().toLowerCase() || 'submitted';
  const safeFrom = prior === STATUS_ARCHIVED ? 'submitted' : prior;
  const patch: Record<string, unknown> = {
    status: STATUS_ARCHIVED,
    archivedAt: Date.now(),
    archivedBy: by || 'unknown',
    archivedFromStatus: safeFrom,
  };
  const n = note != null ? String(note).trim() : '';
  if (n) patch.archiveNote = n;
  else patch.archiveNote = null;
  return patch;
}

export function restorePatch(st: {
  archivedFromStatus?: string | null;
  status?: string | null;
} | null | undefined): Record<string, unknown> {
  const from = String(st?.archivedFromStatus || 'submitted').trim().toLowerCase() || 'submitted';
  const restoreTo = from === STATUS_ARCHIVED ? 'submitted' : from;
  return {
    status: restoreTo,
    archivedAt: null,
    archivedBy: null,
    archivedFromStatus: null,
    archiveNote: null,
    restoredAt: Date.now(),
  };
}
