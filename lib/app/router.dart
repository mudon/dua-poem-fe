import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../presentation/blocs/auth_bloc/auth_state.dart';
import '../presentation/screens/auth_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/my_posts_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/main_shell.dart';
import '../presentation/screens/favorites_screen.dart';
import '../presentation/screens/dua_detail_screen.dart';
import '../presentation/screens/poem_detail_screen.dart';
import '../presentation/screens/user_detail_screen.dart';
import '../presentation/screens/admin/admin_screen.dart';
import '../presentation/screens/admin/revision_review_screen.dart';
import '../presentation/screens/leaderboard_screen.dart';
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
                path: '/my-posts',
                builder: (_, _) => const MyPostsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (_, _) => const LeaderboardScreen(),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (_, state) {
                  final authState = authBloc.state;
                  final user = authState is Authenticated ? authState.user : null;
                  return FavoritesScreen(currentUser: user);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (_, _) => const AdminScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin/revision',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return RevisionReviewScreen(
            revisionId: extra['revisionId'] ?? '',
            contentType: extra['contentType'] ?? '',
            contentTitle: extra['contentTitle'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/dua/:duaId',
        builder: (_, state) {
          final duaId = state.pathParameters['duaId']!;
          final currentUser = state.extra as UserModel;
          return DuaDetailScreen(duaId: duaId, currentUser: currentUser);
        },
      ),
      GoRoute(
        path: '/poem/:poemId',
        builder: (_, state) {
          final poemId = state.pathParameters['poemId']!;
          final currentUser = state.extra as UserModel;
          return PoemDetailScreen(poemId: poemId, currentUser: currentUser);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) {
          final userId = state.pathParameters['userId']!;
          final userDisplayName = state.extra as String? ?? 'User';
          return UserDetailScreen(userId: userId, userDisplayName: userDisplayName);
        },
      ),
    ],
  );
}
