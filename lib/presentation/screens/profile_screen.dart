import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/services/dua_service.dart';
import '../../data/services/poem_service.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    try {
      final duas = await getIt<DuaService>().getUserDuas(user.id);
      final poems = await getIt<PoemService>().getUserPoems(user.id);
      if (mounted) {
        setState(() {
          _userDuas = duas;
          _userPoems = poems;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
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
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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
                  _buildDuas()
                else
                  _buildPoems(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailField(label: 'About', value: 'No bio yet'),
        const SizedBox(height: 12),
        _DetailField(label: 'Email', value: user.email),
        const SizedBox(height: 12),
        _DetailField(label: 'Role', value: user.role),
        const SizedBox(height: 12),
        _DetailField(label: 'Member since', value: user.joinedDate),
        const SizedBox(height: 12),
        _DetailField(label: 'Total contributions', value: '${_userDuas.length + _userPoems.length} posts'),
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
      children: _userDuas.map((d) => DuaCard(dua: d, currentUser: _currentUser())).toList(),
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
      children: _userPoems.map((p) => PoemCard(poem: p, currentUser: _currentUser())).toList(),
    );
  }

  UserModel _currentUser() {
    return (context.read<AuthBloc>().state as Authenticated).user;
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
