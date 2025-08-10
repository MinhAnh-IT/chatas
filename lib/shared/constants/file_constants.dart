/// Constants for file operations and limits.
class FileConstants {
  /// File size limits (in bytes)
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  /// File size units
  static const int bytesPerKB = 1024;
  static const int bytesPerMB = 1024 * 1024;
  static const int bytesPerGB = 1024 * 1024 * 1024;

  /// HTTP status codes
  static const int httpOk = 200;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;

  /// Timeout durations (in seconds)
  static const int defaultTimeout = 30;
  static const int uploadTimeout = 60;
  static const int downloadTimeout = 30;

  /// UI constraints
  static const double maxDialogWidth = 400;
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;

  /// File type categories
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
  ];
  static const List<String> videoExtensions = [
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
  ];
  static const List<String> audioExtensions = [
    'mp3',
    'wav',
    'aac',
    'flac',
    'm4a',
  ];
}
