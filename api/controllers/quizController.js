const fs = require("fs");
const path = require('path')
const userimages = path.join('./public/assets/userImages/');
const { verifyAdminAccess } = require('../config/verification');
const Quiz = require("../models/quizModel");
const Questions = require("../models/questionsModel");
const Admin = require("../models/adminModel");
const Category = require("../models/categoryModel");
const Subcategory = require("../models/subcategoryModel");

// Load Quiz
const loadQuiz= async (req, res) => {
    try {
        const category = await Category.find();
        res.render('addQuiz',{category : category});
    } catch (error) {
        console.log(error.message);
    }
}

// Add Quiz
const addQuiz = async(req,res)=>{
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const imageFile = req.files && req.files['image'] ? req.files['image'][0].filename : (req.file ? req.file.filename : '');
            const pdfEnFile = req.files && req.files['pdf_en'] ? req.files['pdf_en'][0].filename : '';
            const pdfHiFile = req.files && req.files['pdf_hi'] ? req.files['pdf_hi'][0].filename : '';

            const QuizData = new Quiz({
                categoryId: req.body.categoryId,
                subcategoryId: req.body.subcategoryId,
                name: req.body.name,
                image: imageFile,
                points_require_to_play: parseInt(req.body.points_require_to_play) || 0,
                timer_status: req.body.timer_status == "on" ? 1 : 0,
                minutes_per_quiz: parseInt(req.body.minutes_per_quiz) || 0,
                minimum_required_points: parseInt(req.body.minimum_required_points) || 0,
                description: {
                    en: req.body.description || '',
                    hi: req.body.description_hi || ''
                },
                pdf: {
                    en: pdfEnFile,
                    hi: pdfHiFile
                },
                pdf_en: pdfEnFile,
                pdf_hi: pdfHiFile,
                is_active: req.body.is_active == "on" ? 1 : 0,
                correct_ans_reward_per_question: parseFloat(req.body.correct_ans_reward_per_question) || 0,
                penalty_per_question: parseFloat(req.body.penalty_per_question) || 0
            });
            const saveQuiz = await QuizData.save();
            res.redirect('/view-quiz')
        }
        else {
            req.flash('error', 'You have no access to add Quiz , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
        req.flash('error', error.message);
        return res.redirect('back');
    }
}

