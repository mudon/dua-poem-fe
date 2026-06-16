import 'dart:js_interop';
import 'package:web/web.dart';

void showBrowserNotification(String title, String body) {
  if (Notification.permission == 'granted') {
    Notification(title, NotificationOptions(body: body));
    print('[BrowserNotification] Shown: $title');
  } else {
    print('[BrowserNotification] Permission not granted, skipping');
  }
}

Future<bool> requestBrowserNotificationPermission() async {
  final status = (await Notification.requestPermission().toDart).toDart;
  return status == 'granted';
}
