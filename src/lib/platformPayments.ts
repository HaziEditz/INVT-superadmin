/**
 * Platform (BookaWaka) Stripe payment helpers for taxi/TM Tap to Pay.
 *
 * Model (greenlit):
 * - Direct charges on the platform Stripe account (no Connect destination).
 * - BookaWaka fee + company net recorded in our ledger at charge time.
 * - Connect Express remains available for future verticals — not used here.
 * - Refund destination is modular: card reverse now; wallet credit later
 *   without re-architecting charge creation.
 */

export type PaymentClientChannel = 'driver_app' | 'passenger_app' | 'passenger_web' | 'admin';

export type PlatformChargeLedger = {
  chargeId: string;
  paymentIntentId: string;
  companyId: string;
  bookingId?: string | null;
  driverId?: string | null;
  /** Gross amount charged to card, NZD cents */
  amountCents: number;
  /** BookaWaka platform fee, NZD cents (our ledger — not Stripe application_fee) */
  platformFeeCents: number;
  /** Amount attributable to company, NZD cents */
  companyNetCents: number;
  currency: 'nzd';
  method: 'tap_to_pay' | 'card_manual' | 'card_other';
  clientChannel: PaymentClientChannel;
  createdAt: number;
  /** Future: passenger wallet owner when refunds credit wallet */
  passengerUid?: string | null;
};

export type RefundDestination = 'original_card' | 'passenger_wallet';

export type PlatformFeeSplitInput = {
  amountCents: number;
  /** 0–100; TBD commercially — mechanism only */
  platformFeePercent: number;
};

export function splitPlatformFee(input: PlatformFeeSplitInput): {
  amountCents: number;
  platformFeeCents: number;
  companyNetCents: number;
} {
  const amountCents = Math.max(0, Math.round(Number(input.amountCents) || 0));
  const pct = Math.min(100, Math.max(0, Number(input.platformFeePercent) || 0));
  const platformFeeCents = Math.min(amountCents, Math.round((amountCents * pct) / 100));
  return {
    amountCents,
    platformFeeCents,
    companyNetCents: amountCents - platformFeeCents,
  };
}

/**
 * Build a refund plan. Wallet credit path is reserved — callers must not assume
 * wallet ledger exists yet; return structured intent only.
 */
export function planChargeRefund(opts: {
  ledger: PlatformChargeLedger;
  destination: RefundDestination;
  amountCents?: number;
}): {
  paymentIntentId: string;
  amountCents: number;
  destination: RefundDestination;
  /** When destination=passenger_wallet, credit this uid (must be set on ledger later) */
  passengerUid: string | null;
  stripeRefundRequired: boolean;
} {
  const amountCents = Math.min(
    opts.ledger.amountCents,
    Math.max(0, Math.round(opts.amountCents ?? opts.ledger.amountCents)),
  );
  if (opts.destination === 'passenger_wallet') {
    return {
      paymentIntentId: opts.ledger.paymentIntentId,
      amountCents,
      destination: 'passenger_wallet',
      passengerUid: opts.ledger.passengerUid || null,
      stripeRefundRequired: false,
    };
  }
  return {
    paymentIntentId: opts.ledger.paymentIntentId,
    amountCents,
    destination: 'original_card',
    passengerUid: null,
    stripeRefundRequired: true,
  };
}
