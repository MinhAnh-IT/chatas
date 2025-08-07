/// Constants for chat message remote data source operations.
class ChatMessageRemoteConstants {
  /// Firestore collection name for chat messages.
  static const String collectionName = 'chat_messages';
  
  /// Firestore field names for chat message documents.
  static const String idField = 'id';
  static const String chatThreadIdField = 'chatThreadId';
  static const String senderIdField = 'senderId';
  static const String senderNameField = 'senderName';
  static const String senderAvatarUrlField = 'senderAvatarUrl';
  static const String contentField = 'content';
  static const String typeField = 'type';
  static const String statusField = 'status';
  static const String sentAtField = 'sentAt';
  static const String editedAtField = 'editedAt';
  static const String isDeletedField = 'isDeleted';
  static const String reactionsField = 'reactions';
  static const String replyToMessageIdField = 'replyToMessageId';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  
  /// Query limits and pagination.
  static const int defaultMessageLimit = 50;
  static const int maxMessageLimit = 100;
}
