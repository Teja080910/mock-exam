const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const mongoose = require('mongoose');
const Subcategory = require('../models/subcategoryModel');

async function run() {
  const isDryRun = process.argv.includes('--dry-run');

  try {
    console.log(`Connecting to database${isDryRun ? ' (DRY RUN)' : ''}...`);
    await mongoose.connect(process.env.DB_CONNECTION);
    console.log('Connected to database.');

    const subcategoriesToUpdate = await Subcategory.find({
      $or: [
        { test_type: { $exists: false } },
        { test_type: null },
        { test_type: '' }
      ]
    });

    console.log(`Found ${subcategoriesToUpdate.length} subcategories missing test_type.`);

    let updatedCount = 0;
    for (const subcat of subcategoriesToUpdate) {
      // Default to 'pyq'
      const assignedType = 'pyq';

      console.log(`- [${subcat._id}] "${subcat.name}" -> ${assignedType}`);
      if (!isDryRun) {
        await Subcategory.updateOne(
          { _id: subcat._id },
          { $set: { test_type: assignedType } }
        );
        updatedCount++;
      }
    }

    if (isDryRun) {
      console.log(`Dry run complete. ${subcategoriesToUpdate.length} records would be updated to 'pyq'.`);
    } else {
      console.log(`Migration finished. ${updatedCount} records successfully updated to 'pyq'.`);
    }
  } catch (err) {
    console.error('Error during migration:', err);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from database.');
  }
}

run();
