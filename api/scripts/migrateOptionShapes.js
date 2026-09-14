require('dotenv').config();
const mongoose = require('mongoose');

const OPTION_KEYS = ['a', 'b', 'c', 'd'];

function textValue(value) {
    return value === undefined || value === null ? '' : String(value);
}

function normalizeOption(option) {
    if (option === undefined || option === null) return option;

    if (typeof option === 'string') {
        return { text: { en: option, hi: '' }, image: '' };
    }

    if (typeof option !== 'object' || Array.isArray(option)) {
        return option;
    }

    const image = textValue(option.image);
    const rawText = option.text !== undefined ? option.text : option;
    const text = typeof rawText === 'object' && rawText !== null
        ? { en: textValue(rawText.en), hi: textValue(rawText.hi) }
        : { en: textValue(rawText), hi: '' };

    const normalized = { text, image };
    const alreadyNormalized = option.text && typeof option.text === 'object'
        && Object.prototype.hasOwnProperty.call(option.text, 'en')
        && Object.prototype.hasOwnProperty.call(option.text, 'hi')
        && (option.image === undefined || typeof option.image === 'string');

    return alreadyNormalized ? option : normalized;
}

function normalizeOptionMap(optionMap) {
    if (!optionMap || typeof optionMap !== 'object') return { value: optionMap, changed: false };

    const normalized = { ...optionMap };
    let changed = false;
    for (const key of OPTION_KEYS) {
        if (normalized[key] === undefined || normalized[key] === null) continue;
        const next = normalizeOption(normalized[key]);
        if (JSON.stringify(next) !== JSON.stringify(normalized[key])) {
            normalized[key] = next;
            changed = true;
        }
    }
    return { value: normalized, changed };
}

async function migrateCollection(collection, mapper) {
    let scanned = 0;
    let updated = 0;
    let optionsUpdated = 0;

    const cursor = collection.find({});
    for await (const document of cursor) {
        scanned++;
        const result = mapper(document);
        if (!result.changed) continue;

        await collection.updateOne(
            { _id: document._id },
            { $set: result.set }
        );
        updated++;
        optionsUpdated += result.optionsUpdated;
    }

    return { scanned, updated, optionsUpdated };
}

async function main() {
    await mongoose.connect(process.env.DB_CONNECTION);
    const db = mongoose.connection.db;

    const questionResult = await migrateCollection(db.collection('questions'), (question) => {
        const normalized = normalizeOptionMap(question.option);
        return {
            changed: normalized.changed,
            optionsUpdated: normalized.changed ? 1 : 0,
            set: { option: normalized.value },
        };
    });

    const userQuizResult = await migrateCollection(db.collection('userquizzes'), (attempt) => {
        if (!Array.isArray(attempt.questionDetails)) {
            return { changed: false, optionsUpdated: 0, set: {} };
        }

        let changed = false;
        let optionsUpdated = 0;
        const questionDetails = attempt.questionDetails.map((detail) => {
            const normalized = normalizeOptionMap(detail.option);
            if (!normalized.changed) return detail;
            changed = true;
            optionsUpdated++;
            return { ...detail, option: normalized.value };
        });

        return {
            changed,
            optionsUpdated,
            set: { questionDetails },
        };
    });

    console.log(JSON.stringify({ questionResult, userQuizResult }, null, 2));
}

main()
    .catch((error) => {
        console.error('Option migration failed:', error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await mongoose.disconnect();
    });
