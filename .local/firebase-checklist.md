# Firebase Field Contract — BookaWaka Platform
**Last updated: 2026-05-06**
**Status: ALL TEAMS CLOSED. One parked item: net payout deduction via companies/{cid}/cardSettings (both SA portal + owner portal) — coordinate before card commission is activated. No ETA.**
**2026-05-06 additions:** Food order real-time status LIVE (`foodOrders/{cid}/{bookingId}/status` onValue listener). Freight post-booking tracking LIVE (`freightOrders/{cid}/{bookingId}` onValue listener, derives status from `pickupConfirmed`/`deliveryConfirmed`). Both written by passenger app with `food_<ts>` / `freight_<ts>` booking IDs.

This document is the authoritative reference for every Firebase path, field name,
field type, and who writes/reads it. If a new dev joins, start here.

---

## 1. Timezone Rule (non-negotiable)

| Rule | Correct | Wrong |
|------|---------|-------|
| Store timestamps | `new Date().toISOString()` → UTC ISO string | `new Date().toLocaleString()` or any local string |
| Display to user | `new Date(ts).toLocaleString('en-NZ', { timeZone: companyTimezone })` | `new Date(ts).toLocaleString()` with no timezone |
| "Today" / month grouping | `new Date(ts).toLocaleDateString('en-CA', { timeZone: 'Pacific/Auckland' })` → `"YYYY-MM-DD"` | `new Date().setHours(0,0,0,0)` or `.toISOString().slice(0,10)` |
| Company timezone constant | `"Pacific/Auckland"` for all NZ companies | Device timezone, server timezone |

---

## 2. completedJobs/{companyId}/{autoKey}

**Written by:** Driver app (hail / street pickup trips only)
**Read by:** SA portal (Home.aspx, TM-Trips.aspx, SA-PlatformHealth.aspx)

| Field | Type | Notes |
|-------|------|-------|
| `completedAt_ISO` | ISO string | Primary timestamp — use this for all date maths. Identical to `completedAt` for records written from 2026-05-05 onwards. |
| `completedAt` | ISO string | **Fixed 2026-05-05** — now `new Date().toISOString()` (same as `completedAt_ISO`). Pre-fix records contained a local NZ string — skip if not parseable as ISO/numeric. |
| `completedAt_NZ` | string | NZ display string e.g. `"5 May 2026, 2:30 pm"` — display only, written from 2026-05-05. |
| `CompletedAt` | string | Same NZ display string written for dispatcher console — capital C, from 2026-05-05. |
| `startedAt_ISO` | ISO string | Trip start time |
| `fare` | float | Trip fare in dollars |
| `meterFare` | float | Meter fare (fallback if `fare` missing) |
| `paymentType` | string | `"cash"`, `"card"`, `"total_mobility"`, `"account"` |
| `bookingType` | string | `"taxi"`, `"food"`, or `"freight"`. Written on hail trips from 2026-05-05 (Taxi/Food/Freight picker via `HailTripMeta`). Written on dispatched jobs from dispatcher `BookingType` field. Absent on pre-2026-05-05 hail records — use description keyword fallback. |
| `driverName` | string | |
| `vehicleId` | string | |
| `bookingId` | string | Links to `trips/{cid}/{tripId}` for TM jobs only |
| `cardNumber` | string | TM voucher number — present when `paymentType === "total_mobility"` |
| `tmVoucherNo` | string | Alternative TM voucher field — either `cardNumber` or `tmVoucherNo` will be present |
| `tmSubsidy` | float | Pre-calculated council subsidy — use if > 0 and < fare |
| `tmSubsidyFare` | float | Alternative subsidy field name — either `tmSubsidy` or `tmSubsidyFare` |
| `councilId` | string | Not written by driver app — looked up via `tmCards/{cardNumber}.councilId` |

**SA portal read order for timestamps:** `completedAt_ISO` → `completedAt`
**SA portal read order for fare:** `fare` → `meterFare`
**Food/freight hail trips — Option A LIVE (2026-05-05):**
- Hail start modal now shows Taxi / Food / Freight three-button picker before zone and payment fields.
- Selection flows through `startHailTrip` → `HailTripMeta` → written as `bookingType` to `completedJobs` at completion.
- Values written: `"taxi"`, `"food"`, `"freight"` — match exactly what owner portal and SA portal filter on.
- All hail trips from 2026-05-05 onwards will have `bookingType` present. Pre-fix records without `bookingType` fall back to description keyword match or Closed Jobs (Option B, still live as fallback for historical records).

---

## 3. allbookings/{companyId}/{bookingId}

**Written by:** Driver app (dispatched trips only — booked via dispatcher)
**Read by:** SA portal (Home.aspx, SA-PlatformHealth.aspx)

> **Historical records (before 2026-05-05):** Fields written in PascalCase only.
> **New records (from 2026-05-05):** Both PascalCase and lowercase aliases written together.

