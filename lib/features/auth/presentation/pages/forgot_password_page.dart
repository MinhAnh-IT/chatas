import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '/shared/utils/auth_validator.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firebaseAuth.sendPasswordResetEmail(email: _emailController.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi email đặt lại mật khẩu!'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 700), () {
            context.pop();
          });
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        String message = 'Lỗi gửi email';
        switch (e.code) {
          case 'user-not-found':
            message = 'Không tìm thấy tài khoản với email này';
            break;
          case 'invalid-email':
            message = 'Email không hợp lệ';
            break;
          case 'too-many-requests':
            message = 'Thử quá nhiều lần. Vui lòng thử lại sau';
            break;
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi không xác định: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Quên mật khẩu',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nhập email để nhận liên kết đặt lại mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'example@email.com',
                              icon: Icons.email_outlined,
                              validator: (value) => AuthValidator.validateEmail(value),
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              text: 'Gửi liên kết',
                              onPressed: _isLoading ? null : _handleSendReset,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Quay lại đăng nhập'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 