import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../presentation/blocs/auth_bloc/auth_state.dart';
import '../presentation/screens/auth_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/my_duas_screen.dart';
import '../presentation/screens/my_poems_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/main_shell.dart';
import '../presentation/screens/dua_detail_screen.dart';
import '../presentation/screens/poem_detail_screen.dart';
import '../presentation/screens/user_detail_screen.dart';
import '../data/models/user_model.dart';

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  late final AuthStateNotifier _notifier;

  AppRouter(this.authBloc) {
    _notifier = AuthStateNotifier(authBloc.stream);
  }

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _notifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isInitial = authState is AuthInitial || authState is AuthLoading;

      if (isInitial) return null;

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, _) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/duas',
                builder: (_, _) => const MyDuasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/poems',
                builder: (_, _) => const MyPoemsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dua/:duaId',
        builder: (_, state) {
          final duaId = int.parse(state.pathParameters['duaId']!);
          final currentUser = state.extra as UserModel;
          return DuaDetailScreen(duaId: duaId, currentUser: currentUser);
        },
      ),
      GoRoute(
        path: '/poem/:poemId',
        builder: (_, state) {
          final poemId = int.parse(state.pathParameters['poemId']!);
          final currentUser = state.extra as UserModel;
          return PoemDetailScreen(poemId: poemId, currentUser: currentUser);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final userName = state.extra as String? ?? 'User';
          return UserDetailScreen(userId: userId, userName: userName);
        },
      ),
    ],
  );
}
