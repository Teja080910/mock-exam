// Copies a user's UserPlan document from the PROD Atlas DB to the LOCAL DB,
// matching users by email. Handy for testing premium features locally when
// the local account never purchased.
//
// Usage:
//   node scripts/copyProdPlanToLocalUser.js user@example.com          # dry run
//   node scripts/copyProdPlanToLocalUser.js user@example.com --apply  # write
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
require('dotenv').config({ path: path.join(__dirname, '../.env.prod'), override: false });
const mongoose = require('mongoose');
require('../models/userPlanModel');

const email = (process.argv[2] || '').trim();
const APPLY = process.argv.includes('--apply');

if (!email) {
  console.error('Usage: node scripts/copyProdPlanToLocalUser.js <email> [--apply]');
  process.exit(1);
}

async function main() {
  const localUri = process.env.DB_CONNECTION;
  const prodUri = process.env.PROD_DB_CONNECTION || readProdUri();
  if (!localUri) throw new Error('DB_CONNECTION missing in .env');
  if (!prodUri) throw new Error('could not determine prod DB connection');

  const prod = await mongoose.createConnection(prodUri, { serverSelectionTimeoutMS: 10000 }).asPromise();
  const local = await mongoose.createConnection(localUri, { serverSelectionTimeoutMS: 10000 }).asPromise();
  console.log('prod:', prodUri.replace(/\/\/[^@]*@/, '//***@').slice(0, 60));
  console.log('local:', localUri);

  const prodUser = await prod.collection('users').findOne({ email: new RegExp(`^${escapeRegex(email)}$`, 'i') });
  const localUser = await local.collection('users').findOne({ email: new RegExp(`^${escapeRegex(email)}$`, 'i') });
  if (!prodUser) throw new Error(`prod user not found: ${email}`);
  if (!localUser) throw new Error(`local user not found: ${email} (sign up locally first)`);

  const prodPlan = await prod.collection('userplans').findOne({ userId: prodUser._id });
  if (!prodPlan) throw new Error(`prod user has no userplan: ${email}`);

  const existing = await local.collection('userplans').findOne({ userId: localUser._id });
  console.log(`prod user id:  ${prodUser._id}`);
  console.log(`local user id: ${localUser._id}`);
  console.log(`prod plan:     status=${prodPlan.planStatus} subs=${(prodPlan.subscriptions || []).map((s) => s.planName).join(', ')}`);
  console.log(`local plan:    ${existing ? 'exists (will be overwritten)' : 'none'}`);

  const { _id, __v, userId, categoryGroupIds, createdAt, ...rest } = prodPlan;
  const doc = {
    ...rest,
    // Local category groups differ from prod, and isSelectedAll grants
    // everything anyway - keep the array empty to avoid dangling refs.
    categoryGroupIds: prodPlan.isSelectedAll ? [] : (categoryGroupIds || []),
    userId: localUser._id,
    updatedAt: new Date(),
  };

  if (!APPLY) {
    console.log('\nDRY RUN - no changes. Re-run with --apply to write.\n');
    console.log(JSON.stringify({ ...doc, subscriptions: doc.subscriptions }, null, 1).slice(0, 900));
    await prod.close();
    await local.close();
    return;
  }

  const outDir = path.join(__dirname, '..', 'backups');
  fs.mkdirSync(outDir, { recursive: true });
  const backup = path.join(outDir, `local-userplan-${Date.now()}.json`);
  fs.writeFileSync(backup, JSON.stringify(existing ? [existing] : [], null, 1));

  const res = await local.collection('userplans').updateOne(
    { userId: localUser._id },
    { $set: doc, $setOnInsert: { createdAt: createdAt || new Date() } },
    { upsert: true },
  );
  console.log(`\nApplied: matched=${res.matchedCount} upserted=${res.upsertedCount} backup=${backup}`);
  await prod.close();
  await local.close();
}

function readProdUri() {
  const envProd = path.join(__dirname, '../.env.prod');
  if (!fs.existsSync(envProd)) return null;
  const line = fs.readFileSync(envProd, 'utf8').split('\n').find((l) => l.includes('DB_CONNECTION'));
  if (!line) return null;
  return line.slice(line.indexOf('=') + 1).trim().replace(/^["']|["']$/g, '').replace(/[;\s]+$/, '');
}

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

main().catch((e) => {
  console.error('Failed:', e.message);
  process.exit(1);
});
