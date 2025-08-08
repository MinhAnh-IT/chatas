import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_form.dart';
import '../widgets/change_password_dialog.dart';
import '../../constants/profile_constants.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/update_profile_request.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isUpdating = false;

  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getUserProfile();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeAnimationController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          DateTime birthDate;
          if (data['birthDate'] is Timestamp) {
            birthDate = (data['birthDate'] as Timestamp).toDate();
          } else if (data['birthDate'] is String) {
            birthDate = DateTime.parse(data['birthDate']);
          } else {
            birthDate = DateTime.now().subtract(const Duration(days: 6570));
          }

          setState(() {
            _profile = UserProfile(
              id: user.uid,
              fullName: data['fullName'] ?? '',
              email: data['email'] ?? '',
              username: data['username'] ?? '',
              gender: data['gender'] ?? '',
              birthDate: birthDate,
              profileImageUrl: data['avatarUrl'] ?? '',
            );
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông tin: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile(UserProfile updatedProfile) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fullName': updatedProfile.fullName,
          'username': updatedProfile.username,
          'gender': updatedProfile.gender,
          'birthDate': Timestamp.fromDate(updatedProfile.birthDate),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _profile = updatedProfile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(ProfileConstants.profileUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _uploadProfileImage(String imagePath) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${appDir.path}/assets');
      final profileImagesDir = Directory('${assetsDir.path}/profile_images');

      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      final fileName = '${user.uid}_profile.jpg';
      final localImagePath = '${profileImagesDir.path}/$fileName';

      final sourceFile = File(imagePath);
      final targetFile = File(localImagePath);

      if (!await sourceFile.exists()) {
        throw Exception('File nguồn không tồn tại: $imagePath');
      }

      // Ghi ảnh vào local
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await sourceFile.copy(localImagePath);

      // Upload lên Cloudinary
      final cloudinaryUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/dzbo8ubol/image/upload',
      );

      final request = http.MultipartRequest('POST', cloudinaryUrl)
        ..fields['upload_preset'] = 'profile_upload'
        ..files.add(await http.MultipartFile.fromPath('file', localImagePath));

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Không thể upload ảnh lên Cloudinary');
      }

      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      final cloudImageUrl = data['secure_url'];

      // Cập nhật Firestore: Lưu URL public
      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': cloudImageUrl, // 👈 Lưu URL, không phải path local nữa
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (_profile != null) {
        setState(() {
          _profile = _profile!.copyWith(profileImageUrl: cloudImageUrl);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _firebaseAuth.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onCardTap() {
    _cardAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Color(0xFFE74C3C)),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
        ),
      )
          : _profile == null
          ? _buildErrorWidget()
          : _buildProfileContent(context, _profile!),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFE74C3C),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Không thể tải thông tin người dùng',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7F8C8D)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _getUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main Profile Card with Animation
            ScaleTransition(
              scale: _cardScaleAnimation,
              child: GestureDetector(
                onTap: _onCardTap,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header with title
                        Text(
                          'Thông tin cá nhân',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cập nhật thông tin của bạn',
                          style: TextStyle(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Profile Image Section
                        Center(
                          child: ProfileImagePicker(
                            imageUrl: profile.profileImageUrl,
                            onImageSelected: (imagePath) {
                              _uploadProfileImage(imagePath);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Profile Form
                        ProfileForm(
                          profile: profile,
                          onProfileUpdated:
                              (UpdateProfileRequest request) async {
                            final updatedProfile = UserProfile(
                              id: profile.id,
                              fullName: request.fullName,
                              email: profile.email,
                              username: request.username,
                              gender: request.gender,
                              birthDate: request.birthDate,
                              profileImageUrl:
                              request.profileImageUrl ??
                                  profile.profileImageUrl,
                            );
                            await _updateProfile(updatedProfile);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions Card with Animation
            ScaleTransition(
              scale: _cardScaleAnimation,
              child: GestureDetector(
                onTap: _onCardTap,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE67E22).withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}

