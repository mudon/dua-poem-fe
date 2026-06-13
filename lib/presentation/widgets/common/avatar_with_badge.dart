import 'package:flutter/material.dart';
import '../../../core/constants/app_avatars.dart';
import '../../../core/enums/avatar_type.dart';

class AvatarWithBadge extends StatelessWidget {
  final AvatarType? avatarType;
  final String? avatarValue;
  final String name;
  final bool showBadge;
  final double size;

  const AvatarWithBadge({
    super.key,
    this.avatarType,
    this.avatarValue,
    required this.name,
    this.showBadge = false,
    this.size = 35,
  });

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (fullName.isNotEmpty) return fullName[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size;
    final badgeRadius = radius * 0.4;

    final appAvatar = avatarType == AvatarType.icon
        ? findAvatarById(avatarValue)
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: appAvatar?.color.withValues(alpha: 0.15) ?? const Color(0xFFDCE8D3),
          child: appAvatar != null
              ? Icon(appAvatar.icon, size: radius * 0.7, color: appAvatar.color)
              : Text(
                  _getInitials(name),
                  style: TextStyle(
                    fontSize: radius * 0.7,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A5B3E),
                  ),
                ),
        ),
        if (showBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeRadius * 2,
              height: badgeRadius * 2,
              decoration: BoxDecoration(
                color: const Color(0xFF7C9A6E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: badgeRadius,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
