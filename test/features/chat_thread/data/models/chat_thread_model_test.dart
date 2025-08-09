import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

void main() {
  group('ChatThreadModel', () {
    final tDateTime = DateTime(2024, 1, 1, 12, 0);
    final tChatThreadModel = ChatThreadModel(
      id: 'thread_123',
      name: 'Test Thread',
      lastMessage: 'Hello world!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.jpg',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCounts: const {'user1': 0, 'user2': 5},
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    test('should create ChatThreadModel with all required properties', () {
      expect(tChatThreadModel.id, 'thread_123');
      expect(tChatThreadModel.name, 'Test Thread');
      expect(tChatThreadModel.lastMessage, 'Hello world!');
      expect(tChatThreadModel.lastMessageTime, tDateTime);
      expect(tChatThreadModel.avatarUrl, 'https://example.com/avatar.jpg');
      expect(tChatThreadModel.members, const ['user1', 'user2']);
      expect(tChatThreadModel.isGroup, false);
      expect(tChatThreadModel.unreadCounts, const {'user1': 0, 'user2': 5});
      expect(tChatThreadModel.createdAt, tDateTime);
      expect(tChatThreadModel.updatedAt, tDateTime);
      expect(tChatThreadModel.groupAdminId, null);
      expect(tChatThreadModel.groupDescription, null);
    });

    test('should create ChatThreadModel with group properties', () {
      final groupModel = ChatThreadModel(
        id: 'thread_456',
        name: 'Test Group',
        lastMessage: 'Group message',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group.jpg',
        members: const ['user1', 'user2', 'user3'],
        isGroup: true,
        unreadCounts: const {'user1': 0, 'user2': 3, 'user3': 1},
        createdAt: tDateTime,
        updatedAt: tDateTime,
        groupAdminId: 'user1',
        groupDescription: 'Test group description',
      );

      expect(groupModel.isGroup, true);
      expect(groupModel.groupAdminId, 'user1');
      expect(groupModel.groupDescription, 'Test group description');
      expect(groupModel.members, hasLength(3));
    });

    test('should convert to entity correctly', () {
      final entity = tChatThreadModel.toEntity();

      expect(entity.id, tChatThreadModel.id);
      expect(entity.name, tChatThreadModel.name);
      expect(entity.lastMessage, tChatThreadModel.lastMessage);
      expect(entity.lastMessageTime, tChatThreadModel.lastMessageTime);
      expect(entity.avatarUrl, tChatThreadModel.avatarUrl);
      expect(entity.members, tChatThreadModel.members);
      expect(entity.isGroup, tChatThreadModel.isGroup);
      expect(entity.unreadCounts, tChatThreadModel.unreadCounts);
      expect(entity.createdAt, tChatThreadModel.createdAt);
      expect(entity.updatedAt, tChatThreadModel.updatedAt);
      expect(entity.groupAdminId, tChatThreadModel.groupAdminId);
      expect(entity.groupDescription, tChatThreadModel.groupDescription);
    });

    test('should convert from entity correctly', () {
      final entity = tChatThreadModel.toEntity();
      final model = ChatThreadModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.lastMessage, entity.lastMessage);
      expect(model.lastMessageTime, entity.lastMessageTime);
      expect(model.avatarUrl, entity.avatarUrl);
      expect(model.members, entity.members);
      expect(model.isGroup, entity.isGroup);
      expect(model.unreadCounts, entity.unreadCounts);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
      expect(model.groupAdminId, entity.groupAdminId);
      expect(model.groupDescription, entity.groupDescription);
    });

    group('fromJson', () {
      test('should create model from JSON with Timestamp', () {
        final json = {
          'id': 'thread_123',
          'name': 'Test Thread',
          'lastMessage': 'Hello world!',
          'lastMessageTime': Timestamp.fromDate(tDateTime),
          'avatarUrl': 'https://example.com/avatar.jpg',
          'members': ['user1', 'user2'],
          'isGroup': false,
          'unreadCounts': {'user1': 0, 'user2': 5},
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
        };

        final model = ChatThreadModel.fromJson(json);

        expect(model.id, 'thread_123');
        expect(model.name, 'Test Thread');
        expect(model.lastMessage, 'Hello world!');
        expect(model.lastMessageTime, tDateTime);
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.members, const ['user1', 'user2']);
        expect(model.isGroup, false);
        expect(model.unreadCounts, const {'user1': 0, 'user2': 5});
        expect(model.createdAt, tDateTime);
        expect(model.updatedAt, tDateTime);
      });

      test('should create group model from JSON', () {
        final json = {
          'id': 'thread_456',
          'name': 'Test Group',
          'lastMessage': 'Group message',
          'lastMessageTime': Timestamp.fromDate(tDateTime),
          'avatarUrl': 'https://example.com/group.jpg',
          'members': ['user1', 'user2', 'user3'],
          'isGroup': true,
          'unreadCounts': {'user1': 0, 'user2': 3, 'user3': 1},
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
          'groupAdminId': 'user1',
          'groupDescription': 'Test group description',
        };

        final model = ChatThreadModel.fromJson(json);

        expect(model.isGroup, true);
        expect(model.groupAdminId, 'user1');
        expect(model.groupDescription, 'Test group description');
        expect(model.members, hasLength(3));
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'thread_123',
          'name': 'Test Thread',
          'lastMessage': 'Hello world!',
          'lastMessageTime': Timestamp.fromDate(tDateTime),
          'members': ['user1', 'user2'],
          'isGroup': false,
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
        };

        final model = ChatThreadModel.fromJson(json);

        expect(model.avatarUrl, '');
        expect(model.unreadCounts, const {});
        expect(model.groupAdminId, null);
        expect(model.groupDescription, null);
      });
    });

    group('toJson', () {
      test('should convert model to JSON', () {
        final json = tChatThreadModel.toJson();

        expect(json['id'], 'thread_123');
        expect(json['name'], 'Test Thread');
        expect(json['lastMessage'], 'Hello world!');
        expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(json['members'], const ['user1', 'user2']);
        expect(json['isGroup'], false);
        expect(json['unreadCounts'], const {'user1': 0, 'user2': 5});
        expect(json['groupAdminId'], null);
        expect(json['groupDescription'], null);
      });

      test('should convert group model to JSON', () {
        final groupModel = ChatThreadModel(
          id: 'thread_456',
          name: 'Test Group',
          lastMessage: 'Group message',
          lastMessageTime: tDateTime,
          avatarUrl: 'https://example.com/group.jpg',
          members: const ['user1', 'user2', 'user3'],
          isGroup: true,
          unreadCounts: const {'user1': 0, 'user2': 3, 'user3': 1},
          createdAt: tDateTime,
          updatedAt: tDateTime,
          groupAdminId: 'user1',
          groupDescription: 'Test group description',
        );

        final json = groupModel.toJson();

        expect(json['isGroup'], true);
        expect(json['groupAdminId'], 'user1');
        expect(json['groupDescription'], 'Test group description');
        expect(json['members'], hasLength(3));
      });
    });

    test('should support equality comparison', () {
      final model1 = ChatThreadModel(
        id: 'thread_123',
        name: 'Test Thread',
        lastMessage: 'Hello world!',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/avatar.jpg',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 5},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final model2 = ChatThreadModel(
        id: 'thread_123',
        name: 'Test Thread',
        lastMessage: 'Hello world!',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/avatar.jpg',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 5},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('should handle different thread types', () {
      final individualModel = ChatThreadModel(
        id: 'thread_1',
        name: 'Individual Chat',
        lastMessage: 'Individual message',
        lastMessageTime: tDateTime,
        avatarUrl: '',
        members: const ['user1', 'user2'],
        isGroup: false,
        unreadCounts: const {'user1': 0, 'user2': 2},
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final groupModel = ChatThreadModel(
        id: 'thread_2',
        name: 'Group Chat',
        lastMessage: 'Group message',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group.jpg',
        members: const ['user1', 'user2', 'user3', 'user4'],
        isGroup: true,
        unreadCounts: const {'user1': 0, 'user2': 1, 'user3': 3, 'user4': 0},
        createdAt: tDateTime,
        updatedAt: tDateTime,
        groupAdminId: 'user1',
        groupDescription: 'Group description',
      );

      expect(individualModel.isGroup, false);
      expect(groupModel.isGroup, true);
      expect(individualModel.groupAdminId, null);
      expect(groupModel.groupAdminId, 'user1');
      expect(individualModel.members, hasLength(2));
      expect(groupModel.members, hasLength(4));
    });
  });
}
