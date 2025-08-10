import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/smart_image.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final Function(String) onImageSelected;

  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageSelected,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Stack(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildImage()),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE67E22).withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SmartImage(
      imageUrl: widget.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      fallback: _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        ),
      ),
      child: const Icon(Icons.person, size: 70, color: Colors.white),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Color(0xFF3498DB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chọn ảnh',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFE67E22),
                  size: 20,
                ),
              ),
              title: const Text(
                'Chụp ảnh',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: const Text(
                'Chụp ảnh mới',
                style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF27AE60),
                  size: 20,
                ),
              ),
              title: const Text(
                'Chọn từ thư viện',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: const Text(
                'Chọn ảnh có sẵn',
                style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        widget.onImageSelected(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
