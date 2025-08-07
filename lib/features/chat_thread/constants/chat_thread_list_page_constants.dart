class ChatThreadListPageConstants {
  static const String title = 'Chatas';
  static const String searchTooltip = 'Tìm kiếm';
  static const String errorPrefix = 'lỗi: ';
  static const String noChats = 'Không có đoạn chat nào';
  static const String loading = 'Loading...';
  static const String chatCountText = 'Bạn đã nhấn nút này:';
  static const String refreshedMessage = 'Đã làm mới danh sách chat';
  
  // Search constants
  static const String searchHint = 'Tìm kiếm đoạn chat...';
  static const String searchTitle = 'Tìm kiếm';
  static const String searchDialogTitle = 'Tìm kiếm đoạn chat';
  static const String searchCancel = 'Hủy';
  static const String noSearchResults = 'Không tìm thấy kết quả nào';
  static const String searchEmpty = 'Vui lòng nhập từ khóa tìm kiếm';
  static const String searchEmptyHint = 'Nhập từ khóa để tìm kiếm đoạn chat';

  // Delete constants
  static const String deleteTitle = 'Xóa đoạn chat';
  static const String deleteMessage = 'Bạn có chắc chắn muốn xóa đoạn chat này?';
  static const String deleteConfirm = 'Xóa';
  static const String deleteCancel = 'Hủy';
  static const String deleteSuccess = 'Đã xóa đoạn chat thành công';
  static const String deleteError = 'Không thể xóa đoạn chat';
  static const String deleteTooltip = 'Xóa đoạn chat';

  /// Temporary constants for development
  static const String temporaryUserId =
      'current_user'; // TODO: Get from auth service - keep consistent with ChatMessagePageConstants

  /// UI dimensions
  static const double avatarRadius = 20.0;
  static const double dividerHeight = 1.0;
  static const double trailingFontSize = 12.0;
}
