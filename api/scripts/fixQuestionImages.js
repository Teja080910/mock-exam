const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const imageDir = path.join(__dirname, '../public/assets/userImages');

function extractBase64Image(html) {
    if (!html) return { image: '', cleanHtml: html };
    const imgRegex = /<img[^>]*src="data:image\/(\w+);base64,([^"]+)"[^>]*>/gi;
    let match;
    let image = '';
    while ((match = imgRegex.exec(html)) !== null) {
        if (!image) {
            try {
                const ext = match[1] === 'jpeg' ? 'jpg' : match[1];
                const filename = `${Date.now()}-question-${Math.random().toString(36).slice(2, 8)}.${ext}`;
                fs.writeFileSync(path.join(imageDir, filename), Buffer.from(match[2], 'base64'));
                image = filename;
            } catch (e) {
                console.log('Failed to save image:', e.message);
            }
        }
    }
    const cleanHtml = image ? html.replace(imgRegex, '').trim() : html;
    return { image, cleanHtml };
}

(async () => {
    try {
        await mongoose.connect(process.env.DB_CONNECTION);
        console.log('Connected');
        const coll = mongoose.connection.db.collection('questions');
        const docs = await coll.find({ 'question_title.en': /data:image\// }).toArray();
        console.log('Found', docs.length, 'questions with base64 images');
        let updated = 0;
        for (const doc of docs) {
            const en = doc.question_title && doc.question_title.en ? doc.question_title.en : '';
            const hi = doc.question_title && doc.question_title.hi ? doc.question_title.hi : '';
            const { image, cleanHtml } = extractBase64Image(en);
            if (!image) continue;
            const result = await coll.updateOne(
                { _id: doc._id },
                {
                    $set: {
                        image,
                        question_type: 'images',
                        is_active: 1,
                        'question_title.en': cleanHtml,
                        'question_title.hi': hi.replace(/<img[^>]*data:image\/\w+;base64,[^"]+[^>]*>/gi, '').trim()
                    }
                }
            );
            if (result.modifiedCount > 0) {
                updated++;
                console.log('Updated', doc._id.toString(), '->', image, '| type images | active 1');
            }
        }
        console.log('Done. Updated', updated, 'of', docs.length);
        process.exit(0);
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
})();
