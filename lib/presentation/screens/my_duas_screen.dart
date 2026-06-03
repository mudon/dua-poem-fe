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
import '../widgets/common/dua_card.dart';
import '../../app/dependency_injection.dart';
import '../widgets/forms/create_dua_sheet.dart';

void _showCreateDuaSheet(BuildContext context) {
  final homeBloc = context.read<HomeBloc>();
  final authState = context.read<AuthBloc>().state;
  if (authState is! Authenticated) return;
  final userId = authState.user.id;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CreateDuaSheet(
      onCreated: () => homeBloc.add(FetchMyDuas(userId)),
    ),
  );
}

class MyDuasScreen extends StatelessWidget {
  const MyDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(FetchMyDuas(user.id)),
          child: BlocListener<DuaBloc, DuaState>(
            listener: (ctx, state) {
              if (state.error != null) return;
              final id = state.lastToggledDuaId;
              if (id == null) return;
              final homeState = ctx.read<HomeBloc>().state;
              if (state.actionType == 'like') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final isNowLiked = state.likedStates[id] ?? false;
                final newCount = state.likeCounts[id] ?? homeState.myDuas[idx].likeCount;
                ctx.read<HomeBloc>().add(UpdateDua(
                  duaId: id,
                  isLiked: isNowLiked,
                  likeCount: newCount,
                ));
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
              } else if (state.actionType == 'report') {
                final idx = homeState.myDuas.indexWhere((d) => d.id == id);
                if (idx == -1) return;
                final newCount = state.reportCounts[id];
                if (newCount != null) {
                  ctx.read<HomeBloc>().add(UpdateDua(duaId: id, reportCount: newCount));
                }
              }
            },
            child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final duas = state.myDuas;
              final loading = state.myDuasLoading;
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
                            const Icon(Icons.book, color: AppTheme.sage, size: 22),
                            const SizedBox(width: 8),
                            const Text('My Duas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF4A5B3E))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.sageMist,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text('${duas.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A5B3E))),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.sage, size: 26),
                          onPressed: () => _showCreateDuaSheet(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : duas.isEmpty
                              ? const Center(child: Text('No duas yet', style: TextStyle(color: Color(0xFF9A8C79))))
                              : ListView.builder(
                                  itemCount: duas.length,
                                  itemBuilder: (_, i) => DuaCard(key: ValueKey(duas[i].id), dua: duas[i], currentUser: user),
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

