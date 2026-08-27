const mongoose = require("mongoose");
const NewsSchema = mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    description: {
        type: String,
        required: true
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
