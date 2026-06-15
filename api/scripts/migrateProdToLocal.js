require('dotenv').config();
const mongoose = require('mongoose');
const axios = require('axios');

const PROD_BASE = 'https://mediumspringgreen-aardvark-783458.hostingersite.com/api';

async function fetchProd(endpoint, data = {}) {
  try {
    const res = await axios.post(`${PROD_BASE}/${endpoint}`, data, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 30000
    });
    return res.data;
  } catch (e) {
    console.log(`  Failed to fetch ${endpoint}: ${e.message}`);
    return null;
  }
}

async function migrate() {
  await mongoose.connect(process.env.DB_CONNECTION);
  const db = mongoose.connection.db;
  console.log('Connected to local MongoDB\n');

  // 1. Categories
  console.log('1. Migrating categories...');
  const catRes = await fetchProd('getallcategories');
  if (catRes?.data?.categoryDetails) {
    await db.collection('categories').deleteMany({});
    for (const c of catRes.data.categoryDetails) {
      await db.collection('categories').insertOne({
        _id: new mongoose.Types.ObjectId(c._id),
        name: c.name,
        image: c.image,
        is_feature: c.is_feature || 0,
        is_active: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    }
    console.log(`  Inserted ${catRes.data.categoryDetails.length} categories`);
  }

  // 2. Category Groups
  console.log('\n2. Migrating category groups...');
  try {
    const grpRes = await axios.get(`${PROD_BASE}/category-groups`, { timeout: 30000 });
    if (grpRes.data?.data) {
      await db.collection('categorygroups').deleteMany({});
      for (const g of grpRes.data.data) {
        await db.collection('categorygroups').insertOne({
          _id: new mongoose.Types.ObjectId(g._id),
          displayName: g.displayName,
          categories: g.categories?.map(c => new mongoose.Types.ObjectId(c._id)) || [],
          createdAt: new Date(),
          updatedAt: new Date()
        });
      }
      console.log(`  Inserted ${grpRes.data.data.length} category groups`);
    }
  } catch (e) {
    console.log(`  Failed: ${e.message}`);
  }

  // 3. Subcategories
  console.log('\n3. Migrating subcategories...');
  await db.collection('subcategories').deleteMany({});
  const allCats = await db.collection('categories').find({}).toArray();
  let subCount = 0;
  for (const cat of allCats) {
    try {
      const subRes = await axios.get(`${PROD_BASE}/subcategories?categoryId=${cat._id.toString()}`, { timeout: 30000 });
      if (subRes.data && Array.isArray(subRes.data)) {
        for (const s of subRes.data) {
          await db.collection('subcategories').insertOne({
            _id: new mongoose.Types.ObjectId(s._id),
            categoryId: new mongoose.Types.ObjectId(s.categoryId),
            name: s.name,
            image: s.image || '',
            is_feature: s.is_feature || 0,
            is_active: s.is_active ?? 1,
            createdAt: new Date(s.createdAt || Date.now()),
            updatedAt: new Date(s.updatedAt || Date.now())
          });
          subCount++;
        }
      }
    } catch (e) {
      // skip
    }
  }
  console.log(`  Inserted ${subCount} subcategories`);

  // 4. Quizzes
  console.log('\n3. Migrating quizzes...');
  const quizRes = await fetchProd('getallquizzes');
  const quizList = quizRes?.data?.quizDetails || quizRes?.data?.quizzesDetails;
  if (quizList) {
    await db.collection('quizzes').deleteMany({});
    for (const q of quizList) {
      await db.collection('quizzes').insertOne({
        _id: new mongoose.Types.ObjectId(q._id),
        name: q.name,
        categoryId: new mongoose.Types.ObjectId(q.categoryId),
        image: q.image || '',
        timer_status: q.timer_status || 0,
        minutes_per_quiz: q.minutes_per_quiz || 0,
        total_questions: q.total_questions || 0,
        correct_ans_reward_per_question: q.correct_ans_reward_per_question || 0,
        penalty_per_question: q.penalty_per_question || 0,
        description: q.description || '',
        is_played: q.is_played || 0,
        is_active: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    }
    console.log(`  Inserted ${quizList.length} quizzes`);
  }

  // 5. Questions
  console.log('\n4. Migrating questions...');
  const allQuizzes = await db.collection('quizzes').find({}).toArray();
  let totalQuestions = 0;
  for (const quiz of allQuizzes) {
    const qRes = await fetchProd('getquestionsbyquizid', { quizId: quiz._id.toString() });
    if (qRes?.data?.questionsDetails) {
      for (const q of qRes.data.questionsDetails) {
        // Normalize question_type
        const qType = ['text_only', 'true_false', 'images', 'audio'].includes(q.question_type)
          ? q.question_type : 'text_only';

        // Normalize options
        const option = {};
        for (const key of ['a', 'b', 'c', 'd']) {
          const opt = q.option?.[key];
          if (typeof opt === 'string') {
            option[key] = opt;
          } else if (opt?.text) {
            option[key] = opt.text;
          } else {
            option[key] = '';
          }
        }

        await db.collection('questions').insertOne({
          _id: new mongoose.Types.ObjectId(q._id),
          categoryId: new mongoose.Types.ObjectId(q.categoryId),
          quizId: new mongoose.Types.ObjectId(q.quizId?._id || q.quizId),
          question_type: qType,
          question_title: q.question_title || '',
          image: q.image || '',
          audio: q.audio || '',
          option,
          answer: q.answer || '',
          description: q.description || '',
          is_active: 1,
          createdAt: new Date(),
          updatedAt: new Date()
        });
        totalQuestions++;
      }
    }
  }
  console.log(`  Inserted ${totalQuestions} questions`);

  // 6. Plans
  console.log('\n5. Migrating plans...');
  try {
    const planRes = await axios.get(`${PROD_BASE}/get_plan`, { timeout: 30000 });
    const planList = planRes?.data?.data?.planDetails;
    if (planList) {
      await db.collection('plans').deleteMany({});
      for (const p of planList) {
      await db.collection('plans').insertOne({
        _id: new mongoose.Types.ObjectId(p._id),
        planName: p.planName,
        planValidity: p.planValidity,
        price: p.price,
        planId: p.planId,
        categoryGroup: p.categoryGroup?._id ? new mongoose.Types.ObjectId(p.categoryGroup._id) : null,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    }
    console.log(`  Inserted ${planList.length} plans`);
    }
  } catch (e) {
    console.log(`  Failed: ${e.message}`);
  }

  // 7. Carousel Banners
  console.log('\n6. Migrating carousel banners...');
  const carRes = await fetchProd('getcarouselbanners');
  if (carRes?.data?.banners) {
    await db.collection('carouselbanners').deleteMany({});
    for (const b of carRes.data.banners) {
      await db.collection('carouselbanners').insertOne({
        _id: new mongoose.Types.ObjectId(b._id),
        title: b.title || '',
        description: b.description || '',
        image: b.image,
        order: b.order || 0,
        is_active: 1,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    }
    console.log(`  Inserted ${carRes.data.banners.length} carousel banners`);
  }

  // 8. Settings
  console.log('\n7. Migrating settings...');
  const adsRes = await fetchProd('getadssettings');
  if (adsRes?.data?.adsDetails) {
    await db.collection('adssettings').deleteMany({});
    for (const a of adsRes.data.adsDetails) {
      await db.collection('adssettings').insertOne(a);
    }
    console.log(`  Inserted ${adsRes.data.adsDetails.length} ads settings`);
  }

  const ptsRes = await fetchProd('getpointssetting');
  if (ptsRes?.data?.settingDetails) {
    await db.collection('pointssettings').deleteMany({});
    for (const p of ptsRes.data.settingDetails) {
      await db.collection('pointssettings').insertOne(p);
    }
    console.log(`  Inserted ${ptsRes.data.settingDetails.length} points settings`);
  }

  // 9. Payment Methods
  console.log('\n8. Migrating payment methods...');
  try {
    const payRes = await axios.get(`${PROD_BASE}/payment-methods`, { timeout: 30000 });
    if (payRes.data?.data) {
      await db.collection('paymentmethods').deleteMany({});
      for (const p of payRes.data.data) {
        await db.collection('paymentmethods').insertOne(p);
      }
      console.log(`  Inserted ${payRes.data.data.length} payment methods`);
    }
  } catch (e) {
    console.log(`  No payment methods endpoint or failed: ${e.message}`);
  }

  console.log('\n✅ Migration complete!');
  await mongoose.disconnect();
}

migrate().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
