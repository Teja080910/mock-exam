importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAWaKg15juVxHhaH5sQntzXBz3JBtwgxoo",
  authDomain: "mock-test-657990.firebaseapp.com",
  projectId: "mock-test-657990",
  storageBucket: "mock-test-657990.firebasestorage.app",
  messagingSenderId: "481518702750",
  appId: "1:481518702750:android:7cc30006165d5010caeb8f",
});

const messaging = firebase.messaging();
