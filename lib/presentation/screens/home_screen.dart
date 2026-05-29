import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../blocs/dua_bloc/dua_state.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
import '../blocs/poem_bloc/poem_bloc.dart';
import '../blocs/poem_bloc/poem_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../widgets/common/home_tab_bar.dart';
import '../widgets/forms/create_flow_sheet.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/repositories/poem_repository.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    return BlocProvider(
      create: (context) => HomeBloc(
        RepositoryProvider.of<DuaRepository>(context),
        RepositoryProvider.of<PoemRepository>(context),
      )..add(FetchLatestDuas())..add(FetchLatestPoems()),
      child: Builder(
        builder: (inner) => Scaffold(
          backgroundColor: const Color(0xFFF4F0E8),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.sage,
            onPressed: () => _showCreatePicker(inner),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SafeArea(
            child: Column(
                children: [
                  _HeaderBar(user: user),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<DuaBloc, DuaState>(
                            listener: (context, state) {
                              if (state.error != null) return;
                              final id = state.lastToggledDuaId;
                              if (id == null) return;
                              final homeState = context.read<HomeBloc>().state;
                              if (state.actionType == 'like') {
                                final idx = homeState.latestDuas.indexWhere((d) => d.id == id);
                                if (idx == -1) return;
                                final dua = homeState.latestDuas[idx];
                                final isNowLiked = state.likedStates[id] ?? false;
                                context.read<HomeBloc>().add(UpdateDua(
                                  duaId: id,
                                  isLiked: isNowLiked,
                                  likeCount: dua.likeCount + (isNowLiked ? 1 : -1),
                                ));
                              } else if (state.actionType == 'bookmark') {
                                final idx = homeState.latestDuas.indexWhere((d) => d.id == id);
                                if (idx == -1) return;
                                final dua = homeState.latestDuas[idx];
                                final isNowFav = state.favoritedStates[id] ?? false;
                                context.read<HomeBloc>().add(UpdateDua(
                                  duaId: id,
                                  isFavorited: isNowFav,
                                  bookmarkCount: dua.bookmarkCount + (isNowFav ? 1 : -1),
                                ));
                              }
                            },
                          ),
                          BlocListener<PoemBloc, PoemState>(
                            listener: (context, state) {
                              if (state.error != null) return;
                              final id = state.lastToggledPoemId;
                              if (id == null) return;
                              final homeState = context.read<HomeBloc>().state;
                              if (state.actionType == 'like') {
                                final idx = homeState.latestPoems.indexWhere((p) => p.id == id);
                                if (idx == -1) return;
                                final poem = homeState.latestPoems[idx];
                                final isNowLiked = state.likedStates[id] ?? false;
                                context.read<HomeBloc>().add(UpdatePoem(
                                  poemId: id,
                                  isLiked: isNowLiked,
                                  likeCount: poem.likeCount + (isNowLiked ? 1 : -1),
                                ));
                              } else if (state.actionType == 'bookmark') {
                                final idx = homeState.latestPoems.indexWhere((p) => p.id == id);
                                if (idx == -1) return;
                                final poem = homeState.latestPoems[idx];
                                final isNowFav = state.favoritedStates[id] ?? false;
                                context.read<HomeBloc>().add(UpdatePoem(
                                  poemId: id,
                                  isFavorited: isNowFav,
                                  bookmarkCount: poem.bookmarkCount + (isNowFav ? 1 : -1),
                                ));
                              }
                            },
                          ),
                        ],
                        child: Column(
                          children: [
                            const HomeTabBar(),
                            BlocBuilder<HomeBloc, HomeState>(
                              builder: (context, state) {
                                if (state.isLoading && !state.isSearching) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                                if (state.error != null && !state.isSearching && !state.isLoading) return Center(child: Text(state.error!));

                                if (state.isSearching) {
                                  if (state.isSearching && state.searchQuery.isNotEmpty && state.searchDuas.isEmpty && state.searchPoems.isEmpty) {
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
                                  return Column(
                                    children: state.showDuasTab
                                        ? state.searchDuas.map((d) => DuaCard(dua: d, currentUser: user)).toList()
                                        : state.searchPoems.map((p) => PoemCard(poem: p, currentUser: user)).toList(),
                                  );
                                }

                                return state.showDuasTab
                                    ? Column(
                                        children: state.latestDuas.map((d) => DuaCard(dua: d, currentUser: user)).toList(),
                                      )
                                    : Column(
                                        children: state.latestPoems.map((p) => PoemCard(poem: p, currentUser: user)).toList(),
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
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

void _showCreatePicker(BuildContext context) {
  final homeBloc = context.read<HomeBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CreateFlowSheet(
      onDuaCreated: () {
        homeBloc.add(FetchLatestDuas());
        homeBloc.add(FetchLatestPoems());
      },
      onPoemCreated: () {
        homeBloc.add(FetchLatestDuas());
        homeBloc.add(FetchLatestPoems());
      },
    ),
  );
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: const Icon(Icons.eco, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Row(
                    children: [
                      Text('nur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF3C4F34))),
                      Text('·deen', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20, color: AppTheme.earthBrown)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18, color: Color(0xFF5C5346)),
                  const SizedBox(width: 6),
                  const Text('As-salamu alaikum', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5C5346))),
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