| Field | Type | Historical name | Notes |
|-------|------|----------------|-------|
| `completedAt_ISO` | ISO string | `CompletedAt_ISO` | Primary timestamp. Identical to `completedAt` for records from 2026-05-05+. |
| `completedAt` | ISO string | `completedAt` | **Fixed 2026-05-05** — now ISO string same as `completedAt_ISO`. Pre-fix: NZ display string — skip if non-parseable. |
| `completedAt_NZ` | string | — | NZ display string from 2026-05-05. Use for display only. |
| `CompletedAt` | string | `CompletedAt` | NZ display string for dispatcher console. From 2026-05-05 also written in lowercase form. |
| `startedAt_ISO` | ISO string | — | Trip start |
| `fare` | float | `FinalFare` | Trip fare |
| `meterFare` | float | — | Fallback fare |
| `paymentType` | string | — | Same values as completedJobs |
| `status` | string | `Status` | `"completed"` (new) / `"Completed"` (historical) — no other values |
| `driverName` | string | — | |
| `vehicleId` | string | — | |
| `bookingId` | string | — | Same as the record key |
| `cardNumber` | string | — | TM jobs only |
| `tmVoucherNo` | string | — | TM jobs only |
| `tmSubsidy` | float | — | TM jobs only |
| `tmSubsidyFare` | float | — | TM jobs only |

**SA portal read order for timestamps:** `completedAt_ISO` → `CompletedAt_ISO` → `completedAt`
**SA portal read order for fare:** `fare` → `FinalFare` → `meterFare`
**SA portal status filter:** `(j.status || j.Status || '').toLowerCase() === 'completed'`

---

## 4. shiftLogs/{companyId}/{driverId}/{sessionId}

**Written by:** Driver app
**Read by:** SA portal (SA-ShiftLogs.aspx, SA-PlatformHealth.aspx), Owner portal

| Field | Type | Notes |
|-------|------|-------|
| `startTime` | ISO string | Shift start |
| `endTime` | ISO string | Shift end (absent if still active) |
| `status` | string | `"active"` or `"completed"` |
| `totalMinutes` | integer | Total shift duration |
| `breakMinutes` | integer | Total break time within shift |
| `vehicleId` | string | |
| `driverName` | string | |
| `breaks/{breakId}/breakStart` | ISO string | Individual break start |
| `breaks/{breakId}/breakEnd` | ISO string | Individual break end |

---

## 5. trips/{companyId}/{tripId}

**Written by:** Driver app — **TM jobs only**
**Read by:** SA portal (TM-Trips.aspx, Home.aspx TM subsidy fallback)

| Field | Type | Notes |
|-------|------|-------|
| `cardNumber` | string | TM voucher number |
| `bookingId` | string | Links back to `completedJobs` or `allbookings` record |

> **Important:** `trips/{cid}` is **not** populated for cash, card, or account jobs.
> A missing `trips/{cid}/{bookingId}` entry for a non-TM job is expected and correct.

---

## 6. tmCards/{cardNumber}

**Written by:** SA portal (TM-Cards.aspx) — admin creates/edits cards
**Read by:** SA portal (TM-Trips.aspx, Home.aspx, SA-PlatformHealth.aspx), Council portal, Passenger app (lookup live from 2026-05-05)

| Field | Type | Notes |
|-------|------|-------|
| `passengerName` | string | Authoritative cardholder name |
| `councilId` | string | Which council issued this card — look up subsidy rate in `tmConfig/{councilId}` |
| `cardRegion` | string | Region string (from council config) |
| `active` | boolean | `true` = active, `false` = inactive/suspended. **Field is `active` (boolean), NOT `status` (string).** |
| `usageLimitMonthly` | number \| null | Monthly trip limit (null = no limit) |
| `usageLimitDaily` | number \| null | Daily trip limit (null = no limit) |
| `notes` | string | Admin notes |
| `updatedAt` | number | Unix ms timestamp |

> **councilId is looked up here** — it is not present on job records from the driver app.
> SA portal resolves: `j.councilId || tmCards[cardNumber].councilId`
>
> **Passenger app read logic (from 2026-05-05):**
> 1. No record → "Card number not recognised" — block booking
> 2. `active === false` → "Card has been suspended" — block booking  
> 3. `active !== false` (true or absent) → show `passengerName` from registry (read-only, "From registry" badge)
> 4. Write `councilId` to `tmPassengers[i].councilId`, `tmCouncilIds[]`, and `TmCouncilIds[]` on the booking
>
> ⚠️ **Mismatch fixed (2026-05-05):** Passenger app was initially checking `status === "suspended"` — but SA portal writes `active: boolean`, not a `status` string. Passenger app must check `active === false`, not `status`. Flagged and corrected.

---

## 7. tmConfig/{councilId}

**Written by:** Admin setup
**Read by:** SA portal for subsidy rate calculation

| Field | Type | Notes |
|-------|------|-------|
| `subsidyRate` | float | Percentage or fixed — depends on council config |
| `maxSubsidy` | float | Cap per trip |
| `councilName` | string | |

---

## 8. superClients/{companyId}

**Written by:** Admin / SA portal
**Read by:** SA portal — company list, module flags, config

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | Company display name |
| `status` | string | `"active"` / `"suspended"` |
| `modules.taxi` | boolean | Taxi module enabled |
| `modules.foodDelivery` | boolean | Food delivery enabled |
| `modules.freight` | boolean | Freight enabled |
| `modules.towing` | boolean | Towing enabled |
| `modules.rental` | boolean | Rental enabled |
| `modules.totalMobility` | boolean | TM enabled |
| `timezone` | string | e.g. `"Pacific/Auckland"` |

