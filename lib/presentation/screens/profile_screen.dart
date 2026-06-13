import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../data/models/user_model.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/services/user_service.dart';
import '../../data/services/signalr_service.dart';
import '../../data/models/signalr/badge_awarded_model.dart';
import '../../data/models/signalr/badge_revoked_model.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/common/notification_bell.dart';
import '../widgets/common/badge_grid.dart';
import '../widgets/common/avatar_with_badge.dart';
import '../../core/enums/avatar_type.dart';
import '../../core/constants/app_avatars.dart';
import '../../app/dependency_injection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStatsModel? _stats;
  bool _loading = true;
  StreamSubscription<BadgeAwardedModel>? _badgeSub;
  StreamSubscription<BadgeRevokedModel>? _badgeRevokeSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _badgeSub = getIt<SignalRService>().onBadgeAwarded.listen((_) => _loadData());
    _badgeRevokeSub = getIt<SignalRService>().onBadgeRevoked.listen((_) => _loadData());
  }

  @override
  void dispose() {
    _badgeSub?.cancel();
    _badgeRevokeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    final user = authState.user;
    try {
      final stats = await getIt<UserService>().getStats(user.id);
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  AvatarType? _selectedAvatarType;
  String? _selectedAvatarValue;
  String? _selectedBadgeSlug;

  void _showEditProfileDialog(UserModel user) {
    _selectedAvatarType = user.avatarType;
    _selectedAvatarValue = user.avatarValue;
    _selectedBadgeSlug = user.selectedBadgeSlug;
    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final bioCtrl = TextEditingController(text: user.bio ?? '');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showAvatarPicker(ctx, setDialogState),
                child: AvatarWithBadge(
                  avatarType: _selectedAvatarType,
                  avatarValue: _selectedAvatarValue,
                  name: user.fullName,
                  showBadge: _selectedBadgeSlug != null,
                  size: 50,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showAvatarPicker(ctx, setDialogState),
                child: const Text('Change avatar', style: TextStyle(fontSize: 12, color: Color(0xFF7C9A6E))),
              ),
              if (_stats != null && _stats!.badges.isNotEmpty) ...[
                TextButton(
                  onPressed: () => _showBadgePicker(ctx, setDialogState),
                  child: Text(
                    _selectedBadgeSlug == null ? 'Add badge overlay' : 'Change badge overlay',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7C9A6E)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
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
                  context.read<AuthBloc>().add(UpdateProfileRequested(
                    fName,
                    lName,
                    bio: bioCtrl.text.trim(),
                    avatarType: _selectedAvatarType,
                    avatarValue: _selectedAvatarValue,
                    selectedBadgeSlug: _selectedBadgeSlug,
                  ));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext parentCtx, void Function(void Function()) setDialogState) {
    showModalBottomSheet(
      context: parentCtx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                if (_selectedAvatarType != null)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        _selectedAvatarType = null;
                        _selectedAvatarValue = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Remove', style: TextStyle(color: Color(0xFFC25A3F))),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: appAvatars.map((avatar) {
                final selected = _selectedAvatarType == AvatarType.icon && _selectedAvatarValue == avatar.id.toString();
                return GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      _selectedAvatarType = AvatarType.icon;
                      _selectedAvatarValue = avatar.id.toString();
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: selected ? avatar.color.withValues(alpha: 0.2) : const Color(0xFFF3F0EA),
                      borderRadius: BorderRadius.circular(16),
                      border: selected ? Border.all(color: avatar.color, width: 2.5) : Border.all(color: const Color(0xFFE8E2D8)),
                    ),
                    child: Icon(avatar.icon, color: selected ? avatar.color : const Color(0xFF9A8C79), size: 28),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBadgePicker(BuildContext parentCtx, void Function(void Function()) setDialogState) {
    final earned = _stats?.badges ?? [];
    showModalBottomSheet(
      context: parentCtx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Badge overlay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                if (_selectedBadgeSlug != null)
                  TextButton(
                    onPressed: () {
                      setDialogState(() => _selectedBadgeSlug = null);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Remove', style: TextStyle(color: Color(0xFFC25A3F))),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (earned.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No badges earned yet. Create content to earn badges.', style: TextStyle(color: Color(0xFF9A8C79))),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: earned.map((badge) {
                  final selected = _selectedBadgeSlug == badge.slug;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => _selectedBadgeSlug = badge.slug);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFDCE8D3) : const Color(0xFFF3F0EA),
                        borderRadius: BorderRadius.circular(12),
                        border: selected ? Border.all(color: const Color(0xFF7C9A6E), width: 2) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: selected ? const Color(0xFF4A5B3E) : const Color(0xFF9A8C79),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? const Color(0xFF3C3730) : const Color(0xFF6E6558),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select<AuthBloc, AuthState>((b) => b.state);
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
                    AvatarWithBadge(
                      avatarType: user.avatarType,
                      avatarValue: user.avatarValue,
                      name: user.fullName,
                      showBadge: user.selectedBadgeSlug != null,
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
                const SizedBox(height: 16),
                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ))
                else
                  _buildDetailsTab(user),
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
        _DetailField(label: 'Duas created', value: '${stats?.duasCreated ?? 0}'),
        const SizedBox(height: 12),
        _DetailField(label: 'Poems created', value: '${stats?.poemsCreated ?? 0}'),
        if (stats != null && stats.allBadges.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Badges', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9A8C79))),
          const SizedBox(height: 8),
          BadgeGrid(allBadges: stats.allBadges),
        ],
      ],
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
