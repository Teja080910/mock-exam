// Initialize Firebase Admin SDK
const admin = require('firebase-admin');
const serviceAccount = JSON.parse(
  Buffer.from(process.env.FIREBASE_CREDENTIALS, "base64").toString("utf8")
);

let firebaseApp;

try {
    console.log('Initializing Firebase Admin SDK...');
    console.log('Project ID:', serviceAccount.project_id);
    console.log('Client Email:', serviceAccount.client_email);
    
    // Check if already initialized
    if (admin.apps.length > 0) {
        console.log('Using existing Firebase Admin SDK instance');
        firebaseApp = admin.apps[0];
    } else {
        console.log('Creating new Firebase Admin SDK instance');
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: serviceAccount.project_id
        });
    }
    
    // Test the initialization by getting the project ID
    const projectId = firebaseApp.options.projectId;
    console.log('Firebase Admin SDK initialized successfully. Project ID:', projectId);
} catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
    throw error;
}

module.exports = admin;