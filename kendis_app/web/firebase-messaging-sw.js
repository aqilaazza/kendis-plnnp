importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "ISI DARI firebase_options.dart bagian web",
    authDomain: "kendis-driver.firebaseapp.com",
    projectId: "kendis-driver",
    storageBucket: "kendis-driver.appspot.com",
    messagingSenderId: "ISI DARI firebase_options.dart bagian web",
    appId: "1:407872333550:web:17fadab300c5be701ff5ff",
});

const messaging = firebase.messaging();