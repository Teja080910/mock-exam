const mongoose = require('mongoose');

const PROD_URI = 'mongodb+srv://mohammadrehan00121_db_user:9rCwDqMWZDHKmqpF@cluster0.dwxx6dl.mongodb.net/Mockstation';
const LOCAL_URI = 'mongodb://127.0.0.1:27017/Mockstation';

async function migrate() {
  console.log('Connecting to PROD...');
  const prodConn = await mongoose.createConnection(PROD_URI).asPromise();
  console.log('Connecting to LOCAL...');
  const localConn = await mongoose.createConnection(LOCAL_URI).asPromise();

  const collections = [
    'users', 'quizzes', 'questions', 'categories', 'subcategories',
    'categorygroups', 'ebooks', 'news', 'notes', 'plans',
    'notifications', 'userquizzes', 'points', 'intros', 'banners',
    'carouselbanners', 'featuredcategories', 'commonnotifications'
  ];

  let totalDocs = 0;

  for (const collName of collections) {
    try {
      const prodModel = prodConn.db.collection(collName);
      const localModel = localConn.db.collection(collName);

      const count = await prodModel.countDocuments();
      if (count === 0) {
        console.log(`  ${collName}: 0 docs (skipped)`);
        continue;
      }

      const docs = await prodModel.find({}).toArray();
      const existingIds = await localModel.distinct('_id');
      const existingSet = new Set(existingIds.map(id => id.toString()));

      const newDocs = docs.filter(d => !existingSet.has(d._id.toString()));

      if (newDocs.length > 0) {
        await localModel.insertMany(newDocs, { ordered: false });
      }

      console.log(`  ${collName}: ${count} total, ${newDocs.length} new (inserted), ${newDocs.length === 0 ? 'all exist' : ''}`);
      totalDocs += newDocs.length;
    } catch (e) {
      console.log(`  ${collName}: ERROR - ${e.message}`);
    }
  }

  console.log(`\nMigration complete. ${totalDocs} new documents inserted into local DB.`);

  await prodConn.close();
  await localConn.close();
  process.exit(0);
}

migrate().catch(e => { console.error(e); process.exit(1); });
