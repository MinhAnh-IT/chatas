import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../injection/friends_injection.dart';
import '../cubit/friends_list_cubit.dart';
import '../../domain/entities/friend.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../core/constants/app_route_constants.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load danh sách bạn bè khi page được khởi tạo
    context.read<FriendsListCubit>().loadFriends(widget.currentUserId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FriendsListCubit>().refreshFriends(
                widget.currentUserId,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bạn bè...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                context.read<FriendsListCubit>().searchFriends(query);
              },
            ),
          ),
          // Friends list
          Expanded(
            child: BlocConsumer<FriendsListCubit, FriendsState>(
              listener: (context, state) {
                if (state is FriendsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is FriendsLoaded && state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<FriendsListCubit>().clearMessage();
                }
              },
              builder: (context, state) {
                if (state is FriendsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FriendsLoaded) {
                  if (state.friends.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<FriendsListCubit>().refreshFriends(
                        widget.currentUserId,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final friend = state.friends[index];
                        return _buildFriendItem(friend);
                      },
                    ),
                  );
                }

                if (state is FriendsError) {
                  return _buildErrorState(state.message);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: 1, // Index cho tab Bạn bè
        onTap: (index) {
          switch (index) {
            case 0:
              // Chuyển đến trang Chat
              context.go(AppRouteConstants.homePath);
              break;
            case 1:
              // Đã ở trang Bạn bè (hiện tại)
              break;
            case 2:
              // Trang Thông báo (chưa implement)
              break;
            case 3:
              // Chuyển đến trang Profile
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildFriendItem(Friend friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            friend.nickName.isNotEmpty ? friend.nickName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          friend.nickName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          'Kết bạn: ${_formatDate(friend.addAt)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'block':
                _showBlockDialog(friend);
                break;
              case 'chat':
                _openChat(friend);
                break;
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
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Chặn', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có bạn bè nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm bạn bè để bắt đầu trò chuyện',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FriendsListCubit>().refreshFriends(
                widget.currentUserId,
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(Friend friend) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chặn bạn bè'),
        content: Text('Bạn có chắc chắn muốn chặn ${friend.nickName}?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('Chặn', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FriendsListCubit>().blockFriend(
                widget.currentUserId,
                friend.friendId,
              );
            },
          ),
        ],
      ),
    );
  }

  void _openChat(Friend friend) {
    // Navigate đến chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mở chat với ${friend.nickName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Hôm nay';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Example App để demo
class FriendsApp extends StatelessWidget {
  final String currentUserId;

  const FriendsApp({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    FriendsDependencyInjection.init();

    return MaterialApp(
      title: 'Friends List Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocProvider(
        create: (_) => FriendsDependencyInjection.createFriendsListCubit(),
        child: FriendsListPage(currentUserId: currentUserId),
      ),
    );
  }
}
