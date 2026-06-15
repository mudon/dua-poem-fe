import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'core/constants/app_config.dart';

class DefaultFirebaseOptions {
  static final FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey,
    appId: AppConfig.firebaseAppId,
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    projectId: AppConfig.firebaseProjectId,
    authDomain: AppConfig.firebaseAuthDomain,
    storageBucket: AppConfig.firebaseStorageBucket,
  );
}
