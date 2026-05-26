import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';

class MyPoemsScreen extends StatelessWidget {
  final UserModel user;
  const MyPoemsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(FetchLatestPoems()),
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final poems = state.latestPoems.where((p) => p.userId == user.id).toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, color: AppTheme.sage, size: 22),
                            const SizedBox(width: 8),
                            const Text('My Poems', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.sageMist,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text('${poems.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A5B3E))),
                            ),
                          ],
                        ),
                        const Icon(Icons.add_circle_outline, color: AppTheme.sage, size: 26),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : poems.isEmpty
                              ? const Center(child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))))
                              : ListView.builder(
                                  itemCount: poems.length,
                                  itemBuilder: (_, i) => PoemCard(poem: poems[i], currentUser: user),
                                ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
