/**
 * Claim-batch proof document storage.
 * Prefers Firebase Storage via firebase-admin when FIREBASE_SERVICE_ACCOUNT is set;
 * otherwise stores base64 in RTDB under tmBatchDocs/ (download via portal API).
 */
import { randomUUID } from 'crypto';
import { fbWrite } from '../firebase';

const STORAGE_BUCKET =
  process.env.FIREBASE_STORAGE_BUCKET || 'bookawaka2026-564e1.firebasestorage.app';

let _admin: any = null;
let _adminTried = false;

function getAdmin(): any {
  if (_adminTried) return _admin;
  _adminTried = true;
  try {
    const admin = require('firebase-admin');
    const svc = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (!svc) return null;
    if (!admin.apps || !admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(svc)),
        databaseURL: 'https://bookawaka2026-564e1-default-rtdb.firebaseio.com',
        storageBucket: STORAGE_BUCKET,
      });
    }
    _admin = admin;
    return _admin;
  } catch {
    return null;
  }
}

export type StoredBatchProof = {
  paymentDocUrl: string;
  paymentDocName: string;
  paymentDocPath: string;
  paymentDocUploadedAt: number;
  storage: 'firebase_storage' | 'rtdb';
};

function sanitizeName(name: string): string {
  return String(name || 'proof.pdf')
    .replace(/[^a-zA-Z0-9._-]+/g, '_')
    .slice(0, 120);
}

export function decodeDataUrlOrBase64(
  raw: string,
  fallbackContentType = 'application/octet-stream',
): { buffer: Buffer; contentType: string } | null {
  const s = String(raw || '').trim();
  if (!s) return null;
  const m = s.match(/^data:([^;]+);base64,(.+)$/i);
  if (m) {
    try {
      return { buffer: Buffer.from(m[2], 'base64'), contentType: m[1] || fallbackContentType };
    } catch {
      return null;
    }
  }
  try {
    return { buffer: Buffer.from(s, 'base64'), contentType: fallbackContentType };
  } catch {
    return null;
  }
}

/** Max ~4.5MB decoded — keeps RTDB fallback within practical limits. */
export const MAX_PROOF_BYTES = 4.5 * 1024 * 1024;

export function storeBatchProof(
  opts: {
    councilId: string;
    cid: string;
    ym: string;
    filename: string;
    contentType?: string;
    dataBase64: string;
    uploadedBy: string;
  },
  cb: (err: Error | null, result?: StoredBatchProof) => void,
): void {
  const decoded = decodeDataUrlOrBase64(opts.dataBase64, opts.contentType || 'application/octet-stream');
  if (!decoded || !decoded.buffer.length) {
    return cb(new Error('Invalid proof document data'));
  }
  if (decoded.buffer.length > MAX_PROOF_BYTES) {
    return cb(new Error('Proof document too large (max ~4.5 MB)'));
  }
  const filename = sanitizeName(opts.filename);
  const contentType = opts.contentType || decoded.contentType || 'application/octet-stream';
  const now = Date.now();
  const path = `tmBatchDocs/${opts.councilId}/${opts.cid}/${opts.ym}/${now}_${filename}`;
  const admin = getAdmin();

  if (admin) {
    const token = randomUUID();
    const bucket = admin.storage().bucket(STORAGE_BUCKET);
    const file = bucket.file(path);
    file
      .save(decoded.buffer, {
        resumable: false,
        metadata: {
          contentType,
          metadata: { firebaseStorageDownloadTokens: token },
        },
      })
      .then(() => {
        const url =
          'https://firebasestorage.googleapis.com/v0/b/' +
          encodeURIComponent(STORAGE_BUCKET) +
          '/o/' +
          encodeURIComponent(path) +
          '?alt=media&token=' +
          encodeURIComponent(token);
        cb(null, {
          paymentDocUrl: url,
          paymentDocName: filename,
          paymentDocPath: path,
          paymentDocUploadedAt: now,
          storage: 'firebase_storage',
        });
      })
      .catch((e: any) => {
        // Fall through to RTDB if Storage write fails
        storeRtdbProof(opts, decoded.buffer, contentType, filename, now, cb);
      });
    return;
  }

  storeRtdbProof(opts, decoded.buffer, contentType, filename, now, cb);
}

function storeRtdbProof(
  opts: {
    councilId: string;
    cid: string;
    ym: string;
    uploadedBy: string;
  },
  buffer: Buffer,
  contentType: string,
  filename: string,
  now: number,
  cb: (err: Error | null, result?: StoredBatchProof) => void,
): void {
  const rtdbPath = `tmBatchDocs/${opts.councilId}/${opts.cid}/${opts.ym}`;
  const payload = {
    filename,
    contentType,
    encoding: 'base64',
    data: buffer.toString('base64'),
    size: buffer.length,
    uploadedAt: now,
    uploadedBy: opts.uploadedBy,
    storage: 'rtdb',
  };
  fbWrite('PUT', rtdbPath, payload, (err: any) => {
    if (err) return cb(err instanceof Error ? err : new Error(String(err)));
    cb(null, {
      paymentDocUrl: 'rtdb:' + rtdbPath,
      paymentDocName: filename,
      paymentDocPath: rtdbPath,
      paymentDocUploadedAt: now,
      storage: 'rtdb',
    });
  });
}
