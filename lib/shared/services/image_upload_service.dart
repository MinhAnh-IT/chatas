import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageUploadService {
  static const String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dzbo8ubol/image/upload';
  static const String _profileUploadPreset = 'profile_upload';
  static const String _groupUploadPreset =
      'profile_upload'; // Using same preset for now

  /// Uploads an image to Cloudinary and returns the secure URL
  ///
  /// [imagePath] - Local path to the image file
  /// [uploadType] - Type of upload ('profile' or 'group')
  /// [identifier] - Unique identifier for the image (userId or groupId)
  static Future<String> uploadImage({
    required String imagePath,
    required String uploadType,
    required String identifier,
  }) async {
    print(
      'ImageUploadService: Starting upload for $uploadType with identifier: $identifier',
    );

    // Create local directory structure
    final appDir = await getApplicationDocumentsDirectory();
    final assetsDir = Directory('${appDir.path}/assets');
    final imagesDir = Directory('${assetsDir.path}/${uploadType}_images');

    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Copy image to local storage
    final fileName = '${identifier}_$uploadType.jpg';
    final localImagePath = '${imagesDir.path}/$fileName';

    final sourceFile = File(imagePath);
    final targetFile = File(localImagePath);

    if (!await sourceFile.exists()) {
      throw Exception('File nguồn không tồn tại: $imagePath');
    }

    print(
      'ImageUploadService: Copying image to local storage: $localImagePath',
    );

    // Delete existing file if it exists
    if (await targetFile.exists()) {
      await targetFile.delete();
    }
    await sourceFile.copy(localImagePath);

    // Upload to Cloudinary
    print('ImageUploadService: Uploading to Cloudinary...');
    final cloudinaryUrl = Uri.parse(_cloudinaryUrl);
    final uploadPreset = uploadType == 'profile'
        ? _profileUploadPreset
        : _groupUploadPreset;

    final request = http.MultipartRequest('POST', cloudinaryUrl)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] =
          '${uploadType}_${identifier}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', localImagePath));

    final response = await request.send();

    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      print(
        'ImageUploadService: Upload failed with status ${response.statusCode}: $errorBody',
      );
      throw Exception(
        'Không thể upload ảnh lên Cloudinary: HTTP ${response.statusCode}',
      );
    }

    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);
    final cloudImageUrl = data['secure_url'] as String;

    print('ImageUploadService: Upload successful. URL: $cloudImageUrl');
    return cloudImageUrl;
  }

  /// Uploads group chat avatar
  static Future<String> uploadGroupAvatar({
    required String imagePath,
    required String groupId,
  }) async {
    return uploadImage(
      imagePath: imagePath,
      uploadType: 'group',
      identifier: groupId,
    );
  }

  /// Uploads user profile avatar
  static Future<String> uploadUserAvatar({
    required String imagePath,
    required String userId,
  }) async {
    return uploadImage(
      imagePath: imagePath,
      uploadType: 'profile',
      identifier: userId,
    );
  }
}
