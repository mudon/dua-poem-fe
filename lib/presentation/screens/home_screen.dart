import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/home_bloc/home_bloc.dart';
import '../blocs/home_bloc/home_event.dart';
import '../blocs/home_bloc/home_state.dart';
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
                      child: Column(
                        children: [
                          const HomeTabBar(),
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              if (state.isLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                              if (state.error != null) return Center(child: Text(state.error!));
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: const Color(0xFFEBE3D5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 18, color: Color(0xFFB9AA97)),
                SizedBox(width: 8),
                Expanded(child: Text('Search...', style: TextStyle(fontSize: 14, color: Color(0xFFB9AA97)))),
                Icon(Icons.tune, size: 18, color: Color(0xFFB9AA97)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
