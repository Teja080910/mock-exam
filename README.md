# Mock Exam

## Prerequisites

- **Flutter SDK** >= 3.0.0
- **Node.js** >= 18
- **MongoDB** running locally
- **Firebase project** with Authentication, Firestore, Cloud Messaging enabled

---

## Backend (API)

```bash
cd api
npm install
cp .env.example .env
# Edit api/.env with your own credentials:
#   DB_CONNECTION, JWT_SECRET, SESSION_SECRET, FIREBASE_CREDENTIALS, PORT
npm start
```

---

## Frontend (Flutter App)

### 1. Firebase Setup

Create a Firebase project at https://console.firebase.google.com, then:

**Android:**
1. Download `google-services.json` from your Firebase project settings
2. Place it at: `app/mock_station/android/app/google-services.json`

**iOS:**
1. Download `GoogleService-Info.plist`
2. Place it at: `app/mock_station/ios/Runner/GoogleService-Info.plist`

### 2. Configure API URLs and Payment Keys

Edit the config file at `app/mock_station/lib/config/app_config.dart` with your values:

```dart
class AppConfig {
  // Backend API
  static const String baseURL = 'https://your-server.com/';
  static const String imageBaseURL = 'https://your-server.com/assets/userImages/';

  // Firebase (from your Firebase project -> Project Settings -> General)
  static const String firebaseApiKey = 'your-firebase-api-key';
  static const String firebaseProjectId = 'your-firebase-project-id';
  // ... fill in all firebase values

  // Stripe (publishable key only — never put secret key in the app)
  static const String stripePublishableKey = 'your-stripe-publishable-key';

  // Razorpay (key ID only — never put secret in the app)
  static const String razorpayKeyID = 'your-razorpay-key-id';

  // PayPal
  static const String paypalClientId = 'your-paypal-client-id';
  static const String paypalSecretKey = 'your-paypal-secret-key';
}
```

### 3. Android Signing (for release builds)

Create `app/mock_station/android/key.properties` (NOT committed to git):

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../app-keystore.jks
```

### 4. Run the App

```bash
cd app/mock_station
flutter pub get
flutter run
```

---

## What's NOT in this Repo (you must provide)

| File | Purpose | How to Get |
|---|---|---|
| `android/app/google-services.json` | Firebase Android config | Firebase Console → Project Settings → Download |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS config | Firebase Console → Project Settings → Download |
| `api/.env` | Backend credentials | Copy `.env.example`, fill in your secrets |
| `android/key.properties` | Release signing keys | Create manually with your keystore details |
| `android/app-keystore.jks` | Android signing keystore | Generate with `keytool -genkey` |

---

## Security Notes

- **Never commit** `google-services.json`, `.env`, `.jks`, or `key.properties` files
- **Never put** Stripe/Razorpay/PayPal **secret keys** in the Flutter app — handle payments server-side
- All secrets previously in this repo have been extracted to config files — rotate any previously exposed keys
