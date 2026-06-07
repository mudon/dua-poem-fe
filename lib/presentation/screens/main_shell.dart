import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/notification_bloc/notification_bloc.dart';
import '../blocs/notification_bloc/notification_event.dart';
import '../../app/dependency_injection.dart';

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    getIt<NotificationBloc>().add(LoadNotifications(refresh: true));
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is Authenticated && authState.user.role == 'admin';

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'My Posts'),
      const BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), activeIcon: Icon(Icons.emoji_events), label: 'Top'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      const BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Favorites'),
    ];

    if (isAdmin) {
      items.add(
        const BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Admin'),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<DuaBloc>()),
        BlocProvider.value(value: getIt<PoemBloc>()),
        BlocProvider.value(value: getIt<NotificationBloc>()),
      ],
        child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEAE2D6))),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFFEFCF7),
            selectedItemColor: AppTheme.sage,
            unselectedItemColor: const Color(0xFF9D9080),
            currentIndex: widget.navigationShell.currentIndex,
            onTap: (i) => widget.navigationShell.goBranch(i),
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: _buildNavItems(),
          ),
        ),
      ),
    );
  }
}
