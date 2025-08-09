import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';

void main() {
  group('ChatMessageModel', () {
    final tDateTime = DateTime(2024, 1, 1, 12, 0);
    final tChatMessageModel = ChatMessageModel(
      id: 'msg_123',
      chatThreadId: 'thread_456',
      senderId: 'user_789',
      senderName: 'Test User',
      senderAvatarUrl: 'https://example.com/avatar.jpg',
      content: 'Hello world!',
      type: 'text',
      status: 'sent',
      sentAt: tDateTime,
      isDeleted: false,
      reactions: const {},
      replyToMessageId: null,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    test('should create ChatMessageModel with all required properties', () {
      expect(tChatMessageModel.id, 'msg_123');
      expect(tChatMessageModel.chatThreadId, 'thread_456');
      expect(tChatMessageModel.senderId, 'user_789');
      expect(tChatMessageModel.senderName, 'Test User');
      expect(
        tChatMessageModel.senderAvatarUrl,
        'https://example.com/avatar.jpg',
      );
      expect(tChatMessageModel.content, 'Hello world!');
      expect(tChatMessageModel.type, 'text');
      expect(tChatMessageModel.status, 'sent');
      expect(tChatMessageModel.sentAt, tDateTime);
      expect(tChatMessageModel.isDeleted, false);
      expect(tChatMessageModel.reactions, const {});
      expect(tChatMessageModel.replyToMessageId, null);
      expect(tChatMessageModel.createdAt, tDateTime);
      expect(tChatMessageModel.updatedAt, tDateTime);
    });

    test('should create ChatMessageModel with file attachment properties', () {
      final modelWithFile = ChatMessageModel(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'test.jpg',
        type: 'image',
        status: 'sent',
        sentAt: tDateTime,
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: tDateTime,
        updatedAt: tDateTime,
        fileUrl: 'https://example.com/file.jpg',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      expect(modelWithFile.fileUrl, 'https://example.com/file.jpg');
      expect(modelWithFile.fileName, 'test.jpg');
      expect(modelWithFile.fileType, 'image/jpeg');
      expect(modelWithFile.fileSize, 1024);
      expect(modelWithFile.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('should convert to entity correctly', () {
      final entity = tChatMessageModel.toEntity();

      expect(entity.id, tChatMessageModel.id);
      expect(entity.chatThreadId, tChatMessageModel.chatThreadId);
      expect(entity.senderId, tChatMessageModel.senderId);
      expect(entity.senderName, tChatMessageModel.senderName);
      expect(entity.senderAvatarUrl, tChatMessageModel.senderAvatarUrl);
      expect(entity.content, tChatMessageModel.content);
      expect(entity.type, MessageType.text); // Should convert string to enum
      expect(
        entity.status,
        MessageStatus.sent,
      ); // Should convert string to enum
      expect(entity.sentAt, tChatMessageModel.sentAt);
      expect(entity.isDeleted, tChatMessageModel.isDeleted);
      expect(entity.reactions, tChatMessageModel.reactions);
      expect(entity.replyToMessageId, tChatMessageModel.replyToMessageId);
      expect(entity.createdAt, tChatMessageModel.createdAt);
      expect(entity.updatedAt, tChatMessageModel.updatedAt);
    });

    test('should convert from entity correctly', () {
      final entity = tChatMessageModel.toEntity();
      final model = ChatMessageModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.chatThreadId, entity.chatThreadId);
      expect(model.senderId, entity.senderId);
      expect(model.senderName, entity.senderName);
      expect(model.senderAvatarUrl, entity.senderAvatarUrl);
      expect(model.content, entity.content);
      expect(model.type, 'text'); // Should convert enum to string
      expect(model.status, 'sent'); // Should convert enum to string
      expect(model.sentAt, entity.sentAt);
      expect(model.isDeleted, entity.isDeleted);
      expect(model.reactions, entity.reactions);
      expect(model.replyToMessageId, entity.replyToMessageId);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
    });

    group('fromJson', () {
      test('should create model from JSON with Timestamp', () {
        final json = {
          'id': 'msg_123',
          'chatThreadId': 'thread_456',
          'senderId': 'user_789',
          'senderName': 'Test User',
          'senderAvatarUrl': 'https://example.com/avatar.jpg',
          'content': 'Hello world!',
          'type': 'text',
          'status': 'sent',
          'sentAt': Timestamp.fromDate(tDateTime),
          'isDeleted': false,
          'reactions': {},
          'replyToMessageId': null,
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
        };

        final model = ChatMessageModel.fromJson(json);

        expect(model.id, 'msg_123');
        expect(model.chatThreadId, 'thread_456');
        expect(model.senderId, 'user_789');
        expect(model.senderName, 'Test User');
        expect(model.senderAvatarUrl, 'https://example.com/avatar.jpg');
        expect(model.content, 'Hello world!');
        expect(model.type, 'text');
        expect(model.status, 'sent');
        expect(model.sentAt, tDateTime);
        expect(model.isDeleted, false);
        expect(model.reactions, const {});
        expect(model.replyToMessageId, null);
        expect(model.createdAt, tDateTime);
        expect(model.updatedAt, tDateTime);
      });

      test('should create model from JSON with file attachment', () {
        final json = {
          'id': 'msg_123',
          'chatThreadId': 'thread_456',
          'senderId': 'user_789',
          'senderName': 'Test User',
          'senderAvatarUrl': 'https://example.com/avatar.jpg',
          'content': 'test.jpg',
          'type': 'image',
          'status': 'sent',
          'sentAt': Timestamp.fromDate(tDateTime),
          'isDeleted': false,
          'reactions': {},
          'replyToMessageId': null,
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
          'fileUrl': 'https://example.com/file.jpg',
          'fileName': 'test.jpg',
          'fileType': 'image/jpeg',
          'fileSize': 1024,
          'thumbnailUrl': 'https://example.com/thumb.jpg',
        };

        final model = ChatMessageModel.fromJson(json);

        expect(model.fileUrl, 'https://example.com/file.jpg');
        expect(model.fileName, 'test.jpg');
        expect(model.fileType, 'image/jpeg');
        expect(model.fileSize, 1024);
        expect(model.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'msg_123',
          'chatThreadId': 'thread_456',
          'senderId': 'user_789',
          'senderName': 'Test User',
          'content': 'Hello world!',
          'type': 'text',
          'status': 'sent',
          'sentAt': Timestamp.fromDate(tDateTime),
          'createdAt': Timestamp.fromDate(tDateTime),
          'updatedAt': Timestamp.fromDate(tDateTime),
        };

        final model = ChatMessageModel.fromJson(json);

        expect(model.senderAvatarUrl, '');
        expect(model.isDeleted, false);
        expect(model.reactions, const {});
        expect(model.replyToMessageId, null);
        expect(model.fileUrl, null);
        expect(model.fileName, null);
        expect(model.fileType, null);
        expect(model.fileSize, null);
        expect(model.thumbnailUrl, null);
      });
    });

    group('toJson', () {
      test('should convert model to JSON', () {
        final json = tChatMessageModel.toJson();

        expect(json['id'], 'msg_123');
        expect(json['chatThreadId'], 'thread_456');
        expect(json['senderId'], 'user_789');
        expect(json['senderName'], 'Test User');
        expect(json['senderAvatarUrl'], 'https://example.com/avatar.jpg');
        expect(json['content'], 'Hello world!');
        expect(json['type'], 'text');
        expect(json['status'], 'sent');
        expect(json['isDeleted'], false);
        expect(json['reactions'], const {});
        expect(json['replyToMessageId'], null);
      });

      test('should convert model with file attachment to JSON', () {
        final modelWithFile = ChatMessageModel(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.jpg',
          type: 'image',
          status: 'sent',
          sentAt: tDateTime,
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: tDateTime,
          updatedAt: tDateTime,
          fileUrl: 'https://example.com/file.jpg',
          fileName: 'test.jpg',
          fileType: 'image/jpeg',
          fileSize: 1024,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        final json = modelWithFile.toJson();

        expect(json['fileUrl'], 'https://example.com/file.jpg');
        expect(json['fileName'], 'test.jpg');
        expect(json['fileType'], 'image/jpeg');
        expect(json['fileSize'], 1024);
        expect(json['thumbnailUrl'], 'https://example.com/thumb.jpg');
      });
    });

    test('should support equality comparison', () {
      final model1 = ChatMessageModel(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'Hello world!',
        type: 'text',
        status: 'sent',
        sentAt: tDateTime,
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final model2 = ChatMessageModel(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'Hello world!',
        type: 'text',
        status: 'sent',
        sentAt: tDateTime,
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('should handle different message types', () {
      final textModel = ChatMessageModel(
        id: 'msg_1',
        chatThreadId: 'thread_1',
        senderId: 'user_1',
        senderName: 'User 1',
        senderAvatarUrl: '',
        content: 'Text message',
        type: 'text',
        status: 'sent',
        sentAt: tDateTime,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final imageModel = ChatMessageModel(
        id: 'msg_2',
        chatThreadId: 'thread_1',
        senderId: 'user_1',
        senderName: 'User 1',
        senderAvatarUrl: '',
        content: 'image.jpg',
        type: 'image',
        status: 'sent',
        sentAt: tDateTime,
        createdAt: tDateTime,
        updatedAt: tDateTime,
        fileUrl: 'https://example.com/image.jpg',
        fileName: 'image.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
      );

      final videoModel = ChatMessageModel(
        id: 'msg_3',
        chatThreadId: 'thread_1',
        senderId: 'user_1',
        senderName: 'User 1',
        senderAvatarUrl: '',
        content: 'video.mp4',
        type: 'video',
        status: 'sent',
        sentAt: tDateTime,
        createdAt: tDateTime,
        updatedAt: tDateTime,
        fileUrl: 'https://example.com/video.mp4',
        fileName: 'video.mp4',
        fileType: 'video/mp4',
        fileSize: 2048,
      );

      expect(textModel.type, 'text');
      expect(imageModel.type, 'image');
      expect(videoModel.type, 'video');
      expect(imageModel.fileUrl, isNotNull);
      expect(videoModel.fileUrl, isNotNull);
      expect(textModel.fileUrl, isNull);
    });
  });
}
