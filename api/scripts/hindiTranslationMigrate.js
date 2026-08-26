// Bilingual question data tools (nested model):
//   question_title: { en: "...", hi: "..." }
//   option: { a: { text: { en, hi }, image }, ... }
//   answer / description: { en, hi }
//
// Usage (run from api/ folder):
//   1) node scripts/hindiTranslationMigrate.js convert
//        -> one-time: converts legacy/flat docs into the nested {en,hi} shape
//   2) node scripts/hindiTranslationMigrate.js export
//        -> writes data/hindi-translation/pending.json (questions missing English)
//   3) node scripts/hindiTranslationMigrate.js translate [--provider=gemini|openai] [--limit=N]
//        -> AI fills English into data/hindi-translation/translated.json
//        -> resumable: re-run to continue where it stopped
//   4) node scripts/hindiTranslationMigrate.js apply [--dry-run]
//        -> writes English into the nested en fields

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

const DATA_DIR = path.join(__dirname, '..', 'data', 'hindi-translation');
const PENDING_FILE = path.join(DATA_DIR, 'pending.json');
const TRANSLATED_FILE = path.join(DATA_DIR, 'translated.json');

// Server-side $regex needs \x{...} form; \uXXXX is rejected by PCRE2
const DEVANAGARI_SOURCE = '[\\x{0900}-\\x{097F}]';
const isDevanagari = (s) => typeof s === 'string' && /[\u0900-\u097F]/.test(s);

const command = process.argv[2] || '';
const args = Object.fromEntries(
    process.argv.slice(3)
        .filter(a => a.startsWith('--'))
        .map(a => { const [k, v] = a.replace(/^--/, '').split('='); return [k, v === undefined ? true : v]; })
);

function connect() {
    return mongoose.connect(process.env.DB_CONNECTION);
}

async function disconnect() {
    await mongoose.disconnect();
}

function getLegacyOptionText(opt) {
    if (opt == null) return '';
    if (typeof opt === 'string') return opt;
    if (typeof opt.text === 'string') return opt.text;
    if (opt.text && typeof opt.text.text === 'string') return opt.text.text; // very old nesting
    return '';
}

// ---------------------------------------------------------------------------
// CONVERT (one-time): legacy flat strings / parallel _hi fields -> nested
// ---------------------------------------------------------------------------
async function convert() {
    const col = mongoose.connection.db.collection('questions');

    // Anything not yet converted: question_title is a plain string
    const questions = await col.find({
        $or: [
            { question_title: { $type: 'string' } },
            { description: { $type: 'string' } },
            { answer: { $type: 'string' } },
            { question_title_hi: { $exists: true } },
            { option_hi: { $exists: true } },
        ]
    }).toArray();

    console.log(`${questions.length} documents to convert`);

    const ops = questions.map(q => {
        const set = {};
        const unset = {};

        // ---- question_title ----
        let title;
        if (typeof q.question_title === 'string') {
            title = isDevanagari(q.question_title)
                ? { en: '', hi: q.question_title }
                : { en: q.question_title, hi: '' };
        } else {
            title = {
                en: q.question_title?.en || '',
                hi: q.question_title?.hi || q.question_title_hi || ''
            };
        }
        if (!title.hi && q.question_title_hi && isDevanagari(q.question_title_hi)) {
            title.hi = q.question_title_hi;
        }
        set.question_title = title;

        // ---- description ----
        let desc;
        if (typeof q.description === 'string') {
            desc = isDevanagari(q.description)
                ? { en: '', hi: q.description }
                : { en: q.description, hi: '' };
        } else {
            desc = {
                en: q.description?.en || '',
                hi: q.description?.hi || q.description_hi || ''
            };
        }
        set.description = desc;

        // ---- options ----
        const option = {};
        for (const key of ['a', 'b', 'c', 'd']) {
            const legacy = q.option?.[key];
            const legacyText = getLegacyOptionText(legacy);
            let text;
            if (legacyText) {
                text = isDevanagari(legacyText)
                    ? { en: '', hi: legacyText }
                    : { en: legacyText, hi: '' };
            } else {
                text = { en: legacy?.text?.en || '', hi: legacy?.text?.hi || '' };
            }
            // merge old parallel option_hi field
            const oldHi = q.option_hi?.[key];
            if (!text.hi && typeof oldHi === 'string' && oldHi) text.hi = oldHi;
            option[key] = { text, image: (typeof legacy === 'object' && legacy?.image) || '' };
        }
        set.option = option;

        // ---- answer ----
        set.answer = typeof q.answer === 'string'
            ? (isDevanagari(q.answer) ? { en: '', hi: q.answer } : { en: q.answer, hi: '' })
            : { en: q.answer?.en || '', hi: q.answer?.hi || '' };

        // ---- drop obsolete parallel fields ----
        if (q.question_title_hi !== undefined) unset.question_title_hi = '';
        if (q.description_hi !== undefined) unset.description_hi = '';
        if (q.option_hi !== undefined) unset.option_hi = '';

        const update = { $set: set };
        if (Object.keys(unset).length) update.$unset = unset;
        return { updateOne: { filter: { _id: q._id }, update } };
    });

    if (args['dry-run']) {
        console.log(`Would convert ${ops.length} documents. Sample:`);
        console.log(JSON.stringify(set0(ops), null, 2));
    } else {
        let modified = 0;
        for (let i = 0; i < ops.length; i += 500) {
            const result = await col.bulkWrite(ops.slice(i, i + 500), { ordered: false });
            modified += result.modifiedCount;
            process.stdout.write('.');
        }
        console.log(`\nConverted ${modified} documents to nested bilingual format.`);
    }

    function set0(ops) {
        return ops.length ? ops[0].updateOne.update.$set : {};
    }
}

