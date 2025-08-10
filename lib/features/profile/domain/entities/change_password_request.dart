import 'package:equatable/equatable.dart';

class ChangePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword];
}
