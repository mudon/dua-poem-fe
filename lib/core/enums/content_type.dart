enum ContentType {
  dua,
  poem;

  String get value => name;

  static ContentType fromValue(String value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.dua,
    );
  }
}
