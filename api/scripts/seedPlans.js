const mongoose = require('mongoose');
require('dotenv').config();

const plans = [
  {
    planName: 'Railway Pack',
    planValidity: '1 Year',
    price: 499,
    planId: 'PLAN-RAIL01',
    categoryGroup: new mongoose.Types.ObjectId('6a33efd7e66de2485bddf16e'),
  },
  {
    planName: 'SSC Pack',
    planValidity: '1 Year',
    price: 499,
    planId: 'PLAN-SSC01',
    categoryGroup: new mongoose.Types.ObjectId('6a33efd7e66de2485bddf16f'),
  },
  {
    planName: 'Engineering Pack',
    planValidity: '1 Year',
    price: 499,
    planId: 'PLAN-ENGG01',
    categoryGroup: new mongoose.Types.ObjectId('6a33efd7e66de2485bddf170'),
  },
  {
    planName: 'Defence Pack',
    planValidity: '1 Year',
    price: 499,
    planId: 'PLAN-DEF01',
    categoryGroup: new mongoose.Types.ObjectId('6a33efd7e66de2485bddf171'),
  },
  {
    planName: 'All Access Pack',
    planValidity: '1 Year',
    price: 1499,
    planId: 'PLAN-ALL01',
    categoryGroup: null,
  },
];

mongoose.connect(process.env.DB_CONNECTION).then(async () => {
  const db = mongoose.connection.db;
  await db.collection('plans').deleteMany({});
  const result = await db.collection('plans').insertMany(plans);
  console.log(`Inserted ${result.insertedCount} plans`);
  mongoose.disconnect();
});
