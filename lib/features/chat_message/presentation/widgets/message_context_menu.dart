import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../domain/entities/chat_message.dart';
import 'package:chatas/shared/services/online_status_service.dart';

/// Context menu widget that appears when user long presses on a message.
/// Provides options like Reply, Edit, Delete, and Copy based on message ownership.
class MessageContextMenu extends StatelessWidget {
  final ChatMessage message;
  final String currentUserId;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const MessageContextMenu({
    super.key,
    required this.message,
    required this.currentUserId,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  /// Shows the context menu at the specified position.
  static Future<void> show({
    required BuildContext context,
    required Offset position,
    required ChatMessage message,
    required String currentUserId,
    VoidCallback? onReply,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onCopy,
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    void closeMenu() {
      try {
        overlayEntry.remove();
      } catch (e) {
        // Handle case where overlay is already removed
        print('MessageContextMenu: Overlay already removed');
      }
    }

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          // Invisible barrier to close menu when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                OnlineStatusService.instance.onUserActivity();
                closeMenu();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          // Context menu
          Positioned(
            left: position.dx,
            top: position.dy,
            child: MessageContextMenu(
              message: message,
              currentUserId: currentUserId,
              onReply: () {
                closeMenu();
                if (onReply != null) {
                  // Use original context for callbacks, not overlay context
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onReply?.call();
                  });
                }
              },
              onEdit: () {
                closeMenu();
                if (onEdit != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onEdit?.call();
                  });
                }
              },
              onDelete: () {
                closeMenu();
                if (onDelete != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onDelete?.call();
                  });
                }
              },
              onCopy: () {
                closeMenu();
                if (onCopy != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onCopy?.call();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwnMessage = message.isFromUser(currentUserId);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply option (available for all messages)
            _buildMenuItem(
              context: context,
              icon: Icons.reply,
              label: ChatMessagePageConstants.replyMenuOption,
              onTap: () {
                OnlineStatusService.instance.onUserActivity();
                onReply?.call();
              },
            ),

            // Edit option (only for own messages)
            if (isOwnMessage)
              _buildMenuItem(
                context: context,
                icon: Icons.edit,
                label: ChatMessagePageConstants.editMenuOption,
                onTap: () {
                  OnlineStatusService.instance.onUserActivity();
                  onEdit?.call();
                },
              ),

            // Delete option (only for own messages)
            if (isOwnMessage)
              _buildMenuItem(
                context: context,
                icon: Icons.delete,
                label: ChatMessagePageConstants.deleteMenuOption,
                onTap: () {
                  OnlineStatusService.instance.onUserActivity();
                  onDelete?.call();
                },
                isDestructive: true,
              ),

            // Copy option (available for all text messages)
            if (message.type == MessageType.text)
              _buildMenuItem(
                context: context,
                icon: Icons.copy,
                label: ChatMessagePageConstants.copyMenuOption,
                onTap: () {
                  OnlineStatusService.instance.onUserActivity();
                  Clipboard.setData(ClipboardData(text: message.content));
                  onCopy?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a menu item with icon and label.
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final textColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
