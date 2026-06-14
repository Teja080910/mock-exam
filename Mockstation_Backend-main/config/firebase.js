const admin = require('firebase-admin');

let firebaseApp = null;

try {
  const creds = process.env.FIREBASE_CREDENTIALS;
  if (creds) {
    const serviceAccount = JSON.parse(
      Buffer.from(creds, "base64").toString("utf8")
    );
    if (admin.apps.length > 0) {
      firebaseApp = admin.apps[0];
    } else {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id
      });
    }
    console.log('Firebase Admin SDK initialized');
  } else {
    console.log('FIREBASE_CREDENTIALS not set — Firebase disabled');
  }
} catch (error) {
  console.error('Firebase init skipped:', error.message);
}

module.exports = admin;