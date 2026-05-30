class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? avatar;
  final String? bio;
  final String joinedDate;

  String get fullName => '$firstName $lastName';

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role = 'user',
    required this.createdAt,
    this.avatar,
    this.bio,
    String? joinedDate,
  }) : joinedDate = joinedDate ?? _formatDate(createdAt);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt']);
    return UserModel(
      id: json['id'].toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: createdAt,
      avatar: json['avatar'],
      bio: json['bio'],
      joinedDate: json['joinedDate'],
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
