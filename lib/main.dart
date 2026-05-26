import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/dependency_injection.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/blocs/auth_bloc/auth_bloc.dart';
import 'presentation/blocs/auth_bloc/auth_state.dart';
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<DuaRepository>()),
        RepositoryProvider.value(value: getIt<PoemRepository>()),
      ],
      child: BlocProvider.value(
        value: getIt<AuthBloc>()..add(CheckAuthStatus()),
        child: MaterialApp(
          title: 'nur·deen',
          theme: AppTheme.lightTheme,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) return MainScreen(user: state.user);
              if (state is Unauthenticated) return const AuthScreen();
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          ),
        ),
      ),
    );
  }
}
