# BookaWaka Super Admin Portal

A web-based super admin portal for managing the BookaWaka transport booking platform.

## ⚠️ Scope rule (locked 2026-05-18)

**This Replit is admin-only.** Allowed work: monitoring, audit logs, manual overrides, data repair tools, owner portals, billing, payouts, reports, Stripe webhook (data-integrity side only).

**NOT allowed in new work:** customer-facing booking pages, signup flows, passenger app API. Those belong in the separate **Customer Web Replit (`bookawaka.com`)**, which hosts BOTH the public BookaWaka website (taxi rides, food ordering, freight delivery, tow requests, rental car bookings, ride-to-rental, marketing pages) AND the passenger mobile app API (`/api/passenger/*`). Two front-ends, one backend Replit. Operator signup `/join` belongs in External Registration (not Customer Web). See `MIGRATION-CUSTOMER-WEB.md` §1.1 for the full scope map.

**Platform-wide rule (all 5 Replits):**
1. DO NOT DELETE FEATURES
2. DO NOT REMOVE EXISTING FLOWS
3. ONLY FIX DATA FLOW, CONSISTENCY, AND STATE RULES
4. ALL CHANGES MUST BE BACKWARD SAFE

Existing customer-facing flows (`/tow`, `/rent`, `/ride`, `/join`, `/api/passenger/*`) still live here for now and will be migrated out per the plan in `MIGRATION-CUSTOMER-WEB.md`. Until they are migrated, treat them as read-only — do not add new customer-facing features here.

## Run & Operate

- **Run Server**: `npx ts-node src/app.ts` (starts Express server on port 5000)
- **Firebase Project**: `taxilatest` (`https://taxilatest.firebaseio.com`)
- **Required Env Vars**: `BW_ADMIN_KEY` (shared secret with External Registration Replit — must match on both sides; used in `X-Admin-Key` header against `/admin/registrations` etc.), `RESEND_API_KEY` (for email)
- **Do NOT document the actual key value here.** Rotated 2026-05-14 after the previous default (`bookawaka-admin-2026`) was found publicly in this file. Old default is still inert-pending until external Replit updates its secret too.

## Stack

- **Frontend**: ASP.NET Web Forms (.aspx served as HTML), jQuery, UIkit, Bootstrap, Handlebars.js
- **Backend**: Express.js (TypeScript)
- **Database**: Firebase Realtime Database
- **Auth**: Firebase Auth
- **Email**: Resend
- **Charting**: Chartist.js, Peity
- **Validation**: Parsley.js
- **Notifications**: Toastr.js

## Where things live

- `/server.ts`: Main Express server and API entry point.
- `/taxitime.co.nz/superadmin360taxi/`: Contains all `.aspx` frontend pages.
- `/taxitime.co.nz/superadmin360taxi/assets/js/`: Frontend JavaScript assets.
- `Firebase Rules`: Source of truth for database access control.
- `companySettings/{cid}/features`: Canonical source for per-company feature flags.
- `PLATFORM-INTEGRATION-CHECKLIST.md`: Authoritative reference for cross-app field contracts.
- `https://01067f31-afeb-4a32-a195-60c80223accf-00-dgff2mfkeoci.riker.replit.dev`: External Admin API for company accounts.
- `bwConfig/towing/`, `bwConfig/rental/`: Platform-wide configuration for Towing and Rental modules.
- `rentalConfig/{cid}/`: Per-company overrides for Rental module.
- `towingPortalAccess/{cid}/`, `rentalPortalAccess/{cid}/`, `foodRestaurantAccess/{rid}/`, `companyPortalAccess/{cid}/`, `tmCouncilAccess/{councilId}/`: Portal login credentials.

## Architecture decisions

- **Legacy Frontend with Modern Backend**: ASP.NET Web Forms (`.aspx` files served as HTML) are used for the frontend, leveraging jQuery/UIkit, while the backend is a modern Express.js TypeScript server. This allows gradual migration while maintaining existing UI.
- **Firebase as Primary Data Store**: Firebase Realtime Database serves as the central data store for all operational data, enabling real-time updates across connected applications (driver, passenger, dispatch, owner portals).
- **Hybrid SSR Portals**: Specific portals (Council Staff, Restaurant Owner, Company Settlement, Towing Owner, Rental Owner) are Server-Side Rendered by Express.js, providing dedicated interfaces with specific business logic while integrating with the main Firebase data.
- **Micro-Module Design**: Features like Total Mobility, Food Delivery, Freight, Towing, and Rental Cars are structured as distinct modules within the SA portal, each with dedicated admin pages and often their own SSR portals and Firebase data paths.
- **Session Management**: All SSR portals utilize in-memory Map sessions with a 24-hour TTL and URL token authentication for security and statelessness. SHA-256 hashing is used for password storage.

