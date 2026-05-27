import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/dependency_injection.dart';
import 'app/router.dart';
import 'presentation/blocs/auth_bloc/auth_bloc.dart';
import 'presentation/blocs/auth_bloc/auth_event.dart';
import 'core/themes/app_theme.dart';
import 'data/repositories/dua_repository.dart';
import 'data/repositories/poem_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
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
              title: 'nur·deen',
              theme: AppTheme.lightTheme,
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