---

## 9. SA Portal Read Patterns (copy-paste safe)

```javascript
// Timestamp — handles all field name variants across historical + new records
function _jobTs(j) {
  return j.completedAt_ISO || j.CompletedAt_ISO || j.completedAt || '';
}

// Fare — handles PascalCase historical allbookings records
function _jobFare(j) {
  return +(j.fare || j.FinalFare || j.meterFare || 0);
}

// Status — case-insensitive, handles both field name capitalisation variants
function _jobDone(j) {
  return (j.status || j.Status || '').toLowerCase() === 'completed';
}

// TM voucher number — checks job record first, then trips/{cid} via bookingId
function _tmCard(j, tripsData) {
  var n = j.tmVoucherNo || j.cardNumber || '';
  if (!n && j.bookingId && tripsData && tripsData[j.bookingId]) {
    n = tripsData[j.bookingId].cardNumber || '';
  }
  return n;
}

// councilId — job record first (rarely present), then tmCards lookup
function _councilId(j, cards, cardNum) {
  return j.councilId || (cards[cardNum] || {}).councilId || '';
}
```

---

## 10. bookings/{companyId}/{bookingId}

**Written by:** Passenger app (all ride types)
**Read by:** SA portal (SA-Company.aspx live bookings panel)

> **Historical records (before 2026-05-05 commit b8dec66):** Only have `CreatedAt` (ms number),
> `pickup`, `destination`, `paymentMethod`. Missing `requestedAt`, `pickupLocation`,
> `dropoffLocation`, `paymentType`, `tmPassengers`, `tmVoucherNumbers`.
>
> **New records (from b8dec66):** All fields below written in full.

| Field | Type | Historical name / fallback | Notes |
|-------|------|---------------------------|-------|
| `requestedAt` | ISO string | `CreatedAt` (ms number) | Booking creation time — use for sorting and display |
| `RequestedAt` | ISO string | PascalCase alias | Both written |
| `pickupLocation` | object | `pickup` | `{address, lat, lng}` — use `.address` for string; `pickupAddress` is the safe flat-string field |
| `dropoffLocation` | object | `destination` | `{address, lat, lng}` — use `.address` for string |
| `paymentType` | string | `paymentMethod` | `"cash"`, `"card"`, `"total_mobility"`, `"account"` |
| `tmPassengers` | array | — | `[{cardNumber, cardholderName, expiryDate, needsHoist}, …]` — one entry per TM card |
| `tmVoucherNumbers` | array | — | Flat array of card number strings — quick scan alternative |
| `estimatedFare` | float | `fare` | Total trip fare for all passengers combined |
| `tmCouncilAmount` | float | — | Fare subsidy portion only, pre-calculated by passenger app (single-cap — use SA per-card recalc for multi-pax) |
| `tmPassengerAmount` | float | — | Passenger fare share only (bug fixed in passenger app — was incorrectly including hoistFee before) |
| `tmHoistCount` | int | — | Number of passengers requiring hoist lift |
| `tmHoistFeeTotal` | float | — | **New field** — total hoist fee for the trip. Silently dropped before passenger app fix (commit 24d54ac); now written to all booking paths. Historical reconstruction: `tmHoistCount × hoistFeePerLift` — **SA portal hardcodes $5.00** (value at `tm_settings/config` in Firestore). Safe while rate is unchanged. **Risk:** if per-lift rate is ever updated in Firestore, the $5.00 hardcode drifts for any pre-fix records made after that rate change. Check `tm_settings/config` at that point and update the fallback accordingly. |
| `passengerName` | string | — | Now sourced from `users/{uid}/name`, not `fbUser.displayName` |
| `status` | string | — | `"scheduled"`, `"pending"`, `"accepted"`, `"inprogress"`, `"completed"`, `"cancelled"` |
| `driverName` | string | `assignedDriver` | |

**SA portal read order for timestamp:** `requestedAt` (ISO→ms) → `CreatedAt` (ms) → `createdAt` (ms)
**SA portal pickup/dropoff:** `pickupAddress || pickup || pickupLocation.address || —`
**SA portal TM card:** `tmVoucherNo || cardNumber || tmPassengers[].cardNumber (all) || tmVoucherNumbers[] (all)`

**NZ TM multi-passenger subsidy formula (confirmed by passenger app dev):**
```
farePerCard    = estimatedFare / tmPassengers.length
subsidyPerCard = min(farePerCard × councilSubsidyPct, councilCap)   ← cap applied PER CARD
tmSubsidyFare  = sum of subsidyPerCard across all cards
hoistSubsidy   = tmHoistFeeTotal (council-covered) — fallback: tmHoistCount × 5.00
totalCouncilPays = tmSubsidyFare + hoistSubsidy
```
Single-cap on full fare under-claims. Example: $100 fare, 2 passengers, 50% rate, $37.50 cap
→ Correct: $50/card → $25/card → $50 fare subsidy + hoist if applicable
→ Wrong (single-cap): $37.50 fare subsidy (under-claims by $12.50)

