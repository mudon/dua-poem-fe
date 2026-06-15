import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl => dotenv.get('API_BASE_URL');

  static String get firebaseApiKey => dotenv.get('FIREBASE_API_KEY');
  static String get firebaseAppId => dotenv.get('FIREBASE_APP_ID');
  static String get firebaseMessagingSenderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => dotenv.get('FIREBASE_PROJECT_ID');
  static String get firebaseAuthDomain => dotenv.get('FIREBASE_AUTH_DOMAIN');
  static String get firebaseStorageBucket => dotenv.get('FIREBASE_STORAGE_BUCKET');

  static String get vapidKey => dotenv.get('VAPID_KEY');
}
