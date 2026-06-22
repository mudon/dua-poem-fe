import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/enums/action_type.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/repositories/poem_repository.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../widgets/common/notification_bell.dart';
import '../../app/dependency_injection.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../../core/themes/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  final UserModel? currentUser;

  const FavoritesScreen({super.key, this.currentUser});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

UserModel _emptyUser = UserModel(id: '', firstName: '', lastName: '', email: '', createdAt: DateTime.now());

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _showDuasTab = true;

  List<DuaModel> _favoriteDuas = [];
  List<PoemModel> _favoritePoems = [];
  bool _loadingDuas = true;
  bool _loadingPoems = true;
  bool _loadingMoreDuas = false;
  bool _loadingMorePoems = false;
  String? _duaCursor;
  String? _poemCursor;
  bool _hasMoreDuas = true;
  bool _hasMorePoems = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await Future.wait([
      _loadFavoriteDuas(),
      _loadFavoritePoems(),
    ]);
  }

  Future<void> _loadFavoriteDuas() async {
    final repo = getIt<DuaRepository>();
    final result = await repo.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteDuas = result.data?.data ?? [];
        _duaCursor = result.data?.nextCursor;
        _hasMoreDuas = result.data?.hasMore ?? false;
        _loadingDuas = false;
      });
    }
  }

  Future<void> _loadFavoritePoems() async {
    final repo = getIt<PoemRepository>();
    final result = await repo.getPoemFavorites();
    if (mounted) {
      setState(() {
        _favoritePoems = result.data?.data ?? [];
        _poemCursor = result.data?.nextCursor;
        _hasMorePoems = result.data?.hasMore ?? false;
        _loadingPoems = false;
      });
    }
  }

  Future<void> _loadMoreDuas() async {
    if (_loadingMoreDuas || !_hasMoreDuas || _duaCursor == null) return;
    setState(() => _loadingMoreDuas = true);
    final repo = getIt<DuaRepository>();
    final result = await repo.getFavorites(cursor: _duaCursor);
    if (mounted) {
      setState(() {
        _favoriteDuas.addAll(result.data?.data ?? []);
        _duaCursor = result.data?.nextCursor;
        _hasMoreDuas = result.data?.hasMore ?? false;
        _loadingMoreDuas = false;
      });
    }
  }

  Future<void> _loadMorePoems() async {
    if (_loadingMorePoems || !_hasMorePoems || _poemCursor == null) return;
    setState(() => _loadingMorePoems = true);
    final repo = getIt<PoemRepository>();
    final result = await repo.getPoemFavorites(cursor: _poemCursor);
    if (mounted) {
      setState(() {
        _favoritePoems.addAll(result.data?.data ?? []);
        _poemCursor = result.data?.nextCursor;
        _hasMorePoems = result.data?.hasMore ?? false;
        _loadingMorePoems = false;
      });
    }
  }

  Future<void> _onRefresh() => _loadFavorites();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DuaBloc, DuaState>(
          listenWhen: (_, current) => current.actionType == ActionType.bookmark && current.error == null,
          listener: (context, state) {
            final id = state.lastToggledDuaId;
            if (id != null && state.favoritedStates[id] == false) {
              setState(() => _favoriteDuas.removeWhere((d) => d.id == id));
            }
          },
        ),
        BlocListener<PoemBloc, PoemState>(
          listenWhen: (_, current) => current.actionType == ActionType.bookmark && current.error == null,
          listener: (context, state) {
            final id = state.lastToggledPoemId;
            if (id != null && state.favoritedStates[id] == false) {
              setState(() => _favoritePoems.removeWhere((p) => p.id == id));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          automaticallyImplyLeading: false,
          actions: const [Padding(padding: EdgeInsets.only(right: 12), child: NotificationBell())],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FavTabItem(
                      label: 'Duas (${_favoriteDuas.length})',
                      isActive: _showDuasTab,
                      onTap: () => setState(() => _showDuasTab = true),
                    ),
                    const SizedBox(width: 24),
                    _FavTabItem(
                      label: 'Poems (${_favoritePoems.length})',
                      isActive: !_showDuasTab,
                      onTap: () => setState(() => _showDuasTab = false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE2D9CF)),
                const SizedBox(height: 8),
                Expanded(
                  child: IndexedStack(
                    index: _showDuasTab ? 0 : 1,
                    children: [
                      _FavDuasList(
                        isActive: _showDuasTab,
                        duas: _favoriteDuas,
                        hasMore: _hasMoreDuas,
                        loading: _loadingDuas,
                        loadingMore: _loadingMoreDuas,
                        currentUser: widget.currentUser ?? _emptyUser,
                        onRefresh: _onRefresh,
                        onLoadMore: _loadMoreDuas,
                      ),
                      _FavPoemsList(
                        isActive: !_showDuasTab,
                        poems: _favoritePoems,
                        hasMore: _hasMorePoems,
                        loading: _loadingPoems,
                        loadingMore: _loadingMorePoems,
                        currentUser: widget.currentUser ?? _emptyUser,
                        onRefresh: _onRefresh,
                        onLoadMore: _loadMorePoems,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FavTabItem({required this.label, required this.isActive, required this.onTap});

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

class _FavDuasList extends StatefulWidget {
  final bool isActive;
  final List<DuaModel> duas;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final UserModel currentUser;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _FavDuasList({
    required this.isActive,
    required this.duas,
    required this.hasMore,
    required this.loading,
    required this.loadingMore,
    required this.currentUser,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  State<_FavDuasList> createState() => _FavDuasListState();
}

class _FavDuasListState extends State<_FavDuasList> {
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
    if (!widget.isActive) return;

    final showButton = _scrollController.position.pixels > 500;
    if (showButton != _showScrollTopButton) {
      setState(() => _showScrollTopButton = showButton);
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!widget.loadingMore && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && widget.duas.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (widget.duas.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const Center(child: Text('No favorited duas yet')),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.duas.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == widget.duas.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return DuaCard(key: ValueKey(widget.duas[i].id), dua: widget.duas[i], currentUser: widget.currentUser);
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

class _FavPoemsList extends StatefulWidget {
  final bool isActive;
  final List<PoemModel> poems;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final UserModel currentUser;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _FavPoemsList({
    required this.isActive,
    required this.poems,
    required this.hasMore,
    required this.loading,
    required this.loadingMore,
    required this.currentUser,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  State<_FavPoemsList> createState() => _FavPoemsListState();
}

class _FavPoemsListState extends State<_FavPoemsList> {
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
    if (!widget.isActive) return;

    final showButton = _scrollController.position.pixels > 500;
    if (showButton != _showScrollTopButton) {
      setState(() => _showScrollTopButton = showButton);
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!widget.loadingMore && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && widget.poems.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ),
      );
    }

    if (widget.poems.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const Center(child: Text('No favorited poems yet')),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.poems.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == widget.poems.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return PoemCard(key: ValueKey(widget.poems[i].id), poem: widget.poems[i], currentUser: widget.currentUser);
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
