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
      unreadCounts: const {'user1': 0, 'user2': 5},
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
      expect(tChatThread.getUnreadCount('user1'), 0);
      expect(tChatThread.getUnreadCount('user2'), 5);
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
        unreadCounts: const {'user1': 0, 'user2': 12, 'user3': 5, 'user4': 8},
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: tDateTime,
        groupAdminId: 'user1',
        groupDescription: 'Team discussion group',
      );

      // Assert
      expect(groupChat.isGroup, true);
      expect(groupChat.members.length, 4);
      expect(groupChat.name, 'Team Chat');
      expect(groupChat.groupAdminId, 'user1');
      expect(groupChat.groupDescription, 'Team discussion group');
      expect(groupChat.isUserAdmin('user1'), true);
      expect(groupChat.isUserAdmin('user2'), false);
      expect(groupChat.canUserManage('user1'), true);
      expect(groupChat.canUserManage('user2'), false);
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
        unreadCounts: const {'current_user': 0, 'alice_id': 3},
        createdAt: DateTime(2024, 1, 1, 7, 0),
        updatedAt: tDateTime,
      );

      // Assert
      expect(privateChat.isGroup, false);
      expect(privateChat.members.length, 2);
      expect(privateChat.name, 'Alice Johnson');
      expect(privateChat.groupAdminId, null);
      expect(privateChat.groupDescription, null);
      expect(privateChat.isUserAdmin('current_user'), false);
      expect(privateChat.canUserManage('current_user'), false);
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
        unreadCounts: const {},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      // Assert
      expect(emptyChat.lastMessage, '');
      expect(emptyChat.avatarUrl, '');
      expect(emptyChat.members, isEmpty);
      expect(emptyChat.getUnreadCount('any_user'), 0);
    });

    test('should support equality comparison', () {
      // Arrange
      final time = DateTime(2024, 1, 1, 10, 30);
      final chatThread1 = ChatThread(
        id: '1',
        name: 'Test Chat',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 1},
        createdAt: time,
        updatedAt: time,
      );

      final chatThread2 = ChatThread(
        id: '1',
        name: 'Test Chat',
        lastMessage: 'Hello',
        lastMessageTime: time,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 1},
        createdAt: time,
        updatedAt: time,
      );

      // Assert
      expect(chatThread1, equals(chatThread2));
      expect(chatThread1.hashCode, equals(chatThread2.hashCode));
    });

    test('should handle different unread counts for different users', () {
      // Arrange
      final chatThread = ChatThread(
        id: '1',
        name: 'Test Chat',
        lastMessage: 'Hello',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/avatar.png',
        members: const ['user1', 'user2', 'user3'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 5, 'user3': 10},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      // Assert
      expect(chatThread.getUnreadCount('user1'), 0);
      expect(chatThread.getUnreadCount('user2'), 5);
      expect(chatThread.getUnreadCount('user3'), 10);
      expect(chatThread.getUnreadCount('user4'), 0); // Non-member
    });

    test('should handle group admin permissions correctly', () {
      // Arrange
      final groupChat = ChatThread(
        id: 'group_1',
        name: 'Admin Group',
        lastMessage: 'Admin message',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group.png',
        members: const ['admin', 'member1', 'member2'],
        isGroup: true,
        unreadCounts: const {'admin': 0, 'member1': 1, 'member2': 1},
        createdAt: tDateTime,
        updatedAt: tDateTime,
        groupAdminId: 'admin',
        groupDescription: 'Admin controlled group',
      );

      // Assert
      expect(groupChat.isUserAdmin('admin'), true);
      expect(groupChat.isUserAdmin('member1'), false);
      expect(groupChat.isUserAdmin('member2'), false);
      expect(groupChat.canUserManage('admin'), true);
      expect(groupChat.canUserManage('member1'), false);
      expect(groupChat.canUserManage('member2'), false);
    });

    test('should handle group without admin', () {
      // Arrange
      final groupChat = ChatThread(
        id: 'group_1',
        name: 'No Admin Group',
        lastMessage: 'Group message',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group.png',
        members: const ['member1', 'member2'],
        isGroup: true,
        unreadCounts: const {'member1': 0, 'member2': 1},
        createdAt: tDateTime,
        updatedAt: tDateTime,
        groupAdminId: null,
        groupDescription: null,
      );

      // Assert
      expect(groupChat.isUserAdmin('member1'), false);
      expect(groupChat.isUserAdmin('member2'), false);
      expect(groupChat.canUserManage('member1'), false);
      expect(groupChat.canUserManage('member2'), false);
      expect(groupChat.groupAdminId, null);
      expect(groupChat.groupDescription, null);
    });

    test('should handle individual chat admin permissions', () {
      // Arrange
      final individualChat = ChatThread(
        id: 'private_1',
        name: 'Private Chat',
        lastMessage: 'Private message',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/private.png',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 1},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      // Assert
      expect(individualChat.isUserAdmin('user1'), false);
      expect(individualChat.isUserAdmin('user2'), false);
      expect(individualChat.canUserManage('user1'), false);
      expect(individualChat.canUserManage('user2'), false);
    });
  });
}
