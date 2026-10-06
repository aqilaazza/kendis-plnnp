import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import '../core/navigation_service.dart';
import 'penugasan_popup_screen.dart';
import '../screens/kegiatan/kegiatan_screen.dart'; // SESUAIKAN path & nama file halaman Kegiatan kamu

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  showLocalNotification(message);
}

Future<void> initFCM() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((message) {
    showLocalNotification(message);
    showPenugasanOverlay(message);
  });

  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}

void showLocalNotification(RemoteMessage message) {
  final title = message.notification?.title ?? message.data['title'] ?? 'Penugasan Baru';
  final body = message.notification?.body ?? message.data['body'] ?? 'Ada tugas baru untuk kamu';

  flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
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

void showPenugasanOverlay(RemoteMessage message) {
  final kodeRequest = message.data['kode_request'] ?? '-';
  final titikJemput = message.data['titik_jemput'] ?? '-';
  final tujuanAkhir = message.data['tujuan_akhir'] ?? '-';
  final jadwal = message.data['jadwal'] ?? '-';
  final urgent = message.data['urgent'] == 'true';
  final penugasanId = message.data['penugasan_id'];

  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => PenugasanOverlayCard(
      kodeRequest: kodeRequest,
      titikJemput: titikJemput,
      tujuanAkhir: tujuanAkhir,
      jadwal: jadwal,
      urgent: urgent,
      onDismiss: () => entry.remove(),
      onTerima: () {
        entry.remove();
        // TODO: panggil API konfirmasi terima tugas pakai penugasanId di sini

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const KegiatanScreen(), // SESUAIKAN nama class halaman Kegiatan kamu
          ),
        );
      },
    ),
  );

  overlayState.insert(entry);
}