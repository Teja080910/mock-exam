require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');

const APPLY = process.argv.includes('--apply');
const LOCAL = process.argv.includes('--local');
const DB = LOCAL ? process.env.DB_CONNECTION : process.env.PROD_DB_CONNECTION;
const LABEL = LOCAL ? 'LOCAL' : 'PROD';

if (!DB) {
  console.error(`❌ ${LOCAL ? 'DB_CONNECTION' : 'PROD_DB_CONNECTION'} not set in .env`);
  process.exit(1);
}

async function main() {
  const conn = await mongoose.createConnection(DB).asPromise();
  console.log(`[${LABEL}] connected`);

  const UP = conn.collection('userplans');
  const plans = await conn.collection('plans').find({}).toArray();
  const byCode = Object.fromEntries(plans.map((p) => [p.planId, p]));

  const docs = await UP.find({ 'subscriptions.0': { $exists: false } }).toArray();
  console.log(`[${LABEL}] userplans needing backfill: ${docs.length}`);

  if (APPLY && docs.length) {
    const outDir = path.join(__dirname, '..', 'backups');
    fs.mkdirSync(outDir, { recursive: true });
    const out = path.join(outDir, `userplans-backup-${Date.now()}.json`);
    fs.writeFileSync(out, JSON.stringify(docs, null, 1));
    console.log(`[${LABEL}] backup written: ${out}`);
  }

  const ops = [];
  for (const d of docs) {
    const now = new Date();
    const isExp = d.expiresAt && new Date(d.expiresAt) < now;
    const baseStatus = isExp || d.planStatus === 'expired' ? 'expired' : 'active';
    const cgIds = (d.categoryGroupIds || []).map((c) => c);
    const planDoc = d.planId
      ? plans.find((p) => p._id.toString() === d.planId.toString())
      : null;

    let subs = [];
    if (planDoc) {
      subs = [
        {
          planId: planDoc._id,
          planName: planDoc.planName || '',
          planCode: planDoc.planId || '',
          categoryGroupId: cgIds.length === 1 ? cgIds[0] : null,
          price: d.price || planDoc.price || 0,
          planStatus: baseStatus,
          purchasedAt: d.createdAt || now,
          expiresAt: d.expiresAt || null,
        },
      ];
    } else if (d.isSelectedAll && Number(d.price) >= 999 && byCode['PLAN-LTP01']) {
      const p = byCode['PLAN-LTP01'];
      subs = [
        {
          planId: p._id,
          planName: p.planName,
          planCode: p.planId,
          categoryGroupId: null,
          price: d.price || p.price,
          planStatus: baseStatus,
          purchasedAt: d.createdAt || now,
          expiresAt: null,
        },
      ];
    } else if (d.isSelectedAll && byCode['PLAN-AIO01']) {
      const p = byCode['PLAN-AIO01'];
      subs = [
        {
          planId: p._id,
          planName: p.planName,
          planCode: p.planId,
          categoryGroupId: null,
          price: d.price || p.price,
          planStatus: baseStatus,
          purchasedAt: d.createdAt || now,
          expiresAt: d.expiresAt || null,
        },
      ];
    } else if (cgIds.length > 0) {
      subs = cgIds.map((cg) => ({
        planId: null,
        planName: 'Mock Test',
        planCode: '',
        categoryGroupId: cg,
        price: d.price || 0,
        planStatus: baseStatus,
        purchasedAt: d.createdAt || now,
        expiresAt: d.expiresAt || null,
      }));
    } else {
      console.log(`[${LABEL}] ⚠️  skip (no plan info): ${d._id}`);
      continue;
    }

    const hasActive = subs.some((s) => s.planStatus === 'active');
    const newStatus = hasActive ? 'active' : 'expired';
    console.log(
      `[${LABEL}] ${d._id} planId=${d.planId} price=${d.price} all=${d.isSelectedAll} cg=${cgIds.length} -> ${subs
        .map((s) => s.planCode || '(category)')
        .join(', ')} status=${newStatus}`
    );
    ops.push({
      updateOne: {
        filter: { _id: d._id },
        update: { $set: { subscriptions: subs, planStatus: newStatus } },
      },
    });
  }

  if (APPLY && ops.length) {
    const r = await UP.bulkWrite(ops);
    console.log(`[${LABEL}] ✅ updated: ${r.modifiedCount}`);
  } else {
    console.log(`[${LABEL}] dry-run only (${ops.length} updates). Pass --apply to write.`);
  }

  await conn.close();
}

main().catch((err) => {
  console.error('Backfill failed:', err);
  process.exit(1);
});
