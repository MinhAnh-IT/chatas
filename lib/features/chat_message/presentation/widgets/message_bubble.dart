import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../../../shared/utils/date_utils.dart' as app_date_utils;
import 'message_context_menu.dart';
import '../../../../shared/widgets/smart_image.dart';

/// Widget for displaying a single chat message bubble.
/// Handles different message types, reactions, and selection states.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSelected;
  final String currentUserId;
  final String? currentUserName; // Add current user name
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
    
    print('MessageBubble: messageId=${message.id}, senderId="${message.senderId}", currentUserId="$currentUserId", isFromCurrentUser=$isFromCurrentUser, senderName="${message.senderName}"');
    
    // Check if this is current user even if senderId doesn't match
    // More specific backward compatibility - only for messages that should be from current user
    final isCurrentUserMessage = isFromCurrentUser || 
        (message.senderId == 'current_user' && message.senderName == 'Current User');
        
    print('MessageBubble: isCurrentUserMessage=$isCurrentUserMessage');
        
    return GestureDetector(
      onTap: onTap,
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
    final isCurrentUserMessage = message.isFromUser(currentUserId) || 
        (message.senderId == 'current_user' && message.senderName == 'Current User');

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
    return SmartAvatar(
      imageUrl: message.senderAvatarUrl,
      radius: ChatMessagePageConstants.avatarRadius,
      fallbackText: message.senderName,
    );
  }

  /// Builds the main message container with content.
  Widget _buildMessageContainer(BuildContext context) {
    final theme = Theme.of(context);
    final isFromCurrentUser = message.isFromUser(currentUserId);
    
    // Check if this is current user even if senderId doesn't match
    final isCurrentUserMessage = isFromCurrentUser || 
        (message.senderId == 'current_user' && message.senderName == 'Current User');

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
    double top = position.dy + renderBox.size.height + 12; // 12px margin below message
    
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
    
    print('MessageBubble: Showing context menu at position: ($left, $top)');
    print('MessageBubble: Message position: (${position.dx}, ${position.dy})');
    print('MessageBubble: Message size: ${renderBox.size}');
    
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

    final reactionCounts = <ReactionType, int>{};
    for (final reaction in message.reactions.values) {
      reactionCounts[reaction] = (reactionCounts[reaction] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Wrap(
        spacing: 4.0,
        children: reactionCounts.entries.map((entry) {
          // Check if current user has this reaction
          final currentUserHasReaction = message.reactions.entries
              .any((mapEntry) => mapEntry.key == currentUserId && mapEntry.value == entry.key);
          
          return GestureDetector(
            onTap: () => onReactionTap(message.id, entry.key),
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
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
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
    final isCurrentUserMessage = isFromCurrentUser || 
        (message.senderId == 'current_user' && message.senderName == 'Current User');
    
    if (isCurrentUserMessage) {
      // For current user, use provided currentUserName or fallback to message.senderName
      return currentUserName ?? message.senderName;
    } else {
      // For other users, use message.senderName, but fetch from database if needed
      if (message.senderName == 'Current User' || message.senderName.isEmpty) {
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
}
