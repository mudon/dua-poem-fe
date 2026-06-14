import 'dart:html';

void showBrowserNotification(String title, String body) {
  if (Notification.permission == 'granted') {
    Notification(title, body: body);
    print('[BrowserNotification] Shown: $title');
  } else {
    print('[BrowserNotification] Permission not granted, skipping');
  }
}

Future<bool> requestBrowserNotificationPermission() async {
  final status = await Notification.requestPermission();
  return status == 'granted';
}
