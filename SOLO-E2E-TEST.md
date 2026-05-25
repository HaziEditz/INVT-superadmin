# BookaWaka Solo E2E Test Script
**Company under test:** Invercargill Taxis Southland (`620611`)  
**Written:** 2026-05-06  
**Estimated time:** 60–90 minutes  
**What you need:** 2–3 devices (phone + laptop, or two phones + laptop)

---

## Before You Start — Fill In Your App URLs

Write these down before starting:

| App | URL / Store link | Your login |
|-----|-----------------|------------|
| Passenger app | | test passenger account |
| Driver app | | test driver account |
| Dispatcher | | dispatcher login |
| Owner portal | | Safinah / owner login |
| SA portal | (this Replit) | your SA login |

> **Important:** Do NOT use real customer accounts. Create test accounts for each role, or use existing test/demo accounts if you have them. All test bookings will appear in real Firebase — that is expected.

---

## TEST 1 — Standard Taxi Booking (Most Critical)

**Devices needed:** Phone A (passenger), Phone B or tab (driver), Laptop (dispatcher + SA portal)

---

### Step 1 — Dispatcher: Open and log in
- [ ] Open the Dispatcher on your laptop
- [ ] Log in with company `620611`
- [ ] Confirm you can see the dispatch board (map or job queue)
- ✅ Pass: Dispatcher loads, no errors
- ❌ Fail: White screen, login error, or "unauthorised"

---

### Step 2 — Driver app: Go online
- [ ] Open Driver app on Phone B
- [ ] Log in as a test driver for company `620611`
- [ ] Set status to **Online** / **Available**
- [ ] Confirm your vehicle/name appears on the Dispatcher map
- ✅ Pass: Driver pin appears on dispatcher map within 10 seconds
- ❌ Fail: Driver doesn't appear on map after 30 seconds → GPS path issue

> **Firebase check (SA portal side):** After this step, the driver should appear at `online/620611/{vehicleId}/current`. You can ask me to verify this from the SA portal.

---

### Step 3 — Passenger app: Book a trip
- [ ] Open Passenger app on Phone A
- [ ] Log in as a test passenger
- [ ] Book a trip:
  - Pickup: any real address in Invercargill
  - Dropoff: any real address in Invercargill
  - Payment: **Card** (or Cash — whichever works in test)
- [ ] Submit booking
- ✅ Pass: Booking confirmed, you see "Looking for a driver" or similar
- ❌ Fail: Error on booking, or booking disappears immediately

---

### Step 4 — Dispatcher: Assign the job
- [ ] On the laptop, the new booking should appear in the Dispatcher queue
- [ ] Assign it to your test driver
- ✅ Pass: Job assigned, driver is notified
- ❌ Fail: Job doesn't appear in queue → check `allbookings/620611` in SA portal

---

### Step 5 — Driver app: Accept and complete trip
- [ ] On Phone B, a notification should arrive for the new job
- [ ] Accept the job
- [ ] Tap "Start Trip" (or equivalent)
- [ ] Tap "Complete Trip" (or equivalent)
- ✅ Pass: Trip marked completed in driver app
- ❌ Fail: No notification arrives → check `notification/{driverId}` path

---

### Step 6 — Passenger app: Check receipt
- [ ] On Phone A, confirm the trip is marked complete
- [ ] Receipt or fare summary is shown
- [ ] Confirm the time shown is **NZ time** (NZST/NZDT), NOT UTC
- ✅ Pass: Correct fare, correct NZ timezone
- ❌ Fail: Time is 12–13 hours off → timezone bug

---

### Step 7 — SA portal: Verify the trip
- [ ] Open SA portal → **SA-Company** → select Invercargill Taxis Southland
- [ ] Open **SA-MasterReport** or the home dashboard
- [ ] The completed trip should appear in today's totals
- [ ] Check: fare amount matches what passenger saw
- ✅ Pass: Trip visible in SA portal reports
- ❌ Fail: Trip missing → check `allbookings/620611` path

---

### Step 8 — Owner portal: Check revenue
- [ ] Open Owner portal, log in as company `620611`
- [ ] Go to today's revenue / completed trips
- [ ] The test trip should appear
- [ ] Net payout = Fare minus commission (default 15%)
- ✅ Pass: Trip visible, amounts correct
- ❌ Fail: Trip missing or wrong amount

