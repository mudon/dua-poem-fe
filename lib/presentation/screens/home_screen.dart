import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/action_type.dart';
import '../widgets/forms/create_flow_sheet.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
import '../blocs/dua_feed_bloc/dua_feed_bloc.dart';
import '../blocs/dua_feed_bloc/dua_feed_event.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/poem_feed_bloc/poem_feed_bloc.dart';
import '../blocs/poem_feed_bloc/poem_feed_event.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../widgets/common/home_tab_bar.dart';
import '../widgets/common/coffee_button.dart';
import '../widgets/common/notification_bell.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/repositories/poem_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    return BlocProvider(
      create: (context) => HomeBloc(
        RepositoryProvider.of<DuaRepository>(context),
        RepositoryProvider.of<PoemRepository>(context),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.sageMist,
          statusBarIconBrightness: Brightness.dark,
        ),
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
        body: SafeArea(
          child: Column(
            children: [
              _HeaderBar(user: user),
              const HomeTabBar(),
              const Expanded(child: _HomeFeed()),
            ],
          ),
        ),
      ),
      ),
    );
  }
}


class _HomeFeed extends StatefulWidget {
  const _HomeFeed();

  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  final _searchDuasScrollController = ItemScrollController();
  final _searchDuasPositionsListener = ItemPositionsListener.create();
  final _searchPoemsScrollController = ItemScrollController();
  final _searchPoemsPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _searchDuasPositionsListener.itemPositions.addListener(_onSearchDuasPositionsChanged);
    _searchPoemsPositionsListener.itemPositions.addListener(_onSearchPoemsPositionsChanged);
  }

  @override
  void dispose() {
    _searchDuasPositionsListener.itemPositions.removeListener(_onSearchDuasPositionsChanged);
    _searchPoemsPositionsListener.itemPositions.removeListener(_onSearchPoemsPositionsChanged);
    super.dispose();
  }

  void _onSearchDuasPositionsChanged() {
    final homeBloc = context.read<HomeBloc>();
    final s = homeBloc.state;
    if (!s.isSearching || !s.showDuasTab) return;
    final positions = _searchDuasPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final last = positions.map((p) => p.index).reduce(max);
    if (s.isSearchLoading || s.loadingMoreSearch) return;
    if (last >= s.searchDuas.length - 2 && s.hasMoreSearchDuas) {
      homeBloc.add(FetchMoreSearchResults(query: s.searchQuery, showDuasTab: true));
    }
  }

  void _onSearchPoemsPositionsChanged() {
    final homeBloc = context.read<HomeBloc>();
    final s = homeBloc.state;
    if (!s.isSearching || s.showDuasTab) return;
    final positions = _searchPoemsPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final last = positions.map((p) => p.index).reduce(max);
    if (s.isSearchLoading || s.loadingMoreSearch) return;
    if (last >= s.searchPoems.length - 2 && s.hasMoreSearchPoems) {
      homeBloc.add(FetchMoreSearchResults(query: s.searchQuery, showDuasTab: false));
    }
  }

  Future<void> _onSearchRefresh() async {
    context.read<HomeBloc>().add(ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DuaFeedBloc(
            RepositoryProvider.of<DuaRepository>(context),
          )..add(FetchLatestDuas()),
        ),
        BlocProvider(
          create: (context) => PoemFeedBloc(
            RepositoryProvider.of<PoemRepository>(context),
          )..add(FetchLatestPoems()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DuaBloc, DuaState>(
            listener: (ctx, state) {
              if (state.actionType == ActionType.created && state.createdDua != null) {
                ctx.read<DuaFeedBloc>().add(InsertDuaToFeed(state.createdDua!));
              }
              if (state.actionType == ActionType.deleted && state.lastToggledDuaId != null) {
                ctx.read<DuaFeedBloc>().add(RemoveDuaFromFeed(state.lastToggledDuaId!));
              }
            },
          ),
          BlocListener<PoemBloc, PoemState>(
            listener: (ctx, state) {
              if (state.actionType == ActionType.created && state.createdPoem != null) {
                ctx.read<PoemFeedBloc>().add(InsertPoemToFeed(state.createdPoem!));
              }
              if (state.actionType == ActionType.deleted && state.lastToggledPoemId != null) {
                ctx.read<PoemFeedBloc>().add(RemovePoemFromFeed(state.lastToggledPoemId!));
              }
            },
          ),
        ],
        child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.isSearching) {
            if (state.isSearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.searchQuery.isNotEmpty && state.showDuasTab && state.searchDuas.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No results found')),
              );
            }
            if (state.searchQuery.isNotEmpty && !state.showDuasTab && state.searchPoems.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No results found')),
              );
            }
            return IndexedStack(
              index: state.showDuasTab ? 0 : 1,
              children: [
                RefreshIndicator(
                  onRefresh: _onSearchRefresh,
                  child: ScrollablePositionedList.builder(
                    key: const ValueKey('search_duas_feed'),
                    itemScrollController: _searchDuasScrollController,
                    itemPositionsListener: _searchDuasPositionsListener,
                    itemCount: state.searchDuas.length + (state.loadingMoreSearch ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.searchDuas.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final authState = context.watch<AuthBloc>().state;
                      if (authState is! Authenticated) return const SizedBox.shrink();
                      return DuaCard(key: ValueKey(state.searchDuas[index].id), dua: state.searchDuas[index], currentUser: authState.user);
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _onSearchRefresh,
                  child: ScrollablePositionedList.builder(
                    key: const ValueKey('search_poems_feed'),
                    itemScrollController: _searchPoemsScrollController,
                    itemPositionsListener: _searchPoemsPositionsListener,
                    itemCount: state.searchPoems.length + (state.loadingMoreSearch ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.searchPoems.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final authState = context.read<AuthBloc>().state;
                      if (authState is! Authenticated) return const SizedBox.shrink();
                      return PoemCard(key: ValueKey(state.searchPoems[index].id), poem: state.searchPoems[index], currentUser: authState.user);
                    },
                  ),
                ),
              ],
            );
          }

          return IndexedStack(
            index: state.showDuasTab ? 0 : 1,
            children: const [
              _DuaFeed(),
              _PoemFeed(),
            ],
          );
        },
      ),
      ),
    );
  }
}


