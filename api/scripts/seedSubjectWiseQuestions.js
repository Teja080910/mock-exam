require('dotenv').config();
const mongoose = require('mongoose');
const Category = require('../models/categoryModel');
const Subcategory = require('../models/subcategoryModel');
const Quiz = require('../models/quizModel');
const Question = require('../models/questionsModel');

mongoose.connect(process.env.DB_CONNECTION)
  .then(() => console.log('DB connected'))
  .catch(err => { console.error(err); process.exit(1); });

const subjects = [
  { name: 'Mathematics', chapters: ['Algebra', 'Geometry', 'Trigonometry', 'Calculus', 'Statistics'] },
  { name: 'Physics', chapters: ['Mechanics', 'Thermodynamics', 'Optics', 'Electromagnetism', 'Modern Physics'] },
];

const questionBank = {
  'Mathematics': {
    'Algebra': [
      { q_en: 'What is the value of x if 2x + 5 = 15?', q_hi: 'यदि 2x + 5 = 15 है, तो x का मान क्या है?', a: '5', b: '10', c: '7.5', d: '2.5', ans: '5', ans_hi: '5' },
      { q_en: 'Simplify: 3(x + 2) - 2(x - 1)', q_hi: 'सरल करें: 3(x + 2) - 2(x - 1)', a: 'x + 8', b: 'x + 4', c: '5x + 4', d: 'x + 6', ans: 'x + 8', ans_hi: 'x + 8' },
    ],
    'Geometry': [
      { q_en: 'What is the sum of angles in a triangle?', q_hi: 'त्रिभुज के कोणों का योग क्या है?', a: '90°', b: '180°', c: '270°', d: '360°', ans: '180°', ans_hi: '180°' },
      { q_en: 'Area of a circle with radius r is?', q_hi: 'त्रिज्या r वाले वृत्त का क्षेत्रफल क्या है?', a: '2πr', b: 'πr²', c: 'πd', d: '2πr²', ans: 'πr²', ans_hi: 'πr²' },
    ],
    'Trigonometry': [
      { q_en: 'sin²θ + cos²θ = ?', q_hi: 'sin²θ + cos²θ = ?', a: '0', b: '1', c: '2', d: '-1', ans: '1', ans_hi: '1' },
      { q_en: 'tan 45° = ?', q_hi: 'tan 45° = ?', a: '0', b: '1', c: '√2', d: '∞', ans: '1', ans_hi: '1' },
    ],
    'Calculus': [
      { q_en: 'Derivative of x² is?', q_hi: 'x² का अवकलज क्या है?', a: 'x', b: '2x', c: '2x²', d: 'x²', ans: '2x', ans_hi: '2x' },
      { q_en: '∫ 2x dx = ?', q_hi: '∫ 2x dx = ?', a: 'x² + C', b: '2x² + C', c: 'x + C', d: '2 + C', ans: 'x² + C', ans_hi: 'x² + C' },
    ],
    'Statistics': [
      { q_en: 'Mean of 2, 4, 6, 8, 10 is?', q_hi: '2, 4, 6, 8, 10 का माध्य क्या है?', a: '4', b: '6', c: '5', d: '8', ans: '6', ans_hi: '6' },
      { q_en: 'Median of 3, 5, 7, 9, 11 is?', q_hi: '3, 5, 7, 9, 11 का मध्यिका क्या है?', a: '5', b: '7', c: '9', d: '6', ans: '7', ans_hi: '7' },
    ],
  },
  'Physics': {
    'Mechanics': [
      { q_en: 'SI unit of force is?', q_hi: 'बल की SI इकाई क्या है?', a: 'Joule', b: 'Newton', c: 'Watt', d: 'Pascal', ans: 'Newton', ans_hi: 'न्यूटन' },
      { q_en: 'F = ma is which law?', q_hi: 'F = ma कौन सा नियम है?', a: 'First law', b: 'Second law', c: 'Third law', d: 'None', ans: 'Second law', ans_hi: 'दूसरा नियम' },
    ],
    'Thermodynamics': [
      { q_en: 'SI unit of temperature is?', q_hi: 'तापमान की SI इकाई क्या है?', a: 'Celsius', b: 'Fahrenheit', c: 'Kelvin', d: 'Rankine', ans: 'Kelvin', ans_hi: 'केल्विन' },
      { q_en: 'First law of thermodynamics is based on?', q_hi: 'ऊष्मागतिकी का प्रथम नियम किस पर आधारित है?', a: 'Energy conservation', b: 'Mass conservation', c: 'Both', d: 'None', ans: 'Energy conservation', ans_hi: 'ऊर्जा संरक्षण' },
    ],
    'Optics': [
      { q_en: 'Speed of light in vacuum is?', q_hi: 'शून्य में प्रकाश की गति क्या है?', a: '3×10⁶ m/s', b: '3×10⁸ m/s', c: '3×10¹⁰ m/s', d: '3×10⁴ m/s', ans: '3×10⁸ m/s', ans_hi: '3×10⁸ m/s' },
      { q_en: 'Convex lens is used for?', q_hi: 'अवतल लेंस का उपयोग किसके लिए है?', a: 'Magnification', b: 'Minification', c: 'Both', d: 'None', ans: 'Magnification', ans_hi: 'आवर्धन' },
    ],
    'Electromagnetism': [
      { q_en: 'SI unit of electric current is?', q_hi: 'विद्युत धारा की SI इकाई क्या है?', a: 'Volt', b: 'Ampere', c: 'Ohm', d: 'Watt', ans: 'Ampere', ans_hi: 'एम्पियर' },
      { q_en: 'Ohm\'s law states V = ?', q_hi: 'ओम का नियम V = ? बताता है', a: 'IR', b: 'I/R', c: 'I+R', d: 'I-R', ans: 'IR', ans_hi: 'IR' },
    ],
    'Modern Physics': [
      { q_en: 'Who discovered electron?', q_hi: 'इलेक्ट्रॉन की खोज किसने की?', a: 'Newton', b: 'Thomson', c: 'Rutherford', d: 'Bohr', ans: 'Thomson', ans_hi: 'थॉमसन' },
      { q_en: 'E = mc² is which equation?', q_hi: 'E = mc² कौन सा समीकरण है?', a: 'Ohm\'s law', b: 'Newton\'s law', c: 'Mass-energy equivalence', d: 'Faraday\'s law', ans: 'Mass-energy equivalence', ans_hi: 'द्रव्यमान-ऊर्जा समता' },
    ],
  },
};

