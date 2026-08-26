// const userimages = path.join('./public/assets/userImages/');
const path = require('path');
const fs = require('fs');
const fsPromises = require('fs').promises;
const csv = require('csv-parser');
const XLSX = require('xlsx');
const os = require('os');
const crypto = require('crypto');
const { verifyAdminAccess } = require('../config/verification');
const Questions = require("../models/questionsModel");
const Admin = require("../models/adminModel");
const Category = require("../models/categoryModel");
const Quiz = require("../models/quizModel");
const Subcategory = require("../models/subcategoryModel");

// Load questions
const loadQuestions = async (req, res) => {
    try {
        const categories = await Category.find({});
        const quizzes = await Quiz.find({});
        let subcategories = [];
        if (req.query.categoryId) {
            subcategories = await Subcategory.find({ categoryId: req.query.categoryId, is_active: 1 });
        }
        res.render('addQuestions', { category: categories, quiz: quizzes, subcategories });
    } catch (error) {
        console.log(error.message);
    }
}

// Build a bilingual {en, hi} object from separate form fields
function bilingual(enVal, hiVal) {
    return { en: ensureString(enVal), hi: ensureString(hiVal) };
}

// Add questions
const addQuestions = async (req, res) => {
    try {
        let loginData = await Admin.find({});
        if (Array.isArray(loginData)) { // Check if loginData is an array
            for (let i in loginData) {
                if (String(loginData[i]._id) === req.session.user_id) {
                    if (loginData[i].is_admin == 1) {
                        let optionData = {};
                        let optionType;
                        if (req.body.question_type == "text_only") {
                            optionType = "text_only";
                            optionData = {
                                a: { text: bilingual(req.body.a, req.body.a_hi), image: '' },
                                b: { text: bilingual(req.body.b, req.body.b_hi), image: '' },
                                c: { text: bilingual(req.body.c, req.body.c_hi), image: '' },
                                d: { text: bilingual(req.body.d, req.body.d_hi), image: '' },
                            };
                        } else if (req.body.question_type == "true_false") {
                            optionType = "true_false";
                            optionData = {
                                answer: bilingual(req.body.answer, req.body.answer_hi),
                            };
                        } else if (req.body.question_type == "images") {
                            optionType = "images";
                            optionData = {
                                a: {
                                    text: bilingual(req.body.a, req.body.a_hi),
                                    image: req.files.a_image && req.files.a_image[0] ? req.files.a_image[0].filename : ''
                                },
                                b: {
                                    text: bilingual(req.body.b, req.body.b_hi),
                                    image: req.files.b_image && req.files.b_image[0] ? req.files.b_image[0].filename : ''
                                },
                                c: {
                                    text: bilingual(req.body.c, req.body.c_hi),
                                    image: req.files.c_image && req.files.c_image[0] ? req.files.c_image[0].filename : ''
                                },
                                d: {
                                    text: bilingual(req.body.d, req.body.d_hi),
                                    image: req.files.d_image && req.files.d_image[0] ? req.files.d_image[0].filename : ''
                                }
                            };
                        } else if (req.body.question_type == "audio") {
                            optionType = "audio";
                            optionData = {
                                a: { text: bilingual(req.body.audio_a, ''), image: '' },
                                b: { text: bilingual(req.body.audio_b, ''), image: '' },
                                c: { text: bilingual(req.body.audio_c, ''), image: '' },
                                d: { text: bilingual(req.body.audio_d, ''), image: '' },
                            };
                        }

                        const QuestionsData = new Questions({
                            categoryId: req.body.categoryId,
                            subcategoryId: req.body.subcategoryId,
                            quizId: req.body.quizId,
                            question_title: bilingual(req.body.question_title, req.body.question_title_hi),
                            image: optionType === "images" && req.files.image && req.files.image[0] ? req.files.image[0].filename : undefined,
                            audio: optionType === "audio" ? req.files.audio[0].filename : undefined,
                            question_type: optionType,
                            option: optionData,
                            answer: bilingual(req.body.answer, req.body.answer_hi),
                            description: {
                                en: req.body.description || '',
                                hi: req.body.description_hi || ''
                            },
                            is_active: req.body.is_active == "on" ? 1 : 0
                        });
                        
                        const saveQuestions = await QuestionsData.save();
                        const categories = await Category.find({});
                        const quizzes = await Quiz.find({});
                        if (saveQuestions) {
                            return res.render('addQuestions', { category: categories, quiz: quizzes, message: "Questions Added Successfully..!!" });
                        } else {
                            return res.render('addQuestions', { message: "Questions Not Added..!!*" });
                        }
                    } else {
                        req.flash('error', 'You have no access to add Questions, You are not super admin !! *');
                        return res.redirect('back');
                    }
                }
            }
        } else {
            req.flash('error', 'Login data is not an array');
            return res.redirect('back');
        }

    } catch (error) {
        console.log(error.message);
        req.flash('error', 'An error occurred while adding questions');
        return res.redirect('back');
    }
}

