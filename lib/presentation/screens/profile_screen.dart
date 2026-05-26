import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../core/themes/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
                        widget.user.avatar ?? (widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?'),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4A5B3E)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                          if (widget.user.bio != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(widget.user.bio!, style: const TextStyle(fontSize: 13, color: Color(0xFF6E6558))),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF9A8C79)),
                                const SizedBox(width: 4),
                                Text(widget.user.joinedDate, style: const TextStyle(fontSize: 12, color: Color(0xFF9A8C79))),
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
                    _ProfileTab(label: 'Duas (0)', isActive: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                    const SizedBox(width: 16),
                    _ProfileTab(label: 'Poems (0)', isActive: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedTab == 0)
                  _buildDetailsTab()
                else if (_selectedTab == 1)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No duas yet', style: TextStyle(color: Color(0xFF9A8C79))),
                  ))
                else
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No poems yet', style: TextStyle(color: Color(0xFF9A8C79))),
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailField(label: 'About', value: widget.user.bio ?? 'No bio yet'),
        const SizedBox(height: 12),
        _DetailField(label: 'Member since', value: widget.user.joinedDate),
        const SizedBox(height: 12),
        _DetailField(label: 'Total contributions', value: '0 posts'),
      ],
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