// View Quiz
const viewQuiz = async(req,res)=> {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({_id:req.session.user_id});
            const page = Math.max(1, parseInt(req.query.page, 10) || 1);
            const limit = 20;
            const skip = (page - 1) * limit;

            const filter = {};
            if (req.query.categoryId && req.query.categoryId.trim() !== '') {
                filter.categoryId = req.query.categoryId.trim();
            }
            if (req.query.subcategoryId && req.query.subcategoryId.trim() !== '') {
                filter.subcategoryId = req.query.subcategoryId.trim();
            }
            if (req.query.is_active !== undefined && req.query.is_active !== '') {
                filter.is_active = parseInt(req.query.is_active, 10);
            }
            if (req.query.search && String(req.query.search).trim() !== '') {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.name = { $regex: term, $options: 'i' };
            }

            const categories = await Category.find().sort({ name: 1 });
            const subcategories = await Subcategory.find().sort({ name: 1 });

            const totalItems = await Quiz.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalItems / limit));

            const QuizData = await Quiz.find(filter)
                .populate(['categoryId', 'subcategoryId'])
                .sort({ updatedAt: -1 })
                .skip(skip)
                .limit(limit);

            const quizIds = QuizData.map(q => q._id);
            const questionCounts = await Questions.aggregate([
                { $match: { quizId: { $in: quizIds } } },
                { $group: { _id: "$quizId", count: { $sum: 1 } } }
            ]);
            const questionCountMap = {};
            questionCounts.forEach(qc => {
                if (qc._id) questionCountMap[qc._id.toString()] = qc.count;
            });

            // Backward-compatible question list
            const QuestionData = await Questions.find({ quizId: { $in: quizIds } }).populate('quizId');

            // Build extraParams for pagination links
            const params = [];
            if (req.query.categoryId) params.push(`categoryId=${encodeURIComponent(req.query.categoryId)}`);
            if (req.query.subcategoryId) params.push(`subcategoryId=${encodeURIComponent(req.query.subcategoryId)}`);
            if (req.query.is_active !== undefined && req.query.is_active !== '') params.push(`is_active=${encodeURIComponent(req.query.is_active)}`);
            if (req.query.search) params.push(`search=${encodeURIComponent(req.query.search)}`);
            const extraParams = params.length > 0 ? '&' + params.join('&') : '';

            res.render('viewQuiz', {
                quiz: QuizData,
                loginData: loginData,
                question: QuestionData,
                questionCountMap: questionCountMap,
                category: categories,
                subcategory: subcategories,
                currentPage: page,
                totalPages: totalPages,
                totalItems: totalItems,
                limit: limit,
                extraParams: extraParams,
                filters: {
                    categoryId: req.query.categoryId || '',
                    subcategoryId: req.query.subcategoryId || '',
                    is_active: req.query.is_active !== undefined ? req.query.is_active : '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit Quiz
const editQuiz = async(req,res)=>{
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-quiz';
        const category = await Category.find();
        const editData = await Quiz.findById({ _id: id }).populate('categoryId');
        if (editData) {
            res.render('editQuiz', { editquiz: editData, category: category, returnUrl: returnUrl });
        }
        else {
            res.render('editQuiz', { message: 'Quiz Not Added', returnUrl: returnUrl });
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Update Quiz
const UpdateQuiz = async(req,res)=>{
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            const returnUrl = req.body.returnUrl || req.query.returnUrl || '/view-quiz';
            const currentQuiz = await Quiz.findById(id);
            const description = {
                en: req.body.description || '',
                hi: req.body.description_hi || ''
            };

            const updateFields = {
                categoryId: req.body.categoryId,
                subcategoryId: req.body.subcategoryId,
                name: req.body.name,
                points_require_to_play: parseInt(req.body.points_require_to_play) || 0,
                timer_status: req.body.timer_status == "on" ? 1 : 0,
                minutes_per_quiz: parseInt(req.body.minutes_per_quiz) || 0,
                minimum_required_points: parseInt(req.body.minimum_required_points) || 0,
                description: description,
                is_active: req.body.is_active == "on" ? 1 : 0,
                correct_ans_reward_per_question: parseFloat(req.body.correct_ans_reward_per_question) || 0,
                penalty_per_question: parseFloat(req.body.penalty_per_question) || 0
            };

            // Image handling
            if (req.files && req.files['image'] && req.files['image'][0]) {
                if (currentQuiz && currentQuiz.image && fs.existsSync(userimages + currentQuiz.image)) {
                    try { fs.unlinkSync(userimages + currentQuiz.image); } catch (e) { console.log(e); }
                }
                updateFields.image = req.files['image'][0].filename;
            } else if (req.file) {
                if (currentQuiz && currentQuiz.image && fs.existsSync(userimages + currentQuiz.image)) {
                    try { fs.unlinkSync(userimages + currentQuiz.image); } catch (e) { console.log(e); }
                }
                updateFields.image = req.file.filename;
            }

            // PDF English handling
            let pdfEn = currentQuiz && (currentQuiz.pdf_en || (currentQuiz.pdf && currentQuiz.pdf.en)) ? (currentQuiz.pdf_en || currentQuiz.pdf.en) : '';
            if (req.files && req.files['pdf_en'] && req.files['pdf_en'][0]) {
                if (pdfEn && fs.existsSync(userimages + pdfEn)) {
                    try { fs.unlinkSync(userimages + pdfEn); } catch (e) { console.log(e); }
                }
                pdfEn = req.files['pdf_en'][0].filename;
            } else if (req.body.remove_pdf_en === '1') {
                if (pdfEn && fs.existsSync(userimages + pdfEn)) {
                    try { fs.unlinkSync(userimages + pdfEn); } catch (e) { console.log(e); }
                }
                pdfEn = '';
            }

            // PDF Hindi handling
            let pdfHi = currentQuiz && (currentQuiz.pdf_hi || (currentQuiz.pdf && currentQuiz.pdf.hi)) ? (currentQuiz.pdf_hi || currentQuiz.pdf.hi) : '';
            if (req.files && req.files['pdf_hi'] && req.files['pdf_hi'][0]) {
                if (pdfHi && fs.existsSync(userimages + pdfHi)) {
                    try { fs.unlinkSync(userimages + pdfHi); } catch (e) { console.log(e); }
                }
                pdfHi = req.files['pdf_hi'][0].filename;
            } else if (req.body.remove_pdf_hi === '1') {
                if (pdfHi && fs.existsSync(userimages + pdfHi)) {
                    try { fs.unlinkSync(userimages + pdfHi); } catch (e) { console.log(e); }
                }
                pdfHi = '';
            }

            updateFields.pdf = {
                en: pdfEn,
                hi: pdfHi
            };
            updateFields.pdf_en = pdfEn;
            updateFields.pdf_hi = pdfHi;

            await Quiz.findByIdAndUpdate({ _id: id }, { $set: updateFields });
            res.redirect(returnUrl);
        } else {
            req.flash('error', 'You have no access to edit quiz , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
        req.flash('error', error.message);
        return res.redirect('back');
    }
}

// Delete Quiz
const deleteQuiz = async(req,res)=>{
    try {
        const id = req.query.id;
        const returnUrl = req.query.returnUrl || req.get('Referrer') || '/view-quiz';
        const currentQuiz = await Quiz.findById(id);
        if (currentQuiz) {
            if (currentQuiz.image && fs.existsSync(userimages + currentQuiz.image)) {
                try { fs.unlinkSync(userimages + currentQuiz.image); } catch (e) { console.log(e); }
            }
            const pdfEn = currentQuiz.pdf_en || (currentQuiz.pdf && currentQuiz.pdf.en);
            if (pdfEn && fs.existsSync(userimages + pdfEn)) {
                try { fs.unlinkSync(userimages + pdfEn); } catch (e) { console.log(e); }
            }
            const pdfHi = currentQuiz.pdf_hi || (currentQuiz.pdf && currentQuiz.pdf.hi);
            if (pdfHi && fs.existsSync(userimages + pdfHi)) {
                try { fs.unlinkSync(userimages + pdfHi); } catch (e) { console.log(e); }
            }
        }
        await Quiz.deleteOne({ _id: id });
        res.redirect(returnUrl);
    } catch (error) {
        console.log(error.message);
        res.redirect(returnUrl);
    }
}

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const returnUrl = req.body.returnUrl || req.get('Referrer') || '/view-quiz';
        const status = await Quiz.findById({_id:id});
        const is_active = req.body.is_active ? req.body.is_active : "false";
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect(returnUrl);
    } catch (err) {
        console.error(err);
        res.sendStatus(500);
    }
}

module.exports = { loadQuiz, addQuiz, viewQuiz, editQuiz, UpdateQuiz, deleteQuiz, activeStatus }