// Add this new function for importing CSV/Excel
const importQuestionsCSV = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        const ext = path.extname(req.file.originalname).toLowerCase();
        let results = [];

        if (ext === '.csv') {
            // Parse CSV
            await new Promise((resolve, reject) => {
                const rows = [];
                fs.createReadStream(req.file.path)
                    .pipe(csv())
                    .on('data', (data) => rows.push(data))
                    .on('end', () => { results = rows; resolve(); })
                    .on('error', reject);
            });
        } else if (ext === '.xlsx' || ext === '.xls') {
            // Parse Excel
            const workbook = XLSX.readFile(req.file.path);
            const sheetName = workbook.SheetNames[0];
            const sheet = workbook.Sheets[sheetName];
            results = XLSX.utils.sheet_to_json(sheet);
        } else {
            req.flash('error', 'Unsupported file format. Please upload a CSV or Excel file.');
            return res.redirect('/view-questions');
        }

        // Process and save the data to MongoDB
        let importedCount = 0;
        let skippedCount = 0;
        for (const row of results) {
            // Skip rows with missing required fields instead of aborting the whole import
            if (!row.question_title || !row.answer) {
                skippedCount++;
                continue;
            }

            let option = {};
            if (row.question_type === "text_only" || row.question_type === "images" || row.question_type === "audio") {
                const optVal = (en, hi, img) => ({ text: bilingual(en, hi), image: img || '' });
                // accept both header styles: "option.a" (sample template) and "option_a"
                const enOpt = (letter) => row[`option.${letter}`] || row[`option_${letter}`] || row[`image_${letter}`] || row[`audio_${letter}`];
                const hiOpt = (letter) => row[`option_${letter}_hi`] || '';
                option = {
                    a: optVal(enOpt('a'), hiOpt('a')),
                    b: optVal(enOpt('b'), hiOpt('b')),
                    c: optVal(enOpt('c'), hiOpt('c')),
                    d: optVal(enOpt('d'), hiOpt('d')),
                };
            } else if (row.question_type === "true_false") {
                option = {
                    answer: bilingual(row.answer, row.answer_hi),
                };
            }

            // Handle image reference from CSV/Excel
            let imagePath = null;
            if (row.image) {
                imagePath = row.image;
            }

            // Handle audio reference from CSV/Excel
            let audioPath = null;
            if (row.audio) {
                audioPath = row.audio;
            }

            // Question's subcategory = the one selected in the admin modal (the quiz's subcategory).
            // Excel 'subcategory' column = SUBJECT name, stored as a plain string on the question
            // (no subcategory docs auto-created), so the selected category's subcategory list
            // stays clean while the app still shows subject-wise tabs/summary.
            const question = new Questions({
                categoryId: req.body.categoryId,
                subcategoryId: req.body.subcategoryId || null,
                subject: row.subcategory ? row.subcategory.toString().trim() : '',
                quizId: req.body.quizId,
                question_title: bilingual(row.question_title, row.question_title_hi),
                question_type: row.question_type,
                option: option,
                answer: bilingual(row.answer, row.answer_hi),
                description: {
                    en: row.description || '',
                    hi: row.description_hi || ''
                },
                is_active: 1,
                image: imagePath || null,
                audio: audioPath || null
            });
            await question.save();
            importedCount++;
        }

        // Update the Quiz's subcategoryId so the quiz appears under the subcategory
        // selected in the import modal (matches the subcategory detail page query).
        if (req.body.subcategoryId) {
            await Quiz.findByIdAndUpdate(req.body.quizId, { subcategoryId: req.body.subcategoryId });
        }

        // Delete uploaded file after processing
        fs.unlink(req.file.path, (err) => {
            if (err) console.error(`Error deleting file: ${err}`);
        });

        req.flash('message', `${importedCount} questions imported successfully${skippedCount > 0 ? `, ${skippedCount} rows skipped (missing required fields)` : ''} from ${ext === '.csv' ? 'CSV' : 'Excel'} file`);
        res.redirect('/view-questions');
    } catch (error) {
        console.log("IMPORT ERROR:", error.message, error.stack);
        req.flash('error', `An error occurred while importing questions: ${error.message}`);
        res.redirect('/view-questions');
    }
}

