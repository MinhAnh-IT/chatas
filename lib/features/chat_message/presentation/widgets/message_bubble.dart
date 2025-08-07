import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../../../shared/utils/date_utils.dart' as app_date_utils;

/// Widget for displaying a single chat message bubble.
/// Handles different message types, reactions, and selection states.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(String messageId, ReactionType reactionType) onReactionTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSelected,
    required this.onTap,
    required this.onReactionTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: ChatMessagePageConstants.messageSpacing / 2,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: message.isFromCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isSelected) _buildTimestamp(context),
            Row(
              mainAxisAlignment: message.isFromCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!message.isFromCurrentUser) _buildAvatar(),
                if (!message.isFromCurrentUser) const SizedBox(width: 8.0),
                Flexible(
                  child: _buildMessageContainer(context),
                ),
                if (message.isFromCurrentUser) const SizedBox(width: 8.0),
                if (message.isFromCurrentUser) _buildMessageStatus(),
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
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        timestampText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        textAlign: message.isFromCurrentUser ? TextAlign.end : TextAlign.start,
      ),
    );
  }

  /// Builds the user avatar for received messages.
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: ChatMessagePageConstants.avatarRadius,
      backgroundImage: message.senderAvatarUrl.isNotEmpty
          ? NetworkImage(message.senderAvatarUrl)
          : null,
      child: message.senderAvatarUrl.isEmpty
          ? Text(message.senderName.isNotEmpty ? message.senderName[0] : '?')
          : null,
    );
  }

  /// Builds the main message container with content.
  Widget _buildMessageContainer(BuildContext context) {
    final theme = Theme.of(context);
    final isFromCurrentUser = message.isFromCurrentUser;
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isFromCurrentUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(ChatMessagePageConstants.messageRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isFromCurrentUser && message.senderName.isNotEmpty)
                Text(
                  message.senderName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              if (!isFromCurrentUser && message.senderName.isNotEmpty)
                const SizedBox(height: 4.0),
              Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isFromCurrentUser
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

  /// Builds the edited indicator for modified messages.
  Widget _buildEditedIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        'đã chỉnh sửa',
        style: theme.textTheme.bodySmall?.copyWith(
          color: message.isFromCurrentUser
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
    
    return Icon(
      icon,
      size: 16.0,
      color: color,
    );
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
          return GestureDetector(
            onTap: () => onReactionTap(message.id, entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getReactionEmoji(entry.key),
                    style: const TextStyle(fontSize: ChatMessagePageConstants.reactionSize),
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
}
