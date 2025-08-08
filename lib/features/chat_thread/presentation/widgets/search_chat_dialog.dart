import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat_thread.dart';
import '../cubit/chat_thread_list_cubit.dart';
import '../../constants/chat_thread_list_page_constants.dart';
import 'package:chatas/shared/utils/date_utils.dart' as app_date_utils;
import 'package:chatas/shared/widgets/smart_image.dart';

class SearchChatDialog extends StatefulWidget {
  final Function(ChatThread) onThreadSelected;
  final ChatThreadListCubit cubit;

  const SearchChatDialog({
    super.key,
    required this.onThreadSelected,
    required this.cubit,
  });

  @override
  State<SearchChatDialog> createState() => _SearchChatDialogState();
}

class _SearchChatDialogState extends State<SearchChatDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatThread> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
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

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    widget.cubit
        .searchChatThreads(query, currentUserId)
        .then((results) {
          if (mounted) {
            setState(() {
              _searchResults = results;
              _isSearching = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  ChatThreadListPageConstants.searchDialogTitle,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: ChatThreadListPageConstants.searchHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _performSearch,
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

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(
          ChatThreadListPageConstants.searchEmptyHint,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          ChatThreadListPageConstants.noSearchResults,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
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
          onTap: () => widget.onThreadSelected(thread),
        );
      },
    );
  }
}
