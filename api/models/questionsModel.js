const mongoose = require('mongoose');

// Bilingual sub-document: { en: "...", hi: "..." }
const BilingualSchema = mongoose.Schema({
    en: { type: String, default: '' },
    hi: { type: String, default: '' }
}, { _id: false });

// Option value: text is bilingual, image is shared across languages
// e.g. { text: { en: "Paris", hi: "पेरिस" }, image: "abc.jpg" }
const OptionValueSchema = mongoose.Schema({
    text: { type: BilingualSchema, default: () => ({}) },
    image: { type: String, default: '' }
}, { _id: false });

const QuizSchema = mongoose.Schema({

    categoryId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category'
    },
    subcategoryId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subcategory',
        required: false
    },
    subject: {
        type: String,
        default: ''
    },
    quizId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Quiz'
    },
    question_type:{
        type: String,
        required: true,
        trim: true
    },
    question_title: {
        type: BilingualSchema,
        default: () => ({}),
    },
    image:{
        type: String
    },
    audio:{
        type: String
    },
    option: {
        a: { type: OptionValueSchema, default: () => ({}) },
        b: { type: OptionValueSchema, default: () => ({}) },
        c: { type: OptionValueSchema, default: () => ({}) },
        d: { type: OptionValueSchema, default: () => ({}) }
    },
    answer:{
        type: BilingualSchema,
        default: () => ({}),
    },
    description:{
        type: BilingualSchema,
        default: () => ({}),
    },
    is_active:{
        type:Number,
        default:1
    }
},
    {
        timestamps: true
    });

module.exports = mongoose.model('Question',QuizSchema);
