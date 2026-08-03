# DEPLOYMENT_REQUIREMENTS.md

## Files you MUST replace with YOUR keys before building APK

### 1. Firebase

| What | File | Line(s) |
|---|---|---|
| `google-services.json` | `android/app/google-services.json` | Entire file — download from Firebase Console |
| `firebaseApiKey` | `lib/config/app_config.dart` | Line 11-12 |
| `firebaseProjectId` | `lib/config/app_config.dart` | Line 13 |
| `firebaseAuthDomain` | `lib/config/app_config.dart` | Line 14 |
| `firebaseStorageBucket` | `lib/config/app_config.dart` | Line 15-16 |
| `firebaseMessagingSenderId` | `lib/config/app_config.dart` | Line 17 |
| `firebaseAppId` | `lib/config/app_config.dart` | Line 18-19 |

**How to get:** Go to [Firebase Console](https://console.firebase.google.com) → Your Project → Project Settings → General → Your apps → Android app → copy all values.

---

### 2. Razorpay

| What | File | Line |
|---|---|---|
| `razorpayKeyID` | `lib/config/app_config.dart` | Line 29 |
| `RAZORPAY_KEY_ID` | `api/.env` | — |
| `RAZORPAY_KEY_SECRET` | `api/.env` | — |

**How to get:** [Razorpay Dashboard](https://dashboard.razorpay.com) → Settings → API Keys → Use **Live** keys for production, **Test** keys for testing.

---

### 3. Stripe (optional)

| What | File | Line |
|---|---|---|
| `stripePublishableKey` | `lib/config/app_config.dart` | Line 24 |

**How to get:** [Stripe Dashboard](https://dashboard.stripe.com) → Developers → API Keys → Publishable key.

---

### 4. PayPal (optional)

| What | File | Line |
|---|---|---|
| `paypalClientId` | `lib/config/app_config.dart` | Line 34 |
| `paypalSecretKey` | `lib/config/app_config.dart` | Line 35 |

**How to get:** [PayPal Developer Dashboard](https://developer.paypal.com) → My Apps & Credentials.

---

### 5. Backend URL (already set to deployed server)

| File | Line | Current Value |
|---|---|---|
| `lib/config/app_config.dart` | 5-6 | `https://mediumspringgreen-aardvark-783458.hostingersite.com/` |
| `lib/backend/api_requests/api_calls.dart` | 19 | `https://mediumspringgreen-aardvark-783458.hostingersite.com/api/` |

Change these if you deploy your own backend.

---

### 6. Backend `.env` (for your own server)

| Key | File |
|---|---|
| `DB_CONNECTION` | `api/.env` |
| `JWT_SECRET` | `api/.env` |
| `SESSION_SECRET` | `api/.env` |
| `RAZORPAY_KEY_ID` | `api/.env` |
| `RAZORPAY_KEY_SECRET` | `api/.env` |
| `FIREBASE_CREDENTIALS` | `api/.env` (base64 of Firebase service account JSON) |
| `SERVER_KEY` | `api/.env` (FCM server key) |

---

## Build APK

```bash
cd app/mock_station
flutter build apk --debug
```

APK location: `build/app/outputs/flutter-apk/app-debug.apk`

---

## For Release APK (Play Store)

Additional setup:

1. **Generate keystore:**
   ```bash
   cd android
   keytool -genkey -v -keystore app-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`:**
   ```properties
   storePassword=your-password
   keyPassword=your-password
   keyAlias=upload
   storeFile=../app-keystore.jks
   ```

3. **Remove** `android:usesCleartextTraffic="true"` from `AndroidManifest.xml` (only needed for HTTP dev)

4. **Build:**
   ```bash
   flutter build apk --release
   # or
   flutter build appbundle --release
   ```
