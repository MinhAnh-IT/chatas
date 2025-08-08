import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/chat_thread_list_page_constants.dart';
import '../../domain/entities/chat_thread.dart';
import '../../presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/shared/utils/date_utils.dart' as app_date_utils;
import 'package:chatas/shared/widgets/smart_image.dart';

/// Dialog widget for searching chat threads.
class ChatSearchDialog extends StatefulWidget {
  final ChatThreadListCubit cubit;

  const ChatSearchDialog({super.key, required this.cubit});

  @override
  State<ChatSearchDialog> createState() => _ChatSearchDialogState();
}

class _ChatSearchDialogState extends State<ChatSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatThread> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Performs search operation when text changes.
  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await widget.cubit.searchChatThreads(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  /// Navigates to chat message page when a thread is selected.
  void _onThreadSelected(ChatThread thread) {
    final route = AppRouteConstants.chatMessageRoute(
      thread.id,
      currentUserId: ChatThreadListPageConstants.temporaryUserId,
      otherUserName: thread.name,
    );

    // Close dialog and navigate
    Navigator.of(context).pop();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with title and close button
            Row(
              children: [
                const Text(
                  ChatThreadListPageConstants.searchTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(ChatThreadListPageConstants.searchCancel),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search input field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: ChatThreadListPageConstants.searchHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Search results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  /// Builds the search results list widget.
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.trim().isEmpty) {
      return const Center(child: Text(ChatThreadListPageConstants.searchEmpty));
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(ChatThreadListPageConstants.noSearchResults),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final thread = _searchResults[index];
        return ListTile(
          leading: SmartAvatar(
            imageUrl: thread.avatarUrl,
            radius: ChatThreadListPageConstants.avatarRadius,
            fallbackText: thread.name,
          ),
          title: Text(thread.name),
          subtitle: Text(
            thread.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            app_date_utils.DateUtils.formatTime(thread.lastMessageTime),
            style: const TextStyle(
              fontSize: ChatThreadListPageConstants.trailingFontSize,
            ),
          ),
          onTap: () => _onThreadSelected(thread),
        );
      },
    );
  }
}
