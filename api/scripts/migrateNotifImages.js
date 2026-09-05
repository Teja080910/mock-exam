const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const imageDir = path.join(__dirname, '../public/assets/userImages');

function extractDescriptionImage(description) {
    if (!description) return { image: '', cleanDescription: description };
    const imgRegex = /<img[^>]*src="data:image\/(\w+);base64,([^"]+)"[^>]*>/gi;
    let match;
    let image = '';
    let cleanDescription = description;
    while ((match = imgRegex.exec(description)) !== null) {
        if (!image) {
            try {
                const ext = match[1] === 'jpeg' ? 'jpg' : match[1];
                const filename = `${Date.now()}-description-${Math.random().toString(36).slice(2, 8)}.${ext}`;
                fs.writeFileSync(path.join(imageDir, filename), Buffer.from(match[2], 'base64'));
                image = filename;
            } catch (e) {
                console.log('Failed to save image:', e.message);
            }
        }
    }
    if (image) {
        cleanDescription = description.replace(imgRegex, '').trim();
    }
    return { image, cleanDescription };
}

(async () => {
    try {
        await mongoose.connect(process.env.DB_CONNECTION);
        console.log('Connected');
        const coll = mongoose.connection.db.collection('commonnotifications');
        const docs = await coll.find({ description: /data:image\// }).toArray();
        console.log('Found', docs.length, 'notifications with base64 images');
        let updated = 0;
        for (const doc of docs) {
            const { image, cleanDescription } = extractDescriptionImage(doc.description);
            if (!image) continue;
            const result = await coll.updateOne(
                { _id: doc._id },
                { $set: { image, description: cleanDescription } }
            );
            if (result.modifiedCount > 0) {
                updated++;
                console.log('Updated', doc.title, '->', image);
            }
        }
        console.log('Done. Updated', updated, 'of', docs.length);
        process.exit(0);
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
})();
