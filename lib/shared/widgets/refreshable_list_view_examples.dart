/// Example usage of RefreshableListView in different scenarios.
/// This file demonstrates how to use the reusable RefreshableListView widget
/// across different features in the application.

import 'package:flutter/material.dart';
import 'package:chatas/shared/widgets/refreshable_list_view.dart';

/// Example 1: Simple string list with basic functionality
class SimpleListExample extends StatelessWidget {
  final List<String> items;
  final Future<void> Function() onRefresh;

  const SimpleListExample({
    super.key,
    required this.items,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshableListView<String>(
      items: items,
      onRefresh: onRefresh,
      itemBuilder: (context, item, index) => ListTile(
        title: Text(item),
        subtitle: Text('Item #${index + 1}'),
      ),
    );
  }
}

/// Example 2: Complex object list with custom empty and error states
class UserListExample extends StatelessWidget {
  final List<User> users;
  final Future<void> Function() onRefresh;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback? onRetry;

  const UserListExample({
    super.key,
    required this.users,
    required this.onRefresh,
    this.errorMessage,
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshableListView<User>(
      items: users,
      onRefresh: onRefresh,
      isLoading: isLoading,
      errorMessage: errorMessage,
      onRetry: onRetry,
      itemBuilder: (context, user, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(user.name[0].toUpperCase()),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            // Navigate to user detail
          },
        ),
      ),
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có người dùng nào',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      errorWidgetBuilder: (error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải danh sách người dùng',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Example 3: Chat thread list with scroll controller
class ChatThreadListExample extends StatefulWidget {
  final List<ChatThread> threads;
  final Future<void> Function() onRefresh;

  const ChatThreadListExample({
    super.key,
    required this.threads,
    required this.onRefresh,
  });

  @override
  State<ChatThreadListExample> createState() => _ChatThreadListExampleState();
}

class _ChatThreadListExampleState extends State<ChatThreadListExample> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableListView<ChatThread>(
      items: widget.threads,
      onRefresh: widget.onRefresh,
      scrollController: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      refreshedMessage: 'Đã cập nhật danh sách chat',
      itemBuilder: (context, thread, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(thread.avatarUrl),
          ),
          title: Text(
            thread.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            thread.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                thread.lastMessageTime,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (thread.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    thread.unreadCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            // Navigate to chat detail
          },
        ),
      ),
      emptyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có cuộc trò chuyện nào',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu cuộc trò chuyện đầu tiên của bạn',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// Example data models
class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });
}

class ChatThread {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  const ChatThread({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
