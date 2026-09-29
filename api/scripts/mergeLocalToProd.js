// Safe Local → Production merge: upserts local documents into the prod DB by
// _id (updates existing, inserts new) WITHOUT deleting prod-only documents.
// Unlike migrateLocalToProd.js (deleteMany + insertMany), nothing is removed
// from production.
//
// Usage:
//   node scripts/mergeLocalToProd.js          # dry run (counts only)
//   node scripts/mergeLocalToProd.js --apply  # write
require('dotenv').config();
const mongoose = require('mongoose');

const LOCAL_DB = process.env.DB_CONNECTION;
const PROD_DB = process.env.PROD_DB_CONNECTION;
const APPLY = process.argv.includes('--apply');

if (!PROD_DB) {
  console.error('PROD_DB_CONNECTION not set in .env');
  process.exit(1);
}

const COLLECTIONS = [
  'categories',
  'categorygroups',
  'subcategories',
  'quizzes',
  'questions',
  'plans',
  'carouselbanners',
  'adssettings',
  'pointssettings',
  'paymentmethods',
  'ebooks',
  'news',
  'intros',
  'notes',
];

async function mergeCollection(localDb, prodDb, name) {
  const localDocs = await localDb.collection(name).find({}).toArray();
  const prodCountBefore = await prodDb.collection(name).countDocuments();
  if (localDocs.length === 0) {
    console.log(`  ${name}: no local docs, skipped (prod: ${prodCountBefore})`);
    return { name, local: 0, modified: 0, upserted: 0, prodBefore: prodCountBefore };
  }
  if (!APPLY) {
    console.log(`  ${name}: would upsert ${localDocs.length} docs (prod: ${prodCountBefore})`);
    return { name, local: localDocs.length, modified: 0, upserted: 0, prodBefore: prodCountBefore };
  }

  let modified = 0;
  let upserted = 0;
  const batchSize = 500;
  for (let i = 0; i < localDocs.length; i += batchSize) {
    const batch = localDocs.slice(i, i + batchSize);
    const ops = batch.map((doc) => ({
      replaceOne: {
        filter: { _id: doc._id },
        replacement: doc,
        upsert: true,
      },
    }));
    const res = await prodDb.collection(name).bulkWrite(ops, { ordered: false });
    modified += res.modifiedCount || 0;
    upserted += res.upsertedCount || 0;
  }
  const prodCountAfter = await prodDb.collection(name).countDocuments();
  console.log(
    `  ${name}: local=${localDocs.length} updated=${modified} inserted=${upserted} (prod: ${prodCountBefore} -> ${prodCountAfter})`,
  );
  return { name, local: localDocs.length, modified, upserted, prodBefore: prodCountBefore };
}

async function run() {
  const localConn = await mongoose.createConnection(LOCAL_DB).asPromise();
  const prodConn = await mongoose.createConnection(PROD_DB, { serverSelectionTimeoutMS: 10000 }).asPromise();
  console.log('local:', LOCAL_DB);
  console.log('prod: ', PROD_DB.replace(/\/\/[^@]*@/, '//***@').slice(0, 60));
  console.log(APPLY ? 'MODE: APPLY (writing to prod)\n' : 'MODE: DRY RUN\n');

  const results = [];
  for (const name of COLLECTIONS) {
    results.push(await mergeCollection(localConn.db, prodConn.db, name));
  }

  const totalInserted = results.reduce((s, r) => s + r.upserted, 0);
  const totalUpdated = results.reduce((s, r) => s + r.modified, 0);
  console.log(`\n${APPLY ? 'Merged' : 'Would merge'}: ${totalUpdated} updates, ${totalInserted} inserts.`);
  if (!APPLY) console.log('Re-run with --apply to write.');

  await localConn.close();
  await prodConn.close();
}

run().catch((e) => {
  console.error('Merge failed:', e.message);
  process.exit(1);
});
