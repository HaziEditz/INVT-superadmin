import assert from 'node:assert/strict';
import test from 'node:test';
import { planChargeRefund, splitPlatformFee } from '../src/lib/platformPayments.ts';

test('splitPlatformFee records BookaWaka fee in ledger math (not Stripe application_fee)', () => {
  assert.deepEqual(splitPlatformFee({ amountCents: 10000, platformFeePercent: 10 }), {
    amountCents: 10000,
    platformFeeCents: 1000,
    companyNetCents: 9000,
  });
  assert.deepEqual(splitPlatformFee({ amountCents: 100, platformFeePercent: 0 }), {
    amountCents: 100,
    platformFeeCents: 0,
    companyNetCents: 100,
  });
});

test('planChargeRefund keeps wallet path modular without Stripe refund', () => {
  const ledger = {
    chargeId: 'ch_1',
    paymentIntentId: 'pi_1',
    companyId: '860869',
    amountCents: 5000,
    platformFeeCents: 500,
    companyNetCents: 4500,
    currency: 'nzd',
    method: 'tap_to_pay',
    clientChannel: 'driver_app',
    createdAt: 1,
    passengerUid: 'uid_pax',
  };
  const wallet = planChargeRefund({ ledger, destination: 'passenger_wallet' });
  assert.equal(wallet.stripeRefundRequired, false);
  assert.equal(wallet.destination, 'passenger_wallet');
  assert.equal(wallet.passengerUid, 'uid_pax');

  const card = planChargeRefund({ ledger, destination: 'original_card', amountCents: 2000 });
  assert.equal(card.stripeRefundRequired, true);
  assert.equal(card.amountCents, 2000);
});
