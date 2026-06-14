importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAyHOBxPe_bkHUuk2UsMPA19QfCihr5f_4',
  authDomain: 'dua-poem-push-notification.firebaseapp.com',
  projectId: 'dua-poem-push-notification',
  storageBucket: 'dua-poem-push-notification.firebasestorage.app',
  messagingSenderId: '494112043315',
  appId: '1:494112043315:web:e97da02b497c9060e08e46',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification?.title ?? '';
  const notificationBody = payload.notification?.body ?? '';
  self.registration.showNotification(notificationTitle, {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
  });
});
