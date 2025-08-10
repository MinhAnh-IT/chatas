import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/change_password_request.dart';
import '../../../../shared/utils/profile_validator.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFF8F9FA),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Đổi mật khẩu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Mật khẩu hiện tại',
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                    validator: ProfileValidator.validateCurrentPassword,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Mật khẩu mới',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: ProfileValidator.validateNewPassword,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu mới',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) =>
                        ProfileValidator.validateConfirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                      side: const BorderSide(color: Color(0xFFB2BEC3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C47FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final request = ChangePasswordRequest(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      final validationError = ProfileValidator.validateChangePasswordRequest(
        request,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Auth change password logic
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user == null || user.email == null) {
          throw Exception('Không tìm thấy người dùng. Vui lòng đăng nhập lại.');
        }

        // Re-authenticate
        final cred = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: request.currentPassword,
        );
        await user.reauthenticateWithCredential(cred);

        // Update password
        await user.updatePassword(request.newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } on firebase_auth.FirebaseAuthException catch (e) {
        String message = 'Đổi mật khẩu thất bại';
        if (e.code == 'wrong-password') {
          message = 'Mật khẩu hiện tại không đúng';
        } else if (e.code == 'weak-password') {
          message = 'Mật khẩu mới quá yếu';
        } else if (e.code == 'requires-recent-login') {
          message = 'Vui lòng đăng nhập lại để đổi mật khẩu';
        } else if (e.code == 'too-many-requests') {
          message = 'Bạn thao tác quá nhiều lần. Vui lòng thử lại sau.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đổi mật khẩu thất bại: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
