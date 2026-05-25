import { fbReadP, fbWriteP } from './firebase';

const _jobCounters: Record<string, number> = {};

function _todayParts() {
  const now = new Date();
  const yy = String(now.getFullYear()).slice(-2);
  const mm = String(now.getMonth() + 1).padStart(2, '0');
  const dd = String(now.getDate()).padStart(2, '0');
  return { yy, mm, dd, key: yy + mm + dd };
}

// Belt-and-braces seed: scan allbookings/{cid} for any IDs matching today's
// prefix (last3+yymmdd) and return the highest sequence found. Guards against
// the case where `jobCounters/{cid}/{yymmdd}` was lost or fell behind reality
// (e.g. a fire-and-forget write that never landed before a crash).
async function _maxSeqFromAllbookings(cid: string, prefix: string): Promise<number> {
  try {
    const all = await fbReadP('allbookings/' + cid);
    if (!all || typeof all !== 'object') return 0;
    let max = 0;
    for (const id of Object.keys(all)) {
      if (id.length > prefix.length && id.startsWith(prefix)) {
        const seqStr = id.slice(prefix.length);
        if (/^\d+$/.test(seqStr)) {
          const n = parseInt(seqStr, 10);
          if (n > max) max = n;
        }
      }
    }
    return max;
  } catch {
    return 0;
  }
}

export async function generateJobId(companyId: string | number): Promise<string> {
  const cid = String(companyId);
  const last3 = cid.slice(-3);
  const { yy, mm, dd, key } = _todayParts();
  const cacheKey = cid + ':' + key;
  const prefix = last3 + yy + mm + dd;

  if (_jobCounters[cacheKey] === undefined) {
    // Seed from BOTH the counter node and a scan of today's actual bookings,
    // then take whichever is highest. This guarantees we can never re-issue
    // an ID that already exists at allbookings/{cid}/{id} after a restart.
    const [stored, scanned] = await Promise.all([
      fbReadP('jobCounters/' + cid + '/' + key).catch(() => null),
      _maxSeqFromAllbookings(cid, prefix)
    ]);
    const fromCounter = (stored && stored.count) ? Number(stored.count) : 0;
    const seed = Math.max(fromCounter, scanned);
    _jobCounters[cacheKey] = seed;
    if (scanned > fromCounter) {
      console.warn('[jobId] Counter behind reality for cid=' + cid + ' key=' + key
        + ' — counter=' + fromCounter + ' scan=' + scanned + ' (seeded to scan)');
    }
  }

  _jobCounters[cacheKey]++;
  const seq = _jobCounters[cacheKey];

  // AWAIT the persist so we never hand back an ID before Firebase has
  // acknowledged the counter bump. A crash between in-memory increment and
  // Firebase ack would otherwise let the next restart re-issue this seq.
  try {
    await fbWriteP('PUT', 'jobCounters/' + cid + '/' + key, { count: seq, updatedAt: Date.now() });
  } catch (e) {
    // Roll the in-memory counter back so the caller can retry without burning
    // a sequence number. The caller (POST /api/job/create) already retries 3x.
    _jobCounters[cacheKey]--;
    console.error('[jobId] Counter persist failed — rolled back. cid=' + cid + ' seq=' + seq, e);
    throw e;
  }

  return prefix + seq;
}
