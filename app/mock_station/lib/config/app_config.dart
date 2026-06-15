class AppConfig {
  // ============================================
  // Backend API
  // ============================================
  static const String baseURL = 'https://your-server.com/';
  static const String imageBaseURL = 'https://your-server.com/assets/userImages/';

  // ============================================
  // Firebase
  // ============================================
  static const String firebaseApiKey = 'AIzaSyAWaKg15juVxHhaH5sQntzXBz3JBtwgxoo';
  static const String firebaseProjectId = 'mock-test-657990';
  static const String firebaseAuthDomain = 'mock-test-657990.firebaseapp.com';
  static const String firebaseStorageBucket = 'mock-test-657990.firebasestorage.app';
  static const String firebaseMessagingSenderId = '481518702750';
  static const String firebaseAppId = '1:481518702750:android:7cc30006165d5010caeb8f';

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
