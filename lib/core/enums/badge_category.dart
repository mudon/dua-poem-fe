import 'package:flutter/material.dart';

enum BadgeCategory {
  duas,
  poems,
  likes,
  views,
  streak,
  other;

  String get value => name;

  String get displayName {
    switch (this) {
      case BadgeCategory.duas:
        return 'Duas';
      case BadgeCategory.poems:
        return 'Poems';
      case BadgeCategory.likes:
        return 'Likes';
      case BadgeCategory.views:
        return 'Views';
      case BadgeCategory.streak:
        return 'Streak';
      case BadgeCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case BadgeCategory.duas:
        return Icons.menu_book_rounded;
      case BadgeCategory.poems:
        return Icons.auto_stories_rounded;
      case BadgeCategory.likes:
        return Icons.favorite_rounded;
      case BadgeCategory.views:
        return Icons.visibility_rounded;
      case BadgeCategory.streak:
        return Icons.local_fire_department_rounded;
      case BadgeCategory.other:
        return Icons.emoji_events_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BadgeCategory.duas:
        return const Color(0xFF4A7C59);
      case BadgeCategory.poems:
        return const Color(0xFF3A7CA5);
      case BadgeCategory.likes:
        return const Color(0xFFC25A6E);
      case BadgeCategory.views:
        return const Color(0xFFC48B3F);
      case BadgeCategory.streak:
        return const Color(0xFF7C5CA6);
      case BadgeCategory.other:
        return const Color(0xFF6E6558);
    }
  }

  static BadgeCategory fromSlugPrefix(String slug) {
    if (slug.startsWith('duas_')) return BadgeCategory.duas;
    if (slug.startsWith('poems_')) return BadgeCategory.poems;
    if (slug.startsWith('likes_')) return BadgeCategory.likes;
    if (slug.startsWith('views_')) return BadgeCategory.views;
    if (slug.startsWith('streak_')) return BadgeCategory.streak;
    return BadgeCategory.other;
  }

  static BadgeCategory fromDisplayName(String name) {
    return BadgeCategory.values.firstWhere(
      (e) => e.displayName == name,
      orElse: () => BadgeCategory.other,
    );
  }
}
