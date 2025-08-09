import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/constants/chat_thread_list_page_constants.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_state.dart';
import 'package:chatas/features/chat_thread/presentation/widgets/delete_chat_thread_dialog.dart';
import 'package:chatas/shared/utils/date_utils.dart' as app_date_utils;
import 'package:chatas/shared/widgets/smart_image.dart';
import 'package:chatas/features/auth/di/auth_dependency_injection.dart';

/// A custom list tile widget for displaying chat threads with delete functionality.
class ChatThreadListTile extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback? onTap;

  const ChatThreadListTile({super.key, required this.thread, this.onTap});

  /// Gets the friend's avatar URL dynamically for 1-on-1 chats
  Future<String> _getFriendAvatarUrl() async {
    print(
      'ChatThreadListTile: _getFriendAvatarUrl called for thread: ${thread.id}',
    );
    print('ChatThreadListTile: thread.avatarUrl = "${thread.avatarUrl}"');
    print('ChatThreadListTile: thread.isGroup = ${thread.isGroup}');
    print('ChatThreadListTile: thread.members = ${thread.members}');

    // If avatar URL already exists, use it
    if (thread.avatarUrl.isNotEmpty) {
      print(
        'ChatThreadListTile: Using existing avatar URL: ${thread.avatarUrl}',
      );
      return thread.avatarUrl;
    }

    // For 1-on-1 chats, get friend's avatar from their user profile
    if (!thread.isGroup && thread.members.length == 2) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      print('ChatThreadListTile: Current user ID: $currentUserId');

      final friendId = thread.members.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      print('ChatThreadListTile: Friend ID identified: $friendId');

      if (friendId.isNotEmpty) {
        try {
          print(
            'ChatThreadListTile: Calling getUserById for friendId: $friendId',
          );
          final friendUser = await AuthDependencyInjection.authRemoteDataSource
              .getUserById(friendId);
          print(
            'ChatThreadListTile: getUserById returned: ${friendUser != null ? "user found" : "null"}',
          );

          if (friendUser != null) {
            print(
              'ChatThreadListTile: Friend user avatar URL: "${friendUser.avatarUrl}"',
            );
            if (friendUser.avatarUrl.isNotEmpty) {
              print(
                'ChatThreadListTile: SUCCESS - Got friend avatar for $friendId: ${friendUser.avatarUrl}',
              );
              return friendUser.avatarUrl;
            } else {
              print('ChatThreadListTile: Friend user has empty avatar URL');
            }
          } else {
            // Fallback: Direct Firestore query like in ChatMessagePage
            print(
              'ChatThreadListTile: getUserById failed, trying direct Firestore query',
            );
            try {
              final firestore = FirebaseFirestore.instance;
              final userDoc = await firestore
                  .collection('users')
                  .doc(friendId)
                  .get();
              print(
                'ChatThreadListTile: Direct Firestore query - document exists: ${userDoc.exists}',
              );

              if (userDoc.exists) {
                final data = userDoc.data()!;
                final avatarUrl = data['avatarUrl'] as String? ?? '';
                print(
                  'ChatThreadListTile: Direct Firestore - avatarUrl: "$avatarUrl"',
                );

                if (avatarUrl.isNotEmpty) {
                  print(
                    'ChatThreadListTile: SUCCESS via direct Firestore - Got friend avatar: $avatarUrl',
                  );
                  return avatarUrl;
                }
              }
            } catch (e2) {
              print(
                'ChatThreadListTile: Direct Firestore query also failed: $e2',
              );
            }
          }
        } catch (e) {
          print('ChatThreadListTile: ERROR getting friend avatar: $e');
        }
      } else {
        print('ChatThreadListTile: Friend ID is empty - cannot get avatar');
      }
    } else {
      print('ChatThreadListTile: Not a 1-on-1 chat or wrong member count');
    }

    print(
      'ChatThreadListTile: Falling back to original avatar URL: "${thread.avatarUrl}"',
    );
    return thread.avatarUrl; // Fallback to original
  }

  /// Gets the display name dynamically for 1-on-1 chats
  Future<String> _getDisplayName() async {
    print(
      'ChatThreadListTile: _getDisplayName called for thread: ${thread.id}',
    );
    print('ChatThreadListTile: thread.name = "${thread.name}"');
    print('ChatThreadListTile: thread.isGroup = ${thread.isGroup}');

    // For group chats, use the group name
    if (thread.isGroup) {
      return thread.name;
    }

    // For 1-on-1 chats, get the friend's name
    if (thread.members.length == 2) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      print('ChatThreadListTile: Current user ID: $currentUserId');

      final friendId = thread.members.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      print('ChatThreadListTile: Friend ID identified: $friendId');

      if (friendId.isNotEmpty) {
        try {
          print(
            'ChatThreadListTile: Calling getUserById for friendId: $friendId',
          );
          final friendUser = await AuthDependencyInjection.authRemoteDataSource
              .getUserById(friendId);
          print(
            'ChatThreadListTile: getUserById returned: ${friendUser != null ? "user found" : "null"}',
          );

          if (friendUser != null) {
            final friendName = friendUser.fullName.isNotEmpty
                ? friendUser.fullName
                : friendUser.username.isNotEmpty
                ? friendUser.username
                : 'Người dùng';
            print(
              'ChatThreadListTile: SUCCESS - Got friend name for $friendId: $friendName',
            );
            return friendName;
          } else {
            // Fallback: Direct Firestore query
            print(
              'ChatThreadListTile: getUserById failed, trying direct Firestore query',
            );
            try {
              final firestore = FirebaseFirestore.instance;
              final userDoc = await firestore
                  .collection('users')
                  .doc(friendId)
                  .get();
              print(
                'ChatThreadListTile: Direct Firestore query - document exists: ${userDoc.exists}',
              );

              if (userDoc.exists) {
                final data = userDoc.data()!;
                final fullName = data['fullName'] as String? ?? '';
                final username = data['username'] as String? ?? '';
                final displayName = fullName.isNotEmpty
                    ? fullName
                    : username.isNotEmpty
                    ? username
                    : 'Người dùng';
                print(
                  'ChatThreadListTile: SUCCESS via direct Firestore - Got friend name: $displayName',
                );
                return displayName;
              }
            } catch (e2) {
              print(
                'ChatThreadListTile: Direct Firestore query also failed: $e2',
              );
            }
          }
        } catch (e) {
          print('ChatThreadListTile: ERROR getting friend name: $e');
        }
      } else {
        print('ChatThreadListTile: Friend ID is empty - cannot get name');
      }
    }

    print(
      'ChatThreadListTile: Falling back to original name: "${thread.name}"',
    );
    return thread.name; // Fallback to original
  }

  /// Handles the long press gesture to show delete options.
  void _handleLongPress(BuildContext context) {
    DeleteChatThreadDialog.show(
      context: context,
      threadName: thread.name,
      onConfirmDelete: () => _deleteChatThread(context),
    );
  }

  /// Hides the chat thread for the current user and shows appropriate feedback.
  void _deleteChatThread(BuildContext context) {
    final cubit = context.read<ChatThreadListCubit>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    cubit.hideChatThread(thread.id, currentUserId);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ẩn đoạn chat "${thread.name}"'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows error message when deletion fails.
  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ChatThreadListPageConstants.deleteError}: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final unreadCount = thread.getUnreadCount(currentUserId);

    return BlocListener<ChatThreadListCubit, ChatThreadListState>(
      listener: (context, state) {
        if (state is ChatThreadListError) {
          // Check if this is a delete error for this specific thread
          if (state.message.contains('Failed to delete chat')) {
            _showErrorMessage(context, state.message);
          }
        }
      },
      child: BlocBuilder<ChatThreadListCubit, ChatThreadListState>(
        builder: (context, state) {
          final isDeleting =
              state is ChatThreadDeleting && state.threadId == thread.id;

          return Opacity(
            opacity: isDeleting ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: unreadCount > 0
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Stack(
                  children: [
                    FutureBuilder<String>(
                      future: _getFriendAvatarUrl(),
                      builder: (context, snapshot) {
                        final avatarUrl = snapshot.data ?? thread.avatarUrl;
                        print(
                          'ChatThreadListTile: thread.name=${thread.name}, thread.avatarUrl=${thread.avatarUrl}, dynamicAvatarUrl=$avatarUrl',
                        );
                        return FutureBuilder<String>(
                          future: _getDisplayName(),
                          builder: (context, nameSnapshot) {
                            final displayName =
                                nameSnapshot.data ?? thread.name;
                            return SmartAvatar(
                              imageUrl: avatarUrl,
                              radius: ChatThreadListPageConstants.avatarRadius,
                              fallbackText: displayName,
                              showBorder: true,
                              showShadow: true,
                            );
                          },
                        );
                      },
                    ),
                    if (isDeleting)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Unread indicator dot
                    if (unreadCount > 0 && !isDeleting)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: FutureBuilder<String>(
                  future: _getDisplayName(),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? thread.name;
                    return Text(
                      displayName,
                      style: TextStyle(
                        color: isDeleting ? Colors.grey : null,
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
                subtitle: Text(
                  thread.lastMessage,
                  style: TextStyle(
                    color: isDeleting ? Colors.grey : null,
                    fontWeight: unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      app_date_utils.DateUtils.formatTime(
                        thread.lastMessageTime,
                      ),
                      style: TextStyle(
                        fontSize: ChatThreadListPageConstants.trailingFontSize,
                        color: isDeleting ? Colors.grey : null,
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (unreadCount > 0 && !isDeleting)
                      const SizedBox(height: 4),
                    if (unreadCount > 0 && !isDeleting)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                onTap: isDeleting ? null : onTap,
                onLongPress: isDeleting
                    ? null
                    : () => _handleLongPress(context),
                enabled: !isDeleting,
              ),
            ),
          );
        },
      ),
    );
  }
}
