import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../../core/services/browser_notification_stub.dart'
    if (dart.library.html) '../../core/services/browser_notification_web.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../../app/dependency_injection.dart';
import '../../app/router.dart';
import '../../core/enums/notification_type.dart';
import '../models/signalr/notification_update_model.dart';
import 'device_token_service.dart';
import 'signalr_service.dart';

class FcmService {
  final DeviceTokenService _deviceTokenService;
  final FlutterLocalNotificationsPlugin _localNotifications;

  FcmService(this._deviceTokenService)
      : _localNotifications = FlutterLocalNotificationsPlugin();

  String get _platform {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }

  String? get _vapidKey => kIsWeb
      ? 'BB4tbwfm7ypUqSlePNTNx1OsMB3N1ZE-74iQSx5bk11a2CI1iTmyn2vWBz6LDIK-K2h3ry9DF6AIX87JTi14dRE'
      : null;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    print('[FCM] flutter_local_notifications initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    try {
      final parsed = jsonDecode(payload) as Map<String, dynamic>;
      _navigateFromNotificationData(parsed);
    } catch (_) {}
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
    print('[FCM] Token obtained: $token');
    return token;
  }

  Future<void> registerTokenWithBackend() async {
    final token = await getToken();
    if (token == null) {
      print('[FCM] No token — skipping backend registration');
      return;
    }
    try {
      await _deviceTokenService.registerToken(token, _platform);
      print('[FCM] Token registered with backend (platform=$_platform)');
    } catch (e) {
      print('[FCM] Backend registration error: $e');
    }
  }

  void listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('[FCM] Token refreshed');
      try {
        await _deviceTokenService.registerToken(newToken, _platform);
        print('[FCM] Refreshed token registered');
      } catch (e) {
        print('[FCM] Refresh registration error: $e');
      }
    });
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM] Foreground message received: ${message.notification?.title}');
      final notification = message.notification;
      if (notification == null) {
        print('[FCM] No notification payload in message');
        return;
      }

      _showLocalNotification(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data['data'],
      );

      _dispatchToNotificationBloc(message);
    });
  }

  void listenToBackgroundMessageTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[FCM] App opened from notification');
      _dispatchToNotificationBloc(message);
      final dataStr = message.data['data'] as String?;
      if (dataStr == null) return;
      try {
        final parsed = jsonDecode(dataStr) as Map<String, dynamic>;
        _navigateFromNotificationData(parsed);
      } catch (_) {}
    });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      showBrowserNotification(title, body);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'push_notifications',
      'Push Notifications',
      channelDescription: 'Notifications from push messages',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(id, title, body, details, payload: payload);
    print('[FCM] Local notification shown');
  }

  void _dispatchToNotificationBloc(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    if (notification == null) return;

    final typeStr = data['type'] ?? '';
    final type = NotificationType.values.firstWhere(
      (t) => t.value == typeStr,
      orElse: () => NotificationType.likeReceived,
    );

    final update = NotificationUpdateModel(
      id: data['id'] ?? '',
      type: type,
      title: notification.title ?? '',
      body: notification.body ?? '',
      data: data['data'],
      isRead: false,
      createdAt: DateTime.now(),
    );

    getIt<SignalRService>().addNotification(update);
    print('[FCM] Dispatched to notification bloc');
  }

  void _navigateFromNotificationData(Map<String, dynamic> data) {
    final duaId = data['duaId'] as String?;
    final poemId = data['poemId'] as String?;
    final badgeSlug = data['badgeSlug'] as String?;
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    if (duaId != null) {
      GoRouter.of(context).push('/dua/$duaId');
    } else if (poemId != null) {
      GoRouter.of(context).push('/poem/$poemId');
    } else if (badgeSlug != null) {
      GoRouter.of(context).go('/profile');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[FCM Background] Message received: ${message.notification?.title}');
}
