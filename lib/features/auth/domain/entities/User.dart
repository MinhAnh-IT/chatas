class User {
  final String userId;
  final bool isOnline;
  final DateTime lastActive;
  final String fullName;
  final String username;
  final String email;
  final String gender;
  final DateTime birthDate;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.userId,
    required this.isOnline,
    required this.lastActive,
    required this.fullName,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}