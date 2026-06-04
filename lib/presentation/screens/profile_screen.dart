import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/repositories/dua_repository.dart';
import '../../data/repositories/poem_repository.dart';
import '../../data/services/user_service.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../widgets/common/notification_bell.dart';
import '../../app/dependency_injection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  List<DuaModel> _userDuas = [];
  List<PoemModel> _userPoems = [];
  UserStatsModel? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final user = authState.user;
    try {
      final stats = await getIt<UserService>().getStats(user.id);
      final duasResult = await getIt<DuaRepository>().getUserDuas(user.id);
      final duas = duasResult.isSuccess ? duasResult.data! : <DuaModel>[];
      final poemsResult = await getIt<PoemRepository>().getUserPoems(user.id);
      final poems = poemsResult.isSuccess ? poemsResult.data! : <PoemModel>[];
      if (mounted) {
        setState(() {
          _stats = stats;
          _userDuas = duas;
          _userPoems = poems;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEditProfileDialog(UserModel user) {
    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final bioCtrl = TextEditingController(text: user.bio ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'First name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Last name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final fName = firstNameCtrl.text.trim();
              final lName = lastNameCtrl.text.trim();
              if (fName.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(UpdateProfileRequested(fName, lName, bio: bioCtrl.text.trim()));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Profile', style: TextStyle(color: Color(0xFF3C4F34), fontWeight: FontWeight.w600)),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: NotificationBell())],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
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
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                              ),
                              GestureDetector(
                                onTap: () => _showEditProfileDialog(user),
                                child: const Icon(Icons.edit, size: 18, color: Color(0xFF9A8C79)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6558))),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9A8C79)),
                                const SizedBox(width: 4),
                                Text(user.joinedDate, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8C79))),
                              ],
                            ),
                          ),
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
                    _ProfileTab(label: 'Details', isActive: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                    const SizedBox(width: 16),
                    _ProfileTab(label: 'Duas (${_userDuas.length})', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                    const SizedBox(width: 16),
                    _ProfileTab(label: 'Poems (${_userPoems.length})', isActive: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ))
                else if (_selectedTab == 0)
                  _buildDetailsTab(user)
                else if (_selectedTab == 1)
                  _buildDuas(user)
                else
                  _buildPoems(user),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFF0EAE0)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF1EC),
                      foregroundColor: const Color(0xFFC25A3F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildDetailsTab(UserModel user) {
    final stats = _stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailField(label: 'About', value: user.bio?.isNotEmpty == true ? user.bio! : 'No bio yet'),
        const SizedBox(height: 12),
        _DetailField(label: 'Email', value: user.email),
        const SizedBox(height: 12),
        _DetailField(label: 'Role', value: user.role),
        const SizedBox(height: 12),
        _DetailField(label: 'Member since', value: user.joinedDate),
        const SizedBox(height: 12),
        _DetailField(label: 'Duas created', value: '${stats?.duasCreated ?? _userDuas.length}'),
        const SizedBox(height: 12),
        _DetailField(label: 'Poems created', value: '${stats?.poemsCreated ?? _userPoems.length}'),
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

  Widget _buildDuas(UserModel user) {
    if (_userDuas.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No duas yet', style: TextStyle(color: Color(0xFF9A8C79))),
      ));
    }
    return Column(
      children: _userDuas.map((d) => DuaCard(dua: d, currentUser: user)).toList(),
    );
  }

  Widget _buildPoems(UserModel user) {
    if (_userPoems.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))),
      ));
    }
    return Column(
      children: _userPoems.map((p) => PoemCard(poem: p, currentUser: user)).toList(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileTab({required this.label, required this.isActive, required this.onTap});

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

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  const _DetailField({required this.label, required this.value});

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
