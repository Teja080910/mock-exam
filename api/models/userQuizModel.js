const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
    question_title: {
        type: String,
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
        type: String,
        required: true
    },
    user_answer: {
        type: String,
        required: true
    },
    description: {
        type: String
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