**Council claim reconciliation fields (use these to cross-check SA-calculated totals):**
`tmCouncilAmount` = fare subsidy stored by app (single-cap — differs from SA for multi-pax)
`tmHoistFeeTotal` = hoist subsidy stored by app (new, written from passenger app fix onward)
`tmCouncilAmount + tmHoistFeeTotal` = total council claim per booking as app sees it
**SA portal path:** `allbookings/{companyId}` — NOT `bookings/{companyId}` (does not exist)

---

## 11. Sign-off Log

| Date | Item | Driver App Dev | Passenger App Dev | SA Portal Dev |
|------|------|---------------|------------------|---------------|
| 2026-05-05 | Timezone handling — all 3 rules | ✅ Fixed (lib/timezone.ts) | ✅ Fixed throughout | ✅ Fixed |
| 2026-05-05 | shiftLogs path + all fields | ✅ Confirmed | n/a | ✅ Reading correctly |
| 2026-05-05 | completedAt_ISO field name | ✅ Confirmed | n/a | ✅ Fixed |
| 2026-05-05 | cardNumber in completedJobs + allbookings | ✅ Fixed | ✅ tmPassengers written | ✅ Fallback added |
| 2026-05-05 | allbookings path for dispatched trips | ✅ Confirmed | n/a | ✅ Both paths merged |
| 2026-05-05 | Status capitalisation (Status:"Completed") | ✅ Lowercase alias added | n/a | ✅ Case-insensitive filter |
| 2026-05-05 | FinalFare → fare alias (historical allbookings) | ✅ Lowercase alias added | n/a | ✅ Fallback added |
| 2026-05-05 | CompletedAt_ISO → completedAt_ISO (historical) | ✅ Lowercase alias added | n/a | ✅ Fallback chain added |
| 2026-05-05 | councilId — looked up via tmCards, not driver field | ✅ Confirmed | n/a | ✅ Confirmed |
| 2026-05-05 | trips/{cid} — TM only, gap on non-TM is expected | ✅ Confirmed | n/a | ✅ Confirmed |
| 2026-05-05 | requestedAt (ISO) replacing CreatedAt (ms) on bookings | n/a | ✅ Both written (b8dec66) | ✅ Fallback added |
| 2026-05-05 | pickupLocation / dropoffLocation — object {address,lat,lng} | n/a | ✅ Confirmed object shape | ✅ Fixed to use .address |
| 2026-05-05 | paymentType alias for paymentMethod | n/a | ✅ Written (b8dec66) | ✅ Fallback added |
| 2026-05-05 | tmPassengers array + tmVoucherNumbers flat array | n/a | ✅ Written to all 3 paths | ✅ Fallback added |
| 2026-05-05 | passengerName from users/{uid}/name not displayName | n/a | ✅ Fixed (b8dec66) | ✅ Reading passengerName |
| 2026-05-05 | toISOString().slice(0,10) removed from rental API | n/a | ✅ Fixed (Intl.DateTimeFormat) | n/a |
| 2026-05-05 | Historical bookings missing requestedAt/pickupLocation etc | n/a | ✅ Documented | ✅ Fallback to CreatedAt/pickup |
| 2026-05-05 | bookings/{cid} path wrong — should be allbookings/{cid} | n/a | ✅ Confirmed correct path | ✅ Fixed — was silently reading empty path |
| 2026-05-05 | TM multi-passenger — tmPassengers[0] missed all but first | n/a | ✅ Confirmed multi-passenger possible | ✅ All cards/names now iterated |
| 2026-05-05 | TM multi-passenger subsidy formula — per-card cap, not single cap | n/a | ✅ Confirmed NZ TM rule + fields | ✅ Per-card calculation implemented |
| 2026-05-05 | estimatedFare / tmCouncilAmount / tmPassengerAmount / tmHoistCount | n/a | ✅ Fields confirmed and written | ✅ Added to fare chain and trip object |
| 2026-05-05 | tmHoistFeeTotal — new field, was silently dropped before passenger app fix | n/a | ✅ Now written to all booking paths | ✅ Added to hoist chain; historical fallback tmHoistCount × $5.00 |
| 2026-05-05 | tmPassengerAmount bug — was passenger fare + hoist, now fare only | n/a | ✅ Fixed and deployed by passenger app dev | ✅ Checklist note updated |
| 2026-05-05 | Home.aspx monthly council claim missing hoist fee | n/a | ✅ Confirmed hoist is council-covered | ✅ hoistFee now added to tmClaim |

**Passenger app + driver app + SA portal items: all closed.**

---

## 12. Owner Portal Dev Audit (2026-05-05)

### Timezone fixes confirmed (all patterns resolved)

| Pattern | Was | Now |
|---------|-----|-----|
| `NZ_TZ` declaration (5 pages) | `Intl.DateTimeFormat().resolvedOptions().timeZone` (browser TZ) | `window.COMPANY_TZ` from `companySettings/{cid}/timezone` |
| Calendar date comparisons | `.toISOString().slice(0,10)` | `window._tzTodayStr(NZ_TZ)` |
| Midnight anchors | `.setHours(0,0,0,0)` | `window._tzTodayStart(NZ_TZ)` |
| Month key grouping | `d.getFullYear()+'-'+d.getMonth()` | `_tmMonthKey(ms)` → `.toLocaleDateString('en-CA',{timeZone:NZ_TZ}).slice(0,7)` |
| "Is today" check | UTC `getMonth()/getDate()` | Compare `.toLocaleDateString('en-CA',{tz})` strings |
| Formatters (11 calls) | `.toLocaleDateString('en-NZ',{...})` no timeZone | All now pass `timeZone: NZ_TZ` |
| Server-side expiry | `.setHours(0,0,0,0)` on UTC server | `.toLocaleDateString('en-CA',{timeZone:'Pacific/Auckland'})` + UTC midnight anchor |

