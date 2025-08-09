import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage File Attachment Tests', () {
    test('should create message with file attachment properties', () {
      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'test.jpg',
        type: MessageType.image,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 1, 12, 0),
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        fileUrl: 'https://example.com/file.jpg',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      expect(message.hasFileAttachment, true);
      expect(message.isImage, true);
      expect(message.isVideo, false);
      expect(message.isFile, false);
      expect(message.fileUrl, 'https://example.com/file.jpg');
      expect(message.fileName, 'test.jpg');
      expect(message.fileType, 'image/jpeg');
      expect(message.fileSize, 1024);
      expect(message.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('should create video message with file attachment', () {
      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'test.mp4',
        type: MessageType.video,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 1, 12, 0),
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        fileUrl: 'https://example.com/video.mp4',
        fileName: 'test.mp4',
        fileType: 'video/mp4',
        fileSize: 1024 * 1024, // 1MB
        thumbnailUrl: 'https://example.com/video_thumb.jpg',
      );

      expect(message.hasFileAttachment, true);
      expect(message.isImage, false);
      expect(message.isVideo, true);
      expect(message.isFile, false);
      expect(message.fileUrl, 'https://example.com/video.mp4');
      expect(message.fileName, 'test.mp4');
      expect(message.fileType, 'video/mp4');
      expect(message.fileSize, 1024 * 1024);
      expect(message.thumbnailUrl, 'https://example.com/video_thumb.jpg');
    });

    test('should create document message with file attachment', () {
      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'document.pdf',
        type: MessageType.file,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 1, 12, 0),
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        fileUrl: 'https://example.com/document.pdf',
        fileName: 'document.pdf',
        fileType: 'application/pdf',
        fileSize: 2048 * 1024, // 2MB
      );

      expect(message.hasFileAttachment, true);
      expect(message.isImage, false);
      expect(message.isVideo, false);
      expect(message.isFile, true);
      expect(message.fileUrl, 'https://example.com/document.pdf');
      expect(message.fileName, 'document.pdf');
      expect(message.fileType, 'application/pdf');
      expect(message.fileSize, 2048 * 1024);
      expect(message.thumbnailUrl, null);
    });

    test('should create text message without file attachment', () {
      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'Hello world!',
        type: MessageType.text,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 1, 12, 0),
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
      );

      expect(message.hasFileAttachment, false);
      expect(message.isImage, false);
      expect(message.isVideo, false);
      expect(message.isFile, false);
      expect(message.fileUrl, null);
      expect(message.fileName, null);
      expect(message.fileType, null);
      expect(message.fileSize, null);
      expect(message.thumbnailUrl, null);
    });

    group('fileSizeString', () {
      test('should format file size correctly', () {
        final message = ChatMessage(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.jpg',
          type: MessageType.image,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 1, 12, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          fileUrl: 'https://example.com/file.jpg',
          fileName: 'test.jpg',
          fileType: 'image/jpeg',
          fileSize: 1024,
        );

        expect(message.fileSizeString, '1.0KB');
      });

      test('should format bytes correctly', () {
        final message = ChatMessage(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.txt',
          type: MessageType.file,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 1, 12, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          fileUrl: 'https://example.com/file.txt',
          fileName: 'test.txt',
          fileType: 'text/plain',
          fileSize: 512,
        );

        expect(message.fileSizeString, '512B');
      });

      test('should format MB correctly', () {
        final message = ChatMessage(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.mp4',
          type: MessageType.video,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 1, 12, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          fileUrl: 'https://example.com/video.mp4',
          fileName: 'test.mp4',
          fileType: 'video/mp4',
          fileSize: 2 * 1024 * 1024, // 2MB
        );

        expect(message.fileSizeString, '2.0MB');
      });

      test('should format GB correctly', () {
        final message = ChatMessage(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.mp4',
          type: MessageType.video,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 1, 12, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          fileUrl: 'https://example.com/video.mp4',
          fileName: 'test.mp4',
          fileType: 'video/mp4',
          fileSize: 2 * 1024 * 1024 * 1024, // 2GB
        );

        expect(message.fileSizeString, '2.0GB');
      });

      test('should return empty string when fileSize is null', () {
        final message = ChatMessage(
          id: 'msg_123',
          chatThreadId: 'thread_456',
          senderId: 'user_789',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'test.jpg',
          type: MessageType.image,
          status: MessageStatus.sent,
          sentAt: DateTime(2024, 1, 1, 12, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 0),
          fileUrl: 'https://example.com/file.jpg',
          fileName: 'test.jpg',
          fileType: 'image/jpeg',
        );

        expect(message.fileSizeString, '');
      });
    });

    test('should copy message with new file properties', () {
      final originalMessage = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'thread_456',
        senderId: 'user_789',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'test.jpg',
        type: MessageType.image,
        status: MessageStatus.sent,
        sentAt: DateTime(2024, 1, 1, 12, 0),
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
        fileUrl: 'https://example.com/file.jpg',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
      );

      final copiedMessage = originalMessage.copyWith(
        fileUrl: 'https://example.com/new_file.jpg',
        fileName: 'new_test.jpg',
        fileSize: 2048,
      );

      expect(copiedMessage.fileUrl, 'https://example.com/new_file.jpg');
      expect(copiedMessage.fileName, 'new_test.jpg');
      expect(copiedMessage.fileType, 'image/jpeg'); // Should remain the same
      expect(copiedMessage.fileSize, 2048);
      expect(copiedMessage.content, 'test.jpg'); // Should remain the same
    });
  });
}
