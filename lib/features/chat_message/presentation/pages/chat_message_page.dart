import 'dart:async';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/core/constants/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/chat_message_cubit.dart';
import '../cubit/chat_message_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/reply_preview.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../../chat_thread/domain/entities/chat_thread.dart';
import '../../../auth/di/auth_dependency_injection.dart';
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
  String? _replyToMessageId;

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
  /// Handles both regular threads and temporary threads.
  void _initializeMessages() async {
    final cubit = context.read<ChatMessageCubit>();
    
    // Set current user from widget parameter  
    await _setCurrentUserInfo(cubit);
    
    print('ChatMessagePage: Initialized with currentUserId: ${widget.currentUserId}');
    print('ChatMessagePage: Thread ID: ${widget.threadId}');
    
    // Check if this is a temporary thread (starts with 'temp_')
    if (widget.threadId.startsWith('temp_')) {
      print('ChatMessagePage: This is a temporary thread');
      // For temporary threads, create a temporary ChatThread object
      final now = DateTime.now();
      final temporaryThread = ChatThread(
        id: widget.threadId,
        name: widget.otherUserName,
        lastMessage: '',
        lastMessageTime: now,
        avatarUrl: '', // Will be handled by SmartAvatar widget
        members: [widget.currentUserId, _extractFriendIdFromTempThread()],
        isGroup: false,
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
      );
      
      cubit.loadTemporaryThread(temporaryThread);
    } else {
      // For regular threads, load messages normally
      cubit.loadMessages(widget.threadId);
    }
  }

  /// Extracts friend ID from temporary thread ID format: temp_<friendId>_<timestamp>
  String _extractFriendIdFromTempThread() {
    final parts = widget.threadId.split('_');
    if (parts.length >= 3) {
      return parts[1]; // Second part should be friend ID
    }
    return 'unknown'; // Fallback
  }

  /// Sets current user information from widget parameter (with auth service name)
  Future<void> _setCurrentUserInfo(ChatMessageCubit cubit) async {
    print('ChatMessagePage: Setting user info - using widget currentUserId: ${widget.currentUserId}');
    print('ChatMessagePage: Firebase currentUser: ${FirebaseAuth.instance.currentUser?.uid}');
    print('ChatMessagePage: Firebase currentUser email: ${FirebaseAuth.instance.currentUser?.email}');
    
    String userName = 'Current User'; // Default fallback name
    
    // Check if Firebase user matches widget user
    if (FirebaseAuth.instance.currentUser?.uid != widget.currentUserId) {
      print('ChatMessagePage: WARNING - Firebase user (${FirebaseAuth.instance.currentUser?.uid}) != widget user (${widget.currentUserId})');
    }
    
    try {
      // Always try to get full name from auth service
      print('ChatMessagePage: Calling getCurrentUserUseCase...');
      final user = await AuthDependencyInjection.getCurrentUserUseCase();
      print('ChatMessagePage: getCurrentUserUseCase result: $user');
      
      if (user != null) {
        print('ChatMessagePage: Auth user data - ID: "${user.userId}", fullName: "${user.fullName}", username: "${user.username}", email: "${user.email}"');
        print('ChatMessagePage: User fields lengths - fullName: ${user.fullName.length}, username: ${user.username.length}, email: ${user.email.length}');
        
        // Validate that user ID matches
        if (user.userId == widget.currentUserId) {
          // Try to get a meaningful name
          if (user.fullName.isNotEmpty) {
            userName = user.fullName;
            print('ChatMessagePage: Using fullName: $userName');
          } else if (user.username.isNotEmpty) {
            userName = user.username;
            print('ChatMessagePage: Using username: $userName');
          } else if (user.email.isNotEmpty) {
            userName = user.email.split('@')[0]; // Use email prefix as fallback
            print('ChatMessagePage: Using email prefix: $userName');
          }
          
          print('ChatMessagePage: Final user name selected: $userName');
        } else {
          print('ChatMessagePage: ERROR - Auth user ID (${user.userId}) does not match widget currentUserId (${widget.currentUserId})');
          // Force get user by ID directly from Firestore
          try {
            print('ChatMessagePage: Attempting direct fetch by userId: ${widget.currentUserId}');
            final directUser = await AuthDependencyInjection.authRemoteDataSource.getUserById(widget.currentUserId);
            if (directUser != null) {
              if (directUser.fullName.isNotEmpty) {
                userName = directUser.fullName;
              } else if (directUser.username.isNotEmpty) {
                userName = directUser.username;
              } else if (directUser.email.isNotEmpty) {
                userName = directUser.email.split('@')[0];
              }
              print('ChatMessagePage: Direct fetch successful - Final name: $userName');
            }
          } catch (e2) {
            print('ChatMessagePage: Direct fetch failed: $e2');
          }
        }
      } else {
        print('ChatMessagePage: Auth service returned null user');
        // Try direct fetch by ID
        try {
          print('ChatMessagePage: Attempting direct fetch by userId: ${widget.currentUserId}');
          final directUser = await AuthDependencyInjection.authRemoteDataSource.getUserById(widget.currentUserId);
          if (directUser != null) {
            if (directUser.fullName.isNotEmpty) {
              userName = directUser.fullName;
            } else if (directUser.username.isNotEmpty) {
              userName = directUser.username;
            } else if (directUser.email.isNotEmpty) {
              userName = directUser.email.split('@')[0];
            }
            print('ChatMessagePage: Direct fetch successful - Final name: $userName');
          }
        } catch (e2) {
          print('ChatMessagePage: Direct fetch failed: $e2');
        }
      }
    } catch (e, stackTrace) {
      print('ChatMessagePage: Error getting user name from auth service: $e');
      print('ChatMessagePage: Stack trace: $stackTrace');
      // Use default name
    }
    
    cubit.setCurrentUser(
      userId: widget.currentUserId,
      userName: userName,
    );
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

  /// Handles reply to a message.
  void _handleReply(String messageId) {
    context.read<ChatMessageCubit>().setReplyToMessage(messageId);
  }

  /// Handles editing a message.
  void _handleEdit(String messageId, String currentContent) {
    _showEditDialog(messageId, currentContent);
  }

  /// Handles deleting a message.
  void _handleDelete(String messageId) {
    _showDeleteConfirmation(messageId);
  }

  /// Handles reaction tap from MessageBubble.
  void _handleReactionTap(String messageId, ReactionType reactionType) {
    // Find the message to check if current user has this reaction
    final cubit = context.read<ChatMessageCubit>();
    final messages = cubit.currentMessages;
    final message = messages.firstWhere((msg) => msg.id == messageId);
    
    // Check if current user has this reaction
    final currentUserId = widget.currentUserId;
    final currentUserHasReaction = message.reactions.entries
        .any((entry) => entry.key == currentUserId && entry.value == reactionType);
    
    if (currentUserHasReaction) {
      // User can remove their own reaction
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
    } else {
      // User wants to add this reaction (or change to this reaction)
      cubit.addReaction(messageId, reactionType);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ChatMessagePageConstants.reactionAddedMessage),
          duration: Duration(seconds: 1),
        ),
      );
    }
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
    context.read<ChatMessageCubit>().removeReaction(messageId);
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

  /// Shows edit message dialog.
  void _showEditDialog(String messageId, String currentContent) {
    if (!mounted) return;
    
    final TextEditingController controller = TextEditingController(text: currentContent);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(ChatMessagePageConstants.editMessageTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: ChatMessagePageConstants.editMessageHint,
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(ChatMessagePageConstants.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              Navigator.of(dialogContext).pop();
              
              if (newContent.isNotEmpty && newContent != currentContent) {
                try {
                  if (mounted) {
                    await context.read<ChatMessageCubit>().editMessage(messageId, newContent);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(ChatMessagePageConstants.messageEditedSuccessfully),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi chỉnh sửa tin nhắn: ${e.toString()}'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(ChatMessagePageConstants.editMessageSaveButton),
          ),
        ],
      ),
    );
  }

  /// Shows delete confirmation dialog.
  void _showDeleteConfirmation(String messageId) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(ChatMessagePageConstants.deleteConfirmTitle),
        content: const Text(ChatMessagePageConstants.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(ChatMessagePageConstants.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              try {
                // Use the original context, not dialog context
                if (mounted) {
                  await context.read<ChatMessageCubit>().deleteMessage(messageId);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(ChatMessagePageConstants.messageDeletedSuccessfully),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi xóa tin nhắn: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(ChatMessagePageConstants.deleteConfirmButton),
          ),
        ],
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

        if (state is ChatMessageTemporary) {
          // Show empty message list for temporary threads
          return _buildMessageListView(const []);
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
            currentUserId: widget.currentUserId,
            currentUserName: context.read<ChatMessageCubit>().currentUserName,
            onTap: () => _handleMessageTap(message.id),
            onReactionTap: _handleReactionTap,
            onLongPress: () => _showReactionPicker(message),
            onReply: () => _handleReply(message.id),
            onEdit: () => _handleEdit(message.id, message.content),
            onDelete: () => _handleDelete(message.id),
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
    return BlocBuilder<ChatMessageCubit, ChatMessageState>(
      builder: (context, state) {
        final cubit = context.read<ChatMessageCubit>();
        final replyToMessageId = cubit.replyToMessageId;
        
        // Find the reply message if replying
        ChatMessage? replyToMessage;
        if (replyToMessageId != null && state is ChatMessageLoaded) {
          try {
            replyToMessage = state.messages.firstWhere(
              (msg) => msg.id == replyToMessageId,
            );
          } catch (e) {
            // Message not found, clear reply state
            cubit.clearReply();
          }
        }
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview
            if (replyToMessage != null)
              ReplyPreview(
                replyToMessage: replyToMessage,
                onCancel: () => cubit.clearReply(),
              ),
            
            // Message input
            MessageInput(
              onSendMessage: _handleSendMessage,
              onAttachmentPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(ChatMessagePageConstants.attachmentFeatureMessage),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
