class AppConfig {
  // ============================================
  // Backend API
  // ============================================
  static const String baseURL = 'https://your-server.com/';
  static const String imageBaseURL = 'https://your-server.com/assets/userImages/';

  // ============================================
  // Firebase
  // ============================================
  static const String firebaseApiKey = 'your-firebase-api-key';
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String firebaseAuthDomain = 'your-project.firebaseapp.com';
  static const String firebaseStorageBucket = 'your-project.firebasestorage.app';
  static const String firebaseMessagingSenderId = 'your-sender-id';
  static const String firebaseAppId = 'your-app-id';

  // ============================================
  // Stripe (publishable key only - keep secret key on backend)
  // ============================================
  static const String stripePublishableKey = 'your-stripe-publishable-key';

  // ============================================
  // Razorpay (key ID only - keep secret on backend)
  // ============================================
  static const String razorpayKeyID = 'your-razorpay-key-id';

  // ============================================
  // PayPal (client ID only - keep secret on backend)
  // ============================================
  static const String paypalClientId = 'your-paypal-client-id';
  static const String paypalSecretKey = 'your-paypal-secret-key';
}
