## BookaWaka E2E Test — Passenger App Bug Report (2026-05-06)

These bugs were found during a solo end-to-end test run. Please fix and confirm when done.

---

### CRITICAL

**BUG 1 — Passenger app is running but not receiving any driver offers / ride matches**
The app appears to be online but when a booking is made, no driver offer or match notification arrives. The app just sits idle.
Possible causes to check:
1. Firebase listener on `rideStatus/{cid}/{bookingId}` may not be set up correctly
2. The booking's `companyId` may not be matching what the app is listening to
3. Push notification / FCM token may not be registered or sent correctly

Fix: confirm the passenger app is listening to `rideStatus/{cid}/{bookingId}` after a booking is created, and that the dispatcher is writing to this path when a driver is assigned.

---

### Missing test account

A test passenger account is needed for E2E testing. Please provide or create a test account:
- Email + password for a passenger test account
- Or confirm the passenger app has a guest/anonymous booking flow

---

### Passenger app — Firebase field contract reminders
- After booking: listen to `rideStatus/{cid}/{bookingId}` for driver assignment updates
- Driver location during trip: read from `online/{cid}/{vid}/current` → `{lat, lng, time}` (lat/lng are under `current` child, not top-level — this was a GPS bug fixed 2026-05-05, make sure your path is correct)
- Job record: `allbookings/{cid}/{bookingId}` — use `vehicleId` and `companyId` to build the driver GPS path
- Payment: card payments processed via Stripe. `POST /api/payment-config` for publishable key. No pay-on-arrival for web/app bookings.
