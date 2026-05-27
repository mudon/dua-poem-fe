import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class CreatePickerSheet extends StatelessWidget {
  const CreatePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F0E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.warmGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create New',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.earthBrown),
          ),
          const SizedBox(height: 16),
          _OptionRow(
            icon: Icons.book,
            label: 'New Dua',
            onTap: () => Navigator.of(context).pop('dua'),
          ),
          const SizedBox(height: 8),
          _OptionRow(
            icon: Icons.auto_stories,
            label: 'New Poem',
            onTap: () => Navigator.of(context).pop('poem'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppTheme.softCream,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.sage, size: 28),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppTheme.earthBrown)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
