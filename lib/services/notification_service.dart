import 'package:flutter/widgets.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Hapus impor timezone karena notifikasi instan tidak memerlukannya
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzdata; 

class NotificationService {
 static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
   FlutterLocalNotificationsPlugin();
      
 // Channel ID khusus untuk notifikasi transaksi instan
 static const String _transactionChannelId = 'transaction_channel';
 static const String _transactionChannelName = 'Notifikasi Transaksi';
 static const String _transactionChannelDescription = 'Notifikasi saat tabungan berhasil disimpan';

 static Future<void> init() async {
  // Hapus inisialisasi TimeZone
  // tzdata.initializeTimeZones();
  // tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); 
  
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
   android: initializationSettingsAndroid,
   iOS: initializationSettingsIOS, 
  );
  
  await flutterLocalNotificationsPlugin.initialize(
   initializationSettings,
  );

  final bool? androidGranted = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
    
  if (androidGranted == false) {
   debugPrint('Izin notifikasi Android ditolak!');
  }
  
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
     alert: true,
     badge: true,
     sound: true,
    );
 }
  
 // ✅ FUNGSI BARU: Menampilkan notifikasi instan
 static Future<void> showInstantNotification({
  required int id,
  required String title,
  required String body,
 }) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
   _transactionChannelId,
   _transactionChannelName,
   channelDescription: _transactionChannelDescription,
   importance: Importance.max,
   priority: Priority.high,
   ticker: 'ticker',
   // Setting custom sound jika ada
   // sound: RawResourceAndroidNotificationSound('notif_sound'), 
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
     // Setting custom sound jika ada
     // sound: 'notif_sound.aiff', 
    );
  
  const NotificationDetails platformChannelSpecifics =
    NotificationDetails(
     android: androidPlatformChannelSpecifics,
     iOS: iOSPlatformChannelSpecifics,
    );

  await flutterLocalNotificationsPlugin.show(
   id,
   title,
   body,
   platformChannelSpecifics,
   payload: 'transaction_completed',
  );
 }

 // Hapus scheduleDailyNotification
 // static Future<void> scheduleDailyNotification({ ... }) async { ... }
  
 static Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
 }
}