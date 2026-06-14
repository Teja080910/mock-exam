const mongoose = require('mongoose');
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
        type: String,
        required: true,
        trim: true
    },
    image:{
        type: String
    },
    audio:{
        type: String
    },
    // Updated option fields to accept either simple string or {text,image} object
    option: {
        a: { type: mongoose.Schema.Types.Mixed, default: '' },
        b: { type: mongoose.Schema.Types.Mixed, default: '' },
        c: { type: mongoose.Schema.Types.Mixed, default: '' },
        d: { type: mongoose.Schema.Types.Mixed, default: '' }
    },
    answer:{
        type:String,
        required:true,
        trim: true
    },
    description:{
        type:String 
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