import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/friend.dart';
import '../../../../features/chat_thread/presentation/cubit/open_chat_cubit.dart';
import '../../../../features/chat_thread/presentation/cubit/open_chat_state.dart';
import '../../../../features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';
import '../../../../features/chat_thread/data/repositories/chat_thread_repository_impl.dart';
import '../../../../core/constants/app_route_constants.dart';
import 'package:go_router/go_router.dart';

/// Widget that provides OpenChatCubit for friends functionality
class FriendsWithChatProvider extends StatelessWidget {
  final String currentUserId;
  final Widget child;

  const FriendsWithChatProvider({
    super.key,
    required this.currentUserId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpenChatCubit(
        findOrCreateChatThreadUseCase: FindOrCreateChatThreadUseCase(
          ChatThreadRepositoryImpl(),
        ),
      ),
      child: BlocListener<OpenChatCubit, OpenChatState>(
        listener: (context, state) {
          if (state is OpenChatReady) {
            // Navigate to chat message page with the thread
            final route = AppRouteConstants.chatMessageRoute(
              state.chatThread.id,
              currentUserId: currentUserId,
              otherUserName: state.chatThread.name,
            );
            context.go(route);

            // Reset the cubit state after navigation
            context.read<OpenChatCubit>().reset();
          } else if (state is OpenChatError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );

            // Reset the cubit state after showing error
            context.read<OpenChatCubit>().reset();
          }
        },
        child: child,
      ),
    );
  }
}

/// Mixin for handling chat opening functionality in friends pages
mixin ChatOpeningMixin {
  /// Opens chat with a friend using OpenChatCubit
  void openChatWithFriend(
    BuildContext context,
    Friend friend,
    String currentUserId,
  ) {
    // Check if friend is blocked
    if (friend.isBlock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở chat với người dùng đã bị chặn'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Extract actual friend user ID from composite friendId (format: currentUserId_actualFriendId)
    String actualFriendId = friend.friendId;
    final parts = friend.friendId.split('_');
    if (parts.length == 2) {
      actualFriendId = parts[1]; // Extract the actual friend's user ID
      print(
        'ChatOpeningMixin: Extracted actualFriendId: $actualFriendId from composite: ${friend.friendId}',
      );
    } else {
      print(
        'ChatOpeningMixin: WARNING - friendId format unexpected: ${friend.friendId}',
      );
    }

    // Use OpenChatCubit to handle the chat opening
    context.read<OpenChatCubit>().openChatWithFriend(
      currentUserId: currentUserId,
      friendId: actualFriendId,
      friendName: friend.nickName.isNotEmpty ? friend.nickName : 'Người dùng',
      friendAvatarUrl: '', // Avatar will be handled by SmartAvatar widget
    );

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang mở đoạn chat...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
