import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';

void main() {
  group('ChatThreadRemoteDataSource', () {
    late ChatThreadRemoteDataSource dataSource;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      dataSource = ChatThreadRemoteDataSource(firestore: fakeFirestore);
    });

    final testChatThread = ChatThreadModel(
      id: 'test_thread_1',
      name: 'Test Thread',
      lastMessage: 'Hello World',
      lastMessageTime: DateTime(2024, 1, 1, 12, 0),
      avatarUrl: 'test_avatar.jpg',
      members: ['user1', 'user2'],
      isGroup: false,
      unreadCounts: {'user2': 1},
      createdAt: DateTime(2024, 1, 1, 10, 0),
      updatedAt: DateTime(2024, 1, 1, 12, 0),
      hiddenFor: [],
      visibilityCutoff: {},
      joinedAt: {},
    );

    group('fetchChatThreads', () {
      test('should return threads and filter hidden ones', () async {
        // arrange
        final visibleThread = ChatThreadModel(
          id: 'visible_thread',
          name: 'Visible Thread',
          lastMessage: 'Hello',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          hiddenFor: [], // Not hidden
          visibilityCutoff: {},
          joinedAt: {},
        );

        final hiddenThread = ChatThreadModel(
          id: 'hidden_thread',
          name: 'Hidden Thread',
          lastMessage: 'Bye',
          lastMessageTime: DateTime(2024, 1, 1, 11, 0),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 11, 0),
          hiddenFor: ['user1'], // Hidden for user1
          visibilityCutoff: {},
          joinedAt: {},
        );

        await fakeFirestore
            .collection('chat_threads')
            .doc('visible_thread')
            .set(visibleThread.toJson());
        await fakeFirestore
            .collection('chat_threads')
            .doc('hidden_thread')
            .set(hiddenThread.toJson());

        // act
        final result = await dataSource.fetchChatThreads('user1');

        // assert
        expect(result.length, equals(1));
        expect(result[0].id, equals('visible_thread'));
      });

      test('should sort threads by lastMessageTime descending', () async {
        // arrange
        final earlierThread = ChatThreadModel(
          id: 'earlier_thread',
          name: 'Earlier Thread',
          lastMessage: 'Earlier message',
          lastMessageTime: DateTime(2024, 1, 1, 10, 0),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime(2024, 1, 1, 9, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 0),
          hiddenFor: [],
          visibilityCutoff: {},
          joinedAt: {},
        );

        final laterThread = ChatThreadModel(
          id: 'later_thread',
          name: 'Later Thread',
          lastMessage: 'Later message',
          lastMessageTime: DateTime(2024, 1, 1, 15, 0),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime(2024, 1, 1, 9, 0),
          updatedAt: DateTime(2024, 1, 1, 15, 0),
          hiddenFor: [],
          visibilityCutoff: {},
          joinedAt: {},
        );

        await fakeFirestore
            .collection('chat_threads')
            .doc('earlier_thread')
            .set(earlierThread.toJson());
        await fakeFirestore
            .collection('chat_threads')
            .doc('later_thread')
            .set(laterThread.toJson());

        // act
        final result = await dataSource.fetchChatThreads('user1');

        // assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('later_thread')); // Later message first
        expect(result[1].id, equals('earlier_thread')); // Earlier message last
      });
    });

    group('markThreadDeletedForUser', () {
      test('should add user to hiddenFor and set visibilityCutoff', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());
        final cutoffTime = DateTime(2024, 1, 1, 15, 0);

        // act
        await dataSource.markThreadDeletedForUser(
          'test_thread',
          'user1',
          cutoffTime,
        );

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['hiddenFor'], contains('user1'));
        expect(
          data['visibilityCutoff']['user1'],
          equals(cutoffTime.toIso8601String()),
        );
      });
    });

    group('archiveThreadForUser', () {
      test(
        'should add user to hiddenFor without setting visibilityCutoff',
        () async {
          // arrange
          await fakeFirestore
              .collection('chat_threads')
              .doc('test_thread')
              .set(testChatThread.toJson());

          // act
          await dataSource.archiveThreadForUser('test_thread', 'user1');

          // assert
          final doc = await fakeFirestore
              .collection('chat_threads')
              .doc('test_thread')
              .get();
          final data = doc.data()!;
          expect(data['hiddenFor'], contains('user1'));
          // visibilityCutoff should not be modified for archive
          expect(data['visibilityCutoff'], isEmpty);
        },
      );
    });

    group('reviveThreadForUser', () {
      test('should remove user from hiddenFor', () async {
        // arrange
        final hiddenThread = ChatThreadModel(
          id: 'test_thread',
          name: testChatThread.name,
          lastMessage: testChatThread.lastMessage,
          lastMessageTime: testChatThread.lastMessageTime,
          avatarUrl: testChatThread.avatarUrl,
          members: testChatThread.members,
          isGroup: testChatThread.isGroup,
          unreadCounts: testChatThread.unreadCounts,
          createdAt: testChatThread.createdAt,
          updatedAt: testChatThread.updatedAt,
          hiddenFor: ['user1', 'user2'], // Both users hidden
          visibilityCutoff: testChatThread.visibilityCutoff,
          joinedAt: testChatThread.joinedAt,
        );
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(hiddenThread.toJson());

        // act
        await dataSource.reviveThreadForUser('test_thread', 'user1');

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['hiddenFor'], equals(['user2'])); // user1 removed
      });
    });

    group('updateVisibilityCutoff', () {
      test('should set visibilityCutoff for specific user', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());
        final cutoffTime = DateTime(2024, 1, 1, 15, 0);

        // act
        await dataSource.updateVisibilityCutoff(
          'test_thread',
          'user1',
          cutoffTime,
        );

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(
          data['visibilityCutoff']['user1'],
          equals(cutoffTime.toIso8601String()),
        );
      });
    });

    group('getChatThreadById', () {
      test('should return thread if exists', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());

        // act
        final result = await dataSource.getChatThreadById('test_thread');

        // assert
        expect(result, isNotNull);
        expect(result!.id, equals('test_thread'));
      });

      test('should return null if thread does not exist', () async {
        // act
        final result = await dataSource.getChatThreadById('nonexistent_thread');

        // assert
        expect(result, isNull);
      });
    });

    group('updateLastMessage', () {
      test('should update lastMessage and lastMessageTime', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());
        final newTimestamp = DateTime(2024, 1, 2, 10, 0);

        // act
        await dataSource.updateLastMessage(
          'test_thread',
          'New message',
          newTimestamp,
        );

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['lastMessage'], equals('New message'));
        expect(data['lastMessageTime'], equals(newTimestamp.toIso8601String()));
      });
    });

    group('incrementUnreadCount', () {
      test('should increment unread count for specific user', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());

        // act
        await dataSource.incrementUnreadCount('test_thread', 'user2');

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['unreadCounts']['user2'], equals(2)); // Was 1, now 2
      });

      test('should initialize unread count to 1 if not exists', () async {
        // arrange
        final threadWithoutUnread = ChatThreadModel(
          id: 'test_thread',
          name: testChatThread.name,
          lastMessage: testChatThread.lastMessage,
          lastMessageTime: testChatThread.lastMessageTime,
          avatarUrl: testChatThread.avatarUrl,
          members: testChatThread.members,
          isGroup: testChatThread.isGroup,
          unreadCounts: {}, // Empty unread counts
          createdAt: testChatThread.createdAt,
          updatedAt: testChatThread.updatedAt,
          hiddenFor: testChatThread.hiddenFor,
          visibilityCutoff: testChatThread.visibilityCutoff,
          joinedAt: testChatThread.joinedAt,
        );
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(threadWithoutUnread.toJson());

        // act
        await dataSource.incrementUnreadCount('test_thread', 'user2');

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['unreadCounts']['user2'], equals(1));
      });
    });

    group('resetUnreadCount', () {
      test('should reset unread count to 0 for specific user', () async {
        // arrange
        await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .set(testChatThread.toJson());

        // act
        await dataSource.resetUnreadCount('test_thread', 'user2');

        // assert
        final doc = await fakeFirestore
            .collection('chat_threads')
            .doc('test_thread')
            .get();
        final data = doc.data()!;
        expect(data['unreadCounts']['user2'], equals(0));
      });
    });
  });
}
