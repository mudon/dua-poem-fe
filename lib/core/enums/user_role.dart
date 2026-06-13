enum UserRole {
  admin,
  user;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.user,
    );
  }
}
