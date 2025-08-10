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

  /// AI Summary API configuration.
  static const String geminiApiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String geminiModel = 'gemini-1.5-flash';
  static const String geminiApiEndpoint = 'generateContent';
  static const String geminiApiKey =
      'AIzaSyDetTApk70soMynCmEQJokhvJ9uSjnR614'; // TODO: Move to environment config
  static const String offlineSummaryPrompt =
      '''Bạn là trợ lý AI. Hãy tóm tắt cực ngắn cuộc trò chuyện sau bằng tiếng Việt, chỉ nêu ý chính.

YÊU CẦU:
- Trả về 3–5 gạch đầu dòng, mỗi dòng ≤ 20 từ
- Bao gồm: (1) chủ đề chính, (2) quyết định/kế hoạch, (3) người liên quan & việc cần làm
- Nêu thời gian/địa điểm nếu có, bỏ qua chào hỏi/lặp lại
- Không dùng tiêu đề, không dùng đánh số, không in đậm, không kết luận dài dòng

Cuộc trò chuyện (định dạng "Tên: Nội dung"):
''';

  /// Prompt for manual summary (when user clicks summary button)
  static const String manualSummaryPrompt =
      '''Bạn là trợ lý AI. Hãy tóm tắt ngắn gọn toàn bộ cuộc trò chuyện bằng tiếng Việt, đảm bảo đủ ý chính.

YÊU CẦU:
- Trả về 4–7 gạch đầu dòng rõ ràng
- Phải có: chủ đề chính, các quyết định/kế hoạch, người tham gia và vai trò, thời điểm/địa điểm (nếu có), bước tiếp theo
- Ngắn gọn, chỉ thông tin cốt lõi; không chèn tiêu đề, không đánh số, không in đậm

Cuộc trò chuyện (định dạng "Tên: Nội dung"):
''';
}
