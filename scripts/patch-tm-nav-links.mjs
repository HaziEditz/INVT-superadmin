/**
 * Insert Platform Fees / Clean-trip Scan / Settlement into Total Mobility sidebars.
 */
import fs from 'fs';
import path from 'path';

const root = path.join(
  'C:/Users/64275/Projects/INVT-superadmin/taxitime.co.nz/superadmin360taxi',
);
const INSERT = [
  '      <li><a href="TM-Platform-Fees.aspx">Platform Fees</a></li>',
  '      <li><a href="TM-Clean-Scan.aspx">Clean-trip Scan</a></li>',
  '      <li><a href="TM-Settlement.aspx">Settlement</a></li>',
].join('\n');

const files = fs.readdirSync(root).filter((f) => f.endsWith('.aspx'));
const changed = [];
const skipped = [];

for (const f of files) {
  const p = path.join(root, f);
  let s = fs.readFileSync(p, 'utf8');
  if (!s.includes('Total Mobility')) {
    skipped.push(f + ' (no TM)');
    continue;
  }
  if (
    s.includes('TM-Platform-Fees.aspx') &&
    s.includes('TM-Clean-Scan.aspx') &&
    s.includes('TM-Settlement.aspx')
  ) {
    skipped.push(f + ' (already)');
    continue;
  }
  const before = s;

  // After Claim Batches → before Monthly Reports
  s = s.replace(
    /(<li><a href="TM-Batches\.aspx"[^>]*>[\s\S]*?<\/a><\/li>\r?\n)(\s*<li><a href="TM-Reports\.aspx")/g,
    (_, a, b) => a + INSERT + '\n' + b,
  );

  // Home-style: Flagged Trips → Monthly Reports (no Batches link)
  if (!s.includes('TM-Platform-Fees.aspx')) {
    s = s.replace(
      /(<li><a href="TM-Flagged\.aspx"[^>]*>[\s\S]*?<\/a><\/li>\r?\n)(\s*<li><a href="TM-Reports\.aspx")/g,
      (_, a, b) => a + INSERT + '\n' + b,
    );
  }

  if (s === before) {
    skipped.push(f + ' (no match)');
    continue;
  }
  fs.writeFileSync(p, s);
  changed.push(f);
}

console.log('CHANGED', changed.length);
changed.forEach((x) => console.log(' +', x));
console.log('SKIPPED', skipped.length);
skipped.forEach((x) => console.log(' -', x));
