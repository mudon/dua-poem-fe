import '../../../core/enums/avatar_type.dart';

class ProfileUpdateModel {
  final String userId;
  final String firstName;
  final String lastName;
  final AvatarType? avatarType;
  final String? avatarValue;
  final String? selectedBadgeSlug;

  String get userName => '$firstName $lastName';

  String get userAvatar =>
      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

  ProfileUpdateModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.avatarType,
    this.avatarValue,
    this.selectedBadgeSlug,
  });

  factory ProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateModel(
      userId: json['userId'].toString(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatarType: AvatarType.fromValue(json['avatarType'] as String?),
      avatarValue: json['avatarValue'] as String?,
      selectedBadgeSlug: json['selectedBadgeSlug'] as String?,
    );
  }
}
