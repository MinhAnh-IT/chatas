import 'package:flutter/material.dart';

class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastActive;
  final double size;
  final bool showLastActive;
  final String? username;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.lastActive,
    this.size = 12.0,
    this.showLastActive = false,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Online status dot
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF4CAF50) : Colors.grey.shade400,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),

        // Last active text (optional)
        if (showLastActive && !isOnline && lastActive != null) ...[
          const SizedBox(height: 4),
          Text(
            _getLastActiveText(lastActive!),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  String _getLastActiveText(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Vừa hoạt động';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${lastActive.day}/${lastActive.month}/${lastActive.year}';
    }
  }
}

// Widget for showing online status in profile pictures
class ProfileWithOnlineStatus extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final DateTime? lastActive;
  final double imageSize;
  final double indicatorSize;
  final bool showLastActive;
  final VoidCallback? onTap;

  const ProfileWithOnlineStatus({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.lastActive,
    this.imageSize = 50.0,
    this.indicatorSize = 14.0,
    this.showLastActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Profile Image
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: imageSize * 0.5,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        size: imageSize * 0.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
          ),

          // Online Status Indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: OnlineStatusIndicator(
              isOnline: isOnline,
              lastActive: lastActive,
              size: indicatorSize,
              showLastActive: showLastActive,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for showing online status in chat list items
class ChatListOnlineStatus extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final DateTime? lastActive;
  final String username;
  final String? lastMessage;
  final VoidCallback? onTap;

  const ChatListOnlineStatus({
    super.key,
    required this.imageUrl,
    required this.isOnline,
    this.lastActive,
    required this.username,
    this.lastMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile with online status
            ProfileWithOnlineStatus(
              imageUrl: imageUrl,
              isOnline: isOnline,
              lastActive: lastActive,
              imageSize: 48,
              indicatorSize: 14,
            ),

            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isOnline && lastActive != null)
                        Text(
                          _getLastActiveText(lastActive!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  if (lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Online status indicator
            OnlineStatusIndicator(
              isOnline: isOnline,
              lastActive: lastActive,
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  String _getLastActiveText(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}g';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}n';
    } else {
      return '${lastActive.day}/${lastActive.month}';
    }
  }
}
