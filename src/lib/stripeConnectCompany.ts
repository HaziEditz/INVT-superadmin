import { fbReadP, fbWriteP } from '../firebase';
import { getResendClient, getStripe } from '../utils';

function getPortalBaseUrl(): string {
  const explicit = process.env.PUBLIC_SA_URL || process.env.BOOKAWAKA_SA_URL || '';
  if (explicit.trim()) return explicit.trim().replace(/\/$/, '');
  const domain = (process.env.REPLIT_DOMAINS || process.env.REPLIT_DEV_DOMAIN || '').split(',')[0];
  if (!domain) return 'https://taxitime.co.nz';
  return domain.startsWith('http') ? domain.replace(/\/$/, '') : `https://${domain}`;
}

export type ConnectStatus = 'not_started' | 'pending' | 'complete';

export function deriveConnectStatus(data: Record<string, unknown> | null): ConnectStatus {
  if (!data || typeof data !== 'object') return 'not_started';
  if (data.connectStatus === 'complete' || data.connectOnboardingComplete === true) return 'complete';
  const accountId = data.stripeAccountId ?? data.stripeConnectId;
  if (typeof accountId === 'string' && accountId.startsWith('acct_')) return 'pending';
  return 'not_started';
}

async function sendConnectOnboardingEmail(opts: {
  email: string;
  companyName: string;
  cid: string;
  onboardingUrl: string;
}): Promise<{ ok: boolean; error?: string }> {
  try {
    const resend = await getResendClient();
    if (!resend) return { ok: false, error: 'Email client unavailable' };
    const result = (await resend.emails.send({
      from: 'BookaWaka <info@bookawaka.com>',
      to: [opts.email],
      subject: `Complete Stripe setup for ${opts.companyName} — BookaWaka`,
      html: `<div style="font-family:sans-serif;max-width:600px;margin:0 auto;padding:24px;">
        <h2 style="color:#635BFF;">Set up card payments</h2>
        <p>Hi,</p>
        <p>Your company <strong>${opts.companyName}</strong> (ID: <strong>${opts.cid}</strong>) has been approved on BookaWaka.</p>
        <p>To accept online card payments from passengers, complete your Stripe Connect setup:</p>
        <p style="margin:24px 0"><a href="${opts.onboardingUrl}" style="background:#635BFF;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:bold;">Complete Stripe onboarding</a></p>
        <p style="color:#666;font-size:13px;">This link expires after a short time. If it expires, contact BookaWaka support or use the SA Portal to resend it.</p>
      </div>`,
    })) as { error?: { message?: string } };
    if (result.error) return { ok: false, error: result.error.message };
    return { ok: true };
  } catch (err: any) {
    return { ok: false, error: String(err.message || err) };
  }
}

/** Create Express Connect account + onboarding link; email owner. Idempotent if account exists. */
export async function provisionCompanyStripeConnect(opts: {
  cid: string;
  email: string;
  companyName: string;
}): Promise<{ ok: boolean; accountId?: string; onboardingUrl?: string; skipped?: boolean; error?: string }> {
  const cid = String(opts.cid || '').trim();
  const email = String(opts.email || '').trim();
  const companyName = String(opts.companyName || '').trim() || `Company ${cid}`;
  if (!cid || !email) return { ok: false, error: 'cid and email required' };

  if (!process.env.STRIPE_SECRET_KEY) {
    console.warn('[stripe-connect] STRIPE_SECRET_KEY not set — skipping Connect provisioning for', cid);
    return { ok: false, error: 'STRIPE_SECRET_KEY not configured' };
  }

  try {
    const stripe = getStripe();
    const existing = ((await fbReadP(`stripeConfig/${cid}`)) || {}) as Record<string, unknown>;
    const status = deriveConnectStatus(existing);

    if (status === 'complete' && existing.stripeAccountId) {
      return { ok: true, skipped: true, accountId: String(existing.stripeAccountId) };
    }

    let accountId = typeof existing.stripeAccountId === 'string' ? existing.stripeAccountId : '';
    if (!accountId) {
      const account = await stripe.accounts.create({
        type: 'express',
        country: 'NZ',
        email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        business_profile: { name: companyName },
        metadata: { companyId: cid, platform: 'bookawaka' },
      });
      accountId = account.id;
      await fbWriteP('PATCH', `stripeConfig/${cid}`, {
        stripeAccountId: accountId,
        connectStatus: 'pending',
        connectOnboardingComplete: false,
        connectCreatedAt: Date.now(),
      });
      console.log('[stripe-connect] Created Express account', accountId, 'for company', cid);
    }

    const baseUrl = getPortalBaseUrl();
    const link = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: `${baseUrl}/SA-Company.aspx?cid=${encodeURIComponent(cid)}&connect=refresh`,
      return_url: `${baseUrl}/SA-Company.aspx?cid=${encodeURIComponent(cid)}&connect=return`,
      type: 'account_onboarding',
    });

    await fbWriteP('PATCH', `stripeConfig/${cid}`, {
      stripeAccountId: accountId,
      connectStatus: 'pending',
      connectOnboardingUrl: link.url,
      connectLinkExpiresAt: link.expires_at ? link.expires_at * 1000 : null,
      connectLinkSentAt: Date.now(),
    });
    await fbWriteP('PATCH', `superClients/${cid}`, { stripeConnectId: accountId });

    const emailResult = await sendConnectOnboardingEmail({
      email,
      companyName,
      cid,
      onboardingUrl: link.url,
    });
    if (!emailResult.ok) {
      console.warn('[stripe-connect] Onboarding email failed for', email, ':', emailResult.error);
    }

    return { ok: true, accountId, onboardingUrl: link.url };
  } catch (err: any) {
    console.error('[stripe-connect] provision error for', cid, ':', err.message || err);
    return { ok: false, error: String(err.message || err) };
  }
}

/** Sync Connect account state from Stripe account.updated webhook payload. */
export async function syncConnectAccountFromStripe(account: Record<string, unknown>): Promise<void> {
  const accountId = String(account.id || '');
  const companyId = String((account.metadata as Record<string, string> | undefined)?.companyId || '');
  if (!accountId.startsWith('acct_')) return;

  const complete =
    account.charges_enabled === true &&
    account.details_submitted === true;

  const patch = {
    stripeAccountId: accountId,
    connectStatus: complete ? 'complete' : 'pending',
    connectOnboardingComplete: complete,
    connectChargesEnabled: account.charges_enabled === true,
    connectPayoutsEnabled: account.payouts_enabled === true,
    connectUpdatedAt: Date.now(),
  };

  if (companyId) {
    await fbWriteP('PATCH', `stripeConfig/${companyId}`, patch);
    await fbWriteP('PATCH', `superClients/${companyId}`, { stripeConnectId: accountId });
    console.log('[stripe-connect] Synced account', accountId, 'for company', companyId, 'complete=', complete);
    return;
  }

  // Fallback: find company by stored stripeAccountId
  const allConfig = (await fbReadP('stripeConfig')) as Record<string, Record<string, unknown>> | null;
  if (!allConfig || typeof allConfig !== 'object') return;
  for (const [cid, cfg] of Object.entries(allConfig)) {
    if (cfg?.stripeAccountId === accountId || cfg?.stripeConnectId === accountId) {
      await fbWriteP('PATCH', `stripeConfig/${cid}`, patch);
      await fbWriteP('PATCH', `superClients/${cid}`, { stripeConnectId: accountId });
      console.log('[stripe-connect] Synced account', accountId, 'for company', cid, '(lookup by account id)');
      return;
    }
  }
}