// Sample CSV Format
const sampleCSVFormat = async (req, res) => {
    try {
        // Define headers for the CSV
        const headers = [
            "question_type",
            "question_title",
            "question_title_hi",
            "option.a",
            "option.b",
            "option.c",
            "option.d",
            "option_a_hi",
            "option_b_hi",
            "option_c_hi",
            "option_d_hi",
            "answer",
            "answer_hi",
            "description",
            "description_hi",
            "image"
        ].join(',');

        // Create sample data rows
        const sampleRows = [
            // Text Only Question
            [
                "text_only",
                "What is the capital of France?",
                "फ्रांस की राजधानी क्या है?",
                "Paris",
                "London",
                "Berlin",
                "Madrid",
                "पेरिस",
                "लंदन",
                "बर्लिन",
                "मैड्रिड",
                "Paris",
                "Basic geography question",
                "भूगोल से जुड़ा बुनियादी प्रश्न",
                ""
            ].join(','),

            // True/False Question
            [
                "true_false",
                "The Earth is flat?",
                "क्या पृथ्वी चपटी है?",
                "TRUE",
                "FALSE",
                "",
                "",
                "सही",
                "गलत",
                "",
                "",
                "FALSE",
                "Basic science question",
                "विज्ञान से जुड़ा बुनियादी प्रश्न",
                ""
            ].join(','),
        ];

        // Combine headers and rows
        const csvContent = [headers, ...sampleRows].join('\n');

        // Set response headers for CSV download
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename=questions_format.csv');

        // Send CSV content
        res.send(csvContent);

    } catch (error) {
        console.log(error.message);
        res.status(500).send('Server Error');
    }
};

// Helper to ensure value is a string
function ensureString(val) {
    if (Array.isArray(val)) return val[0] || '';
    return val || '';
}

// const importQuestionsCSV = async (req, res) => {
//     try {
//         console.log('Starting CSV import process');

//         if (!req.file) {
//             console.log('No file uploaded');
//             return res.status(400).send('No file uploaded.');
//         }

//         const IMAGE_BASE_PATH = path.join(__dirname, '..', 'public', 'userImages');
//         const DOWNLOADS_FOLDER = path.join(os.homedir(), 'Downloads');

//         console.log(`Image base path: ${IMAGE_BASE_PATH}`);
//         console.log(`Downloads folder: ${DOWNLOADS_FOLDER}`);

//         // Ensure userImages directory exists
//         await fsPromises.mkdir(IMAGE_BASE_PATH, { recursive: true });

//         const results = [];
//         await new Promise((resolve, reject) => {
//             fs.createReadStream(req.file.path)
//                 .pipe(csv())
//                 .on('data', (data) => results.push(data))
//                 .on('end', () => {
//                     console.log(`Parsed ${results.length} rows from CSV`);
//                     resolve();
//                 })
//                 .on('error', (error) => {
//                     console.error('Error parsing CSV:', error);
//                     reject(error);
//                 });
//         });

//         console.log('Starting to process individual rows');

//         for (const row of results) {
//             console.log(`Processing row: ${JSON.stringify(row)}`);

//             let option = {};
//             if (["text_only", "images", "audio"].includes(row.question_type)) {
//                 option = {
//                     a: row.option_a || row.image_a || row.audio_a,
//                     b: row.option_b || row.image_b || row.audio_b,
//                     c: row.option_c || row.image_c || row.audio_c,
//                     d: row.option_d || row.image_d || row.audio_d,
//                 };
//             } else if (row.question_type === "true_false") {
//                 option = {
//                     answer: row.answer,
//                 };
//             }
//             let imagePath = null;
//             if (row.image) {
//                 const sourceImagePath = path.join(DOWNLOADS_FOLDER, row.image);
//                 const destImagePath = path.join(__dirname, '..', 'public', 'assets', 'userImages', row.image); // Store image in public/assets/userImages folder
                
//                 try {
//                     console.log(`Attempting to copy image from ${sourceImagePath} to ${destImagePath}`);
//                     await fsPromises.access(sourceImagePath);
//                     await fsPromises.copyFile(sourceImagePath, destImagePath);
//                     imagePath = `${row.image}`; // Path remains the same as it reflects the correct folder structure
//                     console.log(`Successfully copied image to ${imagePath}`);
//                 } catch (err) {
//                     console.error(`Failed to copy image ${row.image}:`, err);
//                 }
//             }

