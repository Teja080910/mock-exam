# Mock Exam

Full-stack mock exam application with Flutter frontend and Node.js/Express backend.

## 📋 Prerequisites

- **Flutter SDK** >= 3.0.0
- **Node.js** >= 18
- **MongoDB** (local or Atlas)
- **Firebase project** with Authentication, Firestore, Cloud Messaging enabled
- **Razorpay account** (for payments)

---

## 🚀 Deployment Checklist

### Backend (API)

#### Files to update before deploy:

| File                          | Change Needed                                                                                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `api/.env`                    | Set production values: `DB_CONNECTION` (Atlas URI), `JWT_SECRET`, `SESSION_SECRET`, `RAZORPAY_KEY_ID/SECRET` (live keys), `FIREBASE_CREDENTIALS` |
| `api/test-google-signin.js:8` | Change `http://localhost:6900` to your production URL (optional test script)                                                                     |

```bash
cd api
npm install
# Configure api/.env with production credentials
npm start
```

### Flutter App

#### Files to update before deploy:

| File                                                           | What to Change                                                                                      |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `app/mock_station/lib/config/app_config.dart:5-6`              | Set `baseURL` and `imageBaseURL` to your production server URL (e.g. `https://api.yourdomain.com/`) |
| `app/mock_station/lib/backend/api_requests/api_calls.dart:19`  | Same production URL in `QuizGroup.getBaseUrl()`                                                     |
| `app/mock_station/android/app/src/main/AndroidManifest.xml:17` | **Remove** `android:usesCleartextTraffic="true"` (only needed for local HTTP dev)                   |

#### Firebase Setup:

1. Create a Firebase project at https://console.firebase.google.com
2. **Android:** Download `google-services.json` → place at `app/mock_station/android/app/google-services.json`
3. **iOS:** Download `GoogleService-Info.plist` → place at `app/mock_station/ios/Runner/GoogleService-Info.plist`
4. Enable **Authentication** → **Google sign-in** in Firebase Console
5. Enable **Cloud Messaging** (FCM) for push notifications
6. Update Firebase config values in `app/mock_station/lib/config/app_config.dart:11-19`

#### Payment Keys:

| Key                        | Where to Set                                                                        |
| -------------------------- | ----------------------------------------------------------------------------------- |
| **Razorpay Key ID**        | `app/mock_station/lib/config/app_config.dart:29` (publishable key)                  |
| **Razorpay Key Secret**    | `api/.env` → `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` (live keys for production) |
| **Stripe Publishable Key** | `app/mock_station/lib/config/app_config.dart:24`                                    |
| **PayPal Client ID**       | `app/mock_station/lib/config/app_config.dart:34`                                    |

#### Build & Release:

```bash
cd app/mock_station

# Android release build
flutter build apk --release

# Or appbundle for Play Store
flutter build appbundle --release
```

For Android signing, create `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../app-keystore.jks
```

---

## 🧑‍💼 Admin Panel

Access at: `http://your-server.com/` (or locally `http://localhost:6900/`)

| Role      | Email               | Password   |
| --------- | ------------------- | ---------- |
| **Admin** | `admin@example.com` | `admin123` |

Create additional admins:

```bash
cd api
node scripts/createAdmin.js
```

---

## 📦 What's NOT in Repo (create before deploy)

| File                                  | Purpose                                       |
| ------------------------------------- | --------------------------------------------- |
| `android/app/google-services.json`    | Firebase Android config from Firebase Console |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS config from Firebase Console     |
| `api/.env`                            | Backend secrets (copy from `.env.example`)    |
| `android/key.properties`              | Release signing credentials                   |
| `android/app-keystore.jks`            | Android signing keystore                      |

---

## 🛠 Local Development (already configured)

```bash
# Start MongoDB
# In one terminal:
cd api
npm start              # Runs on port 6900

# In another terminal:
cd app/mock_station
flutter run            # Connects to local backend
```

---

## 🔒 Security Notes

- **Never commit** `google-services.json`, `.env`, `.jks`, or `key.properties`
- **Never put** Stripe/Razorpay/PayPal **secret keys** in the Flutter app
- Use production-ready `JWT_SECRET` (64+ char hex string)
- Use MongoDB Atlas for production (not localhost)

---

## 📊 Database

The project ships with production data (31 categories, 111 quizzes, 8748+ questions).
To reset migrated data:

```bash
cd api
node scripts/migrateProdToLocal.js
```
