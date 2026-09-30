const mongoose = require('mongoose');

// Wallet ledger: every wallet balance change gets an entry here.
const CashbackTransactionSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    type: {
        type: String,
        enum: ['earn', 'redeem'],
        required: true
    },
    amountPaise: {
        type: Number,
        required: true
    },
    title: {
        type: String,
        default: ''
    },
    relatedUserId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    referralCashbackId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ReferralCashback'
    },
    orderId: {
        type: String,
        default: ''
    },
    balanceAfterPaise: {
        type: Number,
        default: 0
    }
}, { timestamps: true });

CashbackTransactionSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('CashbackTransaction', CashbackTransactionSchema);
