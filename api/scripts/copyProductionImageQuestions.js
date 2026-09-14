const fs = require('fs');
const path = require('path');
const axios = require('axios');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

const localEnv = dotenv.parse(fs.readFileSync(path.join(__dirname, '../.env')));
const productionEnv = dotenv.parse(fs.readFileSync(path.join(__dirname, '../.env.prod')));
const ASSET_BASE = 'https://app.mockstation.com/assets/userImages/';
const IMAGE_DIR = path.join(__dirname, '../public/assets/userImages');

function objectId(value) {
    return value instanceof mongoose.Types.ObjectId
        ? value
        : new mongoose.Types.ObjectId(String(value));
}

function assetName(value) {
    if (!value || typeof value !== 'string') return '';
    return path.basename(value.split('?')[0]);
}

function collectAsset(value, assets) {
    const name = assetName(value);
    if (name) assets.add(name);
}

function collectQuestionAssets(question, assets) {
    collectAsset(question.image, assets);
    collectAsset(question.audio, assets);
    for (const key of ['a', 'b', 'c', 'd']) {
        collectAsset(question.option?.[key]?.image, assets);
    }
}

async function copyAsset(name) {
    const target = path.join(IMAGE_DIR, name);
    if (fs.existsSync(target) && fs.statSync(target).size > 0) return 'existing';

    try {
        const response = await axios.get(`${ASSET_BASE}${encodeURIComponent(name)}`, {
            responseType: 'arraybuffer',
            timeout: 30000,
            validateStatus: (status) => status >= 200 && status < 300,
        });
        fs.writeFileSync(target, response.data);
        return 'downloaded';
    } catch (error) {
        console.log(`  Asset not copied: ${name} (${error.message})`);
        return 'failed';
    }
}

async function main() {
    fs.mkdirSync(IMAGE_DIR, { recursive: true });
    const localConnection = await mongoose.createConnection(localEnv.DB_CONNECTION).asPromise();
    const productionConnection = await mongoose.createConnection(productionEnv.DB_CONNECTION).asPromise();
    const local = localConnection.db;
    const production = productionConnection.db;

    const productionQuestions = await production.collection('questions').find({
        question_type: 'images',
        $or: [
            { 'option.a.image': { $exists: true, $nin: [null, ''] } },
            { 'option.b.image': { $exists: true, $nin: [null, ''] } },
            { 'option.c.image': { $exists: true, $nin: [null, ''] } },
            { 'option.d.image': { $exists: true, $nin: [null, ''] } },
        ],
    }).toArray();

    const quizIds = [...new Set(productionQuestions.map((question) => String(question.quizId)))];
    const quizzes = await production.collection('quizzes').find({
        _id: { $in: quizIds.map(objectId) },
    }).toArray();
    const categoryIds = [...new Set(quizzes.map((quiz) => String(quiz.categoryId)).filter(Boolean))];
    const subcategoryIds = [...new Set([
        ...quizzes.map((quiz) => quiz.subcategoryId).filter(Boolean).map(String),
        ...productionQuestions.map((question) => question.subcategoryId).filter(Boolean).map(String),
    ])];
    const categories = await production.collection('categories').find({
        _id: { $in: categoryIds.map(objectId) },
    }).toArray();
    const subcategories = await production.collection('subcategories').find({
        _id: { $in: subcategoryIds.map(objectId) },
    }).toArray();

    const copyDocuments = async (collectionName, documents) => {
        for (const document of documents) {
            await local.collection(collectionName).replaceOne(
                { _id: document._id },
                document,
                { upsert: true },
            );
        }
    };
    await copyDocuments('categories', categories);
    await copyDocuments('subcategories', subcategories);
    await copyDocuments('quizzes', quizzes);
    await copyDocuments('questions', productionQuestions);

    const assets = new Set();
    for (const question of productionQuestions) collectQuestionAssets(question, assets);
    for (const quiz of quizzes) collectAsset(quiz.image, assets);
    for (const category of categories) collectAsset(category.image, assets);
    for (const subcategory of subcategories) collectAsset(subcategory.image, assets);

    let downloaded = 0;
    let existing = 0;
    let failed = 0;
    for (const name of assets) {
        const result = await copyAsset(name);
        if (result === 'downloaded') downloaded++;
        if (result === 'existing') existing++;
        if (result === 'failed') failed++;
    }

    console.log(JSON.stringify({
        copiedQuestions: productionQuestions.length,
        copiedQuizzes: quizzes.length,
        copiedCategories: categories.length,
        copiedSubcategories: subcategories.length,
        referencedAssets: assets.size,
        downloaded,
        alreadyLocal: existing,
        failedAssets: failed,
    }, null, 2));

    await productionConnection.close();
    await localConnection.close();
}

main().catch((error) => {
    console.error('Production image-question copy failed:', error);
    process.exitCode = 1;
});
