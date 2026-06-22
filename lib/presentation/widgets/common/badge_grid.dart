import 'package:flutter/material.dart';
import '../../../core/enums/badge_category.dart';
import '../../../data/models/user_stats_model.dart';

class BadgeGrid extends StatelessWidget {
  final List<CatalogBadgeModel> allBadges;

  const BadgeGrid({super.key, required this.allBadges});

  static const _categories = BadgeCategory.values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in _categories)
          _BadgeSection(
            category: category,
            badges: allBadges.where((b) => b.badgeCategory == category).toList(),
          ),
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  final BadgeCategory category;
  final List<CatalogBadgeModel> badges;

  const _BadgeSection({required this.category, required this.badges});

  IconData get _icon => category.icon;

  Color get _color => category.color;

  @override
  Widget build(BuildContext context) {
    final earned = badges.where((b) => b.isEarned).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 16, color: _color),
              const SizedBox(width: 6),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$earned/${badges.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((b) => _BadgeTile(badge: b, color: _color)).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final CatalogBadgeModel badge;
  final Color color;

  const _BadgeTile({required this.badge, required this.color});

  Color get _badgeColor {
    if (badge.color != null) {
      return Color(int.parse(badge.color!.replaceFirst('#', '0xFF')));
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final isEarned = badge.isEarned;
    final tileColor = _badgeColor;
    final bgColor = isEarned ? tileColor.withValues(alpha: 0.1) : const Color(0xFFF3F0EA);
    final fgColor = isEarned ? tileColor : const Color(0xFFB5A99A);
    final borderColor = isEarned ? tileColor.withValues(alpha: 0.3) : const Color(0xFFE8E2D8);

    return Container(
      width: 92,
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isEarned ? 1.5 : 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEarned ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
            size: 18,
            color: fgColor,
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isEarned ? FontWeight.w700 : FontWeight.w500,
              color: isEarned ? const Color(0xFF3C3730) : const Color(0xFF9A8C79),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          if (badge.description != null)
            Text(
              badge.description!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: isEarned ? const Color(0xFF6E6558) : const Color(0xFFB5A99A),
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}
