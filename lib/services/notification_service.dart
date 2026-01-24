import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    
    // Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We request manually later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );
    
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) return true;
    
    // Request for Android 13+
    final status = await Permission.notification.request();
    
    // For iOS, we use the local notifications plugin method
    final iosImpl = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final bool? result = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    
    return status.isGranted;
  }

  Future<void> showNotification({
    required int id, 
    required String title, 
    required String body, 
    String? payload
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'psgmx_channel_main', 
      'PSGMX Notifications',
      importance: Importance.max, 
      priority: Priority.high,
      color: Color(0xFFFF6600),
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    
    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
