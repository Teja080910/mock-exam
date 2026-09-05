const Notification = require("../models/notificationModel");
const common_Notification = require("../models/commonNotificationModel");
const Admin = require("../models/adminModel");
const admin = require('../config/firebase');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Extract first base64 image from Quill description, save as banner file, strip data URIs from HTML
function extractDescriptionImage(description) {
    if (!description) return { image: '', cleanDescription: description };
    const imgRegex = /<img[^>]*src="data:image\/(\w+);base64,([^"]+)"[^>]*>/gi;
    let match;
    let image = '';
    let cleanDescription = description;
    const imageDir = path.join(__dirname, '../public/assets/userImages');
    if (!fs.existsSync(imageDir)) fs.mkdirSync(imageDir, { recursive: true });
    while ((match = imgRegex.exec(description)) !== null) {
        if (!image) {
            try {
                const ext = match[1] === 'jpeg' ? 'jpg' : match[1];
                const filename = `${Date.now()}-description-${Math.random().toString(36).slice(2, 8)}.${ext}`;
                fs.writeFileSync(path.join(imageDir, filename), Buffer.from(match[2], 'base64'));
                image = filename;
            } catch (e) {
                console.log('Failed to save description image:', e.message);
            }
        }
    }
    if (image) {
        cleanDescription = description.replace(imgRegex, '').trim();
    }
    return { image, cleanDescription };
}

// Load notification
const loadNotification = async (req, res) => {
    try {
        res.render('addNotification');
    } catch (error) {
        console.log(error.message);
    }
}

// View notifications list
const viewNotification = async (req, res) => {
    try {
        const loginData = await Admin.findById({ _id: req.session.user_id });
        const page = parseInt(req.query.page) || 1;
        const limit = 20;
        const skip = (page - 1) * limit;
        const totalItems = await common_Notification.countDocuments();
        const totalPages = Math.ceil(totalItems / limit);
        const notifications = await common_Notification.find().sort({ createdAt: -1 }).skip(skip).limit(limit);
        res.render('viewNotification', { notifications: notifications, loginData: loginData, currentPage: page, totalPages: totalPages, totalItems: totalItems, limit: limit });
    } catch (error) {
        console.log(error.message);
    }
}

// Add notification
const addNotification = async (req, res) => {
    try {
        let loginData = await Admin.findById({_id:req.session.user_id});
        if (loginData.is_admin == 1) {
            const { image: descImage, cleanDescription } = extractDescriptionImage(req.body.description);
            const nottificationData = new common_Notification({
                title: req.body.title,
                description: cleanDescription || req.body.description,
                image: req.file ? req.file.filename : descImage
            });
            const saveNotification = await nottificationData.save();

            const findAllToken = await Notification.find();
            const registrationTokensSet = new Set();
                findAllToken.forEach((user) => {
                    if (user.registration_token) {
                        registrationTokensSet.add(user.registration_token);
                    }
                });
            const registrationTokens = Array.from(registrationTokensSet);

            if(!registrationTokens.length) {
                res.render('addNotification', { message: 'Notification Sent Successfully..!!' });
            } else {
                const serverKey = process.env.SERVER_KEY; // Replace with your FCM server key
                const deviceTokens = registrationTokens;
                const title = nottificationData.title;
                const body = nottificationData.description.replace(/<[^>]*>/g, '').trim();
    
                //sendPushNotifications(serverKey, deviceTokens, title, body);
                const imageUrl = nottificationData.image
                    ? `https://app.mockstation.com/assets/userImages/${nottificationData.image}`
                    : '';
                sendPushNotification(registrationTokens, title, body, imageUrl);
    
                if (nottificationData) {
                    res.render('addNotification', { message: 'Notification Sent Successfully..!!' });
                }
            }
        }
        else {
            req.flash('error', 'You have no access to send notification , You are not super admin !! *');
            return res.redirect('back');
        }
    } catch (error) {
        console.log(error.message);
    }
}

// Firebase Push Notification to all users
function sendPushNotification(registrationTokens, title, body, imageUrl = '') {
    const message = {
        notification: {
            title: title,
            body: body
        },
        tokens: registrationTokens
    };
    if (imageUrl) {
        message.notification.imageUrl = imageUrl;
    }
  
    admin.messaging().sendEachForMulticast(message)
        .then((response) => {
            console.log('Successfully sent message:', response);
        })
        .catch((error) => {
            console.error('Error sending message:', error);
        });
}


module.exports = {
    loadNotification,
    viewNotification,
    addNotification
}