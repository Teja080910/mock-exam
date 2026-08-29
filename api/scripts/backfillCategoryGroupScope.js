// Backfill the `scope` field on existing CategoryGroup documents.
// Matches the legacy free-text `displayName` to a Central/State/None scope so
// the Flutter home screen's Central-wise / State-wise sections light up
// without manual admin edits.
//
// Usage (run from api/ folder):
//   node scripts/backfillCategoryGroupScope.js              # write changes
//   node scripts/backfillCategoryGroupScope.js --dry-run   # preview only
//   node scripts/backfillCategoryGroupScope.js --force     # overwrite non-`none` scopes (default: skip)
//
// Notes:
//   * Default skips any group whose `scope` is already 'central' or 'state'
//     (use --force to reclassify them).
//   * Groups with no displayName match (or no displayName) are set to 'none'.
//   * Run with --dry-run first to see what will change.

require('dotenv').config();
const mongoose = require('mongoose');

const args = Object.fromEntries(
  process.argv.slice(2)
    .filter(a => a.startsWith('--'))
    .map(a => { const [k, v] = a.replace(/^--/, '').split('='); return [k, v === undefined ? true : v]; })
);
const DRY_RUN = !!args['dry-run'];
const FORCE = !!args.force;

const CENTRAL_TOKENS = [
  'railway', 'ssc', 'psu', 'banking', 'upsc', 'ibps', 'sbi',
  'rbi', 'central', 'rrb', 'defence', 'defense', 'navy', 'army',
  'air force', 'airforce', 'capf', 'cpo', 'cgl', 'chsl', 'mts',
  'ntpc', 'rrb ntpc', 'lic', 'fcI', 'fci',
];
// Ordered: specific state exam tokens first, generic 'state' last so that
// "State Bank of India" (which contains both 'sbi' and 'state') classifies
// as central rather than state.
const STATE_TOKENS = [
  'psc', 'statewise', 'state wise',
  'tnpsc', 'appsc', 'kpsc', 'uppsc', 'mppsc', 'bpsc', 'rpsc',
  'hpsc', 'spsc', 'wbcs', 'ppsc', 'gpsc', 'mpsc', 'jpsc',
  'cgpsc', 'apspsc',
  'state',
];

function classify(displayName) {
  const name = String(displayName || '').toLowerCase().trim();
  if (!name) return 'none';
  // Central tokens are checked first and always win over a generic 'state'
  // substring (e.g. "State Bank of India" -> central via 'sbi').
  for (const tok of CENTRAL_TOKENS) {
    if (name.includes(tok)) return 'central';
  }
  for (const tok of STATE_TOKENS) {
    if (name.includes(tok)) return 'state';
  }
  return 'none';
}

async function run() {
  await mongoose.connect(process.env.DB_CONNECTION);
  const db = mongoose.connection.db;
  const col = db.collection('categorygroups');

  const groups = await col.find({}).toArray();
  console.log(`Found ${groups.length} category group(s)\n`);

  if (groups.length === 0) {
    await mongoose.disconnect();
    return;
  }

  const preview = [];
  const updates = [];
  const skipped = [];

  for (const g of groups) {
    const current = (g.scope && ['central', 'state', 'none'].includes(g.scope)) ? g.scope : null;
    const next = classify(g.displayName);

    if (current === next) {
      skipped.push({ id: g._id, name: g.displayName, current, next, reason: 'unchanged' });
      continue;
    }
    if (current && current !== 'none' && !FORCE) {
      skipped.push({ id: g._id, name: g.displayName, current, next, reason: 'manual (use --force to overwrite)' });
      continue;
    }

    preview.push({ id: g._id, name: g.displayName, current: current || '<missing>', next });
    updates.push({ _id: g._id, name: g.displayName, current, next });
  }

  // Pretty print
  const pad = (s, n) => String(s).padEnd(n, ' ');
  console.log(pad('NAME', 30) + pad('CURRENT', 12) + 'NEXT');
  console.log('-'.repeat(60));
  for (const p of preview) {
    console.log(pad(p.name, 30) + pad(p.current, 12) + p.next);
  }
  if (skipped.length) {
    console.log('\nSkipped:');
    for (const s of skipped) {
      console.log(`  ${pad(s.name, 28)} current=${s.current} next=${s.next}  (${s.reason})`);
    }
  }

  console.log(`\nPlanned changes: ${updates.length} update(s), ${skipped.length} skipped, ${groups.length} total.`);

  if (DRY_RUN) {
    console.log('\n--dry-run: no changes written.');
  } else if (updates.length === 0) {
    console.log('\nNothing to do.');
  } else {
    const result = await col.bulkWrite(
      updates.map(u => ({
        updateOne: {
          filter: { _id: u._id },
          update: { $set: { scope: u.next, updatedAt: new Date() } },
        },
      }))
    );
    console.log(`\nUpdated: ${result.modifiedCount} document(s).`);
  }

  await mongoose.disconnect();
}

run().catch(err => {
  console.error('Backfill failed:', err);
  process.exit(1);
});