**Global helpers injected via commonScripts (all pages):**
- `window.COMPANY_TZ` — synced from `companySettings/{cid}/timezone` (async, default `'Pacific/Auckland'`)
- `window._tzTodayStr(tz)` — `"YYYY-MM-DD"` in company TZ
- `window._tzTodayStart(tz)` — Unix-ms for `00:00:00` in company TZ

### Firebase paths confirmed by owner portal

| Path | Confirmed | Notes |
|------|-----------|-------|
| `completedJobs/{cid}` | ✅ Hail trips only | Taxi, TM, and **hail** food/freight trips — differentiated by `bookingType` field (not `serviceType` — that field does not exist). Dispatched food/freight go to `foodOrders`/`freightOrders` + `allbookings`. |
| `tmBatches/{councilId}/{cid}/{yearMonth}` | ✅ | TM trips also mirrored here for claim batches |
| `companySettings/{cid}/timezone` | ✅ Ground truth | IANA string e.g. `'Pacific/Auckland'` — all portals source from here |
| `companySettings/{cid}/cardSettings` | ✅ Exists | Card processing fee config — not currently used in any portal report totals |
| `joback` | ⚠️ Global/flat, mixed-company | Legacy node — owner portal reads `limitToLast:500` and merges; `completedJobs/{cid}` entries win on conflict. `joback/620611` confirmed empty — all trips in `completedJobs/620611`. |
| `foodOrders/{cid}/{bookingId}` | ✅ Confirmed | Dispatched food delivery jobs — written when `bookingType` contains food/meal/restaurant/deliver. Also writes to `allbookings/{cid}`. **Correct path is `foodOrders` not `fdOrders`.** |
| `freightOrders/{cid}/{bookingId}` | ✅ Confirmed | Dispatched freight/courier jobs — written when `bookingType` contains freight/parcel/cargo. Also writes to `allbookings/{cid}`. **Correct path is `freightOrders` not `frOrders`.** |
| `fdOrders/{cid}` / `frOrders/{cid}` | ❌ Wrong paths | These names do NOT exist in the driver app. Any portal using these paths reads nothing. See `foodOrders` / `freightOrders` above. |
| `shiftLogs/{cid}/{driverId}/{sessionId}` | ⚠️ Empty | Driver app confirmed NOT writing here — open gap |

### Revenue fare chain (owner portal + SA portal)

**Sources read (owner portal, confirmed 2026-05-05):**
- `completedJobs/{cid}` — hail trips (taxi, TM, hail food/freight)
- `foodOrders/{cid}` — dispatched food delivery ✅ (correct path, not `fdOrders`)
- `freightOrders/{cid}` — dispatched freight ✅ (correct path, not `frOrders`)
- `joback` — global, `limitToLast:500`, merged on conflict; `completedJobs/{cid}` wins
- `allbookings/{cid}` — all five merged by bookingId before totals; no double-counting

**⚠️ allbookings PascalCase fields (owner portal bug — fixed 2026-05-05):**
`allbookings/{cid}` stores fare as `FinalFare` (Title-Case) and timestamp as `CompletedAt_ISO` (Title-Case). Owner portal pickers were not including these → allbookings-only records contributed $0 to totals. Fixed: both pickers now include PascalCase variants.
**SA portal status:** Already handles both casings — `j.fare||j.FinalFare` and `j.completedAt_ISO||j.CompletedAt_ISO` in Home.aspx and SA-PlatformHealth.aspx. No change needed.

**Fare chain (all portals):** `estimatedFare` → `fare` → `FinalFare` → `totalFare` → `amount` → `fareAmount` → `meterFare`

**Payout deduction — current state (raw fare, no deduction):**
Both owner portal and SA portal display raw fare. No commission or card fee applied.
Deduction config exists at `companies/{cid}/cardSettings` (commission %, driver card fee per card payment) but is not wired into any report. Flagged as future sprint item — both portals need to read `cardSettings` and apply per `paymentMethod` per job to show net payout alongside gross. No ETA.

### Driver app gaps surfaced by owner portal audit (6 items — flagged to driver app dev)

