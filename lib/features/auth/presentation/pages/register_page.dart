import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../../domain/entities/register_request.dart';
import '/shared/utils/auth_validator.dart';
import '../../constants/auth_constants.dart';
import '../../data/models/user_model.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  String _selectedGender = '';
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn giới tính'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ngày sinh'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mật khẩu xác nhận không khớp'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (_passwordController.text.length < AuthConstants.minPasswordLength) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mật khẩu quá yếu'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          final userModel = UserModel(
            userid: userCredential.user!.uid,
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            gender: _selectedGender,
            birthDate: _selectedDate!,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            avatarUrl: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestore
              .collection(AuthConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());

          // Đăng xuất để user phải đăng nhập lại
          await _firebaseAuth.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/login');
          }
        }
      } on firebase_auth.FirebaseAuthException catch (e) {
        String message = 'Lỗi đăng ký';
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Email đã được sử dụng';
            break;
          case 'weak-password':
            message = 'Mật khẩu quá yếu';
            break;
          case 'invalid-email':
            message = 'Địa chỉ email không hợp lệ';
            break;
          case 'operation-not-allowed':
            message = 'Thao tác không được phép';
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
              content: Text('Lỗi đăng ký: ${e.toString()}'),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime.now().subtract(const Duration(days: 36500)),
      lastDate: DateTime.now().subtract(const Duration(days: 4745)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F6FF), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _fullNameController,
                      label: 'Họ và tên',
                      hint: 'Nguyễn Văn A',
                      icon: Icons.person_outline,
                      validator: (value) => AuthValidator.validateFullName(value),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _usernameController,
                      label: 'Tên đăng nhập',
                      hint: 'username123',
                      icon: Icons.person_outline,
                      validator: (value) => AuthValidator.validateUsername(value),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'example@email.com',
                      icon: Icons.email_outlined,
                      validator: (value) => AuthValidator.validateEmail(value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Giới tính',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedGender.isEmpty ? null : _selectedGender,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    icon: Icon(Icons.person_outline),
                                  ),
                                  hint: const Text('Chọn'),
                                  items: AuthConstants.genderOptions.map((gender) {
                                    return DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value ?? '';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày sinh',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDate == null
                                            ? 'dd/mm/yyyy'
                                            : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                        style: TextStyle(
                                          color: _selectedDate == null ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      hint: 'Tối thiểu 8 ký tự',
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
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu',
                      hint: 'Nhập lại mật khẩu',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) => AuthValidator.validateConfirmPassword(value, _passwordController.text),
                    ),
                    const SizedBox(height: 32),
                    AuthButton(
                      text: 'Tạo tài khoản',
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Đã có tài khoản? ', style: TextStyle(fontSize: 14)),
                        TextButton(
                          onPressed: () {
                            context.push('/login');
                          },
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 