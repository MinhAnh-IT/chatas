import 'package:flutter/material.dart';
import '../../constants/chat_thread_list_page_constants.dart';

/// A dialog widget for confirming chat thread deletion.
class DeleteChatThreadDialog extends StatelessWidget {
  final String threadName;
  final VoidCallback onConfirmDelete;

  const DeleteChatThreadDialog({
    super.key,
    required this.threadName,
    required this.onConfirmDelete,
  });

  /// Shows the delete confirmation dialog.
  static Future<void> show({
    required BuildContext context,
    required String threadName,
    required VoidCallback onConfirmDelete,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeleteChatThreadDialog(
        threadName: threadName,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ChatThreadListPageConstants.deleteTitle),
      content: Text(
        '${ChatThreadListPageConstants.deleteMessage}\n\n"$threadName"',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(ChatThreadListPageConstants.deleteCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirmDelete();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text(ChatThreadListPageConstants.deleteConfirm),
        ),
      ],
    );
  }
}
