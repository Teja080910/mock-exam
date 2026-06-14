importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBudWXW59XL_rO0ruyCdQaIS2Bnt8eqN7o",
  authDomain: "mock-test-65799.firebaseapp.com",
  projectId: "mock-test-65799",
  storageBucket: "mock-test-65799.firebasestorage.app",
  messagingSenderId: "314697712812",
  appId: "1:314697712812:android:5ea19bc3e2b15b41860b09",
});

const messaging = firebase.messaging();
