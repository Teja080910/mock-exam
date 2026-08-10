class AppConfig {
  // ============================================
  // Backend API
  // ============================================
  static const String baseURL = 'https://app.mockstation.com/';
  static const String imageBaseURL = 'https://app.mockstation.com/assets/userImages/';

  // ============================================
  // Firebase
  // ============================================
  static const String firebaseApiKey =
      'AIzaSyBudWXW59XL_rO0ruyCdQaIS2Bnt8eqN7o';
  static const String firebaseProjectId = 'mock-test-65799';
  static const String firebaseAuthDomain = 'mock-test-65799.firebaseapp.com';
  static const String firebaseStorageBucket =
      'mock-test-65799.firebasestorage.app';
  static const String firebaseMessagingSenderId = '314697712812';
  static const String firebaseAppId =
      '1:314697712812:android:5ea19bc3e2b15b41860b09';

  // ============================================
  // Stripe (publishable key only - keep secret key on backend)
  // ============================================
  static const String stripePublishableKey = 'your-stripe-publishable-key';

  // ============================================
  // Razorpay (key ID only - keep secret on backend)
  // ============================================
  static const String razorpayKeyID = 'rzp_test_rtsWNkrDp1dlT7';

  // ============================================
  // PayPal (client ID only - keep secret on backend)
  // ============================================
  static const String paypalClientId = 'your-paypal-client-id';
  static const String paypalSecretKey = 'your-paypal-secret-key';
}
