const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
    question_title: {
        // The mobile app sends bilingual values as { en, hi }.
        // Mixed also keeps compatibility with older attempts that stored a string.
        type: mongoose.Schema.Types.Mixed,
        required: true
    },
    image: {
        type: String
    },
    audio:{
        type: String
    },
    question_type: {
        type: String,
        required: true
    },
    subject: {
        type: String,
        default: ''
    },
    chapter: {
        type: String,
        default: ''
    },
    // Updated option fields to be flexible (string or object) and optional
    option: {
        a: {
            type: mongoose.Schema.Types.Mixed,
            default: ''
        },
        b: {
            type: mongoose.Schema.Types.Mixed,
            default: ''
        },
        c: {
            type: mongoose.Schema.Types.Mixed,
            default: ''
        },
        d: {
            type: mongoose.Schema.Types.Mixed,
            default: ''
        }
    },
    answer: {
        type: mongoose.Schema.Types.Mixed,
        required: true
    },
    user_answer: {
        type: String,
        required: true
    },
    description: {
        type: mongoose.Schema.Types.Mixed
    }
});

const quizDetailSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    quizId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Quiz'
    },
    questionDetails: [questionSchema], // Array of question objects
    total_questions: {
        type: Number
    },
    correct_answers: {
        type: Number
    },
    wrong_answers: {
        type: Number
    },
    score: {
        type: Number
    }
}, { timestamps: true });

module.exports = mongoose.model('UserQuiz', quizDetailSchema);
