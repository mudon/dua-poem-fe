enum AvatarType {
  icon,
  upload;

  String get value => name;

  static AvatarType? fromValue(String? value) {
    if (value == null) return null;
    return AvatarType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AvatarType.icon,
    );
  }
}
