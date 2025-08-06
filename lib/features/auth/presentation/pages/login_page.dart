import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../domain/entities/login_request.dart';
import '/shared/utils/auth_validator.dart';
import '../../constants/auth_constants.dart';
import '../../data/models/user_model.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String userEmail = _emailOrUsernameController.text.trim();
        
        if (!userEmail.contains('@')) {
          final userQuery = await _firestore
              .collection(AuthConstants.usersCollection)
              .where('username', isEqualTo: userEmail)
              .limit(1)
              .get();

          if (userQuery.docs.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không tìm thấy người dùng'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final userData = userQuery.docs.first.data();
          userEmail = userData['email'] as String;
        }

        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: userEmail,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng nhập thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/');
          }
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        String message = 'Lỗi đăng nhập';
        switch (e.code) {
          case 'user-not-found':
            message = 'Không tìm thấy người dùng';
            break;
          case 'wrong-password':
            message = 'Sai mật khẩu';
            break;
          case 'invalid-email':
            message = 'Email không hợp lệ';
            break;
          case 'user-disabled':
            message = 'Tài khoản đã bị vô hiệu hóa';
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
              content: Text('Lỗi đăng nhập: ${e.toString()}'),
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
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Chào mừng bạn quay trở lại',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AuthTextField(
                              controller: _emailOrUsernameController,
                              label: 'Email hoặc tên đăng nhập',
                              hint: 'example@email.com',
                              icon: Icons.email_outlined,
                              validator: (value) => AuthValidator.validateEmailOrUsername(value),
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) => AuthValidator.validatePassword(value),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Nhớ mật khẩu',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/forgot-password');
                                  },
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(fontSize: 14, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AuthButton(
                              text: 'Đăng nhập',
                              onPressed: _isLoading ? null : _handleLogin,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Chưa có tài khoản? ', style: TextStyle(fontSize: 14)),
                                TextButton(
                                  onPressed: () {
                                    context.push('/register');
                                  },
                                  child: const Text(
                                    'Đăng ký ngay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
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