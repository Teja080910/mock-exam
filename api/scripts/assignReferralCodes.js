// Backfill unique 8-char uppercase alphanumeric referral codes for all users
// missing one (e.g. users created before the Google auth referral fix).
//
// Usage (run from api/ folder):
//   node scripts/assignReferralCodes.js [--db=PROD_DB_NAME]
//   node scripts/assignReferralCodes.js --dry-run

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/userModel');
const randomstring = require('randomstring');

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const dbArg = (args.find((a) => a.startsWith('--db=')) || '').split('=')[1];

const uri = dbArg
  ? (process.env.DB_CONNECTION || process.env.MONGO_URI || 'mongodb://localhost:27017/Mockstation').replace(
      /\/[^/]+$/,
      `/${dbArg}`,
    )
  : process.env.DB_CONNECTION || process.env.MONGO_URI || 'mongodb://localhost:27017/Mockstation';

const generateUniqueCode = async () => {
  let code = '';
  let unique = false;
  while (!unique) {
    code = randomstring.generate({
      length: 8,
      charset: 'alphanumeric',
      capitalization: 'uppercase',
    });
    const existing = await User.findOne({ referral_code: code });
    if (!existing) unique = true;
  }
  return code;
};

(async () => {
  await mongoose.connect(uri);
  console.log(`Connected: ${uri}`);

  const users = await User.find({ $or: [{ referral_code: null }, { referral_code: '' }, { referral_code: { $exists: false } }] });
  console.log(`Users missing referral_code: ${users.length}`);

  if (dryRun) {
    console.log('DRY-RUN: no changes made');
    process.exit(0);
  }

  let assigned = 0;
  for (const user of users) {
    const code = await generateUniqueCode();
    user.referral_code = code;
    await user.save();
    assigned++;
    if (assigned % 100 === 0) console.log(`Assigned ${assigned}/${users.length}...`);
  }

  console.log(`Done. Assigned codes to ${assigned} users.`);
  process.exit(0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