| # | Gap | Status | Resolution |
|---|-----|--------|-----------|
| 1 | **`completedAt` written as local string** | ✅ FIXED (2026-05-05) | `completedAt` now writes `new Date().toISOString()` — identical to `completedAt_ISO`. Display string moved to `completedAt_NZ` and `CompletedAt`. SA portal fallback chain remains safe for old records. |
| 2 | **`shiftLogs/{cid}` is empty** | ✅ RESOLVED — code correct, no shifts run yet | Driver app writes to correct path with correct fields. Empty because no driver has completed a full shift on this React Native build for company 620611 yet. Will populate on first real shift. |
| 3 | **`joback` is global/flat** | ✅ CONFIRMED — not used | `joback` is not written anywhere in this app. `completedJobs/{cid}` (hail) and `allbookings/{cid}` (dispatched) are the only write paths. |
| 4 | **`lastshifttime` key format mismatch** | ✅ RESOLVED — numeric IDs are correct | Driver app uses numeric API-assigned driver ID (e.g. `"1271"`) as key — same as what Firebase already contains. `"D001"` format is from a different app or manual entry. No migration needed. |
| 5 | **Food/freight path and hail gap** | ✅ FULLY CLOSED | Dispatched: `foodOrders`/`freightOrders` paths, `bookingType` field confirmed. Hail: Option A live (2026-05-05) — Taxi/Food/Freight picker on meter start modal. `bookingType` written to `completedJobs` on completion using exact filter keywords. Historical records without `bookingType` handled by description keyword fallback (Option B, still active). |
| 6 | **`activeSessionId` not cleared on disconnect** | ✅ RESOLVED — intentional design | `activeSessionId` is a single string on `drivers/{cid}/{uid}/activeSessionId` — overwrites on each login, cannot accumulate. No `.onDisconnect().remove()` by design: signal loss mid-shift would incorrectly clear an active session. Separate disconnect handling in place. |

---

## 13a. Driver App Audit — Round 2 (2026-05-05)

### Confirmed correct (no changes needed)

| Item | Detail |
|------|--------|
| GPS update frequency | `watchPositionAsync` fires every 2s. Firebase rate-limited to 1 write per 10s. Written to `online/{cid}/{vid}/current` with fields: `lat`, `lng`, `hasGps: true`, `time` (ISO). |
| TM trip flagged in meter | Dispatched TM: `extras.tmVoucherNo` → full `trips/{cid}/{bookingId}` write in `completeJob`. Hail TM: `completeHailTrip` checks `paymentType === 'total_mobility'`. MeterPanel shows "TOTAL_MOBILITY" in running info row. |
| Trip completion fields | All payment types covered in both `completeJob` and `completeHailTrip`. Cash ✅ Card ✅ TM ✅ Account/ACC ✅ |
| ACC payment | Hail: all ACC fields written to `completedJobs`. Dispatch: `tripsUsed` PO counter incremented via transaction. |

### Fixed and shipped (2026-05-05)

**Cancellation path** — `cancelTrip()` now writes to `allbookings/{cid}/{bookingId}`:
```
status:      'Cancelled'
Status:      'Cancelled'     (PascalCase for portals that check this key)
CancelledAt: ISO string
CancelledBy: 'driver'
```
Cancelled trips will no longer appear as open bookings in revenue reports.

**Freight POD** — `freightOrders/{cid}/{bookingId}` now receives two confirmation writes:
```
pickupConfirmed:    true             (Phase 2 Arrived screen — "Confirm Freight Picked Up")
pickupConfirmedAt:  ISO string
deliveryConfirmed:  true             (on "Complete Drop-off")
deliveredAt:        ISO string
driverId:           string
vehicleId:          string
```
Both writes are non-blocking — never gate the job flow.

**Rating** — post-trip 1–5 star modal after food/freight completion (dispatched) and hail trip end. Optional. Written to:
- `driverRatings/{cid}/{bookingId}` — universal path. Both owner portal and SA portal should read from here.
- `allbookings/{cid}/{bookingId}/driverRating` — also patched on dispatched trips for direct booking record access.

### GPS path — CLOSED ✅

Dispatcher confirmed reads `online/{cid}/{vid}` (correct path, company-isolated). Bug was one level deeper: `lat/lng` live under the `current` child, not top-level. Fixed with `driverData.lat || driverData.current?.lat` (backward-compatible). Car markers now move in real time.

### ✅ CLOSED — Both dispatcher questions resolved (2026-05-06)

**Q1: vehicleId + companyId in job payload — FIXED**

Two gaps found and patched by dispatcher dev:
- **Gap A**: `writeJobDetailsToFirebase` accepted `vehicleId` as a parameter but never wrote it into `fullPayload`. Passenger app had no `vehicleId` to build `online/{cid}/{vid}/current`. **Fixed** — `vehicleId` and `companyId` now written into `fullPayload` on every dispatch.
- **Gap B**: `jobDetails` was written to `/jobDetails/{bookingId}` (flat, no company isolation). Passenger app reading `/jobDetails/{cid}/{bookingId}` got nothing. **Fixed** — path is now `/jobDetails/{companyId}/{bookingId}`.
- `rideStatus/{cid}/{bookingId}` already had `vehicleId` correctly — unchanged.

**Q2: TM voucher bridge — FIXED at all three layers**

Three-layer gap, all three patched:

| Layer | Before | After |
|-------|--------|-------|
| `_normFbJob` (server ingest) | All TM fields discarded | Normalises 10 TM fields; `tmVoucherNumbers[0]` → `tmVoucherNo` |
| `_doSend` (job offer builder) | No TM fields passed to `writeJobDetailsToFirebase` | Extracts all TM fields (camelCase + PascalCase aliases) |
| `writeJobDetailsToFirebase` (Firebase write) | No `extras` key in `fullPayload` | Writes `extras: { tmVoucherNo, tmPassengerName, tmCardExpiry, tmSubsidy, tmSubsidyHoist, tmPassengerPays, tmHoistRequired, tmHoistCount, tmPaymentMethod }` when voucher present |

