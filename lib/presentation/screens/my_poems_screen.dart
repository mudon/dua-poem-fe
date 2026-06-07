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
import '../widgets/common/notification_bell.dart';
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

class MyPoemsScreen extends StatefulWidget {
  const MyPoemsScreen({super.key});

  @override
  State<MyPoemsScreen> createState() => _MyPoemsScreenState();
}

class _MyPoemsScreenState extends State<MyPoemsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final homeState = context.read<HomeBloc>().state;
      if (!homeState.loadingMoreMyPoems && homeState.hasMoreMyPoems && homeState.myPoemsCursor != null) {
        context.read<HomeBloc>().add(FetchMoreMyPoems(
          userId: (context.read<AuthBloc>().state as Authenticated).user.id,
          cursor: homeState.myPoemsCursor!,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('My Poems', style: TextStyle(color: Color(0xFF3C4F34), fontWeight: FontWeight.w600)),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: NotificationBell())],
      ),
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
              } else if (state.actionType == 'content_updated') {
                final update = state.contentUpdates[id];
                if (update == null) return;
                ctx.read<HomeBloc>().add(UpdatePoem(
                  poemId: id,
                  title: update.title,
                  content: update.content,
                  transliteration: update.transliteration,
                  translation: update.translation,
                  description: update.description,
                  author: update.author,
                  updatedAt: update.updatedAt,
                ));
              } else if (state.actionType == 'deleted') {
                ctx.read<HomeBloc>().add(RemovePoem(id));
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
                                  controller: _scrollController,
                                  itemCount: poems.length + (state.hasMoreMyPoems ? 1 : 0),
                                  itemBuilder: (_, i) {
                                    if (i >= poems.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    }
                                    return PoemCard(key: ValueKey(poems[i].id), poem: poems[i], currentUser: user);
                                  },
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