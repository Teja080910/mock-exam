const mongoose = require("mongoose");
const NewsSchema = mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    post_type: {
        type: String,
        enum: ['result', 'admit_card', 'answer_key', 'notification', 'other'],
        default: 'notification',
        required: true
    },
    short_description: {
        type: String,
        required: true,
        maxlength: 500
    },
    description: {
        type: String,
        required: false
    },
    link: {
        type: String,
        required: false
    },
    is_active: {
        type: Number,
        default: 0
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('News', NewsSchema);
