import 'package:flutter/material.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/shared/services/online_status_service.dart';
import '../../constants/chat_message_page_constants.dart';

/// Widget that shows a preview of the message being replied to.
/// Displays above the message input when user is replying to a message.
class ReplyPreview extends StatelessWidget {
  final ChatMessage replyToMessage;
  final VoidCallback onCancel;

  const ReplyPreview({
    super.key,
    required this.replyToMessage,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${ChatMessagePageConstants.replyingToPrefix} ${replyToMessage.senderName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTruncatedContent(replyToMessage.content),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              OnlineStatusService.instance.onUserActivity();
              onCancel();
            },
            icon: Icon(
              Icons.close,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: ChatMessagePageConstants.cancelReplyButton,
          ),
        ],
      ),
    );
  }

  /// Truncates content to a reasonable length for preview.
  String _getTruncatedContent(String content) {
    const maxLength = 100;
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }
}