Driver app now receives `extras.tmVoucherNo` on dispatched TM trips → `trips/{cid}/{bookingId}` written → SA portal TM subsidy chain intact for passenger-app TM bookings routed via dispatcher.

---

## 13. Dispatcher Dev Audit (2026-05-05)

### Confirmed (written to Firebase by dispatcher)

| Path | Written by | Fields | Notes |
|------|-----------|--------|-------|
| `notification/{driverId}` | Dispatcher (Default.aspx) + Driver app (outgoing chat) | `bookingid, joboffer, jobpickup, jobdropoff, JobphoneNo, jobname, jobbags, jobpassengers, jobvehicletype, jobFare, jobServiceType, jobBookingSrc` | Job offer to driver — flat path. **Driver app primary listener ✅ confirmed.** |
| `notification/{vehicleId}` | Dispatcher (optional) + Driver app (outgoing chat) | Same job offer payload | Driver app has relay listener — copies to `notification/{driverId}` so offers arrive regardless of which key dispatcher uses. Driver app also writes here on outgoing chat. ✅ |
| `notification/{companyId}/{key}` | ❌ NOT used | — | Driver app has NO listener on nested path. ChatRoom.js (dispatcher) has a listener at line 445 but it is guarded by `_notifFirstLoad` and nobody writes to this path — fires zero times. Dead code, cleanup-only, no urgency. |
| `jobDetails/{bookingId}` | Dispatcher (Default.aspx) | Same payload as notification | ✅ CLOSED — confirmed company-isolated: `jobDetails/{cid}/{bookingId}` |
| `autodisp/{driverId}` | Dispatcher (Default.aspx) | `{bookingid}` only | Auto-dispatch offer — driver must do second lookup for job details |
| `rideStatus/{cid}/{jobId}` | Dispatcher (Default.aspx) | `{RecallStatus, recalledAt, message}` | Written on **recall only** — not on assignment |
| `rentalTaxiRequests/{requestId}` | Dispatcher + server.js | `{status:'confirmed', assignedDriverId, assignedAt, jobId}` on assignment; `{status:'completed', completedAt, jobId}` on completion; `{status:'cancelled', cancelledAt, jobId}` on cancel | ✅ CLOSED — completion patch live across all 5 paths |
| `activeDispatchers/{cid}/{sessionKey}` | Dispatcher (Default.aspx) | `{email, uid, companyId, loginTime, heartbeat, ip, ua, sessionKey}` | Dispatcher heartbeat — SA-Sessions.aspx reads this |
| `jobs/{cid}/{vehicleId}/{driverId}` | Dispatcher (Default.aspx) | `{Status:'Cancelled', BookingId}` | Cancel/away only |
| `adminAccess/{cid}/{uid}` | server.js | `true` | User registration |
| `users/{uid}/companyId, companyName` | server.js | strings | User registration |

### Dispatcher round-2 findings (2026-05-05)

**Confirmed correct (no changes needed):**

| Item | Detail |
|------|--------|
| All booking types in queue | `buildJobListResponse` has no type filter. Taxi/food/freight/TM all appear. Color badges: food=green, freight=orange, TM=purple, with correct icon per type. |
| TM flagged in UI | TM badge on every queue card when `PaymentType==='total_mobility'`. Purple left border. Full TM detail panel in job popup: voucher number, passenger name, card expiry, subsidy, passenger-pays amount, hoist fields. |
| Assignment fields | `writeJobDetailsToFirebase` called on every assignment path. Writes: `pickup, dropoff, phone, name, bags, passengers, vehicleType, serviceType, bookingSource, status, u_id`. Also writes `rideStatus/{cid}/{jobId}` with `driverId, vehicleId, updatedAt`. |
| Recall status | `rideStatus/{cid}/{jobId}` gets `.update({ RecallStatus:'Recalled', recalledAt, message })` — `.update()` not `.set()` so `driverId`/`status` preserved. |

**Fixed and shipped (2026-05-05):**

- **Food/freight badge gap** — `_normFbJob` (Firebase→jobStore normaliser) was dropping `serviceType` and `bookingType` entirely. Fixed: now reads `serviceType`, `ServiceType`, `bookingType`, `BookingType` with alias mapping (`delivery`→`freight`, `restaurant`→`food`). Both Scheduled and Waiting ingest paths updated. Queue cards now render correct colour badge immediately.
- **Tow alert gap** — no `towRequests` listener existed. Fixed: added `towRequests/{companyId}` Firebase listener. On new request: red banner (🚨 driver, vehicle, location, note, time), new-job sound, 30-second display, `_dispatcherAlerted: true` written back so reconnect doesn't re-fire the same alert.

### Open Issues

