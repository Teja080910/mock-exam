// Integration tests for the bilingual ({en, hi}) question feature.
// Run from api/ folder against the local DB:  node tests/bilingual.test.js
// Uses a dedicated test quiz + questions, cleans up after itself.

require('dotenv').config();
const assert = require('assert');
const mongoose = require('mongoose');

const Questions = require('../models/questionsModel');
const Subcategory = require('../models/subcategoryModel');
const apiController = require('../controllers/apiController');
const questionsController = require('../controllers/questionsController');

let passed = 0;
let failed = 0;
const failures = [];

function test(name, fn) {
    return Promise.resolve()
        .then(fn)
        .then(() => { passed++; console.log(`  PASS  ${name}`); })
        .catch(err => {
            failed++;
            failures.push({ name, err: err.message });
            console.log(`  FAIL  ${name}\n        ${err.message}`);
        });
}

// Mock res that captures the json payload
function mockRes() {
    const res = {};
    res.json = (out) => { res.payload = out; return res; };
    res.status = () => res;
    res.send = () => res;
    res.render = () => res;
    res.redirect = () => res;
    res.flash = () => res;
    return res;
}

function makeAdminSessionReq(body) {
    return { body: body || {}, query: {}, session: { user_id: global.__testAdminId }, files: {} };
}

