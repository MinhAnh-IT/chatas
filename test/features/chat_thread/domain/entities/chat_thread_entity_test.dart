import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

void main() {
  group('ChatThread Entity', () {
    final tDateTime = DateTime(2024, 1, 1, 10, 30);
    final tChatThread = ChatThread(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.png',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCount: 5,
      createdAt: DateTime(2024, 1, 1, 9, 0),
      updatedAt: tDateTime,
    );

    test('should create ChatThread with all required properties', () {
      // Act & Assert
      expect(tChatThread.id, '1');
      expect(tChatThread.name, 'John Doe');
      expect(tChatThread.lastMessage, 'Hello there!');
      expect(tChatThread.lastMessageTime, tDateTime);
      expect(tChatThread.avatarUrl, 'https://example.com/avatar.png');
      expect(tChatThread.members, const ['user1', 'user2']);
      expect(tChatThread.isGroup, false);
      expect(tChatThread.unreadCount, 5);
      expect(tChatThread.createdAt, DateTime(2024, 1, 1, 9, 0));
      expect(tChatThread.updatedAt, tDateTime);
    });

    test('should handle group chat properties correctly', () {
      // Arrange
      final groupChat = ChatThread(
        id: 'group_1',
        name: 'Team Chat',
        lastMessage: 'Meeting at 3 PM',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group_avatar.png',
        members: const ['user1', 'user2', 'user3', 'user4'],
        isGroup: true,
        unreadCount: 12,
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: tDateTime,
      );

      // Assert
      expect(groupChat.isGroup, true);
      expect(groupChat.members.length, 4);
      expect(groupChat.name, 'Team Chat');
    });

    test('should handle private chat properties correctly', () {
      // Arrange
      final privateChat = ChatThread(
        id: 'private_1',
        name: 'Alice Johnson',
        lastMessage: 'See you tomorrow',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/alice_avatar.png',
        members: const ['current_user', 'alice_id'],
        isGroup: false,
        unreadCount: 3,
        createdAt: DateTime(2024, 1, 1, 7, 0),
        updatedAt: tDateTime,
      );

      // Assert
      expect(privateChat.isGroup, false);
      expect(privateChat.members.length, 2);
      expect(privateChat.name, 'Alice Johnson');
    });

    test('should handle empty and zero values correctly', () {
      // Arrange
      final emptyChat = ChatThread(
        id: 'empty_1',
        name: 'Empty Chat',
        lastMessage: '',
        lastMessageTime: tDateTime,
        avatarUrl: '',
        members: const [],
        isGroup: false,
        unreadCount: 0,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      // Assert
      expect(emptyChat.lastMessage, '');
      expect(emptyChat.avatarUrl, '');
      expect(emptyChat.members, isEmpty);
      expect(emptyChat.unreadCount, 0);
    });

    test('should support equality comparison', () {
      // Arrange
      final time = DateTime(2024, 1, 1, 10, 30);
      final createdAt = DateTime(2024, 1, 1, 10, 0);
      final chatThread1 = ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCount: 5,
        createdAt: createdAt,
        updatedAt: time,
      );
      final chatThread2 = ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCount: 5,
        createdAt: createdAt,
        updatedAt: time,
      );

      // Assert
      expect(chatThread1, equals(chatThread2));
      expect(chatThread1.hashCode, equals(chatThread2.hashCode));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      final time = DateTime(2024, 1, 1, 10, 30);
      final createdAt = DateTime(2024, 1, 1, 10, 0);
      final chatThread1 = ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCount: 5,
        createdAt: createdAt,
        updatedAt: time,
      );
      final chatThread2 = ChatThread(
        id: '2', // Different ID
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCount: 5,
        createdAt: createdAt,
        updatedAt: time,
      );

      // Assert
      expect(chatThread1, isNot(equals(chatThread2)));
    });
  });
}