---

## TEST 2 — Driver Shift Logging

**Devices needed:** Phone B (driver), Laptop (SA portal)

---

### Step 1 — Driver app: Start a shift
- [ ] On Phone B, tap **Start Shift** (or Clock In)
- ✅ Pass: Shift started in app

### Step 2 — SA portal: Confirm shift appears
- [ ] Open SA portal → **SA-ShiftLogs**
- [ ] A new "Active" session should appear for your test driver
- [ ] Confirm the start time shown is **NZ time**, not UTC
- ✅ Pass: Session appears with correct NZ time
- ❌ Fail: No session → shift logging not writing to `shiftLogs/620611/{driverId}`

### Step 3 — Driver app: End the shift
- [ ] Tap **End Shift** (or Clock Out)
- [ ] SA portal → ShiftLogs → session now shows duration and end time
- ✅ Pass: Duration is correct, times match NZ timezone

---

## TEST 3 — Towing Request (Passenger App → Dispatcher)

**Devices needed:** Phone A (passenger), Laptop (dispatcher)

---

### Step 1 — Passenger app: Request a tow
- [ ] In Passenger app, select **Towing** or **Roadside Assist**
- [ ] Enter vehicle location and problem type (e.g. Flat Tyre)
- [ ] Submit request
- ✅ Pass: Request submitted, reference number shown

### Step 2 — Dispatcher: Tow request appears
- [ ] In Dispatcher, a tow request should appear
- [ ] Assign to a driver
- ✅ Pass: Request routable through dispatcher
- ❌ Fail: Request doesn't appear → check `towRequests/{refId}` path

---

## TEST 4 — SA Portal Admin Checks (Solo, laptop only)

These do not require other apps. Run these independently.

### 4.1 — Billing overview loads
- [ ] SA portal → Billing
- [ ] Invercargill Taxis Southland appears
- [ ] Trial end date shown correctly
- ✅ Pass: Company listed with plan "free_trial" and trial end date

### 4.2 — Subscription summary
- [ ] SA portal → Subscription Billing
- [ ] Company shown with correct plan
- [ ] Commission % = 15 (default)
- ✅ Pass: Data loads, no blank fields or errors

### 4.3 — Payout summary
- [ ] SA portal → Payouts
- [ ] Company shown with gross/commission/net breakdown
- [ ] Values match what you saw in Tests 1–2
- ✅ Pass: Numbers match

### 4.4 — Audit log
- [ ] SA portal → Audit Log
- [ ] Recent admin actions appear (login, etc.)
- ✅ Pass: Log entries present

### 4.5 — Session visibility
- [ ] SA portal → Sessions (SA-Sessions.aspx)
- [ ] Any active dispatcher sessions shown
- ✅ Pass: Sessions visible (or empty if nobody logged in)

---

## After Each Test — Record Result Here

| Test | Pass/Fail | Notes |
|------|-----------|-------|
| TEST 1 Step 1 — Dispatcher loads | | |
| TEST 1 Step 2 — Driver on map | | |
| TEST 1 Step 3 — Passenger books | | |
| TEST 1 Step 4 — Dispatcher assigns | | |
| TEST 1 Step 5 — Driver completes | | |
| TEST 1 Step 6 — Passenger receipt + NZ time | | |
| TEST 1 Step 7 — SA portal shows trip | | |
| TEST 1 Step 8 — Owner portal shows revenue | | |
| TEST 2 Step 1–3 — Shift logging | | |
| TEST 3 — Towing request | | |
| TEST 4.1 — Billing overview | | |
| TEST 4.2 — Subscription summary | | |
| TEST 4.3 — Payout summary | | |
| TEST 4.4 — Audit log | | |
| TEST 4.5 — Sessions | | |

---

## When Something Fails — What to Tell Me

For each failure, tell me:
1. Which step failed (e.g. "TEST 1 Step 5")
2. What you saw (error message, blank screen, wrong data)
3. Which device/app it was on

I can then check Firebase directly to find the exact problem.

---

## Cleanup After Testing

Once done, I'll delete all test bookings from Firebase so they don't affect reports. Just let me know when you're finished.
