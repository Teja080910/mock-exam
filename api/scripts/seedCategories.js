require('dotenv').config();
const mongoose = require('mongoose');
const Category = require('../models/categoryModel');
const CategoryGroup = require('../models/categoryGroupModel');

mongoose.connect(process.env.DB_CONNECTION)
  .then(() => console.log('DB connected'))
  .catch(err => { console.error(err); process.exit(1); });

async function seed() {
  await Category.deleteMany({});
  await CategoryGroup.deleteMany({});

  const railwayCats = await Category.insertMany([
    { name: 'rrb-ntpc', displayName: 'RRB NTPC', image: '1769350427658-indian_railway_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'rrb-group-d', displayName: 'RRB Group D', image: '1769350427658-indian_railway_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'rrb-alp', displayName: 'RRB ALP', image: '1759382671248-rrb_alp.png', is_feature: 1, is_active: 1 },
    { name: 'rrb-je', displayName: 'RRB JE', image: '1763993662089-rrb5.jpg', is_feature: 0, is_active: 1 },
    { name: 'rrb-rpf', displayName: 'RPF', image: '1769353652964-rpf-logo.png', is_feature: 0, is_active: 1 },
  ]);

  const sscCats = await Category.insertMany([
    { name: 'ssc-cgl', displayName: 'SSC CGL', image: '1769231148547-ssc_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'ssc-chsl', displayName: 'SSC CHSL', image: '1769231148547-ssc_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'ssc-gd', displayName: 'SSC GD', image: '1769231148547-ssc_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'ssc-mts', displayName: 'SSC MTS', image: '1769231148547-ssc_logo.jpeg', is_feature: 0, is_active: 1 },
    { name: 'ssc-steno', displayName: 'SSC Stenographer', image: '1769231148547-ssc_logo.jpeg', is_feature: 0, is_active: 1 },
  ]);

  const engineeringCats = await Category.insertMany([
    { name: 'isro', displayName: 'ISRO', image: '1769355633031-isro-logo.png', is_feature: 1, is_active: 1 },
    { name: 'bhel', displayName: 'BHEL', image: '1769356834107-bhel-logo.png', is_feature: 0, is_active: 1 },
    { name: 'hal', displayName: 'HAL', image: '1769357592579-hal-logo.png', is_feature: 0, is_active: 1 },
    { name: 'drdo', displayName: 'DRDO', image: '1769358201565-drdo-logo.png', is_feature: 0, is_active: 1 },
    { name: 'sail', displayName: 'SAIL', image: '1769358521528-sail-logo.png', is_feature: 0, is_active: 1 },
  ]);

  const defenceCats = await Category.insertMany([
    { name: 'indian-army', displayName: 'Indian Army', image: '1769350427658-indian_railway_logo.jpeg', is_feature: 1, is_active: 1 },
    { name: 'indian-navy', displayName: 'Indian Navy', image: '1769350427658-indian_railway_logo.jpeg', is_feature: 0, is_active: 1 },
    { name: 'indian-airforce', displayName: 'Indian Airforce', image: '1769350427658-indian_railway_logo.jpeg', is_feature: 0, is_active: 1 },
  ]);

  await CategoryGroup.insertMany([
    { displayName: 'Railway', categories: railwayCats.map(c => c._id) },
    { displayName: 'SSC', categories: sscCats.map(c => c._id) },
    { displayName: 'Engineering', categories: engineeringCats.map(c => c._id) },
    { displayName: 'Defence', categories: defenceCats.map(c => c._id) },
  ]);

  console.log('Seeded: 4 category groups with categories');
  mongoose.disconnect();
}

seed();
