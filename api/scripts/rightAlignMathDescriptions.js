// Right-aligns paragraphs that contain complete display-math blocks
// (\[ ... \] or $$ ... $$) inside question descriptions (en + hi).
// Usage:
//   node scripts/rightAlignMathDescriptions.js          # dry run
//   node scripts/rightAlignMathDescriptions.js --apply  # write changes
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });
const mongoose = require('mongoose');
require('../models/questionsModel');

const APPLY = process.argv.includes('--apply');
const MATH_BLOCK = /\\\[[\s\S]*?\\\]|\$\$[\s\S]*?\$\$/;

function rightAlignParagraphs(html) {
  if (!html || typeof html !== 'string') return { html, changed: false };
  let changed = false;
  const out = html.replace(/<p(\s[^>]*)?>([\s\S]*?)<\/p>/gi, (match, attrs, content) => {
    if (!MATH_BLOCK.test(content)) return match;
    attrs = attrs || '';
    const styleMatch = attrs.match(/\sstyle\s*=\s*"([^"]*)"/i);
    if (!styleMatch) {
      changed = true;
      return `<p style="text-align:right"${attrs}>${content}</p>`;
    }
    const oldStyle = styleMatch[1];
    let newStyle;
    if (/text-align\s*:/i.test(oldStyle)) {
      if (/text-align\s*:\s*right/i.test(oldStyle)) return match;
      newStyle = oldStyle.replace(/text-align\s*:\s*[^;]+/i, 'text-align:right');
    } else {
      newStyle = oldStyle.trim().replace(/;?$/, ';') + 'text-align:right';
    }
    changed = true;
    return `<p${attrs.replace(styleMatch[0], ` style="${newStyle}"`)}>${content}</p>`;
  });
  return { html: out, changed };
}

// Display math typed directly between paragraphs (e.g. "</p>\[...\]<p>") has
// no block to align; give each loose block its own right-aligned paragraph.
const CONTAINER_TAG = /<(\/)?(p|li|td|th|h[1-6])\b[^>]*>/gi;

function isInsideContainer(textBefore) {
  let inside = false;
  for (const m of textBefore.matchAll(CONTAINER_TAG)) {
    inside = !m[1];
  }
  return inside;
}

function wrapLooseMathBlocks(html) {
  if (!html || typeof html !== 'string') return { html, changed: false };
  let changed = false;
  const out = html.replace(
    /\\\[[\s\S]*?\\\]|\$\$[\s\S]*?\$\$/g,
    (match, offset, full) => {
      if (isInsideContainer(full.slice(0, offset))) return match;
      changed = true;
      return `<p style="text-align:right">${match}</p>`;
    },
  );
  return { html: out, changed };
}

async function run() {
  const dbUri = process.env.DB_CONNECTION || 'mongodb://localhost:27017/Mockstation';
  console.log(`${APPLY ? 'APPLYING' : 'DRY RUN'} against ${dbUri.replace(/\/\/[^@]*@/, '//***@')}`);
  await mongoose.connect(dbUri);

  const Question = mongoose.model('Question');
  const questions = await Question.find({
    $or: [
      { 'description.en': /\\\[|\$\$/ },
      { 'description.hi': /\\\[|\$\$/ },
    ],
  });

  console.log(`Questions with display math: ${questions.length}`);
  let updatedDocs = 0;
  let updatedFields = 0;

  for (const q of questions) {
    if (!q.description) continue;
    let modified = false;
    for (const lang of ['en', 'hi']) {
      const aligned = rightAlignParagraphs(q.description[lang]);
      const wrapped = wrapLooseMathBlocks(aligned.html);
      if (aligned.changed || wrapped.changed) {
        updatedFields++;
        modified = true;
        if (APPLY) q.description[lang] = wrapped.html;
      }
    }
    if (modified && APPLY) {
      q.markModified('description');
      await q.save();
    }
    if (modified) {
      updatedDocs++;
      console.log(`  ${APPLY ? 'updated' : 'would update'} [${q._id}] ${(q.question_title && q.question_title.en) || ''}`.slice(0, 120));
      if (!APPLY && updatedDocs <= 2) {
        const before = q.description.en || q.description.hi || '';
        const after = rightAlignParagraphs(before).html;
        const after2 = wrapLooseMathBlocks(after).html;
        console.log('    BEFORE:', before.slice(0, 260).replace(/\n/g, ' '));
        console.log('    AFTER :', after2.slice(0, 320).replace(/\n/g, ' '));
      }
    }
  }

  console.log(
    `${APPLY ? 'Updated' : 'Would update'} ${updatedDocs} documents (${updatedFields} language fields).`,
  );
  if (!APPLY) console.log('Run again with --apply to write changes.');
  await mongoose.disconnect();
}

run().catch((err) => {
  console.error('Failed:', err.message);
  process.exit(1);
});
