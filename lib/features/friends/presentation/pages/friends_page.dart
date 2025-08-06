import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/friends_cubit.dart';
import '../widgets/friend_item.dart';
import '../widgets/empty_friends.dart';
import 'friend_requests_page.dart';

class FriendsPage extends StatefulWidget {
  final String userId;

  const FriendsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsCubit>().loadFriends(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bạn bè'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FriendRequestsPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<FriendsCubit, FriendsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.friends.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.friends.isEmpty && !state.isLoading) {
            return const EmptyFriends();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FriendsCubit>().loadFriends(widget.userId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return FriendItem(
                  friend: friend,
                  onRemove: () {
                    _showRemoveDialog(
                      context,
                      friend.friendId,
                      friend.friendUserId,
                    );
                  },
                  onChat: () {
                    // Navigate to chat screen
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(friendId: friend.friendUserId)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chức năng chat đang phát triển'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    String friendId,
    String friendUserId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa bạn'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa bạn này khỏi danh sách?',
          ),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<FriendsCubit>().removeFriend(
                  widget.userId,
                  friendUserId,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