async function seed() {
  console.log('Seeding subject-wise questions into existing quiz...\n');

  const category = await Category.findOne({ name: 'mock-station-demo' });
  if (!category) {
    console.error('❌ Category "mock-station-demo" not found.');
    process.exit(1);
  }
  console.log('✅ Found category: Mock Station Demo');

  const subcategory = await Subcategory.findOne({ categoryId: category._id, name: 'mock-station-demo-tests' });
  if (!subcategory) {
    console.error('❌ Subcategory "mock-station-demo-tests" not found.');
    process.exit(1);
  }
  console.log('✅ Found subcategory: mock-station-demo-tests');

  const quiz = await Quiz.findOne({ name: 'Demo Subject Wise - Chapter Test (20)', categoryId: category._id });
  if (!quiz) {
    console.error('❌ Quiz "Demo Subject Wise - Chapter Test (20)" not found.');
    process.exit(1);
  }
  console.log(`✅ Found quiz: ${quiz.name} (${quiz._id})`);

  // Update existing questions to have question_mode: 'subject'
  const updateResult = await Question.updateMany(
    { quizId: quiz._id, question_mode: { $ne: 'subject' } },
    { $set: { question_mode: 'subject' } }
  );
  console.log(`✅ Updated ${updateResult.modifiedCount} existing questions to question_mode: 'subject'`);

  let totalQuestions = 0;

  for (const subject of subjects) {
    for (const chapter of subject.chapters) {
      const questions = questionBank[subject.name]?.[chapter] || [];
      for (const q of questions) {
        const existing = await Question.findOne({
          quizId: quiz._id,
          'question_title.en': q.q_en,
        });
        if (existing) {
          console.log(`  ⏭️  Skipping (exists): ${q.q_en.substring(0, 40)}...`);
          continue;
        }

        await Question.create({
          categoryId: category._id,
          subcategoryId: subcategory._id,
          quizId: quiz._id,
          subject: subject.name,
          chapter: chapter,
          question_mode: 'subject',
          question_type: 'text_only',
          question_title: { en: q.q_en, hi: q.q_hi },
          option: {
            a: { text: { en: q.a, hi: q.a }, image: '' },
            b: { text: { en: q.b, hi: q.b }, image: '' },
            c: { text: { en: q.c, hi: q.c }, image: '' },
            d: { text: { en: q.d, hi: q.d }, image: '' },
          },
          answer: { en: q.ans, hi: q.ans_hi },
          description: { en: '', hi: '' },
          is_active: 1,
        });
        totalQuestions++;
        console.log(`  ✅ ${subject.name} / ${chapter}: ${q.q_en.substring(0, 50)}...`);
      }
    }
  }

  console.log(`\n✅ Inserted ${totalQuestions} subject-wise questions into "${quiz.name}"`);
  mongoose.disconnect();
}

seed().catch(err => {
  console.error('Seed failed:', err);
  process.exit(1);
});
