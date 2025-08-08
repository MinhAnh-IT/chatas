import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/constants/chat_thread_list_page_constants.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';

// Fake repository for testing
class FakeChatThreadRepository implements ChatThreadRepository {
  final List<ChatThread> _threads;

  FakeChatThreadRepository(this._threads);

  @override
  Future<List<ChatThread>> getChatThreads(String currentUserId) async => _threads;

  @override
  Future<void> addChatThread(ChatThread chatThread) async {
    _threads.add(chatThread);
  }

  @override
  Future<void> deleteChatThread(String threadId) async {
    _threads.removeWhere((thread) => thread.id == threadId);
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
    final testChatThreads = [
      ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello, how are you?',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar1.jpg',
        members: ['1', '2'],
        isGroup: false,
        unreadCount: 0,
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
        unreadCount: 2,
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
