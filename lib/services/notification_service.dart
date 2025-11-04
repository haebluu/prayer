import 'package:flutter/widgets.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
 

class NotificationService {
 static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
   FlutterLocalNotificationsPlugin();
      
 static const String _transactionChannelId = 'transaction_channel';
 static const String _transactionChannelName = 'Notifikasi Transaksi';
 static const String _transactionChannelDescription = 'Notifikasi saat tabungan berhasil disimpan';

 static Future<void> init() async { 

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
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
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
  
 static Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
 }
}