// ---------------------------------------------------------------------------
// EXPORT: questions still missing English
// ---------------------------------------------------------------------------
async function exportPending() {
    const col = mongoose.connection.db.collection('questions');

    const query = {
        $or: [
            { 'question_title.en': '' },
            { question_title: { $type: 'string', $regex: DEVANAGARI_SOURCE } },
        ],
        'question_title.hi': { $ne: '' },
    };

    const questions = await col.find(query).project({ question_title: 1, option: 1, description: 1 }).toArray();

    const entries = questions.map(q => ({
        _id: String(q._id),
        hi: {
            title: q.question_title?.hi || '',
            a: q.option?.a?.text?.hi || '',
            b: q.option?.b?.text?.hi || '',
            c: q.option?.c?.text?.hi || '',
            d: q.option?.d?.text?.hi || '',
            description: q.description?.hi || '',
        },
        en: { title: '', a: '', b: '', c: '', d: '', description: '' }
    }));

    fs.mkdirSync(DATA_DIR, { recursive: true });
    fs.writeFileSync(PENDING_FILE, JSON.stringify(entries, null, 2));
    console.log(`Exported ${entries.length} Hindi-only questions to ${PENDING_FILE}`);
}

// ---------------------------------------------------------------------------
// TRANSLATE (one-time AI usage, batched + resumable)
// ---------------------------------------------------------------------------
async function translateBatchGemini(apiKey, items) {
    const prompt = `Translate each exam question from Hindi to English.
Keep the meaning exact. Preserve simple HTML tags like <p>, <b> in "title" and "description".
Return ONLY a valid JSON array of objects with the same keys as the input:
[{"_id": "...", "title": "...", "a": "...", "b": "...", "c": "...", "d": "...", "description": "..."}]
Input:
${JSON.stringify(items.map(i => ({ _id: i._id, ...i.hi })))}`;

    const res = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
        {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: { temperature: 0.1 },
            })
        }
    );
    if (!res.ok) throw new Error(`Gemini API error ${res.status}: ${await res.text()}`);
    const data = await res.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
    const jsonText = text.replace(/^```json\s*/m, '').replace(/```\s*$/m, '').trim();
    return JSON.parse(jsonText);
}

async function translateBatchOpenAI(apiKey, items) {
    const prompt = `Translate each exam question from Hindi to English.
Keep the meaning exact. Preserve simple HTML tags like <p>, <b> in "title" and "description".
Return ONLY a valid JSON array of objects with the same keys as the input:
[{"_id": "...", "title": "...", "a": "...", "b": "...", "c": "...", "d": "...", "description": "..."}]
Input:
${JSON.stringify(items.map(i => ({ _id: i._id, ...i.hi })))}`;

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
            model: 'gpt-4o-mini',
            temperature: 0.1,
            response_format: { type: 'json_object' },
            messages: [
                { role: 'system', content: 'You are a translation API. Respond only with JSON.' },
                { role: 'user', content: prompt }
            ],
        })
    });
    if (!res.ok) throw new Error(`OpenAI API error ${res.status}: ${await res.text()}`);
    const data = await res.json();
    const parsed = JSON.parse(data.choices?.[0]?.message?.content || '{}');
    return Array.isArray(parsed) ? parsed : (parsed.items || []);
}

