import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/enums/action_type.dart';
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
import '../widgets/forms/create_flow_sheet.dart';
import '../../app/dependency_injection.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
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
              if (state.actionType == ActionType.deleted) {
                final id = state.lastToggledDuaId;
                if (id != null) ctx.read<HomeBloc>().add(RemoveDua(id));
              }
              if (state.actionType == ActionType.created) {
                final dua = state.createdDua;
                if (dua != null) ctx.read<HomeBloc>().add(InsertDua(dua));
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (ctx, state) {
              if (state.error != null) return;
              if (state.actionType == ActionType.deleted) {
                final id = state.lastToggledPoemId;
                if (id != null) ctx.read<HomeBloc>().add(RemovePoem(id));
              }
              if (state.actionType == ActionType.created) {
                final poem = state.createdPoem;
                if (poem != null) ctx.read<HomeBloc>().add(InsertPoem(poem));
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F0E8),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.sage,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateFlowSheet(),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFCF7),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('My Posts', style: TextStyle(color: Color(0xFF3C4F34), fontWeight: FontWeight.w600)),
            actions: const [Padding(padding: EdgeInsets.only(right: 12), child: NotificationBell())],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  final showDuas = state.showMyPostsDuasTab;
                  final count = showDuas ? state.myDuas.length : state.myPoems.length;

                  return Column(
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
                            child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A5B3E))),
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
                        child: IndexedStack(
                          index: showDuas ? 0 : 1,
                          children: const [
                            _MyDuasFeed(),
                            _MyPoemsFeed(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
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

class _MyDuasFeed extends StatefulWidget {
  const _MyDuasFeed();

  @override
  State<_MyDuasFeed> createState() => _MyDuasFeedState();
}

class _MyDuasFeedState extends State<_MyDuasFeed> {
  final _scrollController = ScrollController();
  bool _showScrollTopButton = false;

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
    final homeBloc = context.read<HomeBloc>();
    if (!homeBloc.state.showMyPostsDuasTab) return;

    final showButton = _scrollController.position.pixels > 500;
    if (showButton != _showScrollTopButton) {
      setState(() => _showScrollTopButton = showButton);
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final homeState = homeBloc.state;
      if (!homeState.loadingMoreMyDuas && homeState.hasMoreMyDuas && homeState.myDuasCursor != null) {
        homeBloc.add(FetchMoreMyDuas(
          userId: (context.read<AuthBloc>().state as Authenticated).user.id,
          cursor: homeState.myDuasCursor!,
        ));
      }
    }
  }

  Future<void> _onRefresh() async {
    final homeBloc = context.read<HomeBloc>();
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    homeBloc.add(FetchMyDuas(user.id));
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return homeBloc.state.myDuasLoading;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    if (state.myDuasLoading && state.myDuas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (state.myDuas.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Text('No duas yet', style: const TextStyle(color: Color(0xFF9A8C79))),
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.myDuas.length + (state.hasMoreMyDuas ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= state.myDuas.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return DuaCard(key: ValueKey(state.myDuas[i].id), dua: state.myDuas[i], currentUser: user);
            },
          ),
        ),
        if (_showScrollTopButton)
          Positioned(
            right: 16,
            bottom: 88,
            child: FloatingActionButton.small(
              backgroundColor: AppTheme.sage,
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _MyPoemsFeed extends StatefulWidget {
  const _MyPoemsFeed();

  @override
  State<_MyPoemsFeed> createState() => _MyPoemsFeedState();
}

class _MyPoemsFeedState extends State<_MyPoemsFeed> {
  final _scrollController = ScrollController();
  bool _showScrollTopButton = false;

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
    final homeBloc = context.read<HomeBloc>();
    if (homeBloc.state.showMyPostsDuasTab) return;

    final showButton = _scrollController.position.pixels > 500;
    if (showButton != _showScrollTopButton) {
      setState(() => _showScrollTopButton = showButton);
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final homeState = homeBloc.state;
      if (!homeState.loadingMoreMyPoems && homeState.hasMoreMyPoems && homeState.myPoemsCursor != null) {
        homeBloc.add(FetchMoreMyPoems(
          userId: (context.read<AuthBloc>().state as Authenticated).user.id,
          cursor: homeState.myPoemsCursor!,
        ));
      }
    }
  }

  Future<void> _onRefresh() async {
    final homeBloc = context.read<HomeBloc>();
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    homeBloc.add(FetchMyPoems(user.id));
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return homeBloc.state.myPoemsLoading;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    if (state.myPoemsLoading && state.myPoems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (state.myPoems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Text('No poems yet', style: const TextStyle(color: Color(0xFF9A8C79))),
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.myPoems.length + (state.hasMoreMyPoems ? 1 : 0),
            itemBuilder: (_, i) {
              if (i >= state.myPoems.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return PoemCard(key: ValueKey(state.myPoems[i].id), poem: state.myPoems[i], currentUser: user);
            },
          ),
        ),
        if (_showScrollTopButton)
          Positioned(
            right: 16,
            bottom: 88,
            child: FloatingActionButton.small(
              backgroundColor: AppTheme.sage,
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
