const mongoose = require('mongoose');
const EbookSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    language: {
        type: String,
        required: false
    },
    link: {
        type: String,
        default: ''
    },
    file: {
        type: String,
        default: ''
    },
    image: {
        type: String,
        required: true
    },
    is_active: {
        type: Number,
        default: 0
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Ebook', EbookSchema); 