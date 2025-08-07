import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_route_constants.dart';
import '../cubit/friend_request_cubit.dart';
import '../cubit/friend_request_state.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tải dữ liệu ban đầu
    context.read<FriendRequestCubit>().loadReceivedRequests();
    context.read<FriendRequestCubit>().loadSentRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời kết bạn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteConstants.friendsPath);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nhận được'),
            Tab(text: 'Đã gửi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReceivedRequestsTab(), _buildSentRequestsTab()],
      ),
    );
  }

  Widget _buildReceivedRequestsTab() {
    return BlocBuilder<FriendRequestCubit, FriendRequestState>(
      builder: (context, state) {
        if (state.isLoadingReceived) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.receivedRequestsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lỗi: ${state.receivedRequestsError}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FriendRequestCubit>().loadReceivedRequests();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.receivedRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không có lời mời kết bạn nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendRequestCubit>().loadReceivedRequests();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.receivedRequests.length,
            itemBuilder: (context, index) {
              final request = state.receivedRequests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      request.senderName.isNotEmpty
                          ? request.senderName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    request.senderName.isNotEmpty
                        ? request.senderName
                        : 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Gửi lời mời kết bạn - ${_formatDateTime(request.createdAt)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: state.isAccepting
                            ? null
                            : () {
                                context
                                    .read<FriendRequestCubit>()
                                    .acceptRequest(
                                      request.id,
                                      request.senderId,
                                      request.receiverId,
                                    );
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: state.isRejecting
                            ? null
                            : () {
                                context
                                    .read<FriendRequestCubit>()
                                    .rejectRequest(request.id);
                              },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSentRequestsTab() {
    return BlocBuilder<FriendRequestCubit, FriendRequestState>(
      builder: (context, state) {
        if (state.isLoadingSent) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.sentRequestsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lỗi: ${state.sentRequestsError}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<FriendRequestCubit>().loadSentRequests();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.sentRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Chưa gửi lời mời kết bạn nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendRequestCubit>().loadSentRequests();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.sentRequests.length,
            itemBuilder: (context, index) {
              final request = state.sentRequests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(
                      request.receiverName.isNotEmpty
                          ? request.receiverName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    request.receiverName.isNotEmpty
                        ? request.receiverName
                        : 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Đã gửi lời mời - ${_formatDateTime(request.createdAt)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: state.isCanceling
                        ? null
                        : () {
                            context.read<FriendRequestCubit>().cancelRequest(
                              request.senderId,
                              request.receiverId,
                            );
                          },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
