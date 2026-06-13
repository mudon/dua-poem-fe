import '../../core/enums/avatar_type.dart';
import '../../core/enums/user_role.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final String? avatar;
  final String? bio;
  final AvatarType? avatarType;
  final String? avatarValue;
  final String? selectedBadgeSlug;
  final String joinedDate;

  String get fullName => '$firstName $lastName';

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role = UserRole.user,
    required this.createdAt,
    this.avatar,
    this.bio,
    this.avatarType,
    this.avatarValue,
    this.selectedBadgeSlug,
    String? joinedDate,
  }) : joinedDate = joinedDate ?? _formatDate(createdAt);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt']);
    return UserModel(
      id: json['id'].toString(),
      firstName: json['firstName'] ?? json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromValue(json['role'] as String? ?? 'user'),
      createdAt: createdAt,
      avatar: json['avatar'],
      bio: json['bio'],
      avatarType: AvatarType.fromValue(json['avatarType'] as String?),
      avatarValue: json['avatarValue'],
      selectedBadgeSlug: json['selectedBadgeSlug'],
      joinedDate: json['joinedDate'],
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
    DateTime? createdAt,
    String? avatar,
    String? bio,
    AvatarType? avatarType,
    String? avatarValue,
    String? selectedBadgeSlug,
    String? joinedDate,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      avatarType: avatarType ?? this.avatarType,
      avatarValue: avatarValue ?? this.avatarValue,
      selectedBadgeSlug: selectedBadgeSlug ?? this.selectedBadgeSlug,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  static String _formatDate(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return 'Joined ${months[dt.month - 1]} ${dt.year}';
  }
}
