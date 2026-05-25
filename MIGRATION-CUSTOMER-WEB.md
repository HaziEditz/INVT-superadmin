# Migration Plan — Split Customer-Facing Code out of SA Portal

**Decision date:** 2026-05-18
**Reason:** SA Portal scope formally restricted to admin/monitoring/audit/override/repair only. All public customer-facing booking flows, signup pages, and passenger-app APIs move to a new dedicated Replit.

**Platform-wide rule (applies to ALL teams):**
1. DO NOT DELETE FEATURES
2. DO NOT REMOVE EXISTING FLOWS
3. ONLY FIX DATA FLOW, CONSISTENCY, AND STATE RULES
4. ALL CHANGES MUST BE BACKWARD SAFE

---

## 1. Target architecture — 5 Replits

| Replit | Owns | Status |
|---|---|---|
| 🟦 **SA Portal** (this one) | Admin pages, owner portals, billing, payouts, audit, monitoring, data repair, Stripe webhook, cron jobs | exists |
| 🟩 **Customer Web — bookawaka.com** (NEW) | The **BookaWaka public website** + the **passenger mobile app API**. Two surfaces, one Replit. See §1.1 below for the full scope. | LIVE |
| 🟨 **Dispatch backend** | Job state machine, `/api/cancel`, `/api/job/command`, offer engine, driver assignments | exists |
| 🟥 **Driver App** (React Native) | Mobile app | exists |
| 🟪 **External Registration** | Public operator signup form + trial logic + approval flow | exists |

### 1.1 Customer Web — full scope

The new Customer Web Replit (`bookawaka.com`) hosts TWO surfaces, both pointing at the same Firebase backend:

