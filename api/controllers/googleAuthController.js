const admin = require('../config/firebase');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const Notification = require('../models/notificationModel');
const randomstring = require('randomstring');

let firebaseApp = admin.apps.length > 0 ? admin.apps[0] : null;

const googleSignIn = async (req, res) => {
    try {
        if (!firebaseApp) {
            return res.status(500).json({
                success: 0,
                message: 'Firebase configuration is missing or invalid',
                error: 1
            });
        }

        const { token, deviceId } = req.body;

        if (!token) {
            return res.status(400).json({
                success: 0,
                message: 'Token is required',
                error: 1
            });
        }

        console.log('Verifying Firebase ID token...');
        console.log('Token length:', token.length);
        console.log('Token first 50 chars:', token.substring(0, 50));
        
        try {
            // Verify the Firebase ID token
            const decodedToken = await admin.auth().verifyIdToken(token);
            console.log('Token verified successfully:', decodedToken);
            
            const { email, name, picture } = decodedToken;

            // Check if user exists
            let user = await User.findOne({ email });
            
            if (!user) {
                console.log('Creating new user for email:', email);
                // Generate unique referral code
                let referralCode = '';
                let isUnique = false;
                while (!isUnique) {
                    referralCode = randomstring.generate({ length: 8, charset: 'alphanumeric', capitalization: 'uppercase' });
                    const existingCode = await User.findOne({ referral_code: referralCode });
                    if (!existingCode) isUnique = true;
                }

                // Handle referral code from signup flow
                let referredBy = null;
                if (req.body.referralCode) {
                    const referrer = await User.findOne({ referral_code: req.body.referralCode });
                    if (referrer) referredBy = referrer._id;
                }

                // Create new user
                user = await User.create({
                    email,
                    firstname: name?.split(' ')[0] || '',
                    lastname: name?.split(' ').slice(1).join(' ') || '',
                    username: email.split('@')[0],
                    profile_pic: picture,
                    is_google_user: true,
                    is_verified: 1,
                    points: 0,
                    referral_code: referralCode,
                    referred_by: referredBy
                });
                console.log('New user created:', user._id);
            } else {
                console.log('Existing user found:', user._id);
            }

            // Handle device registration
            if (deviceId) {
                const existingDevice = await Notification.findOne({ 
                    user_id: user._id,
                    device_id: deviceId 
                });

                if (!existingDevice) {
                    await Notification.create({
                        user_id: user._id,
                        device_id: deviceId,
                        registration_token: req.body.registrationToken || ''
                    });
                    console.log('New device registered for user:', user._id);
                } else if (req.body.registrationToken) {
                    existingDevice.registration_token = req.body.registrationToken;
                    await existingDevice.save();
                    console.log('Device token updated for user:', user._id);
                }
            }

            // Check if JWT_SECRET exists
            if (!process.env.JWT_SECRET) {
                throw new Error('JWT_SECRET environment variable is not set');
            }

            // Generate JWT token
            const jwtToken = jwt.sign(
                { id: user._id },
                process.env.JWT_SECRET,
                { expiresIn: '7d' }
            );

            // Format user details consistently
            const userDetails = {
                id: user._id.toString(),
                firstname: user.firstname || '',
                lastname: user.lastname || '',
                username: user.username || '',
                email: user.email,
                phone: user.phone || '',
                active: user.active || 'true',
                image: user.profile_pic || '',
                points: user.points || 0,
                is_verified: user.is_verified || 0,
                created_at: user.createdAt || '',
                updated_at: user.updatedAt || ''
            };

            console.log('Sending successful response for user:', user._id);
            return res.json({
                success: 1,
                message: 'Login successful',
                data: {
                    token: jwtToken,
                    userDetails: userDetails
                },
                error: 0
            });
        } catch (verifyError) {
            console.error('Token verification error:', verifyError);
            console.error('Token verification error details:', {
                name: verifyError.name,
                message: verifyError.message,
                code: verifyError.code,
                stack: verifyError.stack
            });
            throw verifyError;
        }

    } catch (error) {
        console.error('Google Sign-In Error:', error);
        return res.status(500).json({
            success: 0,
            message: error.message || 'Authentication failed',
            error: 1
        });
    }
};

module.exports = {
    googleSignIn
}; 