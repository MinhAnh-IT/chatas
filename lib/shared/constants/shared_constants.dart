/// Constants for shared services and utilities.
class SharedConstants {
  /// Project configuration
  static const String firebaseProjectId = 'chatas-9469d';

  /// Cloudinary configuration
  static const String cloudinaryCloudName = 'dzbo8ubol';
  static const String cloudinaryApiBaseUrl = 'https://api.cloudinary.com/v1_1';
  static const String cloudinaryImageUploadUrl =
      '$cloudinaryApiBaseUrl/$cloudinaryCloudName/image/upload';
  static const String cloudinaryResourceBaseUrl =
      'https://res.cloudinary.com/$cloudinaryCloudName';

  /// Placeholder URLs
  static const String placeholderImageUrl = 'https://via.placeholder.com/150';
  static const String placeholderDomain = 'via.placeholder.com';

  /// URL protocols
  static const String httpProtocol = 'http://';
  static const String httpsProtocol = 'https://';

  /// Google APIs
  static const String googleFirebaseMessagingScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  /// FCM URLs
  static const String fcmLegacyUrl = 'https://fcm.googleapis.com/fcm/send';
}
