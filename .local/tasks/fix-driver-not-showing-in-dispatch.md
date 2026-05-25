# Fix Driver Not Showing in Dispatch After Login

## What & Why
When a driver logs in through the driver app, they are not appearing as available in the dispatch console. The SA portal's normalizer is responsible for keeping the top-level `online/{cid}/{vid}/vehiclestatus` field consistent (which is what dispatch reads), but its current condition is too narrow — it only patches `Away → Available` when `current.online === true`. If the driver app doesn't write `current.online`, or the top-level status is `null`/`undefined` (fresh login), the condition never fires and dispatch never sees the driver.

## Done looks like
- A driver who logs in via the driver app and sets their status to Available appears in the dispatch console within 30 seconds (one normalizer tick)
- The fix handles all cases: top-level status is `Away`, `null`, `undefined`, or any non-`Available` value
- Existing behaviour for drivers in a dispatch queue (joboffer / queueWaitSince) is preserved — they are not incorrectly reset to Available
- No regressions to the paymentStatus, bookingNotifications, or stale pending jobs normalizer sections

## Out of scope
- Changes to the driver app or dispatch app themselves
- Handling driver logout / going offline (that is written directly by the driver app to Firebase)
- Firebase rules changes

## Steps
1. **Widen the vehiclestatus normalizer condition** — Change the patch condition in `src/normalizer.ts` so that if `current.vehiclestatus === 'Available'` and the top-level `vehiclestatus` is anything other than `'Available'` (including missing/null), and the driver is not in a dispatch queue, patch the top-level to `'Available'`. Remove the requirement for `current.online === true` as the gate — use `currentStatus === 'Available'` as the primary signal that the driver is online and ready.

2. **Add a log line for the new case** — Log clearly when the patch fires due to a missing or unexpected top-level status (not just the `Away` case) so future debugging is easier.

3. **Smoke test with Firebase data** — Manually verify in the Firebase console that after a driver logs in, the `online/{cid}/{vid}` node reflects `vehiclestatus: 'Available'` at the top level within one normalizer interval.

## Relevant files
- `src/normalizer.ts:28-62`