async function translate() {
    if (!fs.existsSync(PENDING_FILE)) {
        console.error('pending.json not found. Run the "export" command first.');
        process.exit(1);
    }

    const apiKey = args.key || process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY;
    if (!apiKey) {
        console.error('No API key. Pass --key=... or set GEMINI_API_KEY / OPENAI_API_KEY env var.');
        process.exit(1);
    }
    const provider = args.provider || (process.env.GEMINI_API_KEY ? 'gemini' : 'openai');
    const batchSize = parseInt(args.batch || '20', 10);
    const limit = args.limit ? parseInt(args.limit, 10) : Infinity;

    const entries = JSON.parse(fs.readFileSync(PENDING_FILE, 'utf8'));

    let done = new Map();
    if (fs.existsSync(TRANSLATED_FILE)) {
        for (const t of JSON.parse(fs.readFileSync(TRANSLATED_FILE, 'utf8'))) done.set(t._id, t);
    }

    const todo = entries.filter(e => !done.has(e._id)).slice(0, limit);
    console.log(`${done.size}/${entries.length} already translated. Translating ${todo.length} more (${provider}, batches of ${batchSize})...`);

    for (let i = 0; i < todo.length; i += batchSize) {
        const batch = todo.slice(i, i + batchSize);
        try {
            const results = provider === 'gemini'
                ? await translateBatchGemini(apiKey, batch)
                : await translateBatchOpenAI(apiKey, batch);

            for (const r of results) {
                const src = batch.find(b => b._id === r._id);
                if (!src) continue;
                done.set(r._id, {
                    _id: r._id,
                    hi: src.hi,
                    en: {
                        title: r.title || '',
                        a: r.a || '',
                        b: r.b || '',
                        c: r.c || '',
                        d: r.d || '',
                        description: r.description || '',
                    }
                });
            }
            fs.writeFileSync(TRANSLATED_FILE, JSON.stringify([...done.values()], null, 2));
            console.log(`Batch ${Math.floor(i / batchSize) + 1}: OK (${Math.min(i + batchSize, todo.length)}/${todo.length})`);
        } catch (err) {
            console.error(`Batch starting at ${i} failed: ${err.message}`);
            console.error('Progress saved. Re-run the same command to retry this batch.');
            break;
        }
    }

    fs.writeFileSync(TRANSLATED_FILE, JSON.stringify([...done.values()], null, 2));
    console.log(`Done. ${done.size}/${entries.length} translated -> ${TRANSLATED_FILE}`);
}

// ---------------------------------------------------------------------------
// APPLY: write English into the nested en fields
// ---------------------------------------------------------------------------
async function apply() {
    const dryRun = !!args['dry-run'];
    if (!fs.existsSync(TRANSLATED_FILE)) {
        console.error('translated.json not found. Run "translate" first.');
        process.exit(1);
    }

    const col = mongoose.connection.db.collection('questions');
    const translations = JSON.parse(fs.readFileSync(TRANSLATED_FILE, 'utf8'))
        .filter(t => (t.en?.title || '').trim().length > 0);

    console.log(`${translations.length} translations to apply${dryRun ? ' (DRY RUN)' : ''}`);

    const ops = translations.map(t => ({
        updateOne: {
            filter: { _id: new mongoose.Types.ObjectId(t._id) },
            update: {
                $set: {
                    'question_title.en': t.en.title,
                    'option.a.text.en': t.en.a,
                    'option.b.text.en': t.en.b,
                    'option.c.text.en': t.en.c,
                    'option.d.text.en': t.en.d,
                    'answer.en': t.en.a || t.en.b || t.en.c || t.en.d || '',
                    'description.en': t.en.description,
                }
            }
        }
    }));

    if (dryRun) {
        console.log(`Would update ${ops.length} questions. Sample:`);
        console.log(JSON.stringify(translations[0], null, 2));
    } else {
        let modified = 0;
        for (let i = 0; i < ops.length; i += 500) {
            const result = await col.bulkWrite(ops.slice(i, i + 500), { ordered: false });
            modified += result.modifiedCount;
            process.stdout.write('.');
        }
        console.log(`\nApplied English to ${modified} questions.`);
    }
}

// ---------------------------------------------------------------------------
(async () => {
    try {
        if (!['convert', 'export', 'translate', 'apply'].includes(command)) {
            console.log('Usage: node scripts/hindiTranslationMigrate.js <convert|export|translate|apply> [options]');
            console.log('  convert    one-time: legacy flat/_hi fields -> nested {en,hi} (--dry-run supported)');
            console.log('  export     dump questions missing English -> pending.json');
            console.log('  translate  AI-translate pending.json -> translated.json (one-time)');
            console.log('     --provider=gemini|openai   --batch=20   --limit=N');
            console.log('  apply      write English back into DB en fields (--dry-run supported)');
            process.exit(command ? 0 : 1);
        }

        if (command !== 'translate') await connect();
        if (command === 'convert') await convert();
        if (command === 'export') await exportPending();
        if (command === 'translate') await translate();
        if (command === 'apply') await apply();
        if (command !== 'translate') await disconnect();
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
})();
