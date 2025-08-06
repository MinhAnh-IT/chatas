import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';

class FriendItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;
  final VoidCallback onChat;

  const FriendItem({
    Key? key,
    required this.friend,
    required this.onRemove,
    required this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            if (friend.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          'User ${friend.friendUserId}', // In real app, you'd get user name from another service
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friend.isOnline ? 'Đang hoạt động' : _formatLastActive(),
              style: TextStyle(
                color: friend.isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
            if (friend.lastMessageAt != null && friend.lastMessageId != null)
              Text(
                'Tin nhắn cuối: ${_formatMessageTime()}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'chat') {
              onChat();
            } else if (value == 'remove') {
              onRemove();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'chat',
              child: Row(
                children: [
                  Icon(Icons.chat, size: 20),
                  SizedBox(width: 8),
                  Text('Nhắn tin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa bạn', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastActive() {
    if (friend.lastActive == null) return 'Không hoạt động gần đây';

    final now = DateTime.now();
    final lastActive = friend.lastActive!;
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 5) {
      return 'Vừa hoạt động';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return 'Lâu rồi không hoạt động';
    }
  }

  String _formatMessageTime() {
    if (friend.lastMessageAt == null) return '';

    final now = DateTime.now();
    final messageTime = friend.lastMessageAt!;
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 5) {
      return 'vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}
