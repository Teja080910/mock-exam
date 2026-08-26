// Seed a few sample ebooks with generated cover images (SVG).
// Run from api/ folder:  node scripts/seedEbooks.js
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const Ebook = require('../models/ebookModel');

const USER_IMAGES = path.join(__dirname, '..', 'public', 'assets', 'userImages');

const BOOKS = [
    { name: 'RRB Group D Complete Guide', language: 'English', color: '#2563EB' },
    { name: 'RRB NTPC Practice Set', language: 'English', color: '#16A34A' },
    { name: 'SSC GD Constable Study Material', language: 'English', color: '#F43F5E' },
    { name: 'रेलवे सामान्य विज्ञान (हिंदी)', language: 'Hindi', color: '#9333EA' },
    { name: 'गणित शॉर्टकट ट्रिक्स (हिंदी)', language: 'Hindi', color: '#EA580C' },
];

function makeCover(filename, title, color) {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="400" height="520">
  <rect width="400" height="520" rx="16" fill="${color}"/>
  <text x="200" y="240" fill="#ffffff" font-family="Arial" font-size="26" font-weight="bold" text-anchor="middle">${title.replace(/&/g, '&amp;').replace(/</g, '&lt;')}</text>
  <text x="200" y="290" fill="#ffffff" opacity="0.85" font-family="Arial" font-size="16" text-anchor="middle">Mock Station</text>
</svg>`;
    fs.writeFileSync(path.join(USER_IMAGES, filename), svg, 'utf8');
    return filename;
}

async function main() {
    if (!fs.existsSync(USER_IMAGES)) fs.mkdirSync(USER_IMAGES, { recursive: true });
    await mongoose.connect(process.env.DB_CONNECTION);

    let created = 0;
    for (const b of BOOKS) {
        const existing = await Ebook.findOne({ name: b.name });
        if (existing) continue;
        const filename = `ebook-${Date.now()}-${created}.svg`;
        const img = makeCover(filename, b.name, b.color);
        await Ebook.create({
            name: b.name,
            language: b.language,
            link: 'https://example.com/ebooks/sample.pdf',
            image: img,
            is_active: 1,
        });
        created++;
    }

    console.log(`Seeded ${created} ebooks (${BOOKS.length - created} already existed).`);
    await mongoose.disconnect();
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
