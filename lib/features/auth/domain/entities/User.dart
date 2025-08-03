class User {
  final String fullName;
  final String username;
  final String email;
  final String gender;
  final DateTime birthDate;
  final String password;
  final String confirmPassword;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.fullName,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.password,
    required this.confirmPassword,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}