import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../../app/dependency_injection.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<DuaBloc>()),
        BlocProvider.value(value: getIt<PoemBloc>()),
      ],
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEAE2D6))),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFFEFCF7),
            selectedItemColor: AppTheme.sage,
            unselectedItemColor: const Color(0xFF9D9080),
            currentIndex: navigationShell.currentIndex,
            onTap: (i) => navigationShell.goBranch(i),
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Duas'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_stories_outlined), activeIcon: Icon(Icons.auto_stories), label: 'Poems'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Favorites'),
            ],
          ),
        ),
      ),
    );
  }
}
