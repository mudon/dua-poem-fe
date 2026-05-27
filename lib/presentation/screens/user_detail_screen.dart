import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_profiles.dart';
import '../../data/models/user_model.dart';
import '../../data/models/dua_model.dart';
import '../../data/models/poem_model.dart';
import '../../data/services/dua_service.dart';
import '../../data/services/poem_service.dart';
import '../../core/themes/app_theme.dart';
import '../blocs/dua_bloc/dua_bloc.dart';
import '../widgets/common/dua_card.dart';
import '../widgets/common/poem_card.dart';
import '../../app/dependency_injection.dart';

class UserDetailScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const UserDetailScreen({super.key, required this.userName, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int _selectedTab = 0;
  StoredUser? _user;
  List<DuaModel> _userDuas = [];
  List<PoemModel> _userPoems = [];

  @override
  void initState() {
    super.initState();
    _user = findUser(widget.userId);
    _loadData();
  }

  void _loadData() async {
    final duaService = getIt<DuaService>();
    final poemService = getIt<PoemService>();
    final duas = await duaService.getUserDuas(widget.userId);
    final poems = await poemService.getUserPoems(widget.userId);
    if (mounted) {
      setState(() {
        _userDuas = duas;
        _userPoems = poems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => getIt<DuaBloc>(),
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
                              user?.avatar ?? (widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?'),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                if (user?.bio != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(user!.bio, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6558))),
                                  ),
                                if (user?.joined != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9A8C79)),
                                        const SizedBox(width: 4),
                                        Text(user!.joined, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8C79))),
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
                          _UserTab(label: 'Details', isActive: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                          const SizedBox(width: 16),
                          _UserTab(label: 'Duas (${_userDuas.length})', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                          const SizedBox(width: 16),
                          _UserTab(label: 'Poems (${_userPoems.length})', isActive: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_selectedTab == 0)
                        _buildDetails(user)
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
      ),
    );
  }

  Widget _buildDetails(StoredUser? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UserDetailField(label: 'About', value: user?.bio ?? 'No bio'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Member since', value: user?.joined ?? 'Unknown'),
        const SizedBox(height: 12),
        _UserDetailField(label: 'Total contributions', value: '${_userDuas.length + _userPoems.length} posts'),
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
    final user = _user;
    return UserModel(
      id: (user?.id ?? widget.userId).toString(),
      name: user?.name ?? widget.userName,
      email: '',
      avatar: user?.avatar,
      bio: user?.bio,
      createdAt: DateTime.now(),
      joinedDate: user?.joined ?? '',
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
