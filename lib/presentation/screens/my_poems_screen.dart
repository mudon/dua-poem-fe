import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';
import '../widgets/forms/create_poem_sheet.dart';

void _showCreatePoemSheet(BuildContext context) {
  final homeBloc = context.read<HomeBloc>();
  final authState = context.read<AuthBloc>().state;
  if (authState is! Authenticated) return;
  final userId = authState.user.id;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CreatePoemSheet(
      onCreated: () => homeBloc.add(FetchMyPoems(userId)),
    ),
  );
}

class MyPoemsScreen extends StatelessWidget {
  const MyPoemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(FetchMyPoems(user.id)),
          child: BlocListener<PoemBloc, PoemState>(
            listener: (ctx, state) {
              if (state.error != null) return;
              final id = state.lastToggledPoemId;
              if (id == null) return;
              final homeState = ctx.read<HomeBloc>().state;
              if (state.actionType == 'like') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? homeState.myPoems[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdatePoem(
                  poemId: id,
                  isLiked: isNowLiked,
                  likeCount: newCount,
                ));
              } else if (state.actionType == 'bookmark') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final isNowFav = state.favoritedStates[id] ?? false;
                final newCount = state.bookmarkCounts[id] ?? homeState.myPoems[idx].bookmarkCount;
                ctx.read<HomeBloc>().add(UpdatePoem(
                  poemId: id,
                  isFavorited: isNowFav,
                  bookmarkCount: newCount,
                ));
              } else if (state.actionType == 'signalr_view') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, views: newViews));
                }
              } else if (state.actionType == 'view') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, views: newViews));
                }
              } else if (state.actionType == 'report') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, reportCount: newCount));
                }
              }
            },
            child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final poems = state.myPoems;
              final loading = state.myPoemsLoading;
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
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.sage, size: 26),
                          onPressed: () => _showCreatePoemSheet(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : poems.isEmpty
                              ? const Center(child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))))
                              : ListView.builder(
                                  itemCount: poems.length,
                                  itemBuilder: (_, i) => PoemCard(key: ValueKey(poems[i].id), poem: poems[i], currentUser: user),
                                ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}

