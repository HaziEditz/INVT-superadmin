import test from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const {
  listDriversForCompany,
  flattenAllDrivers,
  isDriverWav,
} = require(path.join(__dirname, '../taxitime.co.nz/superadmin360taxi/assets/js/driver-list.js'));

test('listDriversForCompany: nested + flat same email → one row (nested wins)', () => {
  const raw = {
    '860869': {
      authUid1: {
        email: 'a@example.com',
        firstName: 'Ann',
        lastName: 'Driver',
        companyId: '860869',
        active: true,
      },
    },
    pushKeyLegacy: {
      email: 'a@example.com',
      name: 'Ann Driver',
      companyId: '860869',
      active: true,
    },
    otherCid: {
      x: { email: 'b@example.com', companyId: '999' },
    },
  };
  const list = listDriversForCompany(raw, '860869');
  assert.equal(list.length, 1);
  assert.equal(list[0]._source, 'nested');
  assert.equal(list[0].firstName, 'Ann');
});

test('listDriversForCompany: same uid different keys → one row', () => {
  const raw = {
    '860869': {
      uidA: { uid: 'uidA', email: 'x@y.com', companyId: '860869', name: 'Nested' },
    },
    ownerPush: { uid: 'uidA', email: 'x@y.com', companyId: '860869', name: 'Flat' },
    alsoPush: { dispatcherId: 'uidA', companyId: '860869', name: 'Flat2', phone: '0215550100' },
  };
  const list = listDriversForCompany(raw, '860869');
  assert.equal(list.length, 1);
  assert.equal(list[0]._source, 'nested');
});

test('listDriversForCompany: two real drivers stay two', () => {
  const raw = {
    '860869': {
      u1: { email: 'one@ex.com', firstName: 'One', companyId: '860869' },
      u2: { email: 'two@ex.com', firstName: 'Two', companyId: '860869' },
    },
    p1: { email: 'one@ex.com', companyId: '860869', name: 'One copy' },
    p2: { email: 'two@ex.com', companyId: '860869', name: 'Two copy' },
    p3: { email: 'one@ex.com', uid: 'u1', companyId: '860869' },
  };
  const list = listDriversForCompany(raw, '860869');
  assert.equal(list.length, 2);
});

test('listDriversForCompany: activeOnly skips inactive', () => {
  const raw = {
    '860869': {
      a: { email: 'a@ex.com', companyId: '860869', active: true },
      b: { email: 'b@ex.com', companyId: '860869', active: false },
    },
  };
  assert.equal(listDriversForCompany(raw, '860869').length, 2);
  assert.equal(listDriversForCompany(raw, '860869', { activeOnly: true }).length, 1);
});

test('flattenAllDrivers dedupes across shapes', () => {
  const raw = {
    '860869': {
      u1: { email: 'a@ex.com', companyId: '860869' },
    },
    pk: { email: 'a@ex.com', companyId: '860869' },
    '620611': {
      u9: { email: 'z@ex.com', companyId: '620611' },
    },
  };
  const all = flattenAllDrivers(raw);
  assert.equal(all.length, 2);
});

test('isDriverWav matches SA heuristics', () => {
  assert.equal(isDriverWav({ vehicleType: 'Wheelchair Van' }), true);
  assert.equal(isDriverWav({ wav: true }), true);
  assert.equal(isDriverWav({ vehicleType: 'Sedan' }), false);
});
