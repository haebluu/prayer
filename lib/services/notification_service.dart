// lib/services/notification_service.dart

import 'package:flutter/widgets.dart'; // Diperlukan untuk debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata; // Wajib untuk initializeTimeZones

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. SETUP TIMEZONE (Wajib untuk scheduling)
    tzdata.initializeTimeZones();
    // Set lokasi default (e.g., Asia/Jakarta)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

    // 2. SETUP INITIALIZATION SETTINGS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    
    // Tambahkan iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS, 
    );
    
    // 3. INISIALISASI PLUGIN
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // 4. PERMINTAAN UTAMA: REQUEST PERMISSION RUNTIME
    
    // Permintaan izin notifikasi Android (untuk Android 13+)
    final bool? androidGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    if (androidGranted == false) {
       debugPrint('Izin notifikasi Android ditolak!');
    }
    
    // Permintaan izin notifikasi iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // FUNGSI BARU: Untuk menjadwalkan notifikasi berulang setiap hari
  static Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Jika waktu yang dijadwalkan sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dzikir_daily_channel',
      'Pengingat Dzikir Harian',
      channelDescription: 'Pengingat otomatis untuk Dzikir pagi dan sore',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    debugPrint('Notifikasi Dzikir dijadwalkan: ID $id pada $scheduledDate'); // Debugging Log

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics, // <--- KOREKSI TYPO DI SINI
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // FUNGSI BARU: Untuk membatalkan notifikasi (dipanggil di HomePage)
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}