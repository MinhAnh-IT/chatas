import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/constants/chat_thread_list_page_constants.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_state.dart';
import 'package:chatas/features/chat_thread/presentation/widgets/delete_chat_thread_dialog.dart';
import 'package:chatas/shared/utils/date_utils.dart' as app_date_utils;
import 'package:chatas/shared/widgets/smart_image.dart';

/// A custom list tile widget for displaying chat threads with delete functionality.
class ChatThreadListTile extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback? onTap;

  const ChatThreadListTile({super.key, required this.thread, this.onTap});

  /// Handles the long press gesture to show delete options.
  void _handleLongPress(BuildContext context) {
    DeleteChatThreadDialog.show(
      context: context,
      threadName: thread.name,
      onConfirmDelete: () => _deleteChatThread(context),
    );
  }

  /// Deletes the chat thread and shows appropriate feedback.
  void _deleteChatThread(BuildContext context) {
    final cubit = context.read<ChatThreadListCubit>();
    cubit.deleteChatThread(thread.id);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(ChatThreadListPageConstants.deleteSuccess),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
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
            child: ListTile(
              leading: Stack(
                children: [
                  SmartAvatar(
                    imageUrl: thread.avatarUrl,
                    radius: ChatThreadListPageConstants.avatarRadius,
                    fallbackText: thread.name,
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
                ],
              ),
              title: Text(
                thread.name,
                style: TextStyle(color: isDeleting ? Colors.grey : null),
              ),
              subtitle: Text(
                thread.lastMessage,
                style: TextStyle(color: isDeleting ? Colors.grey : null),
              ),
              trailing: Text(
                app_date_utils.DateUtils.formatTime(thread.lastMessageTime),
                style: TextStyle(
                  fontSize: ChatThreadListPageConstants.trailingFontSize,
                  color: isDeleting ? Colors.grey : null,
                ),
              ),
              onTap: isDeleting ? null : onTap,
              onLongPress: isDeleting ? null : () => _handleLongPress(context),
              enabled: !isDeleting,
            ),
          );
        },
      ),
    );
  }
}
