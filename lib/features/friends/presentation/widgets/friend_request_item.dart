import 'package:flutter/material.dart';
import '../../domain/entities/friendRequest.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const FriendRequestItem({
    Key? key,
    required this.request,
    required this.isReceived,
    this.onAccept,
    this.onReject,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: request.senderPhotoURL != null
              ? NetworkImage(request.senderPhotoURL!)
              : null,
          child: request.senderPhotoURL == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          request.senderName ?? 'User ${request.senderId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isReceived ? 'Đã gửi lời mời kết bạn' : 'Đã gửi lời mời',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(request.updatedAt ?? DateTime.now()),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: _buildActions(),
      ),
    );
  }

  Widget _buildActions() {
    if (isReceived) {
      // Received request - show accept/reject buttons
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: onAccept,
            tooltip: 'Chấp nhận',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onReject,
            tooltip: 'Từ chối',
          ),
        ],
      );
    } else {
      // Sent request - show cancel button
      return IconButton(
        icon: const Icon(Icons.cancel, color: Colors.orange),
        onPressed: onCancel,
        tooltip: 'Hủy lời mời',
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 5) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      final day = dateTime.day;
      final month = dateTime.month;
      return '$day/$month';
    }
  }
}
