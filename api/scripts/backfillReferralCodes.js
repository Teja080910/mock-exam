const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const { backfillReferralCodes } = require('../utils/referralHelper');

async function run() {
  try {
    console.log('Connecting to database...');
    await mongoose.connect(process.env.DB_CONNECTION);
    console.log('Connected to database. Running backfill...');
    const count = await backfillReferralCodes();
    console.log(`Finished. ${count} users updated.`);
  } catch (err) {
    console.error('Error running migration:', err);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from database.');
  }
}

run();
