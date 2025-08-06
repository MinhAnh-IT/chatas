import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

void main() {
  group('ChatThreadModel', () {
    final tDateTime = DateTime(2024, 1, 1, 10, 30);
    final tTimestamp = Timestamp.fromDate(tDateTime);
    final tCreatedAt = DateTime(2024, 1, 1, 9, 0);
    final tCreatedAtTimestamp = Timestamp.fromDate(tCreatedAt);

    final tChatThreadModel = ChatThreadModel(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.png',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCount: 5,
      createdAt: tCreatedAt,
      updatedAt: tDateTime,
    );

    final tChatThreadEntity = ChatThread(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.png',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCount: 5,
      createdAt: tCreatedAt,
      updatedAt: tDateTime,
    );

    final tMapWithTimestamp = {
      'id': '1',
      'name': 'John Doe',
      'lastMessage': 'Hello there!',
      'lastMessageTime': tTimestamp,
      'avatarUrl': 'https://example.com/avatar.png',
      'members': ['user1', 'user2'],
      'isGroup': false,
      'unreadCount': 5,
      'createdAt': tCreatedAtTimestamp,
      'updatedAt': tTimestamp,
    };

    final tMapWithDateTime = {
      'id': '1',
      'name': 'John Doe',
      'lastMessage': 'Hello there!',
      'lastMessageTime': tDateTime,
      'avatarUrl': 'https://example.com/avatar.png',
      'members': ['user1', 'user2'],
      'isGroup': false,
      'unreadCount': 5,
      'createdAt': tCreatedAt,
      'updatedAt': tDateTime,
    };

    test('should create ChatThreadModel with all required properties', () {
      // Act & Assert
      expect(tChatThreadModel.id, '1');
      expect(tChatThreadModel.name, 'John Doe');
      expect(tChatThreadModel.lastMessage, 'Hello there!');
      expect(tChatThreadModel.lastMessageTime, tDateTime);
      expect(tChatThreadModel.avatarUrl, 'https://example.com/avatar.png');
      expect(tChatThreadModel.members, const ['user1', 'user2']);
      expect(tChatThreadModel.isGroup, false);
      expect(tChatThreadModel.unreadCount, 5);
      expect(tChatThreadModel.createdAt, tCreatedAt);
      expect(tChatThreadModel.updatedAt, tDateTime);
    });

    test('should convert from JSON with Timestamp correctly', () {
      // Act
      final result = ChatThreadModel.fromJson(tMapWithTimestamp);

      // Assert
      expect(result.id, tChatThreadModel.id);
      expect(result.name, tChatThreadModel.name);
      expect(result.lastMessage, tChatThreadModel.lastMessage);
      expect(result.lastMessageTime, tChatThreadModel.lastMessageTime);
      expect(result.avatarUrl, tChatThreadModel.avatarUrl);
      expect(result.members, tChatThreadModel.members);
      expect(result.isGroup, tChatThreadModel.isGroup);
      expect(result.unreadCount, tChatThreadModel.unreadCount);
      expect(result.createdAt, tChatThreadModel.createdAt);
      expect(result.updatedAt, tChatThreadModel.updatedAt);
    });

    test('should convert from JSON with DateTime correctly', () {
      // Act
      final result = ChatThreadModel.fromJson(tMapWithDateTime);

      // Assert
      expect(result, equals(tChatThreadModel));
    });

    test('should convert to JSON correctly', () {
      // Act
      final result = tChatThreadModel.toJson();

      // Assert
      expect(result, equals(tMapWithDateTime));
    });

    test('should convert to Entity correctly', () {
      // Act
      final result = tChatThreadModel.toEntity();

      // Assert
      expect(result, equals(tChatThreadEntity));
      expect(result.lastMessageTime, equals(tDateTime));
      expect(result.createdAt, equals(tCreatedAt));
      expect(result.updatedAt, equals(tDateTime));
    });

    test('should convert from Entity correctly', () {
      // Act
      final result = ChatThreadModel.fromEntity(tChatThreadEntity);

      // Assert
      expect(result.id, equals(tChatThreadEntity.id));
      expect(result.name, equals(tChatThreadEntity.name));
      expect(result.lastMessage, equals(tChatThreadEntity.lastMessage));
      expect(result.lastMessageTime, equals(tChatThreadEntity.lastMessageTime));
      expect(result.avatarUrl, equals(tChatThreadEntity.avatarUrl));
      expect(result.members, equals(tChatThreadEntity.members));
      expect(result.isGroup, equals(tChatThreadEntity.isGroup));
      expect(result.unreadCount, equals(tChatThreadEntity.unreadCount));
      expect(result.createdAt, equals(tChatThreadEntity.createdAt));
      expect(result.updatedAt, equals(tChatThreadEntity.updatedAt));
    });

    test('should handle group chat conversion correctly', () {
      // Arrange
      final groupEntity = ChatThread(
        id: 'group_1',
        name: 'Team Chat',
        lastMessage: 'Meeting at 3 PM',
        lastMessageTime: tDateTime,
        avatarUrl: 'https://example.com/group_avatar.png',
        members: const ['user1', 'user2', 'user3', 'user4'],
        isGroup: true,
        unreadCount: 12,
        createdAt: tCreatedAt,
        updatedAt: tDateTime,
      );

      // Act
      final model = ChatThreadModel.fromEntity(groupEntity);
      final backToEntity = model.toEntity();

      // Assert
      expect(backToEntity.isGroup, true);
      expect(backToEntity.members.length, 4);
      expect(backToEntity, equals(groupEntity));
    });

    test('should handle empty values correctly', () {
      // Arrange
      final emptyEntity = ChatThread(
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

      // Act
      final model = ChatThreadModel.fromEntity(emptyEntity);
      final backToEntity = model.toEntity();

      // Assert
      expect(backToEntity.lastMessage, '');
      expect(backToEntity.avatarUrl, '');
      expect(backToEntity.members, isEmpty);
      expect(backToEntity.unreadCount, 0);
      expect(backToEntity, equals(emptyEntity));
    });

    test('should handle JSON with missing optional fields', () {
      // Arrange
      final incompleteMap = {
        'id': '1',
        'name': 'John Doe',
        'lastMessage': 'Hello there!',
        'lastMessageTime': tTimestamp,
        'members': ['user1', 'user2'],
        'isGroup': false,
        'unreadCount': 5,
        'createdAt': tCreatedAtTimestamp,
        'updatedAt': tTimestamp,
        // Missing avatarUrl
      };

      // Act
      final result = ChatThreadModel.fromJson(incompleteMap);

      // Assert
      expect(result.id, '1');
      expect(result.name, 'John Doe');
      expect(result.avatarUrl, ''); // Should default to empty string
    });

    test('should handle invalid date formats gracefully', () {
      // Arrange
      final mapWithInvalidDate = {
        'id': '1',
        'name': 'John Doe',
        'lastMessage': 'Hello there!',
        'lastMessageTime': 'invalid_date', // Invalid date type
        'avatarUrl': 'https://example.com/avatar.png',
        'members': ['user1', 'user2'],
        'isGroup': false,
        'unreadCount': 5,
        'createdAt': tCreatedAtTimestamp,
        'updatedAt': tTimestamp,
      };

      // Act
      final result = ChatThreadModel.fromJson(mapWithInvalidDate);

      // Assert
      expect(result.lastMessageTime, isA<DateTime>()); // Should default to DateTime.now()
    });
  });
}
