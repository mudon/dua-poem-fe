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
  bool _loadingMoreDuas = false;
  bool _loadingMorePoems = false;
  String? _duaCursor;
  String? _poemCursor;
  bool _hasMoreDuas = true;
  bool _hasMorePoems = true;
  final ScrollController _duaScroll = ScrollController();
  final ScrollController _poemScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _duaScroll.addListener(_onDuaScroll);
    _poemScroll.addListener(_onPoemScroll);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _duaScroll.dispose();
    _poemScroll.dispose();
    super.dispose();
  }

  void _onDuaScroll() {
    if (_duaScroll.position.pixels >= _duaScroll.position.maxScrollExtent - 200
        && !_loadingMoreDuas && _hasMoreDuas) {
      _loadMoreDuas();
    }
  }

  void _onPoemScroll() {
    if (_poemScroll.position.pixels >= _poemScroll.position.maxScrollExtent - 200
        && !_loadingMorePoems && _hasMorePoems) {
      _loadMorePoems();
    }
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
        body: TabBarView(
            controller: _tabController,
            children: [
              _loadingDuas
                  ? const Center(child: CircularProgressIndicator())
                  : _favoriteDuas.isEmpty
                      ? const Center(child: Text('No favorited duas yet'))
                      : ListView.builder(
                          controller: _duaScroll,
                          itemCount: _favoriteDuas.length + (_hasMoreDuas ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == _favoriteDuas.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            return DuaCard(key: ValueKey(_favoriteDuas[i].id), dua: _favoriteDuas[i], currentUser: widget.currentUser ?? _emptyUser);
                          },
                        ),
              _loadingPoems
                  ? const Center(child: CircularProgressIndicator())
                  : _favoritePoems.isEmpty
                      ? const Center(child: Text('No favorited poems yet'))
                      : ListView.builder(
                          controller: _poemScroll,
                          itemCount: _favoritePoems.length + (_hasMorePoems ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == _favoritePoems.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            return PoemCard(key: ValueKey(_favoritePoems[i].id), poem: _favoritePoems[i], currentUser: widget.currentUser ?? _emptyUser);
                          },
                        ),
                      ],
          ),
      ),
    );
  }
}