class _DuaFeed extends StatefulWidget {
  const _DuaFeed();

  @override
  State<_DuaFeed> createState() => _DuaFeedState();
}

class _DuaFeedState extends State<_DuaFeed> {
  final _scrollController = ItemScrollController();
  final _positionsListener = ItemPositionsListener.create();

  int _lastTriggeredOlderIndex = -1;
  bool _showScrollTopButton = false;

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final homeBloc = context.read<HomeBloc>();
    if (!homeBloc.state.showDuasTab) return;
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions.map((p) => p.index).reduce(min);
    final last = positions.map((p) => p.index).reduce(max);
    final bloc = context.read<DuaFeedBloc>();
    final s = bloc.state;

    final showButton = first > 5;
    if (showButton != _showScrollTopButton && mounted) {
      setState(() => _showScrollTopButton = showButton);
    }

    debugPrint('[DUA_FEED] visible=[$first..$last] '
        'cache=[0..${s.windowDuas.length - 1}](${s.windowDuas.length}) total=${s.totalLoadedDuas} '
        'older=${s.hasMoreOlderDuas}/${s.loadingOlderDuas}');

    if (s.windowDuas.isNotEmpty) {
      final cacheBottom = s.windowDuas.length - 1;
      if (last >= cacheBottom && s.hasMoreOlderDuas && !s.loadingOlderDuas && last != _lastTriggeredOlderIndex) {
        _lastTriggeredOlderIndex = last;
        debugPrint('[DUA_FEED_TRIGGER] fetching older, last=$last, cacheBottom=$cacheBottom');
        bloc.add(FetchOlderDuas());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(ClearSearch());
    final bloc = context.read<DuaFeedBloc>();
    bloc.add(ResetDuas());
    await bloc.stream.firstWhere((s) => !s.isLoading);
    _lastTriggeredOlderIndex = -1;
    _scrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 1));
    setState(() => _showScrollTopButton = false);
  }

  Future<void> _scrollToTop() async {
    context.read<HomeBloc>().add(ClearSearch());
    final bloc = context.read<DuaFeedBloc>();
    bloc.add(ResetDuas());
    await bloc.stream.firstWhere((s) => !s.isLoading);
    _lastTriggeredOlderIndex = -1;
    _scrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 400));
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DuaFeedBloc>().state;

    if (state.isLoading && state.windowDuas.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    final olderLoading = state.loadingOlderDuas ? 1 : 0;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemCount: state.windowDuas.length + olderLoading,
            itemBuilder: (context, index) {
              if (olderLoading > 0 && index == state.windowDuas.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final authState = context.read<AuthBloc>().state;
              if (authState is! Authenticated) return const SizedBox.shrink();
              return DuaCard(key: ValueKey(state.windowDuas[index].id), dua: state.windowDuas[index], currentUser: authState.user);
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


class _PoemFeed extends StatefulWidget {
  const _PoemFeed();

  @override
  State<_PoemFeed> createState() => _PoemFeedState();
}

class _PoemFeedState extends State<_PoemFeed> {
  final _scrollController = ItemScrollController();
  final _positionsListener = ItemPositionsListener.create();

  int _lastTriggeredOlderIndex = -1;
  bool _showScrollTopButton = false;

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final homeBloc = context.read<HomeBloc>();
    if (homeBloc.state.showDuasTab) return;
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions.map((p) => p.index).reduce(min);
    final last = positions.map((p) => p.index).reduce(max);
    final bloc = context.read<PoemFeedBloc>();
    final s = bloc.state;

    final showButton = first > 5;
    if (showButton != _showScrollTopButton && mounted) {
      setState(() => _showScrollTopButton = showButton);
    }

    debugPrint('[POEM_FEED] visible=[$first..$last] '
        'cache=[0..${s.windowPoems.length - 1}](${s.windowPoems.length}) total=${s.totalLoadedPoems} '
        'older=${s.hasMoreOlderPoems}/${s.loadingOlderPoems}');

    if (s.windowPoems.isNotEmpty) {
      final cacheBottom = s.windowPoems.length - 1;
      if (last >= cacheBottom && s.hasMoreOlderPoems && !s.loadingOlderPoems && last != _lastTriggeredOlderIndex) {
        _lastTriggeredOlderIndex = last;
        debugPrint('[POEM_FEED_TRIGGER] fetching older, last=$last, cacheBottom=$cacheBottom');
        bloc.add(FetchOlderPoems());
      }
    }
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(ClearSearch());
    final bloc = context.read<PoemFeedBloc>();
    bloc.add(ResetPoems());
    await bloc.stream.firstWhere((s) => !s.isLoading);
    _lastTriggeredOlderIndex = -1;
    _scrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 1));
    setState(() => _showScrollTopButton = false);
  }

  Future<void> _scrollToTop() async {
    context.read<HomeBloc>().add(ClearSearch());
    final bloc = context.read<PoemFeedBloc>();
    bloc.add(ResetPoems());
    await bloc.stream.firstWhere((s) => !s.isLoading);
    _lastTriggeredOlderIndex = -1;
    _scrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 400));
    setState(() => _showScrollTopButton = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PoemFeedBloc>().state;

    if (state.isLoading && state.windowPoems.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    final olderLoading = state.loadingOlderPoems ? 1 : 0;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemCount: state.windowPoems.length + olderLoading,
            itemBuilder: (context, index) {
              if (olderLoading > 0 && index == state.windowPoems.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final authState = context.read<AuthBloc>().state;
              if (authState is! Authenticated) return const SizedBox.shrink();
              return PoemCard(key: ValueKey(state.windowPoems[index].id), poem: state.windowPoems[index], currentUser: authState.user);
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


class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();
  bool _isActive = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFEBE3D5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Color(0xFFB9AA97)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onTap: () => setState(() => _isActive = true),
              onSubmitted: (value) {
                context.read<HomeBloc>().add(SearchRequested(value));
              },
              onChanged: (value) {
                if (value.isEmpty && _isActive) {
                  context.read<HomeBloc>().add(ClearSearch());
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB9AA97)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF3C4F34)),
            ),
          ),
          if (_isActive)
            GestureDetector(
              onTap: () {
                _controller.clear();
                context.read<HomeBloc>().add(ClearSearch());
                setState(() => _isActive = false);
              },
              child: const Icon(Icons.close, size: 18, color: Color(0xFFB9AA97)),
            )
          else
            const Icon(Icons.tune, size: 18, color: Color(0xFFB9AA97)),
        ],
      ),
    );
  }
}


class _HeaderBar extends StatelessWidget {
  final dynamic user;

  const _HeaderBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.sageMist,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppTheme.sage,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SvgPicture.asset('assets/appImages/teduh.svg',
                        width: 38, height: 38, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(AppStrings.appName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF3C4F34))),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 18, color: Color(0xFF5C5346)),
                      SizedBox(width: 6),
                      Text('Assalamualaikum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5C5346))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoffeeButton(),
                      const SizedBox(width: 16),
                      const NotificationBell(),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SearchBar(),
        ],
      ),
    );
  }
}
