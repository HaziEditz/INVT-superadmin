/**
 * TM trip lifecycle event log helpers (append-only timeline).
 */

export type TripEventType =
  | 'submitted'
  | 'flagged'
  | 'returned'
  | 'owner_edited'
  | 'resubmitted'
  | 'approved'
  | 'rejected'
  | 'archived'
  | 'restored'
  | 'council_edited'
  | string;

export type TripEvent = {
  at: number;
  type: TripEventType;
  by?: string | null;
  byRole?: string | null;
  note?: string | null;
  reasons?: string[] | null;
  fromStatus?: string | null;
  toStatus?: string | null;
  fieldsChanged?: string[] | null;
};

export function buildTripEvent(
  type: TripEventType,
  opts?: Partial<Omit<TripEvent, 'type' | 'at'>> & { at?: number },
): TripEvent {
  return {
    at: opts?.at != null ? Number(opts.at) : Date.now(),
    type,
    by: opts?.by != null ? String(opts.by) : null,
    byRole: opts?.byRole != null ? String(opts.byRole) : null,
    note: opts?.note != null ? String(opts.note) : null,
    reasons: Array.isArray(opts?.reasons) ? opts!.reasons!.map(String) : null,
    fromStatus: opts?.fromStatus != null ? String(opts.fromStatus) : null,
    toStatus: opts?.toStatus != null ? String(opts.toStatus) : null,
    fieldsChanged: Array.isArray(opts?.fieldsChanged) ? opts!.fieldsChanged!.map(String) : null,
  };
}

export function newEventKey(now = Date.now()): string {
  return '-e' + now + '_' + Math.random().toString(36).slice(2, 7);
}

/** Best-effort timeline from legacy timestamp fields when events[] is empty. */
export function synthesizeEventsFromStatus(st: Record<string, any> | null | undefined): TripEvent[] {
  if (!st || typeof st !== 'object') return [];
  const out: TripEvent[] = [];
  const push = (type: TripEventType, at: unknown, extra?: Partial<TripEvent>) => {
    const n = Number(at);
    if (!Number.isFinite(n) || n <= 0) return;
    out.push(buildTripEvent(type, { at: n, ...extra }));
  };
  push('submitted', st.submittedAt, { by: st.submittedBy || null, byRole: 'sa_or_owner', toStatus: 'submitted' });
  push('flagged', st.flaggedAt, {
    byRole: 'system',
    toStatus: 'flagged',
    reasons: Array.isArray(st.flagReasons) ? st.flagReasons : null,
    note: st.anomalyDetail || null,
  });
  push('returned', st.sentBackAt, {
    by: st.sentBackBy || null,
    byRole: 'council_or_sa',
    toStatus: 'revision_needed',
    note: st.revisionNote || st.revisionNotes || null,
  });
  push('resubmitted', st.resubmittedAt, {
    by: st.resubmittedBy || null,
    byRole: 'owner',
    toStatus: 'submitted',
  });
  push('approved', st.approvedAt, { by: st.approvedBy || null, byRole: 'council', toStatus: 'approved' });
  push('rejected', st.rejectedAt, {
    by: st.rejectedBy || null,
    byRole: 'council',
    toStatus: 'rejected',
    note: st.rejectNote || null,
  });
  push('archived', st.archivedAt, {
    by: st.archivedBy || null,
    byRole: 'council_sa_or_owner',
    fromStatus: st.archivedFromStatus || null,
    toStatus: 'archived',
    note: st.archiveNote || null,
  });
  push('restored', st.restoredAt, { byRole: 'council_or_sa', toStatus: st.status || null });
  out.sort((a, b) => a.at - b.at);
  return out;
}

export function normalizeTripEvents(
  st: Record<string, any> | null | undefined,
): TripEvent[] {
  const raw = st && st.events && typeof st.events === 'object' ? st.events : null;
  const listed: TripEvent[] = [];
  if (raw) {
    Object.keys(raw).forEach((k) => {
      const e = raw[k];
      if (!e || typeof e !== 'object') return;
      listed.push(
        buildTripEvent(String(e.type || 'event'), {
          at: e.at,
          by: e.by,
          byRole: e.byRole,
          note: e.note,
          reasons: e.reasons,
          fromStatus: e.fromStatus,
          toStatus: e.toStatus,
          fieldsChanged: e.fieldsChanged,
        }),
      );
    });
  }
  if (listed.length) {
    listed.sort((a, b) => a.at - b.at);
    return listed;
  }
  return synthesizeEventsFromStatus(st);
}

export function formatEventLabel(e: TripEvent): string {
  const type = String(e.type || 'event');
  const labels: Record<string, string> = {
    submitted: 'Submitted to council',
    flagged: 'Flagged',
    returned: 'Returned to company',
    owner_edited: 'Edited by owner',
    resubmitted: 'Resubmitted',
    approved: 'Approved',
    paid: 'Paid',
    rejected: 'Rejected',
    archived: 'Archived',
    restored: 'Restored',
    council_edited: 'Edited by council',
  };
  let line = labels[type] || type;
  if (e.reasons && e.reasons.length) line += ' (' + e.reasons.join(', ') + ')';
  if (e.note) {
    if (type === 'owner_edited' || type === 'resubmitted') line += ' — Owner: ' + e.note;
    else line += ' — ' + e.note;
  }
  if (e.fromStatus && e.toStatus && type === 'archived') {
    line += ` [from ${e.fromStatus}]`;
  }
  return line;
}
