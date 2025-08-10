import 'dart:async';
import 'dart:io';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/core/constants/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/chat_message_cubit.dart';
import '../cubit/chat_message_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/reply_preview.dart';

import '../widgets/chat_summary_widget.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../../chat_thread/domain/entities/chat_thread.dart';
import '../../../chat_thread/data/repositories/chat_thread_repository_impl.dart';
import '../../../chat_thread/presentation/pages/group_chat_settings_page.dart';
import '../../../auth/di/auth_dependency_injection.dart';
import '../../../../shared/widgets/refreshable_list_view.dart';
import '../../../../shared/services/file_upload_service.dart';

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

class _ChatMessagePageState extends State<ChatMessagePage>
    with WidgetsBindingObserver {
  ChatThread? _currentChatThread;
  final ScrollController _scrollController = ScrollController();
  String? _selectedMessageId;
  Timer? _timestampTimer;
  bool _isFirstLoad = true; // Track if this is the first time loading messages
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeMessages();
    _setupScrollListener();
    _loadChatThreadInfo();
    _setupOnlineStatusListener();
  }

  /// Sets up scroll listener to mark messages as read when user scrolls
  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Mark messages as read when user scrolls (indicating they're actively viewing)
      if (_scrollController.hasClients) {
        _markMessagesAsReadOnScroll();
      }
    });
  }

  /// Marks messages as read when user scrolls, with debouncing
  Timer? _markAsReadTimer;
  void _markMessagesAsReadOnScroll() {
    // Debounce the mark as read calls to avoid too many requests
    _markAsReadTimer?.cancel();
    _markAsReadTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<ChatMessageCubit>().markMessagesAsRead();
    });
  }

  /// Sets up online status listener for detecting when user comes back online
  void _setupOnlineStatusListener() {
    // Online status listening is disabled - summary only triggered manually
    // This method is kept for potential future use
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _timestampTimer?.cancel();
    _markAsReadTimer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Mark messages as read when app becomes active and user is viewing this chat
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.read<ChatMessageCubit>().markMessagesAsRead();
        }
      });
    }
  }

  /// Initializes the message stream for the current thread.
  /// Handles both regular threads and temporary threads.
  void _initializeMessages() async {
    final cubit = context.read<ChatMessageCubit>();

    // Set current user from widget parameter
    await _setCurrentUserInfo(cubit);

    // Check if this is a temporary thread (starts with 'temp_')
    if (widget.threadId.startsWith('temp_')) {
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
        unreadCounts: {},
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
    String userName = ''; // No default fallback - force get real name
    String? userAvatarUrl;

    // Check if Firebase user matches widget user
    if (FirebaseAuth.instance.currentUser?.uid != widget.currentUserId) {
      // Firebase user mismatch - this could indicate a session issue
    }

    try {
      // Always try to get full name from auth service
      final user = await AuthDependencyInjection.getCurrentUserUseCase();
      if (user != null) {
        // Validate that user ID matches
        if (user.userId == widget.currentUserId) {
          // Try to get a meaningful name
          if (user.fullName.isNotEmpty) {
            userName = user.fullName;
          } else if (user.username.isNotEmpty) {
            userName = user.username;
          } else if (user.email.isNotEmpty) {
            userName = user.email.split('@')[0]; // Use email prefix as fallback
          }

          // Get avatar URL
          userAvatarUrl = user.avatarUrl;
        } else {
          // Force get user by ID directly from Firestore
          try {
            final directUser = await AuthDependencyInjection
                .authRemoteDataSource
                .getUserById(widget.currentUserId);
            if (directUser != null) {
              if (directUser.fullName.isNotEmpty) {
                userName = directUser.fullName;
              } else if (directUser.username.isNotEmpty) {
                userName = directUser.username;
              } else if (directUser.email.isNotEmpty) {
                userName = directUser.email.split('@')[0];
              }

              // Get avatar URL
              userAvatarUrl = directUser.avatarUrl;
            }
          } catch (e2) {
            // Silent failure, will use fallback
          }
        }
      } else {
        // Try direct fetch by ID
        try {
          // Direct Firestore query as fallback since AuthRemoteDataSource has issues
          final firestore = FirebaseFirestore.instance;
          final userDoc = await firestore
              .collection('users')
              .doc(widget.currentUserId)
              .get();
          if (userDoc.exists) {
            final data = userDoc.data()!;

            // Use Firestore data directly
            final fullName = data['fullName'] as String? ?? '';
            final username = data['username'] as String? ?? '';
            final email = data['email'] as String? ?? '';
            final profileImageUrl = data['profileImageUrl'] as String? ?? '';

            if (fullName.isNotEmpty) {
              userName = fullName;
            } else if (username.isNotEmpty) {
              userName = username;
            } else if (email.isNotEmpty) {
              userName = email.split('@')[0];
            }

            // Get avatar URL
            if (profileImageUrl.isNotEmpty) {
              userAvatarUrl = profileImageUrl;
            }
          }
        } catch (e2) {
          // Silent failure, will use fallback
        }
      }
    } catch (e) {
      // Error getting user name from auth service - use fallback
    }

    // If still empty, use Firebase Auth email as last resort
    if (userName.isEmpty) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.email != null) {
        userName = firebaseUser!.email!.split('@')[0];
      } else if (firebaseUser?.displayName != null) {
        userName = firebaseUser!.displayName!;
      } else {
        // Absolutely last resort - use user ID
        userName = 'User_${widget.currentUserId.substring(0, 8)}';
      }
    }

    // Final user info set
    cubit.setCurrentUser(
      userId: widget.currentUserId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
    );
  }

  /// Scrolls to the bottom of the message list.
  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        // Jump instantly to bottom without animation
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  /// Handles sending a new message.
  void _handleSendMessage(String content) {
    context.read<ChatMessageCubit>().sendMessage(content);

    // Scroll to bottom after sending with animation
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _scrollToBottom(animate: true),
    );
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
    final currentUserHasReaction = message.reactions.entries.any(
      (entry) => entry.key == currentUserId && entry.value == reactionType,
    );

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
        _triggerOfflineSummary();
        break;
      case 'group_settings':
        _showGroupSettings();
        break;
    }
  }

  /// Manually triggers AI summary for all messages in current chat
  Future<void> _triggerOfflineSummary() async {
    // Trigger manual summary for current chat
    final cubit = context.read<ChatMessageCubit>();
    final currentState = cubit.state;

    if (currentState is ChatMessageLoaded) {
      if (currentState.messages.isEmpty) {
        print('⚠️ [UI DEBUG] No messages to summarize');
        _showErrorMessage('Không có tin nhắn nào để tóm tắt');
        return;
      }

      try {
        // Use manual summary method which summarizes all messages
        await cubit.manualSummarizeAllMessages(
          allMessages: currentState.messages,
        );
      } catch (e) {
        _showErrorMessage('Lỗi khi tóm tắt: ${e.toString()}');
      }
    } else {
      print(
        '❌ [UI DEBUG] State is not ChatMessageLoaded: ${currentState.runtimeType}',
      );
      _showErrorMessage('Chưa tải được tin nhắn để tóm tắt');
    }
  }

  /// Shows error message in snackbar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows group chat settings page
  void _showGroupSettings() {
    if (_currentChatThread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải thông tin nhóm...')),
      );
      return;
    }

    if (!_currentChatThread!.isGroup) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đây không phải nhóm chat')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatSettingsPage(
          chatThread: _currentChatThread!,
          onUpdate: () {
            // Reload chat thread info after updates
            _loadChatThreadInfo();
          },
        ),
      ),
    );
  }

  /// Shows edit message dialog.
  void _showEditDialog(String messageId, String currentContent) {
    if (!mounted) return;

    final TextEditingController controller = TextEditingController(
      text: currentContent,
    );

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
                    await context.read<ChatMessageCubit>().editMessage(
                      messageId,
                      newContent,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            ChatMessagePageConstants.messageEditedSuccessfully,
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Lỗi chỉnh sửa tin nhắn: ${e.toString()}',
                        ),
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
                  await context.read<ChatMessageCubit>().deleteMessage(
                    messageId,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          ChatMessagePageConstants.messageDeletedSuccessfully,
                        ),
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

  /// Loads chat thread information for group settings
  Future<void> _loadChatThreadInfo() async {
    try {
      final repository = ChatThreadRepositoryImpl();
      final chatThread = await repository.getChatThreadById(widget.threadId);
      if (mounted) {
        setState(() {
          _currentChatThread = chatThread;
        });
      }
    } catch (e) {
      // Error loading chat thread info
    }
  }

  /// Handles file attachment button press - shows file picker options
  Future<void> _handleFileAttachment() async {
    if (_isUploadingFile) return; // Prevent multiple uploads

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Tệp tin'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        await _uploadAndSendFile(image.path, MessageType.image);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chụp ảnh: ${e.toString()}');
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        await _uploadAndSendFile(image.path, MessageType.image);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn ảnh: ${e.toString()}');
    }
  }

  /// Pick video from gallery
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // 5 minute max
      );
      if (video != null) {
        await _uploadAndSendFile(video.path, MessageType.video);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn video: ${e.toString()}');
    }
  }

  /// Pick any file type
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _uploadAndSendFile(filePath, MessageType.file);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi chọn tệp: ${e.toString()}');
    }
  }

  /// Upload file to Cloudinary and send message
  Future<void> _uploadAndSendFile(
    String filePath,
    MessageType messageType,
  ) async {
    setState(() {
      _isUploadingFile = true;
    });

    try {
      // Uploading file

      // Check file size (50MB max)
      final file = File(filePath);
      final fileSize = await file.length();

      if (!FileUploadService.isFileSizeAcceptable(fileSize)) {
        _showErrorSnackBar('Tệp quá lớn. Kích thước tối đa 50MB.');
        return;
      }

      // Check file type is supported
      if (!FileUploadService.isFileTypeSupported(filePath)) {
        _showErrorSnackBar('Loại tệp không được hỗ trợ.');
        return;
      }

      // Upload file to Cloudinary
      final uploadResult = await FileUploadService.uploadFile(
        filePath: filePath,
        chatThreadId: widget.threadId,
      );

      // File uploaded successfully

      // Send message with file attachment
      final now = DateTime.now();
      final messageId =
          'msg_${now.millisecondsSinceEpoch}_${widget.currentUserId}';

      final fileMessage = ChatMessage(
        id: messageId,
        chatThreadId: widget.threadId,
        senderId: widget.currentUserId,
        senderName: 'Bạn', // This will be updated by cubit
        senderAvatarUrl: '', // Will be populated by cubit
        content: uploadResult.fileName, // File name as content
        type: messageType,
        status: MessageStatus.sending,
        sentAt: now,
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: now,
        updatedAt: now,
        // File properties
        fileUrl: uploadResult.fileUrl,
        fileName: uploadResult.fileName,
        fileType: uploadResult.fileType,
        fileSize: uploadResult.fileSize,
        thumbnailUrl: uploadResult.thumbnailUrl,
      );

      // Send via cubit
      await context.read<ChatMessageCubit>().sendFileMessage(fileMessage);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi ${_getFileTypeDisplayName(messageType)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Error uploading file
      _showErrorSnackBar('Lỗi gửi tệp: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingFile = false;
      });
    }
  }

  /// Get display name for file type
  String _getFileTypeDisplayName(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'hình ảnh';
      case MessageType.video:
        return 'video';
      case MessageType.file:
        return 'tệp tin';
      default:
        return 'tệp';
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
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
            if (_currentChatThread?.isGroup == true)
              const PopupMenuItem<String>(
                value: 'group_settings',
                child: Row(
                  children: [
                    Icon(Icons.group_outlined),
                    SizedBox(width: 12.0),
                    Text('Cài đặt nhóm'),
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
        // Show loading list state for initial chat load
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

        // IMPORTANT: For summary states, we should KEEP rendering the message list
        // and the ChatSummaryWidget. Previously, we returned an empty widget which
        // caused the summary widget to be disposed before receiving the Loaded state.
        if (state is ChatMessageSummaryLoading ||
            state is ChatMessageSummaryLoaded ||
            state is ChatMessageSummaryError) {
          final messages = context.read<ChatMessageCubit>().currentMessages;
          return Column(
            children: [
              ChatSummaryWidget(
                isExpanded: _isOfflineSummaryExpanded,
                onExpandToggle: () {
                  setState(() {
                    _isOfflineSummaryExpanded = !_isOfflineSummaryExpanded;
                  });
                },
              ),
              Expanded(child: _buildMessageListView(messages)),
            ],
          );
        }

        if (state is ChatMessageLoaded) {
          // Scroll to bottom when messages are loaded
          if (state.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // First load: jump instantly without animation
              // Subsequent loads: animate for new messages
              _scrollToBottom(animate: !_isFirstLoad);
              _isFirstLoad = false; // Mark that first load is done

              // Mark messages as read after scrolling is done
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  context.read<ChatMessageCubit>().markMessagesAsRead();
                }
              });
            });
          }
          return Column(
            children: [
              ChatSummaryWidget(
                isExpanded: _isOfflineSummaryExpanded,
                onExpandToggle: () {
                  setState(() {
                    _isOfflineSummaryExpanded = !_isOfflineSummaryExpanded;
                  });
                },
              ),
              Expanded(child: _buildMessageListView(state.messages)),
            ],
          );
        }

        if (state is ChatMessageTemporary) {
          // Show empty message list for temporary threads
          return Column(
            children: [
              ChatSummaryWidget(
                isExpanded: _isOfflineSummaryExpanded,
                onExpandToggle: () {
                  setState(() {
                    _isOfflineSummaryExpanded = !_isOfflineSummaryExpanded;
                  });
                },
              ),
              Expanded(child: _buildMessageListView(const [])),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  bool _isOfflineSummaryExpanded = false;

  /// Builds the scrollable message list view with pull-to-refresh functionality.
  Widget _buildMessageListView(List<ChatMessage> messages) {
    return RefreshableListView<ChatMessage>(
      items: messages,
      onRefresh: _handleRefresh,
      scrollController: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, message, index) {
        final isSelected = _selectedMessageId == message.id;
        final hasUserReacted = message.reactions.containsKey(
          widget.currentUserId,
        );
        final isCurrentUserSender = message.senderId == widget.currentUserId;

        return Padding(
          padding: const EdgeInsets.only(
            bottom: ChatMessagePageConstants.messageSpacing,
          ),
          child: Align(
            alignment: isCurrentUserSender
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bubble
                MessageBubble(
                  message: message,
                  isSelected: isSelected,
                  currentUserId: widget.currentUserId,
                  currentUserName: context
                      .read<ChatMessageCubit>()
                      .currentUserName,
                  repliedMessage: _findRepliedMessage(messages, message),
                  onTap: () => _handleMessageTap(message.id),
                  onReactionTap: _handleReactionTap,
                  onLongPress: () => _showReactionPicker(message),
                  onReply: () => _handleReply(message.id),
                  onEdit: () => _handleEdit(message.id, message.content),
                  onDelete: () => _handleDelete(message.id),
                ),

                if (!hasUserReacted)
                  Align(
                    alignment: isCurrentUserSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4.0,
                        right: isCurrentUserSender ? 25.0 : 0.0,
                        left: isCurrentUserSender ? 0.0 : 55.0,
                      ),
                      child: Tooltip(
                        message: ChatMessagePageConstants.addReactionTooltip,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _showReactionPicker(message),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              Icons.add_reaction_outlined,
                              size: ChatMessagePageConstants.reactionSize,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Finds the message being replied to for a given message, if any
  ChatMessage? _findRepliedMessage(
    List<ChatMessage> messages,
    ChatMessage current,
  ) {
    final replyId = current.replyToMessageId;
    if (replyId == null) return null;
    try {
      return messages.firstWhere((m) => m.id == replyId);
    } catch (_) {
      return null;
    }
  }

  /// Builds the message input section.
  Widget _buildMessageInput() {
    return BlocBuilder<ChatMessageCubit, ChatMessageState>(
      builder: (context, state) {
        final cubit = context.read<ChatMessageCubit>();
        final replyToMessageId = cubit.replyToMessageId;

        // Find the reply message if replying
        ChatMessage? replyToMessage;
        if (replyToMessageId != null) {
          if (state is ChatMessageLoaded) {
            try {
              replyToMessage = state.messages.firstWhere(
                (msg) => msg.id == replyToMessageId,
              );
            } catch (e) {
              // Message not found, clear reply state
              cubit.clearReply();
            }
          } else if (state is ChatMessageSending) {
            try {
              replyToMessage = state.messages.firstWhere(
                (msg) => msg.id == replyToMessageId,
              );
            } catch (e) {}
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
              onAttachmentPressed: _isUploadingFile
                  ? null
                  : _handleFileAttachment,
            ),

            // File upload progress indicator
            if (_isUploadingFile)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang tải tệp lên...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
