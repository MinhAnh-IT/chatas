import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/friend_requests_cubit.dart';
import '../widgets/friend_request_item.dart';
import '../widgets/empty_friend_requests.dart';

class FriendRequestsPage extends StatefulWidget {
  final String userId;

  const FriendRequestsPage({Key? key, required this.userId}) : super(key: key);

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
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRequests() {
    final cubit = context.read<FriendRequestsCubit>();
    cubit.loadReceivedRequests(widget.userId);
    cubit.loadSentRequests(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời kết bạn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Đã nhận'),
            Tab(text: 'Đã gửi'),
          ],
        ),
      ),
      body: BlocConsumer<FriendRequestsCubit, FriendRequestsState>(
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
            context.read<FriendRequestsCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [_buildReceivedTab(state), _buildSentTab(state)],
          );
        },
      ),
    );
  }

  Widget _buildReceivedTab(FriendRequestsState state) {
    if (state.isLoading && state.receivedRequests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.receivedRequests.isEmpty) {
      return const EmptyFriendRequests(message: 'Không có lời mời kết bạn nào');
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendRequestsCubit>().loadReceivedRequests(widget.userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.receivedRequests.length,
        itemBuilder: (context, index) {
          final request = state.receivedRequests[index];
          return FriendRequestItem(
            request: request,
            isReceived: true,
            onAccept: () {
              context.read<FriendRequestsCubit>().acceptFriendRequest(
                request.id,
              );
            },
            onReject: () {
              context.read<FriendRequestsCubit>().rejectFriendRequest(
                request.id,
              );
            },
            onCancel: null,
          );
        },
      ),
    );
  }

  Widget _buildSentTab(FriendRequestsState state) {
    if (state.isLoading && state.sentRequests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sentRequests.isEmpty) {
      return const EmptyFriendRequests(message: 'Chưa gửi lời mời kết bạn nào');
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendRequestsCubit>().loadSentRequests(widget.userId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.sentRequests.length,
        itemBuilder: (context, index) {
          final request = state.sentRequests[index];
          return FriendRequestItem(
            request: request,
            isReceived: false,
            onAccept: null,
            onReject: null,
            onCancel: () {
              context.read<FriendRequestsCubit>().cancelFriendRequest(
                request.id,
              );
            },
          );
        },
      ),
    );
  }
}