//             if (row.audio) {
//                 const sourceAudioPath = path.join(DOWNLOADS_FOLDER, row.audio);
//                 const destAudioPath = path.join(__dirname, '..', 'public', 'assets', 'userImages', row.audio); // Store audio in public/assets/userAudios folder
                
//                 try {
//                     console.log(`Attempting to copy audio from ${sourceAudioPath} to ${destAudioPath}`);
//                     await fsPromises.access(sourceAudioPath);
//                     await fsPromises.copyFile(sourceAudioPath, destAudioPath);
//                     console.log(`Successfully copied audio to ${row.audio}`);
//                 } catch (err) {
//                     console.error(`Failed to copy audio ${row.audio}:`, err);
//                 }
//             }

//             try {
//                 const question = new Questions({
//                     categoryId: req.body.categoryId,
//                     quizId: req.body.quizId,
//                     question_title: row.question_title,
//                     question_type: row.question_type,
//                     option: option,
//                     answer: row.answer,
//                     description: row.description,
//                     is_active: row.is_active === 'TRUE' ? 1 : 0,
//                     image: imagePath,
//                     audio: row.audio || null
//                 });
//                 await question.save();
//                 console.log(`Saved question: ${question._id}`);
//             } catch (err) {
//                 console.error('Error saving question:', err);
//             }
//         }

//         console.log('CSV import process completed');
//         req.flash('message', 'Questions imported successfully');
//         res.redirect('/view-questions');
//     } catch (error) {
//         console.error('Error in importQuestionsCSV:', error);
//         req.flash('error', `An error occurred while importing questions: ${error.message}`);
//         res.redirect('/view-questions');
//     } finally {
//         if (req.file && req.file.path) {
//             try {
//                 await fsPromises.unlink(req.file.path);
//                 console.log(`Deleted temporary file: ${req.file.path}`);
//             } catch (unlinkError) {
//                 console.error('Error deleting temporary file:', unlinkError);
//             }
//         }
//     }
// };


// View questions (server-side paginated)
const viewQuestions = async (req, res) => {
    try {
        await verifyAdminAccess(req, res, async () => {
            let loginData = await Admin.findById({_id: req.session.user_id});
            const QuizData = await Quiz.find();
            const CategoryData = await Category.find();
            const SubcategoryData = await Subcategory.find();

            const page = Math.max(1, parseInt(req.query.page, 10) || 1);
            const limit = 20;

            const filter = {};
            if (req.query.quizId) filter.quizId = req.query.quizId;
            if (req.query.categoryId) filter.categoryId = req.query.categoryId;
            if (req.query.subcategoryId) filter.subcategoryId = req.query.subcategoryId;
            if (req.query.question_type) filter.question_type = req.query.question_type;
            if (req.query.subject) filter.subject = req.query.subject;
            if (req.query.search && String(req.query.search).trim()) {
                const term = String(req.query.search).trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                filter.$or = [
                    { 'question_title.en': { $regex: term, $options: 'i' } },
                    { 'question_title.hi': { $regex: term, $options: 'i' } },
                ];
            }

            const totalQuestions = await Questions.countDocuments(filter);
            const totalPages = Math.max(1, Math.ceil(totalQuestions / limit));

            // Subject-wise quizzes: only when a quiz is selected AND it actually
            // uses distinct subjects. Otherwise no subject filter is shown.
            let subjects = [];
            if (req.query.quizId) {
                const distinct = await Questions.distinct('subject', { quizId: req.query.quizId });
                subjects = distinct.filter(s => s && String(s).trim()).map(String);
            }

            const QuestionsData = await Questions.find(filter)
                .populate({ path: 'quizId', select: 'name _id' })
                .populate('categoryId')
                .populate('subcategoryId')
                .sort({updatedAt: -1})
                .skip((page - 1) * limit)
                .limit(limit)
                .lean();

            res.render('viewQuestions',{
                questions: QuestionsData,
                loginData,
                quiz: QuizData,
                category: CategoryData,
                subcategory: SubcategoryData,
                subjects,
                page,
                limit,
                totalQuestions,
                totalPages,
                filters: {
                    quizId: req.query.quizId || '',
                    categoryId: req.query.categoryId || '',
                    subcategoryId: req.query.subcategoryId || '',
                    question_type: req.query.question_type || '',
                    subject: req.query.subject || '',
                    search: req.query.search || ''
                }
            });
        });
    } catch (error) {
        console.log(error.message);
    }
}

