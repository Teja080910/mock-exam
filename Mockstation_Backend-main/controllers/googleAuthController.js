const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const Notification = require('../models/notificationModel');

// Initialize Firebase Admin
let firebaseApp;
try {
    // Check if Firebase is already initialized
    if (!admin.apps.length) {
        const serviceAccount = require('../config/firebase-adminsdk.json');
        console.log('Firebase service account loaded:', {
            project_id: serviceAccount.project_id,
            client_email: serviceAccount.client_email,
            private_key_id: serviceAccount.private_key_id
        });
        
        // Format the private key if it exists
        if (serviceAccount.private_key) {
            serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
            console.log('Private key formatted successfully');
        } else {
            console.error('Private key is missing from service account');
        }
        
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('Firebase Admin SDK initialized successfully');
    } else {
        firebaseApp = admin.app();
        console.log('Using existing Firebase Admin SDK instance');
    }
} catch (error) {
    console.error('Firebase initialization error:', error);
    console.warn('Firebase configuration not found or invalid. Google Sign-In will not work.');
}

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
                // Create new user
                user = await User.create({
                    email,
                    firstname: name?.split(' ')[0] || '',
                    lastname: name?.split(' ').slice(1).join(' ') || '',
                    username: email.split('@')[0],
                    profile_pic: picture,
                    is_google_user: true,
                    is_verified: 1,
                    points: 0
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