import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/services/user_service.dart';
import '../../data/services/dua_service.dart';
import '../../data/services/poem_service.dart';
import '../../core/themes/app_theme.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';

class UserDetailScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const UserDetailScreen({super.key, required this.userName, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _selectedTab = 0;
  List<DuaModel> _userDuas = [];
  List<PoemModel> _userPoems = [];
  UserModel? _profile;
  UserStatsModel? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await getIt<UserService>().getUserById(widget.userId);
      final profile = UserModel.fromJson(userData);
      final stats = await getIt<UserService>().getStats(widget.userId);

      final duas = await getIt<DuaService>().getUserDuas(widget.userId);
      final poems = await getIt<PoemService>().getUserPoems(widget.userId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _userDuas = duas.map((d) => d.copyWith(
            userName: profile.name,
            userAvatar: profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
          )).toList();
          _userPoems = poems.map((p) => p.copyWith(
            userName: profile.name,
            userAvatar: profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
          )).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.name ?? widget.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppTheme.sage, size: 20),
                    SizedBox(width: 8),
                    Text('Back', style: TextStyle(color: AppTheme.sage, fontWeight: FontWeight.w500, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                            ],
                          ),
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
                        _UserTab(label: 'Duas (${_userDuas.length})', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                        const SizedBox(width: 16),
                        _UserTab(label: 'Poems (${_userPoems.length})', isActive: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_selectedTab == 0)
                      _buildDetails()
                    else if (_selectedTab == 1)
                      _buildDuas()
                    else
                      _buildPoems(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final stats = _stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserDetailField(label: 'About', value: 'No bio'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Role', value: _profile?.role ?? 'user'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Member since', value: _profile?.joinedDate ?? 'Unknown'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Duas created', value: '${stats?.duasCreated ?? _userDuas.length}'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Poems created', value: '${stats?.poemsCreated ?? _userPoems.length}'),
        if (stats != null && stats.badges.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Badges', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stats.badges.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8D3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(b.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A5B3E))),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDuas() {
    if (_userDuas.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No duas yet', style: TextStyle(color: Color(0xFF9A8C79))),
      ));
    }
    return Column(
      children: _userDuas.map((d) => DuaCard(dua: d, currentUser: _toUserModel())).toList(),
    );
  }

  Widget _buildPoems() {
    if (_userPoems.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))),
      ));
    }
    return Column(
      children: _userPoems.map((p) => PoemCard(poem: p, currentUser: _toUserModel())).toList(),
    );
  }

  UserModel _toUserModel() {
    if (_profile != null) return _profile!;
    return UserModel(
      id: widget.userId,
      name: widget.userName,
      email: '',
      createdAt: DateTime.now(),
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