**🌐 Surface A — Public website `bookawaka.com`** (everyday customers browsing in a browser):
- 🚕 **Taxi ride booking** — book a one-off taxi ride (web booking site, currently the separate web-booking team's project — to be consolidated here)
- 🍔 **Food ordering** — browse restaurants, view menu, place a food order
- 📦 **Freight delivery** — book a parcel/freight delivery
- 🚛 **Tow request** — `/tow` (moves out of SA Portal)
- 🚗 **Rental car booking** — `/rent`, `/rent/browse`, `/rent/book`, `/rent/booking`, `/rent/cancel`, `/rent/confirm` (moves out of SA Portal)
- 🚕➡️🚗 **Ride-to-rental** — `/ride` (moves out of SA Portal)
- 📄 **Static / marketing pages** — home, about, contact, T&Cs, privacy

**📱 Surface B — Passenger mobile app API** (the separate React Native passenger app talks to these endpoints):
- All of `/api/passenger/*` — towing config / payment-intent / request / track / cancel; rental search / vehicle / book / booking / cancel
- (Future) `/api/passenger/taxi/*`, `/api/passenger/food/*`, `/api/passenger/freight/*` when the mobile app expands to those services

**Single Replit, single Firebase, single Stripe account.** The website and the passenger app are two front-ends — they share the same backend code and data. The mobile app is a separate codebase but it talks to the *same* Customer Web Replit for its API.

**Not in scope for Customer Web:**
- Admin pages (stay on SA Portal)
- Owner portals — restaurant, towing, rental, council, freight, company earnings (stay on SA Portal)
- Stripe webhook (stays on SA Portal — data integrity / monitoring)
- Operator signup `/join` form (moves to External Registration Replit)
- Job state machine / dispatch logic (stays on Dispatch backend)
- Driver app (separate mobile codebase)

---

## 2. What MOVES out of SA Portal → Customer Web

### 2.1 Towing (public)

| Route | File | New home |
|---|---|---|
| `GET /tow` | `src/routes/towing.ts:1078` | Customer Web |
| `GET /tow/track` | `src/routes/towing.ts:1716` | Customer Web |
| `POST /api/tow-request` | `src/routes/towing.ts:1352` | Customer Web |
| `POST /api/towing-payment-intent` | `src/routes/towing.ts:1432` | Customer Web |
| `GET /join-towing` | `src/routes/towing.ts:1529` | Customer Web |
| `POST /api/join-towing` | `src/routes/towing.ts:1660` | Customer Web |

### 2.2 Rental (public customer flow)

| Route | File | New home |
|---|---|---|
| `GET /rent` | `src/routes/rental.ts:372` | Customer Web |
| `GET /rent/browse` | `src/routes/rental.ts:412` | Customer Web |
| `GET /rent/book` | `src/routes/rental.ts:505` | Customer Web |
| `GET /rent/booking` | `src/routes/rental.ts:1045` | Customer Web |
| `GET /rent/confirm` | `src/routes/rental.ts:1232` | Customer Web |
| `GET /rent/cancel` | `src/routes/rental.ts:906` | Customer Web |
| `POST /api/rent/payment-intent` | `src/routes/rental.ts:755` | Customer Web |
| `POST /api/rent/confirm-booking` | `src/routes/rental.ts:807` | Customer Web |
| `POST /api/rent/cancel-booking` | `src/routes/rental.ts:967` | Customer Web |
| `GET /api/rent/validate-promo` | `src/routes/rental.ts:1014` | Customer Web |
| `POST /api/rent/use-promo` | `src/routes/rental.ts:1029` | Customer Web |
| `GET /ride` | `src/routes/rental.ts:1120` | Customer Web |
| `POST /api/ride/book` | `src/routes/rental.ts:1171` | Customer Web |

### 2.3 Passenger app API (built today)

All of `src/routes/passenger.ts` moves wholesale:

- `GET /api/passenger/towing/config`
- `POST /api/passenger/towing/payment-intent`
- `POST /api/passenger/towing/request`
- `GET /api/passenger/towing/track/:jobId`
- `POST /api/passenger/towing/cancel/:jobId`
- `GET /api/passenger/rental/search`
- `GET /api/passenger/rental/vehicle`
- `POST /api/passenger/rental/book`
- `GET /api/passenger/rental/booking/:jobId`
- `POST /api/passenger/rental/cancel/:jobId`

### 2.4 General operator signup (public)

| Route | File | New home |
|---|---|---|
| `GET /join` | `src/routes/sa-admin.ts:652` | Customer Web (or External Registration — see §5) |
| `GET /join/success` | `src/routes/sa-admin.ts:841` | Customer Web |
| `POST /api/public/register` | `src/routes/sa-admin.ts:876` | Customer Web |

### 2.5 Customer-facing Stripe endpoints

| Route | File | New home |
|---|---|---|
| `POST /api/stripe/create-booking-payment` | `src/routes/stripe.ts:158` | Customer Web |
| `GET /api/stripe/session-status` | `src/routes/stripe.ts:145` | Customer Web |
| `GET /api/stripe/config` | `src/routes/stripe.ts:255` | Customer Web |
| `GET /payment-success` | `src/routes/stripe.ts:185` | Customer Web |
| `GET /payment-cancel` | `src/routes/stripe.ts:220` | Customer Web |

### 2.6 Shared helpers (copy, do NOT move — both Replits need them)

These files must exist in BOTH Replits and stay in sync:

- `src/firebase.ts` — Firebase REST wrapper (`fbReadP`, `fbWriteP`)
- `src/utils.ts` — `getStripe()`, `getResendClient()`
- `src/jobId.ts` — `generateJobId()` (calls Dispatch's `/api/job/create`)
- `src/rentalHelpers.ts` — `rentDays`, `rentIsAvailable`, `rentCalcPricing`

**Risk:** divergence over time. **Mitigation:** publish as a shared npm package later, or document in `PLATFORM-INTEGRATION-CHECKLIST.md` that any change to these files MUST be applied to both Replits in the same PR.

---

## 3. What STAYS in SA Portal (forever)

### 3.1 All `SA-*.aspx` and module admin pages
All 47 ASPX files stay — they're the admin console.

### 3.2 All `/admin/*` endpoints (entire `sa-admin.ts` except the 3 public signup routes)
Approve/reject/activate/deactivate/reactivate/extend-trial/reset-password/PATCH/drivers/payments/sync/etc.

### 3.3 Owner portals (all SSR)
- `/council-portal/*` — entire `council.ts`
- `/restaurant-portal/*` — entire `restaurant.ts`
- `/freight-portal/*` — entire `freight.ts`
- `/towing-portal/*` — admin section of `towing.ts` (everything EXCEPT 2.1 above)
- `/rental-portal/*` — admin section of `rental.ts` (everything EXCEPT 2.2 above)
- `/company-earnings-portal/*` — entire `earnings.ts`

### 3.4 Stripe webhook + admin Stripe endpoints
- `POST /api/stripe/webhook` — STAYS (it's data-integrity / monitoring, fits the new scope rule)
- `POST /api/stripe/create-invoice-checkout` — STAYS (admin-side invoice flow)
- `POST /api/stripe/connect/*` — STAYS (Stripe Connect onboarding for operators)
- `GET /api/stripe/recent-payments` — STAYS (admin reporting)

### 3.5 Cron jobs
- Trial expiry alerts
- Overdue invoice marker
- Normalizer

### 3.6 Shared job engine (read-only views; writes go via Dispatch)
- `POST /api/job/create` — Job ID generator — **MIGRATE LATER** to Dispatch (it's their concern, but it currently lives here). Out of scope for this migration.
- `GET /api/tariffs`, `GET /api/fare-estimate`, `GET /api/public/companies`, `GET /api/payment-config` — STAYS (used by both customer apps and admin)

---

## 4. Migration order (phased rollout)

### Phase 0 — Prep (user does this) — 1 hour
1. **User creates new Replit** named `bookawaka-customer-web` in the Replit dashboard.
2. **User points DNS:** `book.taxitime.co.nz` → new Replit (Customer Web).
3. **User copies these secrets** into the new Replit:
   - `FIREBASE_DB_SECRET`
   - `STRIPE_SECRET_KEY`
   - `STRIPE_PUBLISHABLE_KEY`
   - `RESEND_API_KEY`
   - `BW_ADMIN_KEY` (so Customer Web can call SA Portal admin endpoints if needed — not needed for booking flows, but useful for the future `/api/cancel` proxy)

### Phase 1 — Stand up empty server (Customer Web Replit) — half a day
1. Copy `src/firebase.ts`, `src/utils.ts`, `src/jobId.ts`, `src/rentalHelpers.ts` to new Replit
2. Create minimal `src/app.ts` (Express, port 5000) — just a `/health` route returning `{ok:true}`
3. Deploy and confirm `https://book.taxitime.co.nz/health` returns 200

### Phase 2 — Move public routes in safe order — 5-7 days
**Order chosen so dependencies move before dependents.**

1. **Towing public** (smallest, fewest deps): move 2.1 → test `/tow`, `/tow/track` end-to-end on new domain
2. **Rental customer flow**: move 2.2 → test full `/rent` → book → confirm → cancel
3. **Passenger app API**: move 2.3 → update passenger app config to point at `book.taxitime.co.nz` instead of SA Portal domain
4. **General signup**: move 2.4 → test `/join` form submission lands in Firebase the same way
5. **Customer Stripe endpoints**: move 2.5 → confirm Stripe checkout flow works end-to-end

**After each step:** the old route in SA Portal stays alive but returns `301 Moved Permanently` to the new domain for ~2 weeks (backward-safe per platform rule), then is removed.

### Phase 3 — Lock down SA Portal — 2-3 days
1. Delete migrated route handlers from `src/routes/rental.ts`, `src/routes/towing.ts`, `src/routes/sa-admin.ts`, `src/routes/stripe.ts`
2. Delete entire `src/routes/passenger.ts`
3. Add a guard in `src/app.ts` that returns 404 for any path matching `/tow|/rent|/ride|/join|/api/passenger`
4. Update `replit.md` with the new scope rule (already done as part of this migration)
5. Run smoke tests — confirm all owner portals + admin pages still work

---

## 5. Decisions locked (2026-05-18)

1. **Operator signup `/join`** → **External Registration Replit owns the form.** Not Customer Web, not SA Portal. Customer Web is for passengers booking rides/tow/rental. External Registration owns the entire operator-signup flow end-to-end (form + trial + approval + admin API to SA Portal).
2. **Stripe webhook split** → **No second webhook.** SA Portal keeps the one webhook (data integrity / monitoring). Customer Web creates PaymentIntents and Sessions; SA Portal webhook stamps confirmations on Firebase. Matches existing §110 split in `replit.md`.
3. **Shared helpers** → **Copy + document for the migration. Switch to git submodule once Customer Web is stable (~2 weeks after launch).** Long-term path is a `bookawaka-shared` git repo pulled in as a submodule by both Replits — free, one source of truth, scales to all 5 Replits.
4. **Cancel reason taxonomy (passenger app)** → **controlled list of 8 codes** stored in Firebase as fixed strings, free-text only allowed when reason = `other`:
   - `changed_plans` — Plans changed
   - `waited_too_long` — Waited too long
   - `found_another_ride` — Found another ride
   - `booked_by_mistake` — Booked by mistake
   - `driver_too_far` — Driver too far away
   - `price_too_high` — Price too high
   - `vehicle_issue` — Vehicle issue (rental only, but allowed for tow too)
   - `other` — Other (free-text `cancelDetails` field, max 500 chars)
   Applied to: `POST /api/passenger/towing/cancel/:jobId` and `POST /api/passenger/rental/cancel/:jobId`. Firebase fields: `cancelReason` (code), `cancelDetails` (free text or empty).
5. **Rollback plan** — SA Portal keeps 301 redirects active for 2 weeks after each route migrates; if Customer Web breaks, flip routes back to local handlers (code stays in git history).

---

## 6. Acceptance criteria (migration is "done" when…)

- [ ] `book.taxitime.co.nz` serves all customer booking flows + passenger API
- [ ] `bookawaka-superadmin.replit.app` (SA Portal) returns 404 for any `/tow|/rent|/ride|/join|/api/passenger` path
- [ ] All owner portals still function on SA Portal
- [ ] Stripe webhook still stamps `stripeConfirmedFare` correctly
- [ ] Passenger app updated to use new domain
- [ ] `PLATFORM-INTEGRATION-CHECKLIST.md` updated with the new lane map
- [ ] `replit.md` scope rule reads "SA Portal is admin-only" with no contradicting routes

---

## 7. Estimated effort

| Phase | Days |
|---|---|
| Phase 0 (user prep) | 0.5 |
| Phase 1 (empty server) | 0.5 |
| Phase 2 (move routes) | 5-7 |
| Phase 3 (lock down) | 2-3 |
| **Total** | **~8-11 working days** |

System is still pre-production (no real drivers/companies/customers), so all of this can happen without downtime impact.
