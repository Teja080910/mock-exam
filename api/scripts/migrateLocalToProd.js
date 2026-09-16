require('dotenv').config();
const mongoose = require('mongoose');

// Local DB (source) and Prod DB (destination)
const LOCAL_DB = process.env.DB_CONNECTION;
const PROD_DB = process.env.PROD_DB_CONNECTION;

if (!PROD_DB) {
  console.error('❌ PROD_DB_CONNECTION not set in .env');
  process.exit(1);
}

let localDb, prodDb;

async function connectDbs() {
  const localConn = await mongoose.createConnection(LOCAL_DB).asPromise();
  console.log('✅ Connected to local MongoDB');
  const prodConn = await mongoose.createConnection(PROD_DB).asPromise();
  console.log('✅ Connected to production MongoDB');
  localDb = localConn.db;
  prodDb = prodConn.db;
  return { localConn, prodConn };
}

async function migrateCollection(name, transform) {
  const localDocs = await localDb.collection(name).find({}).toArray();
  if (localDocs.length === 0) {
    console.log(`  ⚠️  ${name}: no local documents, skipping`);
    return 0;
  }
  await prodDb.collection(name).deleteMany({});
  const docs = transform ? localDocs.map(transform) : localDocs;
  if (docs.length > 0) {
    await prodDb.collection(name).insertMany(docs);
  }
  console.log(`  ✅ ${name}: ${docs.length} documents`);
  return docs.length;
}

async function migrate() {
  const { localConn, prodConn } = await connectDbs();

  console.log('\n📦 Migrating Local → Production\n');

  // 1. Categories
  console.log('1. Categories');
  await migrateCollection('categories');

  // 2. Category Groups
  console.log('2. Category Groups');
  await migrateCollection('categorygroups');

  // 3. Subcategories
  console.log('3. Subcategories');
  await migrateCollection('subcategories');

  // 4. Quizzes
  console.log('4. Quizzes');
  await migrateCollection('quizzes');

  // 5. Questions
  console.log('5. Questions');
  await migrateCollection('questions');

  // 6. Plans
  console.log('6. Plans');
  await migrateCollection('plans');

  // 7. Carousel Banners
  console.log('7. Carousel Banners');
  await migrateCollection('carouselbanners');

  // 8. Settings
  console.log('8. Ads Settings');
  await migrateCollection('adssettings');

  console.log('9. Points Settings');
  await migrateCollection('pointssettings');

  // 9. Payment Methods
  console.log('10. Payment Methods');
  await migrateCollection('paymentmethods');

  // 10. Ebooks
  console.log('11. Ebooks');
  await migrateCollection('ebooks');

  // 11. News
  console.log('12. News');
  await migrateCollection('news');

  // 12. Intros
  console.log('13. Intros');
  await migrateCollection('intros');

  // 13. Notes
  console.log('14. Notes');
  await migrateCollection('notes');

  console.log('\n✅ Local → Production migration complete!');
  await localConn.close();
  await prodConn.close();
}

migrate().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
