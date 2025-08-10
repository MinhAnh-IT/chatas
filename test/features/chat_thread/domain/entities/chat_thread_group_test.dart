import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

void main() {
  group('ChatThread Group Chat Tests', () {
    test('should create group chat thread', () {
      final groupThread = ChatThread(
        id: 'group_123',
        name: 'Test Group',
        lastMessage: 'Hello everyone!',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        avatarUrl: 'https://example.com/group_avatar.jpg',
        isGroup: true,
        members: ['user_1', 'user_2', 'user_3'],
        unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        groupAdminId: 'user_1',
        groupDescription: 'A test group for testing purposes',
      );

      expect(groupThread.isGroup, true);
      expect(groupThread.groupAdminId, 'user_1');
      expect(groupThread.groupDescription, 'A test group for testing purposes');
      expect(groupThread.members.length, 3);
      expect(groupThread.members, contains('user_1'));
      expect(groupThread.members, contains('user_2'));
      expect(groupThread.members, contains('user_3'));
    });

    test('should create individual chat thread', () {
      final individualThread = ChatThread(
        id: 'chat_123',
        name: 'John Doe',
        lastMessage: 'Hello!',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        avatarUrl: 'https://example.com/john_avatar.jpg',
        isGroup: false,
        members: ['user_1', 'user_2'],
        unreadCounts: {'user_1': 0, 'user_2': 1},
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
      );

      expect(individualThread.isGroup, false);
      expect(individualThread.groupAdminId, null);
      expect(individualThread.groupDescription, null);
      expect(individualThread.members.length, 2);
    });

    group('isUserAdmin', () {
      test('should return true when user is admin of group', () {
        final groupThread = ChatThread(
          id: 'group_123',
          name: 'Test Group',
          lastMessage: 'Hello everyone!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/group_avatar.jpg',
          isGroup: true,
          members: ['user_1', 'user_2', 'user_3'],
          unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          groupAdminId: 'user_1',
          groupDescription: 'A test group for testing purposes',
        );

        expect(groupThread.isUserAdmin('user_1'), true);
        expect(groupThread.isUserAdmin('user_2'), false);
        expect(groupThread.isUserAdmin('user_3'), false);
        expect(groupThread.isUserAdmin('user_4'), false);
      });

      test('should return false for individual chat threads', () {
        final individualThread = ChatThread(
          id: 'chat_123',
          name: 'John Doe',
          lastMessage: 'Hello!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/john_avatar.jpg',
          isGroup: false,
          members: ['user_1', 'user_2'],
          unreadCounts: {'user_1': 0, 'user_2': 1},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
        );

        expect(individualThread.isUserAdmin('user_1'), false);
        expect(individualThread.isUserAdmin('user_2'), false);
      });

      test('should return false when groupAdminId is null', () {
        final groupThread = ChatThread(
          id: 'group_123',
          name: 'Test Group',
          lastMessage: 'Hello everyone!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/group_avatar.jpg',
          isGroup: true,
          members: ['user_1', 'user_2', 'user_3'],
          unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          groupAdminId: null,
          groupDescription: 'A test group for testing purposes',
        );

        expect(groupThread.isUserAdmin('user_1'), false);
        expect(groupThread.isUserAdmin('user_2'), false);
      });
    });

    group('canUserManage', () {
      test('should return true when user is admin of group', () {
        final groupThread = ChatThread(
          id: 'group_123',
          name: 'Test Group',
          lastMessage: 'Hello everyone!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/group_avatar.jpg',
          isGroup: true,
          members: ['user_1', 'user_2', 'user_3'],
          unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          groupAdminId: 'user_1',
          groupDescription: 'A test group for testing purposes',
        );

        expect(groupThread.canUserManage('user_1'), true);
        expect(groupThread.canUserManage('user_2'), false);
        expect(groupThread.canUserManage('user_3'), false);
      });

      test('should return false for individual chat threads', () {
        final individualThread = ChatThread(
          id: 'chat_123',
          name: 'John Doe',
          lastMessage: 'Hello!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/john_avatar.jpg',
          isGroup: false,
          members: ['user_1', 'user_2'],
          unreadCounts: {'user_1': 0, 'user_2': 1},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
        );

        expect(individualThread.canUserManage('user_1'), false);
        expect(individualThread.canUserManage('user_2'), false);
      });
    });

    group('getUnreadCount', () {
      test('should return correct unread count for user', () {
        final groupThread = ChatThread(
          id: 'group_123',
          name: 'Test Group',
          lastMessage: 'Hello everyone!',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          avatarUrl: 'https://example.com/group_avatar.jpg',
          isGroup: true,
          members: ['user_1', 'user_2', 'user_3'],
          unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
          createdAt: DateTime(2024, 1, 1, 10, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          groupAdminId: 'user_1',
          groupDescription: 'A test group for testing purposes',
        );

        expect(groupThread.getUnreadCount('user_1'), 0);
        expect(groupThread.getUnreadCount('user_2'), 1);
        expect(groupThread.getUnreadCount('user_3'), 2);
        expect(groupThread.getUnreadCount('user_4'), 0); // Non-member
      });
    });

    test('should handle group thread with different admin', () {
      final groupThread = ChatThread(
        id: 'group_123',
        name: 'Test Group',
        lastMessage: 'Hello everyone!',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        avatarUrl: 'https://example.com/group_avatar.jpg',
        isGroup: true,
        members: ['user_1', 'user_2', 'user_3', 'user_4'],
        unreadCounts: {'user_1': 0, 'user_2': 0, 'user_3': 1, 'user_4': 0},
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        groupAdminId: 'user_2',
        groupDescription: 'Updated group description',
      );

      expect(groupThread.name, 'Test Group');
      expect(groupThread.groupDescription, 'Updated group description');
      expect(groupThread.members.length, 4);
      expect(groupThread.members, contains('user_4'));
      expect(groupThread.groupAdminId, 'user_2');
      expect(groupThread.isUserAdmin('user_1'), false);
      expect(groupThread.isUserAdmin('user_2'), true);
      expect(groupThread.getUnreadCount('user_4'), 0);
    });

    test('should handle group thread without admin', () {
      final groupThread = ChatThread(
        id: 'group_123',
        name: 'Test Group',
        lastMessage: 'Hello everyone!',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        avatarUrl: 'https://example.com/group_avatar.jpg',
        isGroup: true,
        members: ['user_1', 'user_2', 'user_3'],
        unreadCounts: {'user_1': 0, 'user_2': 1, 'user_3': 2},
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        groupAdminId: null,
        groupDescription: null,
      );

      expect(groupThread.isUserAdmin('user_1'), false);
      expect(groupThread.isUserAdmin('user_2'), false);
      expect(groupThread.canUserManage('user_1'), false);
      expect(groupThread.canUserManage('user_2'), false);
      expect(groupThread.groupAdminId, null);
      expect(groupThread.groupDescription, null);
    });

    test('should create group thread with minimal required fields', () {
      final groupThread = ChatThread(
        id: 'group_123',
        name: 'Test Group',
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1, 10, 0),
        avatarUrl: '',
        isGroup: true,
        members: ['user_1'],
        unreadCounts: {'user_1': 0},
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 0),
      );

      expect(groupThread.isGroup, true);
      expect(groupThread.groupAdminId, null);
      expect(groupThread.groupDescription, null);
      expect(groupThread.members.length, 1);
      expect(groupThread.members, contains('user_1'));
      expect(groupThread.isUserAdmin('user_1'), false);
      expect(groupThread.canUserManage('user_1'), false);
    });
  });
}
