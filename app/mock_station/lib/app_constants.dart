import 'config/app_config.dart' as config;

/// Standard font size scale used across the entire app.
/// Always use FFFont instead of raw fontSize values so sizes stay consistent.
abstract class FFFont {
  static const double f9 = 9;
  static const double f10 = 10;
  static const double f11 = 11;
  static const double f12 = 12;
  static const double f14 = 14;
  static const double f16 = 16;
  static const double f18 = 18;
  static const double f20 = 20;
  static const double f22 = 22;
  static const double f24 = 24;
  static const double f28 = 28;
  static const double f32 = 32;
  static const double f36 = 36;
  static const double f44 = 44;
  static const double f64 = 64;
}

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
