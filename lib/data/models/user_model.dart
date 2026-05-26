class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final String joinedDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    required this.joinedDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatar: json['avatar'],
        bio: json['bio'],
        joinedDate: json['joinedDate'],
      );
}
