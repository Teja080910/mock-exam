const Verification = require('../models/verificationModel');

// Verify Access
const verifyAccess = async (req, res, next) => {
    // Always allow access
    next();
};

const verifyAdminAccess = async (req, res, next) => {
    next();
};

module.exports = {
    verifyAccess,
    verifyAdminAccess
};