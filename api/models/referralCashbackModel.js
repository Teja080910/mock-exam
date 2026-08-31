const mongoose = require('mongoose');

const ReferralCashbackSchema = mongoose.Schema({
    referrerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    referredUserId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    planId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Plan'
    },
    planName: {
        type: String,
        default: ''
    },
    planAmount: {
        type: Number,
        default: 0
    },
    discountAmount: {
        type: Number,
        default: 0
    },
    paidAmount: {
        type: Number,
        default: 0
    },
    cashbackPercent: {
        type: Number,
        default: 0
    },
    cashbackAmount: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['pending', 'paid'],
        default: 'pending'
    },
    paidAt: {
        type: Date
    }
}, { timestamps: true });

ReferralCashbackSchema.index({ referrerId: 1, createdAt: -1 });

module.exports = mongoose.model('ReferralCashback', ReferralCashbackSchema);
