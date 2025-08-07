import 'dart:async';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/core/constants/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/chat_message_cubit.dart';
import '../cubit/chat_message_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/reaction_picker.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../../../shared/widgets/refreshable_list_view.dart';

/// Main chat message page that displays a conversation between users.
/// Implements real-time messaging with reactions and message status.
class ChatMessagePage extends StatefulWidget {
  final String threadId;
  final String currentUserId;
  final String otherUserName;

  const ChatMessagePage({
    super.key,
    required this.threadId,
    required this.currentUserId,
    required this.otherUserName,
  });

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedMessageId;
  Timer? _timestampTimer;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timestampTimer?.cancel();
    super.dispose();
  }

  /// Initializes the message stream for the current thread.
  void _initializeMessages() {
    context.read<ChatMessageCubit>().loadMessages(widget.threadId);
  }

  /// Scrolls to the bottom of the message list.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Handles sending a new message.
  void _handleSendMessage(String content) {
    context.read<ChatMessageCubit>().sendMessage(content);

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  /// Handles reaction tap from MessageBubble.
  void _handleReactionTap(String messageId, ReactionType reactionType) {
    // This will be called when user taps existing reactions
    // Show dialog to confirm reaction removal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy cảm xúc'),
        content: Text(
          'Bạn có muốn hủy cảm xúc ${_getReactionEmoji(reactionType)} này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeReaction(messageId, reactionType);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Gets emoji representation for reaction type
  String _getReactionEmoji(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return ChatMessagePageConstants.likeReaction;
      case ReactionType.love:
        return ChatMessagePageConstants.loveReaction;
      case ReactionType.laugh:
        return ChatMessagePageConstants.laughReaction;
      case ReactionType.wow:
        return ChatMessagePageConstants.wowReaction;
      case ReactionType.sad:
        return ChatMessagePageConstants.sadReaction;
      case ReactionType.angry:
        return ChatMessagePageConstants.angryReaction;
    }
  }

  /// Removes a reaction from the specified message
  void _removeReaction(String messageId, ReactionType reactionType) {
    // Use current user ID - this should come from auth service
    context.read<ChatMessageCubit>().removeReaction(
      messageId,
      widget.currentUserId,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hủy cảm xúc ${_getReactionEmoji(reactionType)}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Shows reaction picker for adding reactions to a message.
  void _showReactionPicker(ChatMessage message) {
    ReactionPicker.show(
      context,
      onReactionSelected: (reaction) {
        context.read<ChatMessageCubit>().addReaction(message.id, reaction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ChatMessagePageConstants.reactionAddedMessage),
            duration: Duration(seconds: 1),
          ),
        );
      },
    );
  }

  /// Handles menu selection from AppBar popup menu.
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'ai_summary':
        _showAISummaryFeature();
        break;
    }
  }

  /// Shows AI summary feature placeholder.
  void _showAISummaryFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(ChatMessagePageConstants.aiSummaryFeatureMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handles message tap to toggle timestamp display.
  void _handleMessageTap(String messageId) {
    setState(() {
      if (_selectedMessageId == messageId) {
        _selectedMessageId = null; // Hide timestamp if same message tapped
      } else {
        _selectedMessageId = messageId; // Show timestamp for new message
      }
    });
  }

  /// Handles refresh action when user pulls down to refresh.
  Future<void> _handleRefresh() async {
    await context.read<ChatMessageCubit>().refreshMessages();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ChatMessagePageConstants.refreshedMessage),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// Handles back navigation safely with GoRouter.
  void _handleBackNavigation() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Fallback to home route if can't pop
      context.go(AppRouteConstants.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar with conversation title and actions.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.otherUserName),
      leading: IconButton(
        onPressed: _handleBackNavigation,
        icon: const Icon(Icons.arrow_back),
        tooltip: ChatMessagePageConstants.backTooltip,
      ),
      backgroundColor: ColorConstant.appBarColor,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: ChatMessagePageConstants.moreOptionsTooltip,
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'ai_summary',
              child: Row(
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 12.0),
                  Text('Tóm tắt với AI'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the message list with loading states and error handling.
  Widget _buildMessageList() {
    return BlocBuilder<ChatMessageCubit, ChatMessageState>(
      builder: (context, state) {
        if (state is ChatMessageLoading) {
          return RefreshableListView<ChatMessage>(
            items: const [],
            onRefresh: _handleRefresh,
            isLoading: true,
            scrollController: _scrollController,
            itemBuilder: (context, message, index) => const SizedBox.shrink(),
          );
        }

        if (state is ChatMessageError) {
          return RefreshableListView<ChatMessage>(
            items: const [],
            onRefresh: _handleRefresh,
            errorMessage: state.message,
            onRetry: _initializeMessages,
            scrollController: _scrollController,
            itemBuilder: (context, message, index) => const SizedBox.shrink(),
          );
        }

        if (state is ChatMessageLoaded) {
          return _buildMessageListView(state.messages);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the scrollable message list view with pull-to-refresh functionality.
  Widget _buildMessageListView(List<ChatMessage> messages) {
    return RefreshableListView<ChatMessage>(
      items: messages,
      onRefresh: _handleRefresh,
      scrollController: _scrollController,
      padding: const EdgeInsets.all(16.0),
      refreshedMessage: ChatMessagePageConstants.refreshedMessage,
      showRefreshMessage:
          false, // We handle the message manually in _handleRefresh
      itemBuilder: (context, message, index) {
        final isSelected = _selectedMessageId == message.id;

        return Padding(
          padding: const EdgeInsets.only(
            bottom: ChatMessagePageConstants.messageSpacing,
          ),
          child: MessageBubble(
            message: message,
            isSelected: isSelected,
            onTap: () => _handleMessageTap(message.id),
            onReactionTap: _handleReactionTap,
            onLongPress: () => _showReactionPicker(message),
          ),
        );
      },
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.0,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16.0),
          Text(
            ChatMessagePageConstants.noMessages,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the message input section.
  Widget _buildMessageInput() {
    return MessageInput(
      onSendMessage: _handleSendMessage,
      onAttachmentPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ChatMessagePageConstants.attachmentFeatureMessage),
          ),
        );
      },
    );
  }
}
