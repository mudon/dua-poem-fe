import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/dependency_injection.dart';
import 'app/router.dart';
import 'core/network/dio_client.dart';
import 'presentation/blocs/auth_bloc/auth_bloc.dart';
import 'presentation/blocs/auth_bloc/auth_event.dart';
import 'core/themes/app_theme.dart';
import 'data/repositories/dua_repository.dart';
import 'data/repositories/poem_repository.dart';
import 'data/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase already initialized on native side
  }
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await setupDependencies();
  DioClient.navigatorKey = AppRouter.navigatorKey;
  final fcm = getIt<FcmService>();
  await fcm.initialize();
  await fcm.requestPermission();
  fcm.listenToTokenRefresh();
  fcm.listenToForegroundMessages();
  fcm.listenToBackgroundMessageTap();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = getIt<AuthBloc>()..add(CheckAuthStatus());

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<DuaRepository>()),
        RepositoryProvider.value(value: getIt<PoemRepository>()),
      ],
      child: BlocProvider.value(
        value: authBloc,
        child: Builder(
          builder: (context) {
            final router = AppRouter(authBloc).router;
            return MaterialApp.router(
              title: 'Teduh',
              theme: AppTheme.lightTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
