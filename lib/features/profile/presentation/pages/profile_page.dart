import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_image_picker.dart';
import '../widgets/profile_form.dart';
import '../widgets/change_password_dialog.dart';
import '../../constants/profile_constants.dart';
import '../../domain/entities/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(ProfileConstants.profileUpdatedSuccess),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(ProfileConstants.passwordChangedSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Close password dialog
          } else if (state is ImageUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(ProfileConstants.imageUploadedSuccess),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          } else if (state is ProfileUpdating || state is PasswordChanging || state is ImageUploading) {
            return _buildProfileContent(context, (state as dynamic).profile ?? UserProfile(
              id: '',
              fullName: '',
              email: '',
              username: '',
              gender: '',
              birthDate: DateTime.now(),
            ));
          } else if (state is ProfileFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().getUserProfile(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Section
          Center(
            child: ProfileImagePicker(
              imageUrl: profile.profileImageUrl,
              onImageSelected: (imagePath) {
                context.read<ProfileCubit>().uploadProfileImage(imagePath);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Profile Form
          ProfileForm(
            profile: profile,
            onProfileUpdated: (updatedProfile) {
              context.read<ProfileCubit>().updateProfile(updatedProfile);
            },
          ),
          const SizedBox(height: 24),

          // Change Password Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Đổi mật khẩu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
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