require('dotenv').config();
const mongoose = require('mongoose');
mongoose.connect(process.env.DB_CONNECTION).then(async () => {
  const d = mongoose.connection.db;
  const q = await d.collection('quizzes').findOne();
  console.log('Quiz fields:', Object.keys(q));
  console.log('Has subcategoryId:', 'subcategoryId' in q);
  console.log('Has categoryId:', 'categoryId' in q);
  const withSub = await d.collection('quizzes').countDocuments({ subcategoryId: { $exists: true } });
  console.log('Quizzes with subcategoryId:', withSub);
  const total = await d.collection('quizzes').countDocuments();
  console.log('Total quizzes:', total);
  mongoose.disconnect();
});