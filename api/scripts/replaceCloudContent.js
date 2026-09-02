/**
 * Replace cloud CONTENT collections with local data (1:1).
 * Preserves ALL user data collections on cloud (users, admins, userplans,
 * userquizzes, points, notifications, sessions, otps, etc.).
 *
 * Content collections are backed up locally (./backups/cloud-<ts>/) then
 * deleted from cloud and re-inserted from local as-is (IDs kept from local,
 * so content is self-consistent).
 *
 * NOTE: user data that references content IDs (userplans.user.plans etc.)
 * may point to IDs that no longer exist after replacement.
 *
 * Usage:
 *   node scripts/replaceCloudContent.js --dry-run     # preview counts
 *   node scripts/replaceCloudContent.js --apply       # write changes
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

const LOCAL_URI = 'mongodb://localhost:27017/Mockstation';
const CLOUD_URI = process.env.CLOUD_URI || 'mongodb+srv://mohammadrehan00121_db_user:9rCwDqMWZDHKmqpF@cluster0.dwxx6dl.mongodb.net/Mockstation';

const args = process.argv.slice(2);
const DRY_RUN = !args.includes('--apply');

// CONTENT collections to replace on cloud:
const CONTENT = [
  'categories',
  'subcategories',
  'categorygroups',
  'quizzes',
  'questions',
  'news',
  'ebooks',
  'plans',
  'settings',
  'banners',
  'carouselbanners',
  'commonnotifications',
  'pages',
  'intros',
  'ads',
  'paymentmethods',
  'currencies',
];

let local, cloud;

async function connect() {
  local = await mongoose.createConnection(LOCAL_URI).asPromise();
  cloud = await mongoose.createConnection(CLOUD_URI).asPromise();
  console.log('Connected to local + cloud');
}

async function main() {
  await connect();
  console.log(`\n=== REPLACE CONTENT (${DRY_RUN ? 'DRY-RUN: no writes' : 'APPLY: writing'}) ===`);

  const backupDir = path.join(__dirname, '..', 'backups', `cloud-${Date.now()}`);
  fs.mkdirSync(backupDir, { recursive: true });

  for (const name of CONTENT) {
    try {
      const localDocs = await local.collection(name).find({}).toArray();
      const cloudDocs = await cloud.collection(name).find({}).toArray();

      console.log(`[${name}] local=${localDocs.length} cloud=${cloudDocs.length}`);

      if (DRY_RUN) continue;

      // backup cloud content
      if (cloudDocs.length) {
        fs.writeFileSync(
          path.join(backupDir, `${name}.json`),
          JSON.stringify(cloudDocs, null, 2),
        );
      }

      // wipe cloud content
      await cloud.collection(name).deleteMany({});

      // re-insert all local docs
      if (localDocs.length) {
        await cloud.collection(name).insertMany(localDocs, { ordered: false });
      }
    } catch (e) {
      console.log(`[${name}] ERROR: ${e.message}`);
    }
  }

  console.log(`\nBackups at: ${backupDir}`);
  console.log(DRY_RUN ? 'Dry-run complete. Run with --apply to write.' : 'APPLY complete.');
  await local.close();
  await cloud.close();
}

main().catch((e) => {
  console.error('FATAL:', e);
  process.exit(1);
});
