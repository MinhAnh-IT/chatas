import 'package:flutter/material.dart';
import '../constants/refreshable_list_view_constants.dart';

/// A reusable widget that provides pull-to-refresh functionality for any list.
/// Follows Clean Architecture principles and can be used across multiple features.
class RefreshableListView<T> extends StatelessWidget {
  /// The list of items to display.
  final List<T> items;

  /// Callback when user pulls to refresh.
  final Future<void> Function() onRefresh;

  /// Builder function for each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional custom loading widget.
  final Widget? loadingWidget;

  /// Optional custom error widget.
  final Widget Function(String error)? errorWidgetBuilder;

  /// Optional custom empty state widget.
  final Widget? emptyWidget;

  /// Whether the list is currently loading.
  final bool isLoading;

  /// Error message to display if any.
  final String? errorMessage;

  /// Custom refresh success message.
  final String? refreshedMessage;

  /// Custom refresh tooltip.
  final String? refreshTooltip;

  /// Optional retry callback for error state.
  final VoidCallback? onRetry;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// Custom padding for the list.
  final EdgeInsetsGeometry? padding;

  /// Whether to show refresh success message.
  final bool showRefreshMessage;

  const RefreshableListView({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidgetBuilder,
    this.emptyWidget,
    this.isLoading = false,
    this.errorMessage,
    this.refreshedMessage,
    this.refreshTooltip,
    this.onRetry,
    this.scrollController,
    this.padding,
    this.showRefreshMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return _buildLoadingWidget();
    }

    // Show error state
    if (errorMessage != null) {
      return _buildErrorWidget(context);
    }

    // Show empty state
    if (items.isEmpty) {
      return _buildEmptyWidget(context);
    }

    // Show list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding:
            padding ??
            const EdgeInsets.all(RefreshableListViewConstants.defaultPadding),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            itemBuilder(context, items[index], index),
      ),
    );
  }

  /// Handles the refresh action with optional success message.
  Future<void> _handleRefresh() async {
    await onRefresh();

    // Show success message if enabled
    if (showRefreshMessage) {
      // Note: We can't access context here directly, so the parent widget
      // should handle showing success messages if needed
    }
  }

  /// Builds the loading widget.
  Widget _buildLoadingWidget() {
    return loadingWidget ?? const Center(child: CircularProgressIndicator());
  }

  /// Builds the error widget with retry functionality.
  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidgetBuilder != null) {
      return errorWidgetBuilder!(errorMessage!);
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: RefreshableListViewConstants.defaultIconSize,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(
                  height: RefreshableListViewConstants.defaultSpacing,
                ),
                Text(
                  '${RefreshableListViewConstants.defaultErrorPrefix}$errorMessage',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(
                    height: RefreshableListViewConstants.defaultSpacing,
                  ),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text(
                      RefreshableListViewConstants.defaultRetryButtonText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyWidget(BuildContext context) {
    if (emptyWidget != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(child: emptyWidget!),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: RefreshableListViewConstants.defaultIconSize,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(
                  height: RefreshableListViewConstants.defaultSpacing,
                ),
                Text(
                  RefreshableListViewConstants.defaultEmptyMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