// Edit questions
const editQuestions = async (req, res) => {
    try {

        const id = req.query.id;
        const category = await Category.find();
        const quizzes = await Quiz.find({});
        const editData = await Questions.findById({ _id: id }).populate('categoryId');

        if (editData) {
            res.render('editQuestions', { editdata: editData,category:category,quiz:quizzes});
        }
        else {
            res.render('editQuestions', { message: 'Questions Not Added' });
        }

    } catch (error) {
        console.log(error.message);
    }
}

// Update questions
const UpdateQuestions = async(req,res)=> {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const id = req.body.id;
            let optionData = {};
            let optionType;
            if (req.body.question_type == "text_only") {
                optionType = "text_only";
                optionData = {
                    a: { text: bilingual(req.body.a, req.body.a_hi), image: '' },
                    b: { text: bilingual(req.body.b, req.body.b_hi), image: '' },
                    c: { text: bilingual(req.body.c, req.body.c_hi), image: '' },
                    d: { text: bilingual(req.body.d, req.body.d_hi), image: '' },
                };

            } else if (req.body.question_type == "true_false") {
                optionType = "true_false";
                optionData = {
                    answer: bilingual(req.body.answer, req.body.answer_hi),
                };
            } else if (req.body.question_type == "images") {
                optionType ="images";
                optionData = {
                    a: {
                        text: bilingual(req.body.a, req.body.a_hi),
                        image: req.files.a_image && req.files.a_image[0] ? req.files.a_image[0].filename : ensureString(req.body.img_a)
                    },
                    b: {
                        text: bilingual(req.body.b, req.body.b_hi),
                        image: req.files.b_image && req.files.b_image[0] ? req.files.b_image[0].filename : ensureString(req.body.img_b)
                    },
                    c: {
                        text: bilingual(req.body.c, req.body.c_hi),
                        image: req.files.c_image && req.files.c_image[0] ? req.files.c_image[0].filename : ensureString(req.body.img_c)
                    },
                    d: {
                        text: bilingual(req.body.d, req.body.d_hi),
                        image: req.files.d_image && req.files.d_image[0] ? req.files.d_image[0].filename : ensureString(req.body.img_d)
                    },
                };
            }
            else if (req.body.question_type == "audio") {
                optionType = "audio";
                optionData = {
                    a: { text: bilingual(req.body.audio_a, ''), image: '' },
                    b: { text: bilingual(req.body.audio_b, ''), image: '' },
                    c: { text: bilingual(req.body.audio_c, ''), image: '' },
                    d: { text: bilingual(req.body.audio_d, ''), image: '' },
                };
            }
            const updateFields = {
                categoryId: req.body.categoryId,
                quizId: req.body.quizId,
                question_title: bilingual(req.body.question_title, req.body.question_title_hi),
                question_type : optionType,
                option: optionData,
                answer: bilingual(req.body.answer, req.body.answer_hi),
                description: {
                    en: req.body.description || '',
                    hi: req.body.description_hi || ''
                }
            };
            if (req.files.image || req.files.audio) {
                const UpdateQuestions = await Questions.findByIdAndUpdate({ _id: id },
                    {
                        $set:
                        {
                            ...updateFields,
                            image: optionType === "images" ? req.files.image[0].filename : undefined,
                            audio: optionType === "audio" ? req.files.audio[0].filename : undefined
                        }
                    });
                const saveQuestions = await UpdateQuestions.save();
                res.redirect('/view-questions');
            }
            else{
                const UpdateQuestions = await Questions.findByIdAndUpdate({ _id: id },
                    {
                        $set:
                        {
                            ...updateFields
                        }
                    });
                const saveQuestions = await UpdateQuestions.save();
                res.redirect('/view-questions');
            }
        }
        else {
            req.flash('error', 'You have no access to edit quiz , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Delete questions
const deleteQuestions = async(req,res)=> {
    try {
        const id = req.query.id;
        const deleteQuestions = await Questions.deleteOne({_id:id});
        if (req.query.ajax === '1') {
            return res.json({ success: deleteQuestions.deletedCount > 0 });
        }
        res.redirect('back');
        
    } catch (error) {
        console.log(error.message); 
    }
}

// Active status
const activeStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const status = await Questions.findById(id);
        const is_active = req.body.is_active ? req.body.is_active : "false";
        if (!status) {
            return res.sendStatus(404);
        }
        status.is_active = !status.is_active;
        await status.save();
        res.redirect('/view-questions');

    } catch (err) {

        console.error(err);
        res.sendStatus(500);

    }
}

module.exports = {
    loadQuestions,
    addQuestions,
    viewQuestions,
    importQuestionsCSV,
    editQuestions,
    UpdateQuestions,
    deleteQuestions,
    activeStatus,
    sampleCSVFormat
}
