import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/shared/services/file_upload_service.dart';

void main() {
  group('FileUploadService', () {
    group('isFileSizeAcceptable', () {
      test('should return true for acceptable file sizes', () {
        expect(FileUploadService.isFileSizeAcceptable(1024), true); // 1KB
        expect(
          FileUploadService.isFileSizeAcceptable(50 * 1024 * 1024),
          true,
        ); // 50MB
        expect(FileUploadService.isFileSizeAcceptable(0), true);
      });

      test('should return false for files larger than max size', () {
        expect(
          FileUploadService.isFileSizeAcceptable(51 * 1024 * 1024),
          false,
        ); // 51MB
        expect(
          FileUploadService.isFileSizeAcceptable(100 * 1024 * 1024),
          false,
        ); // 100MB
      });

      test('should respect custom max size', () {
        expect(
          FileUploadService.isFileSizeAcceptable(
            10 * 1024 * 1024,
            maxSizeMB: 5,
          ),
          false,
        ); // 10MB > 5MB
        expect(
          FileUploadService.isFileSizeAcceptable(
            5 * 1024 * 1024,
            maxSizeMB: 10,
          ),
          true,
        ); // 5MB < 10MB
      });
    });

    group('isFileTypeSupported', () {
      test('should return true for supported image extensions', () {
        expect(FileUploadService.isFileTypeSupported('test.jpg'), true);
        expect(FileUploadService.isFileTypeSupported('test.jpeg'), true);
        expect(FileUploadService.isFileTypeSupported('test.png'), true);
        expect(FileUploadService.isFileTypeSupported('test.gif'), true);
        expect(FileUploadService.isFileTypeSupported('test.webp'), true);
        expect(FileUploadService.isFileTypeSupported('test.bmp'), true);
      });

      test('should return true for supported video extensions', () {
        expect(FileUploadService.isFileTypeSupported('test.mp4'), true);
        expect(FileUploadService.isFileTypeSupported('test.avi'), true);
        expect(FileUploadService.isFileTypeSupported('test.mov'), true);
        expect(FileUploadService.isFileTypeSupported('test.wmv'), true);
        expect(FileUploadService.isFileTypeSupported('test.flv'), true);
        expect(FileUploadService.isFileTypeSupported('test.webm'), true);
        expect(FileUploadService.isFileTypeSupported('test.mkv'), true);
      });

      test('should return true for supported document extensions', () {
        expect(FileUploadService.isFileTypeSupported('test.pdf'), true);
        expect(FileUploadService.isFileTypeSupported('test.doc'), true);
        expect(FileUploadService.isFileTypeSupported('test.docx'), true);
        expect(FileUploadService.isFileTypeSupported('test.xls'), true);
        expect(FileUploadService.isFileTypeSupported('test.xlsx'), true);
        expect(FileUploadService.isFileTypeSupported('test.ppt'), true);
        expect(FileUploadService.isFileTypeSupported('test.pptx'), true);
        expect(FileUploadService.isFileTypeSupported('test.txt'), true);
        expect(FileUploadService.isFileTypeSupported('test.rtf'), true);
      });

      test('should return false for unsupported extensions', () {
        expect(FileUploadService.isFileTypeSupported('test.exe'), false);
        expect(FileUploadService.isFileTypeSupported('test.bat'), false);
        expect(FileUploadService.isFileTypeSupported('test.sh'), false);
        expect(FileUploadService.isFileTypeSupported('test.unknown'), false);
      });

      test('should handle case insensitive extensions', () {
        expect(FileUploadService.isFileTypeSupported('test.JPG'), true);
        expect(FileUploadService.isFileTypeSupported('test.PNG'), true);
        expect(FileUploadService.isFileTypeSupported('test.MP4'), true);
        expect(FileUploadService.isFileTypeSupported('test.PDF'), true);
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(FileUploadService.formatFileSize(0), '0B');
        expect(FileUploadService.formatFileSize(1023), '1023B');
        expect(FileUploadService.formatFileSize(1024), '1.0KB');
        expect(FileUploadService.formatFileSize(1536), '1.5KB');
        expect(FileUploadService.formatFileSize(1024 * 1024), '1.0MB');
        expect(FileUploadService.formatFileSize(1024 * 1024 * 1024), '1.0GB');
      });
    });

    group('FileUploadResult', () {
      test('should create FileUploadResult with all properties', () {
        const result = FileUploadResult(
          fileUrl: 'https://example.com/file.jpg',
          fileName: 'test.jpg',
          fileType: 'image/jpeg',
          fileSize: 1024,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        expect(result.fileUrl, 'https://example.com/file.jpg');
        expect(result.fileName, 'test.jpg');
        expect(result.fileType, 'image/jpeg');
        expect(result.fileSize, 1024);
        expect(result.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      test('should create FileUploadResult without thumbnailUrl', () {
        const result = FileUploadResult(
          fileUrl: 'https://example.com/file.pdf',
          fileName: 'test.pdf',
          fileType: 'application/pdf',
          fileSize: 2048,
        );

        expect(result.fileUrl, 'https://example.com/file.pdf');
        expect(result.fileName, 'test.pdf');
        expect(result.fileType, 'application/pdf');
        expect(result.fileSize, 2048);
        expect(result.thumbnailUrl, null);
      });
    });
  });
}
