// Attach sample images + categories to existing news posts.
// Run from api/ folder:  node scripts/attachNewsImages.js
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env.prod') });
const mongoose = require('mongoose');
const News = require('../models/newsModel');

const UPDATES = [
    { id: '6a978432f283d310eb0ec460', image: '1788587052484-isro_admitcard.jpg', category: 'Government Exams' },
    { id: '6a93f81f49467fd9623ee61b', image: '1788587052927-news_news.jpg', category: 'General' },
    { id: '6a93f623589a7e5a826c0643', image: '1788587053781-ssc_result.jpg', category: 'Government Exams' },
    { id: '6a93f623589a7e5a826c0644', image: '1788587053525-rrb_ntpc.jpg', category: 'Railway' },
    { id: '6a93f623589a7e5a826c0645', image: '1788587054252-upsc_key.jpg', category: 'Government Exams' },
    { id: '6a93f623589a7e5a826c0646', image: '1788587052085-bpsc_schedule.jpg', category: 'Government Exams' },
    { id: '6a93f623589a7e5a826c0647', image: '1788587053305-rrb_alp_result.jpg', category: 'Railway' },
    { id: '6a93f623589a7e5a826c0648', image: '1788587052709-jee_key.jpg', category: 'Engineering' },
];

mongoose.connect(process.env.DB_CONNECTION).then(async () => {
    console.log('Connected. Updating news records...');
    for (const u of UPDATES) {
        const res = await News.findByIdAndUpdate(u.id, { $set: { image: u.image, category: u.category } });
        console.log(u.id, res ? 'updated -> ' + u.category + ' / ' + u.image : 'NOT FOUND');
    }
    const total = await News.countDocuments();
    console.log('Total news docs:', total);
    await mongoose.disconnect();
    process.exit(0);
}).catch((e) => { console.error(e.message); process.exit(1); });
