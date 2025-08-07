class ChatMessagePageConstants {
  /// Page title and navigation.
  static const String title = 'Tin nhắn';
  static const String backTooltip = 'Quay lại';
  
  /// Message input and sending.
  static const String messageHint = 'Nhập tin nhắn...';
  static const String sendTooltip = 'Gửi tin nhắn';
  static const String sendingText = 'Đang gửi...';
  static const String failedToSend = 'Gửi thất bại';
  
  /// Message status.
  static const String statusSending = 'Đang gửi';
  static const String statusSent = 'Đã gửi';
  static const String statusDelivered = 'Đã nhận';
  static const String statusRead = 'Đã đọc';
  static const String statusFailed = 'Thất bại';
  
  /// Time formatting.
  static const String todayLabel = 'Hôm nay';
  static const String yesterdayLabel = 'Hôm qua';
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String fullDateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  /// Reactions.
  static const String likeReaction = '👍';
  static const String loveReaction = '❤️';
  static const String laughReaction = '😂';
  static const String wowReaction = '😮';
  static const String sadReaction = '😢';
  static const String angryReaction = '😡';
  
  /// Error messages.
  static const String errorPrefix = 'Lỗi: ';
  static const String noMessages = 'Hãy bắt đầu với một tin nhắn';
  static const String loadingMessages = 'Đang tải tin nhắn...';
  static const String failedToLoadMessages = 'Không thể tải tin nhắn';
  static const String retryButtonText = 'Thử lại';
  
  /// Timestamp tooltips.
  static const String hideTimeTooltip = 'Ẩn thời gian';
  static const String showTimeTooltip = 'Hiện thời gian';
  
  /// AppBar actions.
  static const String moreOptionsTooltip = 'Tùy chọn khác';
  static const String aiSummaryTooltip = 'Tóm tắt đoạn chat với AI';
  
  /// Feature development messages.
  static const String attachmentFeatureMessage = 'Tính năng đính kèm đang được phát triển';
  static const String aiSummaryFeatureMessage = 'Tính năng tóm tắt AI đang được phát triển';
  
  /// Reaction messages.
  static const String addReactionTooltip = 'Thêm cảm xúc';
  static const String reactionAddedMessage = 'Đã thêm cảm xúc';
  
  /// Refresh messages.
  static const String refreshTooltip = 'Kéo xuống để làm mới';
  static const String refreshedMessage = 'Đã làm mới tin nhắn';
  
  /// Temporary constants for development
  static const String temporaryUserId = 'current_user'; 
  static const String temporaryUserName = 'Current User'; 
  static const String temporaryAvatarUrl = 'https://via.placeholder.com/150';
  
  /// UI dimensions.
  static const double messageRadius = 18.0;
  static const double avatarRadius = 16.0;
  static const double messageSpacing = 8.0;
  static const double sectionSpacing = 16.0;
  static const double reactionSize = 20.0;
  static const double inputHeight = 56.0;
  
  /// Colors (will be replaced with theme colors).
  static const String sentMessageColor = 'primary';
  static const String receivedMessageColor = 'surface';
}