| # | Issue | Affects SA | Action |
|---|-------|-----------|--------|
| 1 | **`rentalTaxiRequests` completion patch** | ✅ CLOSED — patch live across all 5 completion paths (DriverStatusChanged/DP+DS, ForceCompleteJob, UpdateBooking, SOT offline sync). Cancellation paths excluded. Retry: closedJobStore first (durable), Firebase patch, retry once after 4s. Final-failure log: `console.error('[rental-complete] Firebase patch failed after retry', { rentalKey, jobId, completedAt, error })` — searchable by rentalKey. First-attempt failures demoted to `console.warn` (retry already queued). |
| 2 | **`notification` path** | ✅ CLOSED | Flat path confirmed correct. Driver app listens on `notification/{driverId}` (primary) and `notification/{vehicleId}` (relay). Nested `notification/{cid}/{key}` is NOT listened to — any write there is silently dropped. Dispatcher flat path write is correct and job offers are reaching drivers. |
| 3 | **`jobDetails/{bookingId}` no company isolation** | ✅ CLOSED | Dispatcher confirmed it already writes to `jobDetails/{cid}/{bookingId}` — company-isolated. No flat path overwrite risk. No change needed. |
| 4 | **ChatRoom.js dead listener on `notification/{companyId}`** (line 445) | ✅ CLOSED | Dead 26-line block removed (2026-05-06). No Firebase subscription opened, no child_added callback, noisy console.log gone. Driver→dispatcher messages still arrive via `notification/{driverId}` as before. |
| 5 | **GPS path + sub-node bug** | ✅ CLOSED | Dispatcher reads `online/{cid}/{vid}` — correct path + company isolation. Bug was one level deeper: driver writes to `online/{cid}/{vid}/current`, so `lat/lng` are under `current`, not top-level. Map was reading `driverData.lat` (undefined) → `parseFloat(NaN)` → all drivers frozen at (0,0). Fix: `_gpsLat = driverData.lat \|\| driverData.current?.lat`. Backward-compatible (top-level tried first for older app versions). Real-time car marker movement restored. |
| 6 | **`serviceType` field casing** | ✅ CLOSED | Driver app reads `BookingType` (PascalCase) — never read `serviceType`. Fixed on driver app: both normalizers now cascade `BookingType → bookingType → serviceType → ServiceType`. Dispatcher keeps writing `serviceType` as-is. TypeScript clean. No dispatcher change needed. |

### Confirmed NOT in Firebase (dispatcher uses SQL/in-memory)
- Regular job assignment (DriverId, VehicleId, assignedAt) — SQL only; SA portal reads completed trips from `allbookings/{cid}`, not in-flight state — no SA impact
- `JobCompleteTime` (UTC ISO) on completion — SQL/in-memory only; aliased as `completedAt` in REST response shape; SA reads `completedAt_ISO` from Firebase (`allbookings`) written by driver/passenger app, not dispatcher — no SA impact

### Timezone (dispatcher)
- Storage: all UTC ISO (`new Date().toISOString()`) confirmed throughout
- `_tzTodayStart(tz)` bug fixed: was using `getTimezoneOffset()` (returns 0 on UTC server); now uses Intl probe for true IANA offset — server-TZ-agnostic

---

## 14. Website Dev Audit (2026-05-05)

### Timezone — confirmed clean
- Storage: `new Date().toISOString()` (UTC) throughout
- Display: `.toLocaleString("en-NZ", { timeZone: "Pacific/Auckland" })` throughout
- Full codebase audit done — one violation found and corrected (booking confirmation screen)

### Firebase paths confirmed (written by website)

| Path | Fields written | SA portal reads it? | Notes |
|------|---------------|---------------------|-------|
| `onboardRequests/{refId}` | serviceType, businessTypes, businessName, contactName, email, phone, city, country, submittedAt (ISO UTC), status: "pending", source: "website" | ✅ SA-Onboard.aspx | Merged with external Admin API records, deduplicated by email. **Keep writing.** |
| `registrations/{refId}` | Same fields as onboardRequests | ✅ SA-Registrations.aspx | Different SA page — direct Firebase approve/reject flow. **Keep writing. Not a duplicate.** |
| `pendingjobs/{cid}/{bookingId}` | Full booking record | ✅ Dispatcher pickup | Dispatcher polls this for incoming web bookings |
| `allbookings/{cid}/{bookingId}` | Full booking record + assigned driver/vehicle fields | ✅ SA portal, Owner portal | Shared history path — same node as driver app dispatched completions |
| `Passengerjobs/{passengerKey}/{bookingId}` | Booking record | — | Passenger's My Rides page only — not read by SA portal |
| `towRequests/{refId}` | Tow request record | — | Tow portal — not currently read by SA portal |
| `contactInquiries/{inquiryId}` | inquiryId, submittedAt (ISO UTC), status: "unread", name, email, subject, message, source: "website" | ❌ Not yet | New path as of 2026-05-05. SA portal has no reader yet — flagged as future feature. |

### Confirmed NOT written by website to Firebase
- `fdRestaurants/{cid}` — food delivery page is static marketing only. "Order Now" → general booking flow. Dynamic restaurant listing from Firebase not built yet.

### Open items (website)

| # | Item | Status |
|---|------|--------|
| 1 | Registration path canonical question | ✅ RESOLVED — write to BOTH. `onboardRequests/` → SA-Onboard.aspx; `registrations/` → SA-Registrations.aspx. Different pages, not duplicates. |
| 2 | `contactInquiries/` SA portal reader | ⬜ Future feature — SA portal needs a new page/section to read, filter, and update status on contact inquiries. |
| 3 | `fdRestaurants/` dynamic food listing | ⬜ Future feature — website food page currently static. Dynamic listing is a separate build when ready. |
