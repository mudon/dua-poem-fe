import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/repositories/poem_repository.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';

class FavoritesScreen extends StatefulWidget {
  final UserModel? currentUser;

  const FavoritesScreen({super.key, this.currentUser});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

UserModel _emptyUser = UserModel(id: '', firstName: '', lastName: '', email: '', createdAt: DateTime.now());

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DuaModel> _favoriteDuas = [];
  List<PoemModel> _favoritePoems = [];
  bool _loadingDuas = true;
  bool _loadingPoems = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        _favoriteDuas = result.data ?? [];
        _loadingDuas = false;
      });
    }
  }

  Future<void> _loadFavoritePoems() async {
    final repo = getIt<PoemRepository>();
    final result = await repo.getPoemFavorites();
    if (mounted) {
      setState(() {
        _favoritePoems = result.data ?? [];
        _loadingPoems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Duas'),
            Tab(text: 'Poems'),
          ],
          indicatorColor: const Color(0xFF7C9A6E),
          labelColor: const Color(0xFF7C9A6E),
          unselectedLabelColor: const Color(0xFF9D9080),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DuaBloc, DuaState>(
            listener: (context, state) {
              if (state.error != null) return;
              final id = state.lastToggledDuaId;
              if (id == null) return;
              final idx = _favoriteDuas.indexWhere((d) => d.id == id);
              if (state.actionType == 'like') {
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? _favoriteDuas[idx].likeCount;
                setState(() {
                  _favoriteDuas[idx] = _favoriteDuas[idx].copyWith(
                    isLiked: isNowLiked,
                    likeCount: newCount,
                  );
                });
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                if (isNowFav) {
                  if (idx == -1) {
                    getIt<DuaRepository>().getDuaDetail(id).then((result) {
                      if (result.isSuccess && mounted) {
                        setState(() => _favoriteDuas.insert(0, result.data!));
                      }
                    });
                  } else {
                    final newCount = state.bookmarkCounts[id] ?? _favoriteDuas[idx].bookmarkCount;
                    setState(() {
                      _favoriteDuas[idx] = _favoriteDuas[idx].copyWith(isFavorited: true, bookmarkCount: newCount);
                    });
                  }
                } else {
                  if (idx != -1) {
                    setState(() => _favoriteDuas.removeAt(idx));
                  }
                }
              } else if (state.actionType == 'signalr_view') {
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() {
                    _favoriteDuas[idx] = _favoriteDuas[idx].copyWith(views: newViews);
                  });
                }
              } else if (state.actionType == 'view') {
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() {
                    _favoriteDuas[idx] = _favoriteDuas[idx].copyWith(views: newViews);
                  });
                }
              } else if (state.actionType == 'report') {
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() {
                    _favoriteDuas[idx] = _favoriteDuas[idx].copyWith(reportCount: newCount);
                  });
                }
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (context, state) {
              if (state.error != null) return;
              final id = state.lastToggledPoemId;
              if (id == null) return;
              final idx = _favoritePoems.indexWhere((p) => p.id == id);
              if (state.actionType == 'like') {
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? _favoritePoems[idx].likeCount;
                setState(() {
                  _favoritePoems[idx] = _favoritePoems[idx].copyWith(
                    isLiked: isNowLiked,
                    likeCount: newCount,
                  );
                });
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                if (isNowFav) {
                  if (idx == -1) {
                    getIt<PoemRepository>().getPoemDetail(id).then((result) {
                      if (result.isSuccess && mounted) {
                        setState(() => _favoritePoems.insert(0, result.data!));
                      }
                    });
                  } else {
                    final newCount = state.bookmarkCounts[id] ?? _favoritePoems[idx].bookmarkCount;
                    setState(() {
                      _favoritePoems[idx] = _favoritePoems[idx].copyWith(isFavorited: true, bookmarkCount: newCount);
                    });
                  }
                } else {
                  if (idx != -1) {
                    setState(() => _favoritePoems.removeAt(idx));
                  }
                }
              } else if (state.actionType == 'signalr_view') {
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() {
                    _favoritePoems[idx] = _favoritePoems[idx].copyWith(views: newViews);
                  });
                }
              } else if (state.actionType == 'view') {
                if (idx == -1) return;
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() {
                    _favoritePoems[idx] = _favoritePoems[idx].copyWith(views: newViews);
                  });
                }
              } else if (state.actionType == 'report') {
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() {
                    _favoritePoems[idx] = _favoritePoems[idx].copyWith(reportCount: newCount);
                  });
                }
              }
            },
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [
            _loadingDuas
                ? const Center(child: CircularProgressIndicator())
                : _favoriteDuas.isEmpty
                    ? const Center(child: Text('No favorited duas yet'))
                    : ListView.builder(
                        itemCount: _favoriteDuas.length,
                        itemBuilder: (_, i) => DuaCard(key: ValueKey(_favoriteDuas[i].id), dua: _favoriteDuas[i], currentUser: widget.currentUser ?? _emptyUser),
                      ),
            _loadingPoems
                ? const Center(child: CircularProgressIndicator())
                : _favoritePoems.isEmpty
                    ? const Center(child: Text('No favorited poems yet'))
                    : ListView.builder(
                        itemCount: _favoritePoems.length,
                        itemBuilder: (_, i) => PoemCard(key: ValueKey(_favoritePoems[i].id), poem: _favoritePoems[i], currentUser: widget.currentUser ?? _emptyUser),
                      ),
          ],
        ),
      ),
    );
  }
}