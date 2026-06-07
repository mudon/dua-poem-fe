import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../widgets/common/notification_bell.dart';
import '../../app/dependency_injection.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final ScrollController _duaScrollController = ScrollController();
  final ScrollController _poemScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _duaScrollController.addListener(_onDuaScroll);
    _poemScrollController.addListener(_onPoemScroll);
  }

  @override
  void dispose() {
    _duaScrollController.removeListener(_onDuaScroll);
    _poemScrollController.removeListener(_onPoemScroll);
    _duaScrollController.dispose();
    _poemScrollController.dispose();
    super.dispose();
  }

  void _onDuaScroll() {
    if (_duaScrollController.position.pixels >= _duaScrollController.position.maxScrollExtent - 200) {
      final homeState = context.read<HomeBloc>().state;
      if (!homeState.loadingMoreMyDuas && homeState.hasMoreMyDuas && homeState.myDuasCursor != null) {
        context.read<HomeBloc>().add(FetchMoreMyDuas(
          userId: (context.read<AuthBloc>().state as Authenticated).user.id,
          cursor: homeState.myDuasCursor!,
        ));
      }
    }
  }

  void _onPoemScroll() {
    if (_poemScrollController.position.pixels >= _poemScrollController.position.maxScrollExtent - 200) {
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

    return BlocProvider(
      create: (_) => getIt<HomeBloc>()
        ..add(FetchMyDuas(user.id))
        ..add(FetchMyPoems(user.id)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<DuaBloc, DuaState>(
            listener: (ctx, state) {
              if (state.error != null) return;
              final id = state.lastToggledDuaId;
              if (id == null) return;
              final homeState = ctx.read<HomeBloc>().state;
              if (state.actionType == 'signalr_like') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newCount = state.likeCounts[id] ?? homeState.myDuas[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdateDua(duaId: id, likeCount: newCount));
              } else if (state.actionType == 'like') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? homeState.myDuas[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdateDua(
                  duaId: id,
                  isLiked: isNowLiked,
                  likeCount: newCount,
                ));
              } else if (state.actionType == 'signalr_bookmark') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newCount = state.bookmarkCounts[id] ?? homeState.myDuas[idx].bookmarkCount;
                ctx.read<HomeBloc>().add(UpdateDua(duaId: id, bookmarkCount: newCount));
              } else if (state.actionType == 'bookmark') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final isNowFav = state.favoritedStates[id] ?? false;
                final newCount = state.bookmarkCounts[id] ?? homeState.myDuas[idx].bookmarkCount;
                ctx.read<HomeBloc>().add(UpdateDua(
                  duaId: id,
                  isFavorited: isNowFav,
                  bookmarkCount: newCount,
                ));
              } else if (state.actionType == 'signalr_view') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  ctx.read<HomeBloc>().add(UpdateDua(duaId: id, views: newViews));
                }
              } else if (state.actionType == 'view') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  ctx.read<HomeBloc>().add(UpdateDua(duaId: id, views: newViews));
                }
              } else if (state.actionType == 'signalr_report') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  ctx.read<HomeBloc>().add(UpdateDua(duaId: id, reportCount: newCount));
                }
              } else if (state.actionType == 'report') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  ctx.read<HomeBloc>().add(UpdateDua(duaId: id, reportCount: newCount));
                }
              } else if (state.actionType == 'content_updated') {
                final update = state.contentUpdates[id];
                if (update == null) return;
                ctx.read<HomeBloc>().add(UpdateDua(
                  duaId: id,
                  title: update.title,
                  arabicText: update.arabicText,
                  transliteration: update.transliteration,
                  translation: update.translation,
                  description: update.description,
                  whenToRecite: update.whenToRecite,
                  occasion: update.occasion,
                  repetitionCount: update.repetitionCount,
                  updatedAt: update.updatedAt,
                ));
              } else if (state.actionType == 'deleted') {
                ctx.read<HomeBloc>().add(RemoveDua(id));
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (ctx, state) {
              if (state.error != null) return;
              final id = state.lastToggledPoemId;
              if (id == null) return;
              final homeState = ctx.read<HomeBloc>().state;
              if (state.actionType == 'signalr_like') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newCount = state.likeCounts[id] ?? homeState.myPoems[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, likeCount: newCount));
              } else if (state.actionType == 'like') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? homeState.myPoems[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdatePoem(
                  poemId: id,
                  isLiked: isNowLiked,
                  likeCount: newCount,
                ));
              } else if (state.actionType == 'signalr_bookmark') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newCount = state.bookmarkCounts[id] ?? homeState.myPoems[idx].bookmarkCount;
                ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, bookmarkCount: newCount));
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
              } else if (state.actionType == 'signalr_report') {
                final idx = homeState.myPoems.indexWhere((p) => p.id == id);
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  ctx.read<HomeBloc>().add(UpdatePoem(poemId: id, reportCount: newCount));
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
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F0E8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFCF7),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('My Posts', style: TextStyle(color: Color(0xFF3C4F34), fontWeight: FontWeight.w600)),
            actions: const [Padding(padding: EdgeInsets.only(right: 12), child: NotificationBell())],
          ),
          body: SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final duas = state.myDuas;
                final poems = state.myPoems;
                final showDuas = state.showMyPostsDuasTab;
                final loading = showDuas ? state.myDuasLoading : state.myPoemsLoading;
                final items = showDuas ? duas : poems;
                final hasMore = showDuas ? state.hasMoreMyDuas : state.hasMoreMyPoems;
                final scrollController = showDuas ? _duaScrollController : _poemScrollController;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(showDuas ? Icons.book : Icons.auto_stories, color: AppTheme.sage, size: 22),
                          const SizedBox(width: 8),
                          Text(showDuas ? 'My Duas' : 'My Poems', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.sageMist,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Text('${items.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A5B3E))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE2D9CF))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _MyPostsTabItem(
                              label: 'My Duas',
                              isActive: showDuas,
                              onTap: () => context.read<HomeBloc>().add(ToggleMyPostsTab(true)),
                            ),
                            const SizedBox(width: 24),
                            _MyPostsTabItem(
                              label: 'My Poems',
                              isActive: !showDuas,
                              onTap: () => context.read<HomeBloc>().add(ToggleMyPostsTab(false)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : items.isEmpty
                                ? Center(
                                    child: Text(
                                      showDuas ? 'No duas yet' : 'No poems yet',
                                      style: const TextStyle(color: Color(0xFF9A8C79)),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: items.length + (hasMore ? 1 : 0),
                                    itemBuilder: (_, i) {
                                      if (i >= items.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        );
                                      }
                                      if (showDuas) {
                                        return DuaCard(key: ValueKey(duas[i].id), dua: duas[i], currentUser: user);
                                      } else {
                                        return PoemCard(key: ValueKey(poems[i].id), poem: poems[i], currentUser: user);
                                      }
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

class _MyPostsTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MyPostsTabItem({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.sage : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.sage : const Color(0xFF9A8C79),
          ),
        ),
      ),
    );
  }
}
