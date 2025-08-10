import 'package:flutter/material.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../../../shared/services/online_status_service.dart';

/// Widget for composing and sending new messages.
/// Includes text input, send button, and reaction picker.
class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onAttachmentPressed;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.onAttachmentPressed,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Handles sending a message when the send button is pressed.
  void _handleSendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      OnlineStatusService.instance.onUserActivity();
      widget.onSendMessage(text);
      _textController.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  /// Updates the composing state based on text input.
  void _handleTextChanged(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (widget.onAttachmentPressed != null) _buildAttachmentButton(theme),
          if (widget.onAttachmentPressed != null) const SizedBox(width: 8.0),
          Expanded(child: _buildTextInput(theme)),
          const SizedBox(width: 8.0),
          _buildSendButton(theme),
        ],
      ),
    );
  }

  /// Builds the attachment button for adding files or images.
  Widget _buildAttachmentButton(ThemeData theme) {
    return IconButton(
      onPressed: () {
        OnlineStatusService.instance.onUserActivity();
        if (widget.onAttachmentPressed != null) {
          widget.onAttachmentPressed!();
        }
      },
      icon: Icon(
        Icons.attach_file,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      tooltip: 'Đính kèm tệp',
    );
  }

  /// Builds the text input field for message composition.
  Widget _buildTextInput(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: ChatMessagePageConstants.inputHeight,
        maxHeight: 120.0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: _handleTextChanged,
        onSubmitted: (_) => _handleSendMessage(),
        onTap: () {
          OnlineStatusService.instance.onUserActivity();
        },
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: ChatMessagePageConstants.messageHint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  /// Builds the send button that appears when there's text to send.
  Widget _buildSendButton(ThemeData theme) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: _isComposing
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _isComposing
            ? () {
                OnlineStatusService.instance.onUserActivity();
                _handleSendMessage();
              }
            : null,
        icon: Icon(
          Icons.send,
          color: _isComposing
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.4),
          size: 20.0,
        ),
        tooltip: ChatMessagePageConstants.sendTooltip,
      ),
    );
  }
}
