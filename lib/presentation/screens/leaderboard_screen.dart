import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/dependency_injection.dart';
import '../../core/themes/app_theme.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/services/leaderboard_service.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../data/models/signalr/leaderboard_update_model.dart';
import '../../data/services/signalr_service.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../../data/models/user_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _duas = [];
  List<LeaderboardEntry> _poems = [];
  bool _isLoading = true;
  StreamSubscription<List<LeaderboardUpdateModel>>? _leaderboardSub;

  static const double _rowHeight = 52.0;

  @override
  void initState() {
    super.initState();
    _fetch();
    _leaderboardSub = getIt<SignalRService>().onLeaderboardUpdated.listen((entries) {
      _onLeaderboardUpdate(entries);
    });
  }

  @override
  void dispose() {
    _leaderboardSub?.cancel();
    super.dispose();
  }

  void _onLeaderboardUpdate(List<LeaderboardUpdateModel> entries) {
    setState(() {
      _duas = entries
          .where((e) => e.type == 'dua')
          .map((e) => LeaderboardEntry(id: e.id, title: e.title, likesCount: e.likesCount, type: e.type))
          .toList();
      _poems = entries
          .where((e) => e.type == 'poem')
          .map((e) => LeaderboardEntry(id: e.id, title: e.title, likesCount: e.likesCount, type: e.type))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final repo = LeaderboardRepository(getIt<LeaderboardService>());
    final result = await repo.getTopLiked(count: 10);
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      setState(() {
        _duas = result.data!['duas']!;
        _poems = result.data!['poems']!;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    void onItemTap(LeaderboardEntry entry) {
      if (currentUser == null) return;
      final route = entry.type == 'dua' ? '/dua/${entry.id}' : '/poem/${entry.id}';
      context.push(route, extra: currentUser);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF4F0E8),
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _SectionHeader(label: 'Top Duas', icon: Icons.menu_book_rounded),
                  const SizedBox(height: 4),
                  _AnimatedLeaderList(
                    items: _duas,
                    rowHeight: _rowHeight,
                    onItemTap: onItemTap,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(label: 'Top Poems', icon: Icons.auto_stories_rounded),
                  const SizedBox(height: 4),
                  _AnimatedLeaderList(
                    items: _poems,
                    rowHeight: _rowHeight,
                    onItemTap: onItemTap,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.sage),
          const SizedBox(width: 8),
          Text(label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C3730),
            )),
        ],
      ),
    );
  }
}

class _AnimatedLeaderList extends StatelessWidget {
  final List<LeaderboardEntry> items;
  final double rowHeight;
  final void Function(LeaderboardEntry entry)? onItemTap;

  const _AnimatedLeaderList({
    required this.items,
    required this.rowHeight,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No entries yet', style: TextStyle(color: Color(0xFF9A8C79))),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE3D5)),
        ),
        height: items.length * rowHeight,
        child: Stack(
          children: items.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: entry.key * rowHeight,
              left: 0,
              right: 0,
              height: rowHeight,
              child: _LeaderboardRow(
                key: ValueKey(entry.value.id),
                entry: entry.value,
                rank: rank,
                onTap: onItemTap,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final void Function(LeaderboardEntry entry)? onTap;

  const _LeaderboardRow({
    super.key,
    required this.entry,
    required this.rank,
    this.onTap,
  });

  String get _rankDisplay {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank.';
  }

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFD4A843);
    if (rank == 2) return const Color(0xFF9EA5B4);
    if (rank == 3) return const Color(0xFFCD7F5E);
    return const Color(0xFFAB9F8E);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(entry) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: rank <= 3 ? const Color(0xFFFFFCF5) : Colors.white,
          border: Border(bottom: BorderSide(color: const Color(0xFFF0EAE0), width: 0.5)),
        ),
        child: Row(
        children: [
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(_rankDisplay, style: const TextStyle(fontSize: 16))
                : Text(_rankDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _rankColor,
                    )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3C3730),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 14, color: Color(0xFFD6B17E)),
              const SizedBox(width: 4),
              Text(
                formatCount(entry.likesCount),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD6B17E),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  String formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
