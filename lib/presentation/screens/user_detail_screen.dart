import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/services/user_service.dart';
import '../../data/repositories/dua_repository.dart';
import '../widgets/common/badge_grid.dart';
import '../../data/repositories/poem_repository.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';

class UserDetailScreen extends StatefulWidget {
  final String userDisplayName;
  final String userId;

  const UserDetailScreen({super.key, required this.userDisplayName, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _selectedTab = 0;

  UserModel? _profile;
  UserStatsModel? _stats;
  bool _loading = true;

  List<DuaModel> _userDuas = [];
  String? _duaCursor;
  bool _hasMoreDuas = true;
  bool _loadingDuas = false;

  List<PoemModel> _userPoems = [];
  String? _poemCursor;
  bool _hasMorePoems = true;
  bool _loadingPoems = false;

  final ScrollController _duaScrollController = ScrollController();
  final ScrollController _poemScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
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
      if (!_loadingDuas && _hasMoreDuas && _duaCursor != null) {
        _loadMoreDuas();
      }
    }
  }

  void _onPoemScroll() {
    if (_poemScrollController.position.pixels >= _poemScrollController.position.maxScrollExtent - 200) {
      if (!_loadingPoems && _hasMorePoems && _poemCursor != null) {
        _loadMorePoems();
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final userData = await getIt<UserService>().getUserById(widget.userId);
      final profile = UserModel.fromJson(userData);
      final stats = await getIt<UserService>().getStats(widget.userId);

      final duasResult = await getIt<DuaRepository>().getUserDuas(widget.userId);
      final poemsResult = await getIt<PoemRepository>().getUserPoems(widget.userId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;

          if (duasResult.isSuccess) {
            final paged = duasResult.data!;
            _userDuas = paged.data.map((d) => d.copyWith(
              userName: profile.fullName,
              userAvatar: profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?',
            )).toList();
            _duaCursor = paged.nextCursor;
            _hasMoreDuas = paged.hasMore;
          }

          if (poemsResult.isSuccess) {
            final paged = poemsResult.data!;
            _userPoems = paged.data.map((p) => p.copyWith(
              userName: profile.fullName,
              userAvatar: profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?',
            )).toList();
            _poemCursor = paged.nextCursor;
            _hasMorePoems = paged.hasMore;
          }

          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMoreDuas() async {
    if (_loadingDuas || !_hasMoreDuas || _duaCursor == null) return;
    setState(() => _loadingDuas = true);
    final result = await getIt<DuaRepository>().getUserDuas(widget.userId, cursor: _duaCursor);
    if (mounted && result.isSuccess) {
      final paged = result.data!;
      setState(() {
        _userDuas.addAll(paged.data.map((d) => d.copyWith(
          userName: _profile?.fullName ?? widget.userDisplayName,
          userAvatar: _profile?.firstName.isNotEmpty == true ? _profile!.firstName[0].toUpperCase() : '?',
        )));
        _duaCursor = paged.nextCursor;
        _hasMoreDuas = paged.hasMore;
        _loadingDuas = false;
      });
    } else {
      if (mounted) setState(() => _loadingDuas = false);
    }
  }

  Future<void> _loadMorePoems() async {
    if (_loadingPoems || !_hasMorePoems || _poemCursor == null) return;
    setState(() => _loadingPoems = true);
    final result = await getIt<PoemRepository>().getUserPoems(widget.userId, cursor: _poemCursor);
    if (mounted && result.isSuccess) {
      final paged = result.data!;
      setState(() {
        _userPoems.addAll(paged.data.map((p) => p.copyWith(
          userName: _profile?.fullName ?? widget.userDisplayName,
          userAvatar: _profile?.firstName.isNotEmpty == true ? _profile!.firstName[0].toUpperCase() : '?',
        )));
        _poemCursor = paged.nextCursor;
        _hasMorePoems = paged.hasMore;
        _loadingPoems = false;
      });
    } else {
      if (mounted) setState(() => _loadingPoems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.fullName ?? widget.userDisplayName;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final currentUser = authState.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<DuaBloc>()),
        BlocProvider.value(value: getIt<PoemBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DuaBloc, DuaState>(
            listener: (context, state) {
              if (state.error != null) return;
              final id = state.lastToggledDuaId;
              if (id == null) return;
              final idx = _userDuas.indexWhere((d) => d.id == id);
              if (idx == -1) return;
              final d = _userDuas[idx];
              if (state.actionType == 'signalr_like') {
                final newCount = state.likeCounts[id];
                if (newCount != null) {
                  setState(() => _userDuas[idx] = d.copyWith(likeCount: newCount));
                }
              } else if (state.actionType == 'like') {
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? d.likeCount;
                setState(() {
                  _userDuas[idx] = d.copyWith(
                    isLiked: isNowLiked,
                    likeCount: newCount,
                  );
                });
              } else if (state.actionType == 'signalr_bookmark') {
                final newCount = state.bookmarkCounts[id];
                if (newCount != null) {
                  setState(() => _userDuas[idx] = d.copyWith(bookmarkCount: newCount));
                }
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                final newCount = state.bookmarkCounts[id] ?? d.bookmarkCount;
                setState(() {
                  _userDuas[idx] = d.copyWith(
                    isFavorited: isNowFav,
                    bookmarkCount: newCount,
                  );
                });
              } else if (state.actionType == 'signalr_view') {
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() => _userDuas[idx] = d.copyWith(views: newViews));
                }
              } else if (state.actionType == 'view') {
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() => _userDuas[idx] = d.copyWith(views: newViews));
                }
              } else if (state.actionType == 'signalr_report') {
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() => _userDuas[idx] = d.copyWith(reportCount: newCount));
                }
              } else if (state.actionType == 'report') {
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() => _userDuas[idx] = d.copyWith(reportCount: newCount));
                }
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (context, state) {
              if (state.error != null) return;
              final id = state.lastToggledPoemId;
              if (id == null) return;
              final idx = _userPoems.indexWhere((p) => p.id == id);
              if (idx == -1) return;
              final p = _userPoems[idx];
              if (state.actionType == 'signalr_like') {
                final newCount = state.likeCounts[id];
                if (newCount != null) {
                  setState(() => _userPoems[idx] = p.copyWith(likeCount: newCount));
                }
              } else if (state.actionType == 'like') {
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? p.likeCount;
                setState(() {
                  _userPoems[idx] = p.copyWith(
                    isLiked: isNowLiked,
                    likeCount: newCount,
                  );
                });
              } else if (state.actionType == 'signalr_bookmark') {
                final newCount = state.bookmarkCounts[id];
                if (newCount != null) {
                  setState(() => _userPoems[idx] = p.copyWith(bookmarkCount: newCount));
                }
              } else if (state.actionType == 'bookmark') {
                final isNowFav = state.favoritedStates[id] ?? false;
                final newCount = state.bookmarkCounts[id] ?? p.bookmarkCount;
                setState(() {
                  _userPoems[idx] = p.copyWith(
                    isFavorited: isNowFav,
                    bookmarkCount: newCount,
                  );
                });
              } else if (state.actionType == 'signalr_view') {
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() => _userPoems[idx] = p.copyWith(views: newViews));
                }
              } else if (state.actionType == 'view') {
                final newViews = state.viewCounts[id];
                if (newViews != null) {
                  setState(() => _userPoems[idx] = p.copyWith(views: newViews));
                }
              } else if (state.actionType == 'signalr_report') {
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() => _userPoems[idx] = p.copyWith(reportCount: newCount));
                }
              } else if (state.actionType == 'report') {
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  setState(() => _userPoems[idx] = p.copyWith(reportCount: newCount));
                }
              }
            },
          ),
        ],
        child: Scaffold(
        backgroundColor: const Color(0xFFF4F0E8),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, color: AppTheme.sage, size: 20),
                            SizedBox(width: 8),
                            Text('Back', style: TextStyle(color: AppTheme.sage, fontWeight: FontWeight.w500, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFFDCE8D3),
                                child: Text(
                                  _profile?.firstName.isNotEmpty == true
                                      ? _profile!.firstName[0].toUpperCase()
                                      : (name.isNotEmpty ? name[0].toUpperCase() : '?'),
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: const Color(0xFFF0EAE0)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _UserTab(label: 'Details', isActive: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                              const SizedBox(width: 16),
                              _UserTab(label: 'Duas (${_stats?.duasCreated ?? _userDuas.length})', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                              const SizedBox(width: 16),
                              _UserTab(label: 'Poems (${_stats?.poemsCreated ?? _userPoems.length})', isActive: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _selectedTab == 0
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildDetails(),
                            )
                          : _selectedTab == 1
                              ? _buildDuasList(currentUser)
                              : _buildPoemsList(currentUser),
                    ),
                  ],
                ),
        ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final stats = _stats;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserDetailField(label: 'About', value: _profile?.bio?.isNotEmpty == true ? _profile!.bio! : 'No bio'),
          const SizedBox(height: 12),
          _UserDetailField(label: 'Role', value: _profile?.role ?? 'user'),
          const SizedBox(height: 12),
          _UserDetailField(label: 'Member since', value: _profile?.joinedDate ?? 'Unknown'),
          const SizedBox(height: 12),
          _UserDetailField(label: 'Duas created', value: '${stats?.duasCreated ?? _userDuas.length}'),
          const SizedBox(height: 12),
          _UserDetailField(label: 'Poems created', value: '${stats?.poemsCreated ?? _userPoems.length}'),
          if (stats != null && stats.allBadges.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Badges', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
            const SizedBox(height: 8),
            BadgeGrid(allBadges: stats.allBadges),
          ],
        ],
      ),
    );
  }

  Widget _buildDuasList(UserModel currentUser) {
    if (_userDuas.isEmpty) {
      return const Center(child: Text('No duas yet', style: TextStyle(color: Color(0xFF9A8C79))));
    }
    return ListView.builder(
      controller: _duaScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _userDuas.length + (_hasMoreDuas ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= _userDuas.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DuaCard(dua: _userDuas[i], currentUser: currentUser),
        );
      },
    );
  }

  Widget _buildPoemsList(UserModel currentUser) {
    if (_userPoems.isEmpty) {
      return const Center(child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))));
    }
    return ListView.builder(
      controller: _poemScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _userPoems.length + (_hasMorePoems ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= _userPoems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PoemCard(poem: _userPoems[i], currentUser: currentUser),
        );
      },
    );
  }
}

class _UserTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _UserTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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

class _UserDetailField extends StatelessWidget {
  final String label;
  final String value;
  const _UserDetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF3C3730))),
      ],
    );
  }
}