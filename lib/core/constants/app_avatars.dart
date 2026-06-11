import 'package:flutter/material.dart';

class AppAvatar {
  final int id;
  final IconData icon;
  final String name;
  final Color color;

  const AppAvatar(this.id, this.icon, this.name, this.color);
}

const List<AppAvatar> appAvatars = [
  AppAvatar(1, Icons.person, 'Person', Color(0xFF7C9A6E)),
  AppAvatar(2, Icons.face, 'Face', Color(0xFF6B8FA3)),
  AppAvatar(3, Icons.eco, 'Leaf', Color(0xFF5B8C5A)),
  AppAvatar(4, Icons.star, 'Star', Color(0xFFD4A84B)),
  AppAvatar(5, Icons.favorite, 'Heart', Color(0xFFC25A6E)),
  AppAvatar(6, Icons.nights_stay, 'Night', Color(0xFF5C6BC0)),
  AppAvatar(7, Icons.wb_sunny, 'Sun', Color(0xFFE8A838)),
  AppAvatar(8, Icons.spa, 'Spa', Color(0xFFD481B2)),
  AppAvatar(9, Icons.forest, 'Tree', Color(0xFF4A7C59)),
  AppAvatar(10, Icons.water_drop, 'Drop', Color(0xFF4AA3C2)),
  AppAvatar(11, Icons.psychology, 'Mind', Color(0xFF8E6F9E)),
  AppAvatar(12, Icons.self_improvement, 'Zen', Color(0xFF7C9A6E)),
  AppAvatar(13, Icons.book, 'Book', Color(0xFFA68B5B)),
  AppAvatar(14, Icons.music_note, 'Note', Color(0xFFC27A5A)),
  AppAvatar(15, Icons.light, 'Light', Color(0xFFD4A84B)),
  AppAvatar(16, Icons.shield, 'Shield', Color(0xFF6B7B8D)),
  AppAvatar(17, Icons.handshake, 'Hands', Color(0xFF8E8E6E)),
  AppAvatar(18, Icons.diamond, 'Diamond', Color(0xFF7CAAB5)),
  AppAvatar(19, Icons.bolt, 'Bolt', Color(0xFFD49B4B)),
  AppAvatar(20, Icons.park, 'Nature', Color(0xFF5B9A6E)),
];

AppAvatar? findAvatarById(String? id) {
  if (id == null) return null;
  final parsed = int.tryParse(id);
  if (parsed == null) return null;
  try {
    return appAvatars.firstWhere((a) => a.id == parsed);
  } catch (_) {
    return null;
  }
}
