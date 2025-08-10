import '../../../shared/constants/shared_constants.dart';

class ChatMessagePageConstants {
  /// Page title and navigation.
  static const String title = 'Tin nhắn';
  static const String backTooltip = 'Quay lại';

  /// Message input and sending.
  static const String messageHint = 'Nhập tin nhắn...';
  static const String sendTooltip = 'Gửi tin nhắn';
  static const String sendingText = 'Đang gửi...';
  static const String failedToSend = 'Gửi thất bại';
  static const String userInfoUnknown =
      'Không thể xác định thông tin người dùng';

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
  static const String userNotLoggedInError = 'Người dùng chưa đăng nhập';

  /// Timestamp tooltips.
  static const String hideTimeTooltip = 'Ẩn thời gian';
  static const String showTimeTooltip = 'Hiện thời gian';

  /// AppBar actions.
  static const String moreOptionsTooltip = 'Tùy chọn khác';
  static const String aiSummaryTooltip = 'Tóm tắt đoạn chat với AI';

  /// Offline chat summary feature.
  static const String offlineSummaryTitle = 'Tóm tắt tin nhắn khi vắng mặt';
  static const String offlineSummaryLoading =
      'Đang tóm tắt cuộc trò chuyện bằng AI...';
  static const String offlineSummaryNoNewMessages =
      'Không có tin nhắn mới để tóm tắt.';
  static const String offlineSummaryNoContent = 'Không có nội dung để tóm tắt.';
  static const String offlineSummaryError = 'Lỗi tóm tắt AI: ';
  static const String offlineSummaryClose = 'Đóng';
  static const String offlineSummaryErrorTitle = 'Lỗi tóm tắt';
  static const String offlineSummaryDialogTitle = 'Tóm tắt AI';
  static const String offlineSummaryButtonText = 'Tóm tắt khi vắng mặt';
  static const String offlineSummaryButtonTooltip =
      'Tóm tắt các tin nhắn gửi khi bạn vắng mặt';

  /// Feature development messages.
  static const String attachmentFeatureMessage =
      'Tính năng đính kèm đang được phát triển';
  static const String aiSummaryFeatureMessage =
      'Tính năng tóm tắt AI đang được phát triển';

  /// Reaction messages.
  static const String addReactionTooltip = 'Thêm cảm xúc';
  static const String reactionAddedMessage = 'Đã thêm cảm xúc';

  /// Refresh messages.
  static const String refreshTooltip = 'Kéo xuống để làm mới';
  static const String refreshedMessage = 'Đã làm mới tin nhắn';

  /// Message context menu
  static const String replyMenuOption = 'Trả lời';
  static const String editMenuOption = 'Chỉnh sửa';
  static const String deleteMenuOption = 'Xóa';
  static const String copyMenuOption = 'Sao chép';

  /// Message actions confirmations
  static const String deleteConfirmTitle = 'Xóa tin nhắn';
  static const String deleteConfirmMessage =
      'Bạn có chắc chắn muốn xóa tin nhắn này không?';
  static const String deleteConfirmButton = 'Xóa';
  static const String cancelButton = 'Hủy';

  /// Edit message
  static const String editMessageTitle = 'Chỉnh sửa tin nhắn';
  static const String editMessageSaveButton = 'Lưu';
  static const String editMessageHint = 'Nhập tin nhắn mới...';

  /// Reply message
  static const String replyingToPrefix = 'Đang trả lời';
  static const String cancelReplyButton = 'Hủy trả lời';

  /// Status messages
  static const String messageEditedSuccessfully = 'Tin nhắn đã được chỉnh sửa';
  static const String messageDeletedSuccessfully = 'Tin nhắn đã được xóa';
  static const String editedIndicator = 'đã chỉnh sửa';

  /// Additional UI text
  static const String showMore = 'Xem thêm';
  static const String showLess = 'Thu gọn';
  static const String retryButton = 'Thử lại';

  /// Temporary constants for development
  static const String temporaryAvatarUrl = SharedConstants.placeholderImageUrl;

  /// UI dimensions.
  static const double messageRadius = 18.0;
  static const double avatarRadius = 16.0;
  static const double messageSpacing = 8.0;
  static const double sectionSpacing = 16.0;
  static const double reactionSize = 17.0;
  static const double inputHeight = 56.0;

  /// Colors (will be replaced with theme colors).
  static const String sentMessageColor = 'primary';
  static const String receivedMessageColor = 'surface';
}
