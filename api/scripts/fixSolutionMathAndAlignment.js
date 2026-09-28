const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
require('../models/questionsModel');

function cleanDesc(text, isHindi) {
  if (!text || typeof text !== 'string') return text;
  let cleaned = text.replace(/<p\s+style=["\x27]text-align:\s*right;?["\x27]>/gi, '<p>');

  if (isHindi) {
    // Move trailing Indic text out of display math \[ ... \text{ text } \]
    cleaned = cleaned.replace(/\\text\{\s*([^a-zA-Z\\}]+?)\s*\}\s*\\\]/g, '\\] $1');

    // Q4: fraction with Hindi in math mode
    cleaned = cleaned.replace(
      /\$\\frac\{\\text\{लाभ\}\}\{\\text\{क्रय मूल्य\}\}\\times100\$/g,
      '(लाभ / क्रय मूल्य) $\\times 100$'
    );

    // Q5: \[\text{औसत}=\frac{100}{4}=25\]
    cleaned = cleaned.replace(
      /\\\[\\text\{औसत\}=\\frac\{100\}\{4\}=25\\\]/g,
      'औसत = \\[\\frac{100}{4}=25\\]'
    );

    // Q8: \frac{\text{दूरी}}{\text{समय}}
    cleaned = cleaned.replace(
      /\$\\frac\{\\text\{दूरी\}\}\{\\text\{समय\}\}\$/g,
      '(दूरी / समय)'
    );

    // Q10: \[\text{चक्रवृद्धि ब्याज}=12100-10000=₹2,100\]
    cleaned = cleaned.replace(
      /\\\[\\text\{चक्रवृद्धि ब्याज\}=12100-10000=₹2,100\\\]/g,
      'चक्रवृद्धि ब्याज = \\[12100-10000=₹2,100\\]'
    );
  }
  return cleaned;
}

async function run() {
  const dbUri = process.env.DB_CONNECTION || 'mongodb://localhost:27017/Mockstation';
  console.log(`Connecting to ${dbUri}...`);
  await mongoose.connect(dbUri);

  const Question = mongoose.model('Question');
  const questions = await Question.find({
    $or: [
      { 'description.hi': /text-align/ },
      { 'description.en': /text-align/ },
      { 'description.hi': /\\text\{/ },
    ],
  });

  console.log(`Found ${questions.length} questions to inspect/update.`);
  let updatedCount = 0;

  for (const q of questions) {
    let modified = false;

    if (q.description) {
      if (q.description.en) {
        const cleanedEn = cleanDesc(q.description.en, false);
        if (cleanedEn !== q.description.en) {
          q.description.en = cleanedEn;
          modified = true;
        }
      }

      if (q.description.hi) {
        const cleanedHi = cleanDesc(q.description.hi, true);
        if (cleanedHi !== q.description.hi) {
          q.description.hi = cleanedHi;
          modified = true;
        }
      }
    }

    if (modified) {
      q.markModified('description');
      await q.save();
      updatedCount++;
      console.log(`Updated question [${q._id}]`);
    }
  }

  console.log(`Successfully updated ${updatedCount} questions in DB.`);
  process.exit(0);
}

run().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
