import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {


  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();



  static Future<void> initialize() async {


    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );



    final InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );



    await _notifications.initialize(
      settings: settings,
    );


  }





  static Future<void> requestPermission() async {


    final AndroidFlutterLocalNotificationsPlugin? android =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();


    await android?.requestNotificationsPermission();


  }






  static Future<void> showNotification({

    required String title,

    required String body,

  }) async {



    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(

      'finansmart_channel',

      'FinanSmart',

      channelDescription:
          'Notificaciones de solicitudes',

      importance:
          Importance.high,

      priority:
          Priority.high,

    );



    const NotificationDetails notificationDetails =
        NotificationDetails(

      android:
          androidDetails,

    );



    await _notifications.show(

      id: 1,

      title: title,

      body: body,

      notificationDetails:
          notificationDetails,

    );


  }


}