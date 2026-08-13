import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart'; // TAMBAHAN

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'penugasan_channel',
  'Penugasan Driver',
  description: 'Notifikasi perintah penugasan untuk driver',
  importance: Importance.max,
  playSound: true,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // GANTI
  );
  showLocalNotification(message);
}

Future<void> initFCM() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // GANTI
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(showLocalNotification);

  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token'); // nanti kirim token ini ke backend kendis_api
}

void showLocalNotification(RemoteMessage message) {
  flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.data['title'] ?? 'Penugasan Baru',
    message.data['body'] ?? 'Ada tugas baru untuk kamu',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'penugasan_channel',
        'Penugasan Driver',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
      ),
    ),
  );
}