import 'dart:convert';
import 'dart:io';
import 'package:chatas/shared/constants/shared_constants.dart';
import 'package:chatas/shared/constants/file_constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// File upload result containing URL and metadata
class FileUploadResult {
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String? thumbnailUrl;

  const FileUploadResult({
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.thumbnailUrl,
  });
}

/// Service for uploading various file types to Cloudinary
class FileUploadService {
  static const String _cloudinaryCloudName =
      'dzbo8ubol'; // Replace with your Cloudinary cloud name
  static const String _cloudinaryUploadPreset =
      'chatas_upload'; // Use custom preset for chat app

  /// Upload any file type to Cloudinary
  static Future<FileUploadResult> uploadFile({
    required String filePath,
    required String chatThreadId,
    String? customFileName,
  }) async {
    // Test Cloudinary connection first
    final isConnected = await testCloudinaryConnection();
    if (!isConnected) {
      throw Exception(
        'Không thể kết nối đến Cloudinary. Vui lòng kiểm tra kết nối mạng.',
      );
    }

    return _uploadFileWithPreset(
      filePath,
      chatThreadId,
      customFileName,
      _cloudinaryUploadPreset,
    );
  }

  /// Internal method to upload with specific preset
  static Future<FileUploadResult> _uploadFileWithPreset(
    String filePath,
    String chatThreadId,
    String? customFileName,
    String uploadPreset,
  ) async {
    print('FileUploadService: Starting file upload from: $filePath');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File không tồn tại: $filePath');
    }

    // Get file info
    final fileName = customFileName ?? path.basename(filePath);
    final fileSize = await file.length();
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

    // Validate file size (max 50MB)
    if (fileSize > FileConstants.maxFileSize) {
      throw Exception('File quá lớn. Kích thước tối đa 50MB.');
    }

    print(
      'FileUploadService: File info - name: $fileName, size: $fileSize, type: $mimeType',
    );

    // Determine resource type based on file type
    String resourceType = 'auto'; // Cloudinary auto-detection

    if (mimeType.startsWith('image/')) {
      resourceType = 'image';
    } else if (mimeType.startsWith('video/')) {
      resourceType = 'video';
    } else {
      resourceType = 'raw'; // For non-media files
    }

    // Create local storage copy
    final localFilePath = await _copyToLocalStorage(
      filePath,
      fileName,
      chatThreadId,
    );

    try {
      // Upload to Cloudinary
      final cloudinaryUrl = Uri.parse(
        '${SharedConstants.cloudinaryApiBaseUrl}/$_cloudinaryCloudName/$resourceType/upload',
      );

      final publicId =
          'chat_${chatThreadId}_${DateTime.now().millisecondsSinceEpoch}';

      final request = http.MultipartRequest('POST', cloudinaryUrl)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = publicId
        ..fields['resource_type'] = resourceType
        ..files.add(await http.MultipartFile.fromPath('file', localFilePath));

      print(
        'FileUploadService: Uploading to Cloudinary with preset: $uploadPreset, resource_type: $resourceType',
      );

      final response = await request.send();

      if (response.statusCode != FileConstants.httpOk) {
        final errorBody = await response.stream.bytesToString();
        print(
          'FileUploadService: Upload failed with status ${response.statusCode}: $errorBody',
        );
        print('FileUploadService: Request URL: $cloudinaryUrl');
        print('FileUploadService: Upload preset: $uploadPreset');
        print('FileUploadService: Resource type: $resourceType');
        print('FileUploadService: Public ID: $publicId');
        throw Exception(
          'Upload thất bại: HTTP ${response.statusCode} - $errorBody',
        );
      }

      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);

      final fileUrl = data['secure_url'] as String;
      final thumbnailUrl = _generateThumbnailUrl(data, mimeType);

      print('FileUploadService: Upload successful. URL: $fileUrl');

