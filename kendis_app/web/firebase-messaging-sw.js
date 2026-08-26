importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyCdtvGBfLrsMtHAjN6TbgnpBwbOlhox-2w",
    authDomain: "kendis-driver.firebaseapp.com",
    projectId: "kendis-driver",
    storageBucket: "kendis-driver.firebasestorage.app",
    messagingSenderId: "407872333550",
    appId: "1:407872333550:web:17fadab300c5be701ff5ff",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.data || {};
  self.registration.showNotification(title || 'Penugasan Baru', {
    body: body || 'Ada tugas baru untuk kamu'
  });
});