import 'config/app_config.dart' as config;

abstract class FFAppConstants {
  static const String baseURL = config.AppConfig.baseURL;
  static const String imageBaseURL = config.AppConfig.imageBaseURL;

  // Stripe
  // Secret key must be handled by your backend - never put it in the app
  static const String stripeSecretKey = config.AppConfig.stripePublishableKey; // FIXME: Replace with server-side Stripe integration
  static const String stripePublishableKey = config.AppConfig.stripePublishableKey;

  // Razorpay
  // Secret key must be handled by your backend - never put it in the app
  static const String razorpayKeyID = config.AppConfig.razorpayKeyID;
  static const String razorpaySecretKey = ''; // FIXME: Replace with server-side Razorpay integration
}
