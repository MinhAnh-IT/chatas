/// Constants for RefreshableListView widget.
/// Contains all hardcoded values for reusable pull-to-refresh functionality.
class RefreshableListViewConstants {
  /// Refresh indicator text messages.
  static const String defaultRefreshTooltip = 'Kéo xuống để làm mới';
  static const String defaultRefreshedMessage = 'Đã làm mới';
  static const String defaultRefreshingMessage = 'Đang làm mới...';

  /// Error messages.
  static const String defaultErrorPrefix = 'Lỗi: ';
  static const String defaultRetryButtonText = 'Thử lại';

  /// Empty state messages.
  static const String defaultEmptyMessage = 'Không có dữ liệu';
  static const String defaultLoadingMessage = 'Đang tải...';

  /// UI dimensions.
  static const double defaultPadding = 16.0;
  static const double defaultIconSize = 64.0;
  static const double defaultSpacing = 16.0;

  /// Animation durations.
  static const int refreshDurationMs = 1000;
  static const int snackBarDurationSeconds = 2;
}
