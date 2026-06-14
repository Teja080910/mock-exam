const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        // required: true, // Make optional
    },
    device_id: {
        type: String,
        // required: true, // Make optional
    },
    registration_token: {
        type: String,
        default: ''
    }
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);