## Product

- **Comprehensive Administration**: Manage drivers, companies, onboarding requests, billing, payouts, reports, and system settings.
- **Multi-Service Support**: Modules for Taxi, Total Mobility, Food Delivery, Freight Delivery, Towing, and Rental Cars.
- **Role-Based Portals**: Dedicated portals for Council Staff, Restaurant Owners, Company Admins, Towing Owners, and Rental Company Owners.
- **Real-time Monitoring**: Live sessions visibility and audit logs for administrative oversight.
- **Customizable Platform**: Per-company feature flags, branding, commission rates, and notification settings.

## User preferences

_Populate as you build_

## Gotchas

- **Session Revocation**: When suspending a company or revoking sessions, SA writes `sessionRevoke: Date.now()` to `superClients/{cid}`. Dispatch apps must listen and force sign-out if `sessionRevoke > loginTimestamp`.
- **Firebase `allbookings/{cid}` vs `completedJobs/{cid}`**: `allbookings/{cid}` contains ALL completed dispatched bookings (driver app + passenger app). `completedJobs/{cid}` is specifically for hail trips.
- **Job ID Generation**: Passenger app, Dispatch app, and Web Booking site **MUST** use `POST /api/job/create` for Job ID generation. No local fallback, retry 3x to avoid ID collisions.
- **Cash Toggle Logic**: Cash payment options should be hidden if *either* the platform-wide `bwConfig/paymentMethods/cashEnabled` OR the per-company `companySettings/{cid}/paymentMethods/cashEnabled` is false.
- **Payment Method Policy (confirmed 2026-05-07)**: Web booking site and Passenger app must NOT offer cash. Allowed methods: Card (Stripe), Account (account number verified), ACC (claim number), Total Mobility/TM (TM card number), Gift Card (voucher code). Driver app keeps ALL methods including cash — drivers handle hail passengers in person and may need to process any payment type manually.
- **External Registration System**: Operator signup, approval, and trial logic are handled by a separate external Replit. Do not modify signup/trial logic within this SA portal.
- **Firebase `pickupLocation`/`dropoffLocation`**: These are `{address, lat, lng}` objects; use `.address` for string display.
- **Driver GPS path**: Driver app writes to `online/{cid}/{vid}/current` — `{lat, lng, hasGps: true, time}`. Dispatcher reads `online/{cid}/{vid}` (correct). GPS bug fixed 2026-05-05: `lat/lng` are under the `current` child, not top-level; map now reads `driverData.lat || driverData.current?.lat` (backward-compatible).
- **Driver ratings path**: `driverRatings/{cid}/{bookingId}` — universal ratings path (all job types). Also patched to `allbookings/{cid}/{bookingId}/driverRating` for dispatched trips.
- **Freight POD fields**: `freightOrders/{cid}/{bookingId}` receives `pickupConfirmed`, `pickupConfirmedAt`, `deliveryConfirmed`, `deliveredAt`, `driverId`, `vehicleId` from driver app (non-blocking writes, 2026-05-05+).
- **Cancelled trips**: `cancelTrip()` writes `status: 'Cancelled'`, `Status: 'Cancelled'`, `CancelledAt` (ISO), `CancelledBy: 'driver'` to `allbookings/{cid}/{bookingId}` (fixed 2026-05-05). Filter on either casing.
- **Stripe Payments (Rental)**: Rental bookings use two PaymentIntents: one for the rental total (auto-capture) and one for the deposit (manual capture). Both confirmed sequentially by frontend JS.
- **`superClients/{cid}` field name is `name` (not `companyName`)**: All backend routes (`council.ts`, `sa-admin.ts`, etc.) read `sc.name`. Fixed SA-Rental.aspx which incorrectly read `res[0].companyName` (always fell back to CID).
- **Subscription un-suspend requires explicit `'active'` string**: `/api/sa-set-subscription-config` guard is `if (subscriptionStatus)` — passing `undefined` silently skips the write. SA-SubscriptionBilling.aspx `saveEdit()` now sends `'active'` when un-suspending so Firebase is always updated.
- **`/api/sa-set-subscription-config` is the authoritative subscription writer**: handles `stripeCustomerId`, `deductFromPayout`, `monthlyOverride`, `subscriptionStatus`. The companion call to `/api/sa-set-company-payout-schedule` only writes `payoutSchedule` + `stripeConnectId`.
- **`completedJobs/{cid}` dual key structure**: Dispatch writes at `completedJobs/{cid}/{numericTripId}`; driver app writes at `completedJobs/{cid}/{pushKey}` via `push()`. Both records store `bookingId` as an internal field. SA portal reads `t.fare || t.FinalFare || t.meterFare`. Index `.indexOn: ["bookingId"]` live on `$companyId` node — enables dispatch's dedup guard (`orderByChild('bookingId')` before driverEarnings increment).
- **`rideStatus/{cid}/{bookingId}` owned by driver app**: Driver writes full record at Assigned, patches `status+updatedAt` at OnTrip/Declined/Cancelled/Completed. Dispatch only writes rideStatus at recall notifications and ETA anchors. Driver app dispatch tabs (Current/Offer/Queue) are driven by in-memory `jobs/` state from `notification/{driverId}` + `jobs/{cid}/{vehicleId}/{driverId}` — NOT by rideStatus.
- **`driverEarnings/taxi/{cid}/{driverId}` is the canonical path**: `jobs.ts` syncOfflineTrip previously wrote to `driverEarnings/{cid}/{driverId}` (missing `taxi` segment) — fixed 2026-05-07. Dispatch owns this path for online trips (dedup-guarded). Driver app never writes driverEarnings.
- **`online/{cid}/{vid}` accept writes — both sides**: At job acceptance, BOTH dispatch (`_bwWriteAssignmentToFirebase`) and driver app write: `current/currentJobId = {bookingId}` and top-level `vehiclestatus = 'Assigned'`. Both use `.update()` — merge cleanly, no clobber. Driver app restart reconstructs active job from `current/currentJobId`.
- **Driver app writes `paymentMethod` + fare to `allbookings` at completion (§109)**: `completeJob()` does `.update()` on allbookings with `fare/FinalFare/meterFare` (meter reading) and `paymentMethod` derived from `job.paymentType` (set at offer-accept). If dispatch notification did NOT include `PaymentType: 'card'`, driver defaults to `'cash'` — overwriting the Stripe webhook's value. SA portal sync endpoints re-assert `paymentMethod: 'card'`, `paymentStatus: 'paid'`, and `fare: stripeConfirmedFare` when `isPrePaid` to correct this as the last writer. Dispatch team should include `PaymentType: 'card'` in offer notifications for paid bookings as the permanent fix.
- **`stripeConfirmedFare` is write-once, owned by SA portal Stripe webhook**: Written to `allbookings/{cid}/{bookingId}` on `checkout.session.completed`. Never written by dispatch, driver app, or sync endpoints (sync endpoints READ it, not write it). Safe to use as authoritative fare for pre-paid bookings even after other systems have overwritten `fare`.
- **Dual Stripe webhooks — ownership split (§110)**: Web booking site webhook owns: Status transition, `pendingjobs` push (dispatch trigger), `paidAt`, `stripeSessionId`. SA portal webhook owns: `stripeConfirmedFare` (write-once), `paymentStatus: 'paid'`, `paymentMethod: 'card'` — PATCH only, no pendingjobs write. Web booking webhook was returning 503 (missing STRIPE_WEBHOOK_SECRET in their env) as of 2026-05-07 — SA portal was sole handler. Once web team sets their secret, both fire without conflict under this split.
- **`_normFbJob()` in dispatch handles all address field variants**: Reads `PickupAddress || pickupAddress || PickAddress || pickAddress` for pickup, and same pattern for dropoff. All apps (passenger, web booking, dispatcher direct entry) are handled — no field name contract required for addresses.
- **Driver app sync payload has NO `paymentMethod` field**: `POST /api/job/sync-offline-trip` body contains only fare/distance/location fields. Payment method resolution happens via the `isPrePaid` guard reading `stripeConfirmedFare` from allbookings, not from the sync payload.
- **Card booking status standard: `"PendingPayment"` (§111)**: Agreed standard for card bookings awaiting payment confirmation. Passenger app already uses it. Web booking site must change `"PaymentPending"` → `"PendingPayment"` (one-liner in bookings.ts). Dispatch team must confirm their hold gate checks `"PendingPayment"`. SA portal does not write this status.
- **`allowedServices` gate (§112)**: Dispatch reads `drivers/{cid}/{uid}/allowedServices.{jobType}` (boolean) to gate which job types a driver receives. Missing field = taxi:true only (no silent all-access). SA portal writes this map on every driver save alongside the legacy `drivers/{uid}/foodDelivery` comma-string. TM checkbox only shown when `companySettings/{cid}/features.tmEnabled` or `.totalMobility` is true.
- **Food delivery completion is centralized (§114)**: When a driver completes a food delivery, dispatch/driver-app calls `POST /api/food-delivery-complete` with `{cid, orderId, driverId, vehicleId}` + `X-Admin-Key` header. SA portal computes `foodCommission`, `restaurantPayout`, `deliveryCommission`, `driverPay` and writes them to `foodOrders/{cid}/{orderId}` + `driverEarnings/food/{cid}/{driverId}/{orderId}`. Do NOT compute these splits anywhere else. The owner Earnings/Payouts pages read `foodOrders.restaurantPayout`/`foodCommission` — they stay empty until this endpoint is called. For manual testing, the owner Orders page has a "Mark Delivered" button that runs the same logic via session auth.
- **`driverEarnings/food/{cid}/{driverId}` is the canonical path**: parallel to `driverEarnings/taxi/{cid}/{driverId}`. Written by `/api/food-delivery-complete` only — never by dispatch or driver app directly.
- **Duplicate-operator guard in `/api/admin/sync-registrations` (2026-05-15)**: External Registration assigns a fresh `cid` for every signup with no name check, so an operator who re-signs up (or whose record was rebuilt) gets a second `superClients/{cid}` entry under the same business name. Sync now refuses to mirror an `onboardRequest` whose name (lowercased, whitespace-collapsed) collides with an existing `superClients.name` or with another row in the same scan, logs `[sync-registrations] REFUSED duplicate name …`, and records the existing cid in the skipped list. SA must merge/rename manually. Historical cleanup: deleted phantom cid `768576` (Invercargill Taxis Southland duplicate of real cid `620611`).
- **Passenger cancel policy (70% rule) is passenger-app-only, NOT server-enforced (2026-05-18)**: The "free cancel before driver is 70% of the way to pickup, charge after" rule lives entirely client-side in the passenger mobile app — function `computeCancelPolicy` in `artifacts/passenger-app/context/RideContext.tsx`. It reads live driver-distance % from GPS vs original pickup distance plus the booking's `paymentMethod`, returns an outcome (`refund` / `charge` / `free`), and either credits the wallet client-side or shows a charge notification. **No server (SA Portal, Customer Web, or dispatch) currently enforces this rule** — the cancel endpoints just flip `status:'cancelled'` and (for `paymentMethod:'card'`) refund the full Stripe charge regardless of driver position. If true server-side enforcement is ever needed (e.g. partial Stripe capture, account-invoice line, ACC reconciliation), the passenger app must pass `driverDistancePct` and `cancelOutcome` to the cancel endpoint and the server side needs new logic to honour them. Until then: SA staff investigating a cancel-charge dispute should remember the visible outcome shown to the passenger came from the app, not from any backend gate.
- **Passenger wallet — ownership + admin API (2026-05-18, Option 1 signed off)**: Storage owned by Customer Web Replit at `passengerWallet/{key}/entries/{entryId}`. SA Portal owns the admin UI (`SA-Wallet.aspx`) and a thin proxy (`/api/sa-wallet/*` in `src/routes/sa-wallet.ts`) that forwards to `${CUSTOMER_WEB_URL}/api/admin/wallet/*` with `X-Admin-Key: ${BW_ADMIN_KEY}` server-side — the secret never reaches the browser. Frontend authenticates by sending `Authorization: Bearer <Firebase ID token>` — proxy verifies the token via `verifyFirebaseToken()` and enforces `isSuperAdmin()` on the resolved uid; caller-supplied `saUid` is ignored. The verified uid is stamped onto the upstream request as `X-Admin-Uid` header and `adminUid` body field for audit. **Also locked down (`/api/fb` blocklist)**: `superAdmins`, `passengerWallet`, `walletAdminAudit` paths now return 403 via the generic Firebase proxy — must go through dedicated authenticated endpoints. This closes the UID-enumeration bypass that would otherwise let any `/api/fb` reader pose as a super-admin. **Two new envs required on SA Portal**: `CUSTOMER_WEB_URL` (Customer Web Replit's base URL, no trailing slash) and existing `BW_ADMIN_KEY`. **Identifier resolver** lives at `passengerIndex/uid/{uid} → {key}` and `passengerIndex/key/{key} → {uid?}` — wallet identity follows the passenger across web (key-only) and mobile (gains uid at first sign-in) without data migration. **Audit recovery**: every `/adjust` writes to `walletAdminAudit/{txId}` AND embeds `auditTxId` into the ledger entry itself, so if the audit write fails the ledger row still carries the full recovery handle. **Integrity check** on reconciliation: `closingBalanceCents - openingBalanceCents` MUST equal `totalCreditsCents - totalDebitsCents` — UI shows ⚠️ banner if divergent (clock skew or missing `createdAt` will trigger it). **Adjust reason codes**: `refund_correction | goodwill_credit | dispute_resolution | fraud_clawback | other` (controlled list, same pattern as passenger cancel reasons).
- **Passenger app cancel reason taxonomy (2026-05-18)**: Both passenger cancel endpoints now enforce a controlled list of reason codes via `normalizeCancelReason()` in `src/routes/passenger.ts`. Allowed codes: `changed_plans`, `waited_too_long`, `found_another_ride`, `booked_by_mistake`, `driver_too_far`, `price_too_high`, `vehicle_issue`, `other`. Anything not in the list is coerced to `other`. Firebase fields written: `cancelReason` (code), `cancelDetails` (free text, populated only when reason=`other`, max 500 chars). Downstream readers (SA-Towing.aspx, owner portals, reports) should map codes → human labels for display; the raw code is fine for filtering/grouping. Legacy records before 2026-05-18 have free-text in `cancelReason` — readers should fall back to displaying the value as-is if it doesn't match a known code.
- **Passenger app cancel endpoints (2026-05-17)**: `POST /api/passenger/towing/cancel/:jobId` body `{customerPhone, reason?}` — last-4-digit phone match auth, allowed only while status is `pending`/`assigned`, refunds Stripe pre-payment if present, patches `towingJobs/{cid}/{jobId}` + `towingJobIndex/{jobId}` to `status:'cancelled'`, emails the assigned company (or platform if still unassigned). `POST /api/passenger/rental/cancel/:jobId` body `{cancelToken? | customerEmail?, reason?}` — either token or email matches, refunds rental Stripe charge, releases deposit auth, frees `rentalAvailability` for the booked dates, patches `rentalReservations/{cid}/{reservationId}` + `allbookings/{cid}/{jobId}` to `status:'cancelled'`. Both track/booking GETs (`/api/passenger/towing/track/:jobId`, `/api/passenger/rental/booking/:jobId`) now return `companyPhone`, `canCancel`, and `cancellationPolicy {text, …}`. Operator overrides live at `bwConfig/towing/cancellationPolicy` (string) and `bwConfig/rental/cancellationPolicy {freeHours, text}` — defaults: towing free pre-dispatch only, rental free 48+ hrs before pickup.
- **`accClients/{cid}/{clientId}` schema + `percentPaid` (2026-05-17)**: ACC client record = `{ name, claimNumber, phone, serviceCode, wheelchair, percentPaid, notes, createdAt, updatedAt, purchaseOrders: { [poId]: PO } }`. `percentPaid` is the council/ACC subsidy percentage (0–100) — what's covered for that client. Passenger pays the remainder via Account, ACC claim, Card, TM card or Gift Card. PO record = `{ poNumber, dateFrom (YYYY-MM-DD), dateTo, qty, tripsUsed, maxPrice, managerName, managerEmail, branch, percentPaid (override, null=use client default), createdAt, updatedAt }`. **Effective subsidy at trip time = PO.percentPaid if set, else client.percentPaid, else 100.** `tripsUsed` is incremented by dispatch by transaction on each completed ACC trip — SA HQ only adjusts manually to correct mistakes. Writers: SA-ACCClients.aspx (HQ edit modal). Readers: dispatch (gates booking, computes split), driver app (display + completion split), passenger app + web booking (display "Council covers X%" + collect remainder via Account/ACC).
- **Menu item options schema**: `foodMenu/{rid}/items/{iid}/variants/{vid} = {name, priceDelta, sortOrder}` (exclusive choice e.g. size). `foodMenu/{rid}/items/{iid}/modifiers/{gid} = {name, required, multi, sortOrder, options:{[oid]:{name, price, sortOrder}}}` (optional add-on groups). Customer total = item.price + selectedVariant.priceDelta + sum(selectedModifierOptions.price).

## Pointers

- **Firebase Docs**: Refer to the official Firebase Realtime Database documentation for data structure and query understanding.
- **Express.js Docs**: Consult Express.js documentation for server-side routing and middleware.
- **Resend API Docs**: For email sending functionality.
- **Stripe API Docs**: For payment processing and webhook handling.
- **UIkit/jQuery/Bootstrap Docs**: For frontend component and interaction details.
- **`PLATFORM-INTEGRATION-CHECKLIST.md`**: For cross-app integration contracts.
- **`.local/firebase-checklist.md`**: Detailed Firebase field contract audit.
- **External Admin API**: `https://01067f31-afeb-4a32-a195-60c80223accf-00-dgff2mfkeoci.riker.replit.dev` for company account management.