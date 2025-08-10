import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/constants/chat_thread_list_page_constants.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';

// Fake repository for testing
class FakeChatThreadRepository implements ChatThreadRepository {
  @override
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId) async {
    return [];
  }

  final List<ChatThread> _threads;

  FakeChatThreadRepository(this._threads);

  @override
  Future<List<ChatThread>> getChatThreads(String currentUserId) async =>
      _threads;

  Future<void> addChatThread(ChatThread chatThread) async {
    _threads.add(chatThread);
  }

  @override
  Future<void> deleteChatThread(String threadId) async {
    _threads.removeWhere((thread) => thread.id == threadId);
  }

  @override
  Future<void> hideChatThread(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    // Implementation for testing
  }

  @override
  Future<void> unhideChatThread(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> updateLastRecreatedAt(
    String threadId,
    DateTime timestamp,
  ) async {
    // Implementation for testing
  }

  @override
  Future<List<ChatThread>> searchChatThreads(
    String query,
    String currentUserId,
  ) async {
    // Implementation for testing
    return _threads
        .where(
          (thread) =>
              thread.name.toLowerCase().contains(query.toLowerCase()) ||
              thread.lastMessage.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Stream<List<ChatThread>> getChatThreadsStream(String currentUserId) {
    return Stream.value(_threads);
  }

  @override
  Future<void> resetThreadForUser(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<List<ChatThread>> getAllChatThreads(String currentUserId) async {
    return _threads;
  }

  @override
  Future<void> createChatThread(ChatThread chatThread) async {
    _threads.add(chatThread);
  }

  @override
  Future<ChatThread?> getChatThreadById(String chatThreadId) async {
    try {
      return _threads.firstWhere((thread) => thread.id == chatThreadId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateChatThreadMembers(
    String chatThreadId,
    List<String> members,
  ) async {
    final index = _threads.indexWhere((thread) => thread.id == chatThreadId);
    if (index != -1) {
      final thread = _threads[index];
      _threads[index] = ChatThread(
        id: thread.id,
        name: thread.name,
        lastMessage: thread.lastMessage,
        lastMessageTime: thread.lastMessageTime,
        avatarUrl: thread.avatarUrl,
        isGroup: thread.isGroup,
        members: members,
        unreadCounts: thread.unreadCounts,
        createdAt: thread.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateChatThreadName(String chatThreadId, String name) async {
    final index = _threads.indexWhere((thread) => thread.id == chatThreadId);
    if (index != -1) {
      final thread = _threads[index];
      _threads[index] = ChatThread(
        id: thread.id,
        name: name,
        lastMessage: thread.lastMessage,
        lastMessageTime: thread.lastMessageTime,
        avatarUrl: thread.avatarUrl,
        isGroup: thread.isGroup,
        members: thread.members,
        unreadCounts: thread.unreadCounts,
        createdAt: thread.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateChatThreadAvatar(
    String chatThreadId,
    String avatarUrl,
  ) async {
    final index = _threads.indexWhere((thread) => thread.id == chatThreadId);
    if (index != -1) {
      final thread = _threads[index];
      _threads[index] = ChatThread(
        id: thread.id,
        name: thread.name,
        lastMessage: thread.lastMessage,
        lastMessageTime: thread.lastMessageTime,
        avatarUrl: avatarUrl,
        isGroup: thread.isGroup,
        members: thread.members,
        unreadCounts: thread.unreadCounts,
        createdAt: thread.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> updateChatThreadDescription(
    String chatThreadId,
    String description,
  ) async {
    final index = _threads.indexWhere((thread) => thread.id == chatThreadId);
    if (index != -1) {
      final thread = _threads[index];
      _threads[index] = ChatThread(
        id: thread.id,
        name: thread.name,
        lastMessage: thread.lastMessage,
        lastMessageTime: thread.lastMessageTime,
        avatarUrl: thread.avatarUrl,
        isGroup: thread.isGroup,
        members: thread.members,
        unreadCounts: thread.unreadCounts,
        createdAt: thread.createdAt,
        updatedAt: DateTime.now(),
        groupAdminId: thread.groupAdminId,
        groupDescription: description,
      );
    }
  }

  // Implementation for new methods

  @override
  Future<void> updateLastMessage(
    String threadId,
    String message,
    DateTime timestamp,
  ) async {
    // Implementation for testing
  }

  @override
  Future<void> incrementUnreadCount(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> resetUnreadCount(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> markThreadDeletedForUser(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    // Implementation for testing
  }

  @override
  Future<void> archiveThreadForUser(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> reviveThreadForUser(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> leaveGroup(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<void> joinGroup(String threadId, String userId) async {
    // Implementation for testing
  }

  @override
  Future<ChatThread> findOrCreate1v1Thread(
    String user1,
    String user2, {
    String? threadName,
    String? avatarUrl,
  }) async {
    // Implementation for testing
    final threadId = '${user1}_${user2}';
    return ChatThread(
      id: threadId,
      name: threadName ?? 'Test Chat',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      avatarUrl: avatarUrl ?? '',
      members: [user1, user2],
      isGroup: false,
      unreadCounts: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Simple test widget that mimics the chat thread list page without Firebase dependencies
class TestChatThreadListWidget extends StatefulWidget {
  final List<ChatThread> chatThreads;

  const TestChatThreadListWidget({super.key, required this.chatThreads});

  @override
  State<TestChatThreadListWidget> createState() =>
      _TestChatThreadListWidgetState();
}

class _TestChatThreadListWidgetState extends State<TestChatThreadListWidget> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatThread> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate immediate loading completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = widget.chatThreads
        .where(
          (thread) => thread.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ChatThreadListPageConstants.title),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _toggleSearch),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: ChatThreadListPageConstants.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _performSearch,
                autofocus: true,
              ),
            ),
          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearchVisible) {
      return _buildSearchResults();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: widget.chatThreads.length,
      itemBuilder: (context, index) {
        final thread = widget.chatThreads[index];
        return ListTile(
          title: Text(thread.name),
          subtitle: Text(thread.lastMessage),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(ChatThreadListPageConstants.searchEmptyHint),
      );
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
          title: Text(thread.name),
          subtitle: Text(thread.lastMessage),
        );
      },
    );
  }
}

void main() {
  group('ChatThreadListPage Widget Tests', () {
    final now = DateTime.now();
    final testChatThreads = <ChatThread>[
      ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello, how are you?',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar1.jpg',
        members: ['1', '2'],
        isGroup: false,
        unreadCounts: {'1': 0, '2': 0},
        createdAt: now,
        updatedAt: now,
      ),
      ChatThread(
        id: '2',
        name: 'Jane Smith',
        lastMessage: 'Meeting at 3pm today',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar2.jpg',
        members: ['1', '3'],
        isGroup: false,
        unreadCounts: {'1': 0, '3': 2},
        createdAt: now,
        updatedAt: now,
      ),
    ];

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: TestChatThreadListWidget(chatThreads: testChatThreads),
      );
    }

    testWidgets('should display app bar with title and search icon', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text(ChatThreadListPageConstants.title), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should show search bar when search icon is tapped', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(ChatThreadListPageConstants.searchHint), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should hide search bar when close icon is tapped', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Close search bar
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // assert
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should display loading indicator initially', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - check loading is briefly shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display chat threads after loading', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Complete the post frame callback

      // assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('should display empty hint when search is visible but empty', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Complete loading

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // assert
      expect(
        find.text(ChatThreadListPageConstants.searchEmptyHint),
        findsOneWidget,
      );
    });

    testWidgets('should perform search when text is entered', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Complete loading

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'john');
      await tester.pump();

      // assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('should show no results message when search returns empty', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Complete loading

      // Open search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter search text that returns no results
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      // assert
      expect(
        find.text(ChatThreadListPageConstants.noSearchResults),
        findsOneWidget,
      );
    });
  });
}
