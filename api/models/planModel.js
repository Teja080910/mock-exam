const mongoose = require('mongoose');
const planSchema = new mongoose.Schema({
    planName: {
        type: String,
        required: true
    },
    planValidity: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        default: 0,
        required: true
    },
    planId: {
        type: String,
        required: true,
        unique: true
    },
    categoryGroup: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'CategoryGroup',
        required: false
    }
},

    { timestamps: true });

module.exports = mongoose.model('Plan', planSchema);
