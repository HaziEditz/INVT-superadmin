/**
 * Shared TM trip text search (council portal + SA).
 */

export type SearchableTrip = {
  _cid?: string;
  _rawKey?: string;
  bookingId?: string;
  id?: string;
  jobId?: string;
  passengerName?: string;
  tmCardName?: string;
  tmPassengerName?: string;
  customerName?: string;
  driverName?: string;
  driver?: string;
  tmCardNumber?: string;
  tmVoucherNo?: string;
  cardNumber?: string;
  allCardNums?: string[];
  allCards?: string;
};

function norm(v: unknown): string {
  return v == null ? '' : String(v).trim().toLowerCase();
}

/** True if query is empty or matches job/booking id, passenger, driver, or TM card number. */
export function tripMatchesSearch(trip: SearchableTrip | null | undefined, query: string | null | undefined): boolean {
  const q = norm(query);
  if (!q) return true;
  if (!trip) return false;

  const ids = [
    trip._rawKey,
    trip.bookingId,
    trip.id,
    trip.jobId,
  ]
    .map(norm)
    .filter(Boolean);

  const passengers = [
    trip.passengerName,
    trip.tmCardName,
    trip.tmPassengerName,
    trip.customerName,
  ]
    .map(norm)
    .filter(Boolean);

  const drivers = [trip.driverName, trip.driver].map(norm).filter(Boolean);

  const cards: string[] = [];
  const primary = norm(trip.tmCardNumber || trip.tmVoucherNo || trip.cardNumber).replace(/\s+/g, '');
  if (primary) cards.push(primary);
  if (Array.isArray(trip.allCardNums)) {
    trip.allCardNums.forEach((c) => {
      const n = norm(c).replace(/\s+/g, '');
      if (n) cards.push(n);
    });
  }
  const allCards = norm(trip.allCards).replace(/\s+/g, '');
  if (allCards) cards.push(allCards);

  const hay = ids.concat(passengers, drivers, cards).join(' ');
  const qCompact = q.replace(/\s+/g, '');
  return hay.includes(q) || (qCompact.length > 0 && hay.replace(/\s+/g, '').includes(qCompact));
}
