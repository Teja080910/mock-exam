require('dotenv').config();
const mongoose = require('mongoose');

mongoose.connect(process.env.DB_CONNECTION)
.then(async () => {
  const db = mongoose.connection.db;
  const r = await db.collection('questions').updateMany(
    { question_type: 'multiple_choice' },
    { $set: { question_type: 'text_only' } }
  );
  console.log('Modified:', r.modifiedCount);
  const count = await db.collection('questions').countDocuments({ question_type: 'text_only' });
  console.log('Total text_only questions:', count);
  mongoose.disconnect();
})
.catch(err => console.error(err));
