import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/chat_message.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../../../shared/utils/date_utils.dart' as app_date_utils;
import '../../../../shared/constants/shared_constants.dart';
import 'message_context_menu.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../auth/di/auth_dependency_injection.dart';
import '../../../auth/constants/auth_remote_constants.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_cubit.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_state.dart';
import 'package:chatas/shared/services/online_status_service.dart';

/// Widget for displaying a single chat message bubble.
/// Handles different message types, reactions, and selection states.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSelected;
  final String currentUserId;
  final String? currentUserName; // Add current user name
  final ChatMessage?
  repliedMessage; // Original message being replied to (if any)
  final VoidCallback onTap;
  final Function(String messageId, ReactionType reactionType) onReactionTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSelected,
    required this.currentUserId,
    this.currentUserName,
    this.repliedMessage,
    required this.onTap,
    required this.onReactionTap,
    this.onLongPress,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isFromCurrentUser = message.isFromUser(currentUserId);

    final isCurrentUserMessage = isFromCurrentUser;

    return GestureDetector(
      onTap: () {
        OnlineStatusService.instance.onUserActivity();
        onTap();
      },
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: ChatMessagePageConstants.messageSpacing / 2,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isSelected) _buildTimestamp(context),
            Row(
              mainAxisAlignment: isCurrentUserMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isCurrentUserMessage) _buildAvatar(),
                if (!isCurrentUserMessage) const SizedBox(width: 8.0),
                Flexible(child: _buildMessageContainer(context)),
                if (isCurrentUserMessage) const SizedBox(width: 8.0),
                if (isCurrentUserMessage) _buildMessageStatus(),
              ],
            ),
            if (message.hasReactions) _buildReactions(context),
          ],
        ),
      ),
    );
  }

  /// Builds the timestamp display above the message.
  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final timestampText = app_date_utils.DateUtils.formatTime(message.sentAt);

    // Check if this is current user even if senderId doesn't match
    final isCurrentUserMessage =
        message.isFromUser(currentUserId) ||
        false; // Remove backward compatibility

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        timestampText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        textAlign: isCurrentUserMessage ? TextAlign.end : TextAlign.start,
      ),
    );
  }

  /// Builds the user avatar for received messages.
  Widget _buildAvatar() {
    return FutureBuilder<String>(
      future: _getSenderAvatarUrl(),
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data ?? message.senderAvatarUrl;
        print(
          'MessageBubble: senderId=${message.senderId}, senderName=${message.senderName}, senderAvatarUrl=${message.senderAvatarUrl}, dynamicAvatarUrl=$avatarUrl',
        );
        return SmartAvatar(
          imageUrl: avatarUrl,
          radius: ChatMessagePageConstants.avatarRadius,
          fallbackText: message.senderName,
          showBorder: true,
          showShadow: true,
        );
      },
    );
  }

  /// Gets the sender's avatar URL dynamically
  Future<String> _getSenderAvatarUrl() async {
    print(
      'MessageBubble: _getSenderAvatarUrl called for senderId: ${message.senderId}',
    );

    // If avatar URL already exists and is not placeholder, use it
    if (message.senderAvatarUrl.isNotEmpty &&
        !message.senderAvatarUrl.contains('placeholder') &&
        !message.senderAvatarUrl.contains(SharedConstants.placeholderDomain)) {
      print(
        'MessageBubble: Using existing avatar URL: ${message.senderAvatarUrl}',
      );
      return message.senderAvatarUrl;
    }

    // Get sender's avatar from their user profile
    try {
      print(
        'MessageBubble: Calling getUserById for senderId: ${message.senderId}',
      );
      final senderUser = await AuthDependencyInjection.authRemoteDataSource
          .getUserById(message.senderId);
      print(
        'MessageBubble: getUserById returned: ${senderUser != null ? "user found" : "null"}',
      );

      if (senderUser != null) {
        print(
          'MessageBubble: Sender user avatar URL: "${senderUser.avatarUrl}"',
        );
        if (senderUser.avatarUrl.isNotEmpty) {
          print(
            'MessageBubble: SUCCESS - Got sender avatar: ${senderUser.avatarUrl}',
          );
          return senderUser.avatarUrl;
        }
      } else {
        // Fallback: Direct Firestore query
        print(
          'MessageBubble: getUserById failed, trying direct Firestore query',
        );
        try {
          final firestore = FirebaseFirestore.instance;
          final userDoc = await firestore
              .collection(AuthRemoteConstants.usersCollectionName)
              .doc(message.senderId)
              .get();
          print(
            'MessageBubble: Direct Firestore query - document exists: ${userDoc.exists}',
          );

          if (userDoc.exists) {
            final data = userDoc.data()!;
            final avatarUrl =
                data[AuthRemoteConstants.avatarUrlField] as String? ?? '';
            print('MessageBubble: Direct Firestore - avatarUrl: "$avatarUrl"');

            if (avatarUrl.isNotEmpty) {
              print(
                'MessageBubble: SUCCESS via direct Firestore - Got sender avatar: $avatarUrl',
              );
              return avatarUrl;
            }
          }
        } catch (e2) {
          print('MessageBubble: Direct Firestore query also failed: $e2');
        }
      }
    } catch (e) {
      print('MessageBubble: Error getting sender avatar: $e');
    }

    print(
      'MessageBubble: Falling back to original avatar URL: "${message.senderAvatarUrl}"',
    );
    return message.senderAvatarUrl; // Fallback to original
  }

  /// Builds the main message container with content.
  Widget _buildMessageContainer(BuildContext context) {
    final theme = Theme.of(context);
    final isFromCurrentUser = message.isFromUser(currentUserId);

    // Check if this is current user even if senderId doesn't match
    final isCurrentUserMessage = isFromCurrentUser;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isCurrentUserMessage
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(
              ChatMessagePageConstants.messageRadius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCurrentUserMessage && _getDisplayName().isNotEmpty)
                Text(
                  _getDisplayName(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              if (!isCurrentUserMessage && _getDisplayName().isNotEmpty)
                const SizedBox(height: 4.0),
              if (message.replyToMessageId != null && repliedMessage != null)
                _buildReplyReference(context, isCurrentUserMessage),

              // File attachment or text content
              if (message.hasFileAttachment)
                _buildFileAttachment(context, isCurrentUserMessage)
              else
                Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isCurrentUserMessage
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (message.editedAt != null) _buildEditedIndicator(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the small referenced message preview when this message is a reply.
  Widget _buildReplyReference(BuildContext context, bool isCurrentUserMessage) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isCurrentUserMessage
            ? theme.colorScheme.onPrimary.withOpacity(0.08)
            : theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color:
              (isCurrentUserMessage
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface)
                  .withOpacity(0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repliedMessage!.senderName.isNotEmpty
                ? repliedMessage!.senderName
                : 'Người dùng',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCurrentUserMessage
                  ? theme.colorScheme.onPrimary.withOpacity(0.9)
                  : theme.colorScheme.onSurface.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),
          Text(
            repliedMessage!.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCurrentUserMessage
                  ? theme.colorScheme.onPrimary.withOpacity(0.9)
                  : theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Shows the context menu for message actions.
  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Calculate menu position - center horizontally below the message
    const menuWidth = 180.0; // Width of context menu
    const menuHeight = 200.0; // Approximate height of context menu

    // Center the menu horizontally relative to the message
    double left = position.dx + (renderBox.size.width / 2) - (menuWidth / 2);
    double top =
        position.dy + renderBox.size.height + 12; // 12px margin below message

    // Adjust horizontal position if menu would go off screen
    if (left + menuWidth > screenSize.width - 16) {
      left = screenSize.width - menuWidth - 16; // 16px margin from right edge
    }
    if (left < 16) {
      left = 16; // 16px margin from left edge
    }

    // Adjust vertical position if menu would go off screen
    if (top + menuHeight > screenSize.height - 100) {
      // Show above the message instead
      top = position.dy - menuHeight - 12;
      // If still off screen above, show at a safe position
      if (top < 100) {
        top = 100; // Safe margin from top
      }
    }

    MessageContextMenu.show(
      context: context,
      position: Offset(left, top),
      message: message,
      currentUserId: currentUserId,
      onReply: onReply,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  /// Builds the edited indicator for modified messages.
  Widget _buildEditedIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        ChatMessagePageConstants.editedIndicator,
        style: theme.textTheme.bodySmall?.copyWith(
          color: message.isFromUser(currentUserId)
              ? theme.colorScheme.onPrimary.withOpacity(0.7)
              : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Builds the message status indicator for sent messages.
  Widget _buildMessageStatus() {
    IconData icon;
    Color color = Colors.grey;

    switch (message.status) {
      case MessageStatus.sending:
        // No icon for sending status (removed clock icon)
        return const SizedBox.shrink();
      case MessageStatus.sent:
        icon = Icons.check;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 16.0, color: color);
  }

  /// Builds the reactions display below the message.
  Widget _buildReactions(BuildContext context) {
    if (message.reactions.isEmpty) return const SizedBox.shrink();

    final bool isCurrentUserMessage =
        message.isFromUser(currentUserId) ||
        false; // Remove backward compatibility

    final reactionCounts = <ReactionType, int>{};
    for (final reaction in message.reactions.values) {
      reactionCounts[reaction] = (reactionCounts[reaction] ?? 0) + 1;
    }

    return Align(
      alignment: isCurrentUserMessage
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: 4.0,
          right: isCurrentUserMessage ? 7.0 : 0.0,
          left: isCurrentUserMessage ? 0.0 : 42.0,
        ),
        child: Wrap(
          spacing: 4.0,
          children: reactionCounts.entries.map((entry) {
            // Check if current user has this reaction
            final currentUserHasReaction = message.reactions.entries.any(
              (mapEntry) =>
                  mapEntry.key == currentUserId && mapEntry.value == entry.key,
            );

            return GestureDetector(
              onTap: () {
                OnlineStatusService.instance.onUserActivity();
                onReactionTap(message.id, entry.key);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: currentUserHasReaction
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.0),
                  border: currentUserHasReaction
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getReactionEmoji(entry.key),
                      style: const TextStyle(
                        fontSize: ChatMessagePageConstants.reactionSize,
                      ),
                    ),
                    if (entry.value > 1) const SizedBox(width: 4.0),
                    if (entry.value > 1)
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Gets the emoji representation for a reaction type.
  String _getReactionEmoji(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return ChatMessagePageConstants.likeReaction;
      case ReactionType.love:
        return ChatMessagePageConstants.loveReaction;
      case ReactionType.sad:
        return ChatMessagePageConstants.sadReaction;
      case ReactionType.angry:
        return ChatMessagePageConstants.angryReaction;
      case ReactionType.laugh:
        return ChatMessagePageConstants.laughReaction;
      case ReactionType.wow:
        return ChatMessagePageConstants.wowReaction;
    }
  }

  /// Gets the display name for the message sender.
  /// For current user messages, use the currentUserName if available.
  /// For other users, use the message.senderName.
  String _getDisplayName() {
    final isFromCurrentUser = message.isFromUser(currentUserId);

    // Check if this is current user even if senderId doesn't match
    // (for backward compatibility with old messages)
    final isCurrentUserMessage = isFromCurrentUser;

    if (isCurrentUserMessage) {
      // For current user, use provided currentUserName or fallback to message.senderName
      return currentUserName ?? message.senderName;
    } else {
      // For other users, use message.senderName, but fetch from database if needed
      if (message.senderName.isEmpty) {
        // Since we know User B ID is f8LkmJxJOIhAEjHCwfPiVrmRiXF2 and name is "Huỳnh Minh Anh"
        if (message.senderId == 'f8LkmJxJOIhAEjHCwfPiVrmRiXF2') {
          return 'Huỳnh Minh Anh';
        }
        // For other users, show generic fallback
        return 'Người dùng khác';
      }
      return message.senderName;
    }
  }

  /// Builds file attachment widget based on message type
  Widget _buildFileAttachment(BuildContext context, bool isCurrentUserMessage) {
    if (message.isImage) {
      return _buildImageAttachment(context, isCurrentUserMessage);
    } else if (message.isVideo) {
      return _buildVideoAttachment(context, isCurrentUserMessage);
    } else if (message.isFile) {
      return _buildDocumentAttachment(context, isCurrentUserMessage);
    }

    // Fallback for unknown file types
    return _buildDocumentAttachment(context, isCurrentUserMessage);
  }

  /// Builds image attachment widget
  Widget _buildImageAttachment(
    BuildContext context,
    bool isCurrentUserMessage,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        OnlineStatusService.instance.onUserActivity();
        _openFile(context);
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250, maxHeight: 250),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SmartImage(
            imageUrl: message.fileUrl!,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
            fallback: Container(
              width: 250,
              height: 250,
              color: theme.colorScheme.surfaceVariant,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds video attachment widget
  Widget _buildVideoAttachment(
    BuildContext context,
    bool isCurrentUserMessage,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        OnlineStatusService.instance.onUserActivity();
        _openFile(context);
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUserMessage
              ? theme.colorScheme.onPrimary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // Video thumbnail or placeholder
            Container(
              width: 226,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: message.thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SmartImage(
                        imageUrl: message.thumbnailUrl!,
                        width: 226,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.videocam,
                  size: 20,
                  color: isCurrentUserMessage
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.fileName ?? 'Video',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isCurrentUserMessage
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (message.fileSize != null)
                        Text(
                          message.fileSizeString,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCurrentUserMessage
                                ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds document/file attachment widget
  Widget _buildDocumentAttachment(
    BuildContext context,
    bool isCurrentUserMessage,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        OnlineStatusService.instance.onUserActivity();
        _openFile(context);
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUserMessage
              ? theme.colorScheme.onPrimary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(),
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Tệp tin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCurrentUserMessage
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null)
                    Text(
                      message.fileSizeString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCurrentUserMessage
                            ? theme.colorScheme.onPrimary.withOpacity(0.7)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.download_outlined,
              color: isCurrentUserMessage
                  ? theme.colorScheme.onPrimary.withOpacity(0.7)
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Gets appropriate icon for file type
  IconData _getFileIcon() {
    final fileType = message.fileType?.toLowerCase() ?? '';

    if (fileType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileType.contains('doc') || fileType.contains('word')) {
      return Icons.description;
    } else if (fileType.contains('xls') || fileType.contains('excel')) {
      return Icons.table_chart;
    } else if (fileType.contains('ppt') || fileType.contains('powerpoint')) {
      return Icons.slideshow;
    } else if (fileType.contains('zip') || fileType.contains('rar')) {
      return Icons.folder_zip;
    } else if (fileType.contains('text') || fileType.contains('txt')) {
      return Icons.text_snippet;
    }

    return Icons.attach_file;
  }

  /// Opens file using external app or browser
  Future<void> _openFile(BuildContext context) async {
    if (message.fileUrl == null || message.fileUrl!.isEmpty) return;

    try {
      final uri = Uri.parse(message.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở tệp'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở tệp: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
