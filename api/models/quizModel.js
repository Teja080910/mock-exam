const mongoose = require('mongoose');
const QuizSchema = mongoose.Schema({

    categoryId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category'
    },
    subcategoryId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subcategory',
        required: true
    },
    name: {
        type: String,
        required: true,
        trim: true
    },
    image:{
        type:String
    },
    timer_status:{
        type:Number,
        default:0
    },
    minimum_required_points: {
        type: Number,
        required: true,
        trim: true
    },
    minutes_per_quiz: {
        type: Number,
        required: true,
        trim: true
    },
    description:{
        type: mongoose.Schema.Types.Mixed 
    },
    is_active:{
        type:Number,
        default:0
    },
    correct_ans_reward_per_question: {
        type: Number,
        default: 0
    },
    penalty_per_question: {
        type: Number,
        default: 0
    },
    pdf: {
        type: mongoose.Schema.Types.Mixed,
        default: { en: '', hi: '' }
    },
    pdf_en: {
        type: String,
        default: ''
    },
    pdf_hi: {
        type: String,
        default: ''
    }
},
    {
        timestamps: true
    });

module.exports = mongoose.model('Quiz',QuizSchema);