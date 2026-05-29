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

UserModel _emptyUser = UserModel(id: '', name: '', email: '', createdAt: DateTime.now());

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
              if (idx == -1) return;
              final d = _favoriteDuas[idx];
              if (state.actionType == 'like') {
                final isNowLiked = state.likedStates[id] ?? false;
                setState(() {
                  _favoriteDuas[idx] = d.copyWith(
                    isLiked: isNowLiked,
                    likeCount: d.likeCount + (isNowLiked ? 1 : -1),
                  );
                });
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                setState(() {
                  _favoriteDuas[idx] = d.copyWith(
                    isFavorited: isNowFav,
                    bookmarkCount: d.bookmarkCount + (isNowFav ? 1 : -1),
                  );
                });
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (context, state) {
              if (state.error != null) return;
              final id = state.lastToggledPoemId;
              if (id == null) return;
              final idx = _favoritePoems.indexWhere((p) => p.id == id);
              if (idx == -1) return;
              final p = _favoritePoems[idx];
              if (state.actionType == 'like') {
                final isNowLiked = state.likedStates[id] ?? false;
                setState(() {
                  _favoritePoems[idx] = p.copyWith(
                    isLiked: isNowLiked,
                    likeCount: p.likeCount + (isNowLiked ? 1 : -1),
                  );
                });
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                setState(() {
                  _favoritePoems[idx] = p.copyWith(
                    isFavorited: isNowFav,
                    bookmarkCount: p.bookmarkCount + (isNowFav ? 1 : -1),
                  );
                });
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
                        itemBuilder: (_, i) => DuaCard(dua: _favoriteDuas[i], currentUser: widget.currentUser ?? _emptyUser),
                      ),
            _loadingPoems
                ? const Center(child: CircularProgressIndicator())
                : _favoritePoems.isEmpty
                    ? const Center(child: Text('No favorited poems yet'))
                    : ListView.builder(
                        itemCount: _favoritePoems.length,
                        itemBuilder: (_, i) => PoemCard(poem: _favoritePoems[i], currentUser: widget.currentUser ?? _emptyUser),
                      ),
          ],
        ),
      ),
    );
  }
}