      return FileUploadResult(
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: mimeType,
        fileSize: fileSize,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      print('FileUploadService: Upload error with preset $uploadPreset: $e');

      // Try with fallback preset if main preset fails
      if (uploadPreset == _cloudinaryUploadPreset) {
        print('FileUploadService: Trying fallback preset...');
        try {
          return await _uploadFileWithPreset(
            filePath,
            chatThreadId,
            customFileName,
            'ml_default',
          );
        } catch (fallbackError) {
          print(
            'FileUploadService: Fallback preset also failed: $fallbackError',
          );
        }
      }

      rethrow;
    }
  }

  /// Upload image specifically
  static Future<FileUploadResult> uploadImage({
    required String imagePath,
    required String chatThreadId,
    String? customFileName,
  }) async {
    // Validate it's an image
    final mimeType = lookupMimeType(imagePath);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw Exception('File không phải là hình ảnh hợp lệ');
    }

    return uploadFile(
      filePath: imagePath,
      chatThreadId: chatThreadId,
      customFileName: customFileName,
    );
  }

  /// Upload video specifically
  static Future<FileUploadResult> uploadVideo({
    required String videoPath,
    required String chatThreadId,
    String? customFileName,
  }) async {
    // Validate it's a video
    final mimeType = lookupMimeType(videoPath);
    if (mimeType == null || !mimeType.startsWith('video/')) {
      throw Exception('File không phải là video hợp lệ');
    }

    return uploadFile(
      filePath: videoPath,
      chatThreadId: chatThreadId,
      customFileName: customFileName,
    );
  }

  /// Copy file to local storage for temporary processing
  static Future<String> _copyToLocalStorage(
    String filePath,
    String fileName,
    String chatThreadId,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = Directory('${appDir.path}/temp_uploads/$chatThreadId');

    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }

    // Create unique filename to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(fileName);
    final baseName = path.basenameWithoutExtension(fileName);
    final uniqueFileName = '${baseName}_$timestamp$extension';

    final localFilePath = '${tempDir.path}/$uniqueFileName';

    final sourceFile = File(filePath);
    await sourceFile.copy(localFilePath);

    print('FileUploadService: Copied file to local storage: $localFilePath');
    return localFilePath;
  }

  /// Generate thumbnail URL for videos and documents
  static String? _generateThumbnailUrl(
    Map<String, dynamic> cloudinaryResponse,
    String mimeType,
  ) {
    final publicId = cloudinaryResponse['public_id'] as String?;
    if (publicId == null) return null;

    // For videos, Cloudinary can generate thumbnails
    if (mimeType.startsWith('video/')) {
      return '${SharedConstants.cloudinaryResourceBaseUrl}/video/upload/so_0,w_300,h_200,c_fill/$publicId.jpg';
    }

    // For images, use the same URL but smaller
    if (mimeType.startsWith('image/')) {
      return '${SharedConstants.cloudinaryResourceBaseUrl}/image/upload/w_300,h_200,c_fill/$publicId';
    }

    // For documents, you might want to generate preview thumbnails
    // For now, return null (will use file type icon)
    return null;
  }

  /// Test Cloudinary connection
  static Future<bool> testCloudinaryConnection() async {
    try {
      final testUrl = Uri.parse(
        '${SharedConstants.cloudinaryApiBaseUrl}/$_cloudinaryCloudName/image/upload',
      );

      // Test with POST request and upload preset
      final request = http.MultipartRequest('POST', testUrl)
        ..fields['upload_preset'] = _cloudinaryUploadPreset;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print(
        'FileUploadService: Cloudinary test response: ${response.statusCode}',
      );
      print('FileUploadService: Cloudinary test body: $responseBody');

      // 400 with "Upload preset not found" means preset doesn't exist
      if (response.statusCode == FileConstants.httpBadRequest &&
          responseBody.contains('Upload preset not found')) {
        print(
          'FileUploadService: Upload preset $_cloudinaryUploadPreset not found',
        );
        return false;
      }

      // 400 with "Upload preset must be specified" means preset is required
      if (response.statusCode == FileConstants.httpBadRequest &&
          responseBody.contains('Upload preset must be specified')) {
        print('FileUploadService: Upload preset is required');
        return false;
      }

      // 200 means success (even without file, it should accept the request)
      return response.statusCode == FileConstants.httpOk;
    } catch (e) {
      print('FileUploadService: Cloudinary test failed: $e');
      return false;
    }
  }

  /// Clean up local temp files
  static Future<void> cleanupTempFiles(String chatThreadId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempDir = Directory('${appDir.path}/temp_uploads/$chatThreadId');

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        print(
          'FileUploadService: Cleaned up temp files for chat: $chatThreadId',
        );
      }
    } catch (e) {
      print('FileUploadService: Error cleaning up temp files: $e');
    }
  }

  /// Get file size string helper
  static String formatFileSize(int bytes) {
    if (bytes < FileConstants.bytesPerKB) return '${bytes}B';
    if (bytes < FileConstants.bytesPerMB)
      return '${(bytes / FileConstants.bytesPerKB).toStringAsFixed(1)}KB';
    if (bytes < FileConstants.bytesPerGB) {
      return '${(bytes / FileConstants.bytesPerMB).toStringAsFixed(1)}MB';
    }
    return '${(bytes / FileConstants.bytesPerGB).toStringAsFixed(1)}GB';
  }

  /// Check if file size is acceptable
  static bool isFileSizeAcceptable(int bytes, {int maxSizeMB = 50}) {
    final maxBytes = maxSizeMB * FileConstants.bytesPerMB;
    return bytes <= maxBytes;
  }

  /// Get supported file extensions
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
  ];

  static const List<String> supportedVideoExtensions = [
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'mkv',
  ];

  static const List<String> supportedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
  ];

  /// Check if file type is supported
  static bool isFileTypeSupported(String filePath) {
    final extension = path
        .extension(filePath)
        .toLowerCase()
        .replaceAll('.', '');
    return supportedImageExtensions.contains(extension) ||
        supportedVideoExtensions.contains(extension) ||
        supportedDocumentExtensions.contains(extension);
  }
}
