# Mock Exam

## Backend (API)

```bash
cd api
npm install
# Create api/.env with required env vars (DB_CONNECTION, JWT_SECRET, etc.)
npm start
```

Server runs on `http://localhost:6900`.

## Frontend (Flutter App)

```bash
cd "app/mock_station"
flutter pub get
flutter run
```

The app connects to the backend API at the URL configured in the Flutter source.