async function main() {
    await mongoose.connect(process.env.DB_CONNECTION);

    // Register models needed by populate()
    require('../models/categoryModel');
    require('../models/quizModel');
    Subcategory.findOne(); // ensure schema registered

    const col = mongoose.connection.db.collection('questions');

    // ---- setup: find an admin for session-gated controller tests ----
    const admin = await mongoose.connection.db.collection('admins').findOne({ is_admin: 1 });
    global.__testAdminId = admin ? String(admin._id) : null;

    // ---- setup: test quiz ----
    const quizCol = mongoose.connection.db.collection('quizzes');
    const quizInsert = await quizCol.insertOne({
        name: 'TEST-QUIZ-bilingual',
        categoryId: new mongoose.Types.ObjectId(),
        timer_status: 1,
        minutes_per_quiz: 10,
        correct_ans_reward_per_question: 1,
        penalty_per_question: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
    });
    const quizId = quizInsert.insertedId;

    // ---- setup: one nested Hindi-only question via model ----
    const q1 = await Questions.create({
        categoryId: new mongoose.Types.ObjectId(),
        quizId,
        question_type: 'text_only',
        question_title: { en: '', hi: '<p>प्रश्न एक?</p>' },
        option: {
            a: { text: { en: '', hi: 'उत्तर हिंदी' }, image: '' },
            b: { text: { en: 'Option B', hi: '' }, image: '' },
            c: { text: { en: '', hi: '' }, image: '' },
            d: { text: { en: '', hi: '' }, image: '' },
        },
        answer: { en: '', hi: 'उत्तर हिंदी' },
        description: { en: '<p><br></p>', hi: '<p>समाधान एक</p>' },
        is_active: 1,
    });

    // ---- setup: legacy flat-string document (raw, bypassing strict schema) ----
    const legacyInsert = await col.insertOne({
        categoryId: new mongoose.Types.ObjectId(),
        quizId,
        question_type: 'text_only',
        question_title: '<p>Legacy English question?</p>',
        option: { a: 'legacy A', b: { text: 'legacy B text', image: 'b.jpg' }, c: '', d: '' },
        answer: 'legacy A',
        description: '<p>Legacy desc</p>',
        is_active: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
    });

    // =========================================================================
    console.log('\nAPI: GetQuestionsByQuizId');
    // =========================================================================

    await test('returns nested question_title {en, hi}', async () => {
        const req = { body: { quizId: String(quizId) } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        assert.strictEqual(res.payload.data.success, 1);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(q1._id));
        assert.ok(item, 'question not in response');
        assert.deepStrictEqual(Object.keys(item.question_title).sort(), ['en', 'hi']);
        assert.strictEqual(item.question_title.hi, '<p>प्रश्न एक?</p>');
        assert.strictEqual(item.question_title.en, '');
    });

    await test('option text is nested {en, hi} with image key', async () => {
        const req = { body: { quizId: String(quizId) } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(q1._id));
        assert.deepStrictEqual(item.option.a.text, { en: '', hi: 'उत्तर हिंदी' });
        assert.strictEqual(item.option.b.text.en, 'Option B');
        assert.strictEqual(item.option.a.image, '');
        assert.ok(!('option_hi' in item), 'flat option_hi must be gone');
        assert.ok(!('question_title_hi' in item), 'flat question_title_hi must be gone');
    });

    await test('description strips <p><br></p>', async () => {
        const req = { body: { quizId: String(quizId) } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(q1._id));
        assert.strictEqual(item.description.hi, '<p>समाधान एक</p>');
        assert.strictEqual(item.description.en, '');
    });

    await test('answer is nested {en, hi}', async () => {
        const req = { body: { quizId: String(quizId) } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(q1._id));
        assert.deepStrictEqual(item.answer, { en: '', hi: 'उत्तर हिंदी' });
    });

    await test('legacy flat-string docs normalized without crashing', async () => {
        const req = { body: { quizId: String(quizId) } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(legacyInsert.insertedId));
        assert.ok(item, 'legacy question missing');
        assert.strictEqual(item.question_title.en, '<p>Legacy English question?</p>');
        assert.strictEqual(item.option.a.text.en, 'legacy A');
        assert.strictEqual(item.option.b.text.en, 'legacy B text');
        assert.strictEqual(item.option.b.image, 'b.jpg');
        assert.strictEqual(item.answer.en, 'legacy A');
    });

    await test('unknown quizId -> success 0', async () => {
        const req = { body: { quizId: new mongoose.Types.ObjectId().toString() } };
        const res = mockRes();
        await apiController.GetQuestionsByQuizId(req, res);
        assert.strictEqual(res.payload.data.success, 0);
    });

    // =========================================================================
    console.log('\nAPI: GetQuestions + GetQuestionsByCategoryId');
    // =========================================================================

    await test('GetQuestions returns nested shapes', async () => {
        const res = mockRes();
        await apiController.GetQuestions({}, res);
        assert.strictEqual(res.payload.data.success, 1);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(q1._id));
        assert.ok(item && typeof item.question_title === 'object');
        assert.ok(item.option.a.text && typeof item.option.a.text === 'object');
    });

    await test('GetQuestionsByCategoryId normalizes legacy option', async () => {
        const catDoc = await mongoose.connection.db.collection('questions').findOne({ _id: legacyInsert.insertedId }, { projection: { categoryId: 1 } });
        const req = { body: { categoryId: String(catDoc.categoryId) } };
        const res = mockRes();
        await apiController.GetQuestionsByCategoryId(req, res);
        assert.strictEqual(res.payload.data.success, 1);
        const item = res.payload.data.questionsDetails.find(q => String(q._id) === String(legacyInsert.insertedId));
        assert.ok(item, 'missing from category response');
        assert.strictEqual(item.option.b.image, 'b.jpg');
        assert.strictEqual(item.option.a.text.en, 'legacy A');
    });

    // =========================================================================
    console.log('\nAdmin: addQuestions + UpdateQuestions (nested writes)');
    // =========================================================================

    await test('addQuestions stores bilingual nested fields', async function () {
        if (!global.__testAdminId) return;
        const req = makeAdminSessionReq({
            question_type: 'text_only',
            question_title: 'What is 2+2?',
            question_title_hi: '२+२ क्या है?',
            a: '4', b: '5', c: '6', d: '7',
            a_hi: '४', b_hi: '५', c_hi: '६', d_hi: '७',
            answer: '4',
            answer_hi: '४',
            description: '<p>Basic math</p>',
            description_hi: '<p>गणित</p>',
            is_active: 'on',
        });
        req.body.categoryId = String((await Questions.findById(q1._id)).categoryId);
        req.body.quizId = String(quizId);
        const res = mockRes();
        res.redirect = () => {};
        req.flash = () => {};
        await questionsController.addQuestions(req, res);
        const saved = await col.findOne({ quizId, 'question_title.en': 'What is 2+2?' });
        assert.ok(saved, 'question was not saved');
        assert.strictEqual(saved.question_title.hi, '२+२ क्या है?');
        assert.strictEqual(saved.option.c.text.hi, '६');
        assert.strictEqual(saved.answer.en, '4');
        assert.strictEqual(saved.answer.hi, '४');
        assert.strictEqual(saved.description.hi, '<p>गणित</p>');
        global.__addedId = saved._id;
    });

    await test('UpdateQuestions rewrites nested fields', async function () {
        if (!global.__testAdminId || !global.__addedId) return;
        const req = makeAdminSessionReq({
            id: String(global.__addedId),
            question_type: 'text_only',
            question_title: 'What is 3+3?',
            question_title_hi: '३+३ क्या है?',
            a: '6', b: '5', c: '4', d: '9',
            a_hi: '६', d_hi: '९',
            answer: '6',
            answer_hi: '६',
            description: '<p>Updated</p>',
            description_hi: '<p>अद्यतन</p>',
        });
        req.body.categoryId = String((await Questions.findById(q1._id)).categoryId);
        req.body.quizId = String(quizId);
        const res = mockRes();
        res.redirect = () => {};
        req.flash = () => {};
        await questionsController.UpdateQuestions(req, res);
        const updated = await col.findOne({ _id: global.__addedId });
        assert.strictEqual(updated.question_title.en, 'What is 3+3?');
        assert.strictEqual(updated.question_title.hi, '३+३ क्या है?');
        assert.strictEqual(updated.option.a.text.hi, '६');
        assert.strictEqual(updated.description.hi, '<p>अद्यतन</p>');
    });

    // =========================================================================
    console.log('\nMigration script helpers (convert idempotency)');
    // =========================================================================

    await test('convert skips already-nested docs (no $type:string matches)', async () => {
        const pending = await col.countDocuments({
            $or: [
                { question_title: { $type: 'string' } },
                { description: { $type: 'string' } },
                { answer: { $type: 'string' } },
            ]
        });
        // legacy test doc above is intentionally still flat, so expect exactly 1
        assert.strictEqual(pending, 1);
    });

    // ---- cleanup ----
    await Questions.deleteMany({ quizId });
    await quizCol.deleteOne({ _id: quizId });

    await mongoose.disconnect();

    console.log(`\n${passed} passed, ${failed} failed`);
    if (failed > 0) {
        process.exit(1);
    }
}

main().catch(err => { console.error(err); process.exit(1); });
