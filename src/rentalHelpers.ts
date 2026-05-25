export function rentIsAvailable(avData: any, vehicleId: string, pickupDate: string, returnDate: string): boolean {
  const vAv = (avData && avData[vehicleId]) || {};
  let d = new Date(pickupDate);
  const end = new Date(returnDate);
  while (d < end) {
    const ds = d.toISOString().slice(0, 10);
    if (vAv[ds] === 'blocked') return false;
    d.setDate(d.getDate() + 1);
  }
  return true;
}

export function rentDays(pickupDate: string, returnDate: string): number {
  const d1 = new Date(pickupDate), d2 = new Date(returnDate);
  return Math.max(1, Math.ceil((d2.getTime() - d1.getTime()) / 86400000));
}

export function rentCalcPricing(v: any, addons: any, addonKeys: string[], insuranceTier: string, ins: any, days: number, commissionRate: number) {
  const rentalBase = parseFloat(v.pricePerDay || 0) * days;
  let rentalTotal = rentalBase;
  if (v.pricePerWeek && days >= 7) {
    const weeks = Math.floor(days / 7), rem = days % 7;
    rentalTotal = weeks * parseFloat(v.pricePerWeek) + rem * parseFloat(v.pricePerDay || 0);
  }
  let addonTotal = 0;
  (addonKeys || []).forEach(k => {
    const ao = addons && addons[k];
    if (!ao || ao.enabled === false) return;
    if (ao.pricePerDay) addonTotal += ao.pricePerDay * days;
    else if (ao.priceFlat) addonTotal += ao.priceFlat;
  });
  const insTier = ins && ins[insuranceTier];
  const insTotal = insTier ? parseFloat(insTier.pricePerDay || 0) * days : 0;
  const subtotal = rentalTotal + addonTotal + insTotal;
  const commission = subtotal * (commissionRate / 100);
  const ownerNet = subtotal - commission;
  const depositAmount = parseFloat(v.depositAmount || 0);
  return { rentalBase, rentalTotal, addonTotal, insTotal, subtotal, commission, commissionRate, ownerNet, depositAmount, days };
}
