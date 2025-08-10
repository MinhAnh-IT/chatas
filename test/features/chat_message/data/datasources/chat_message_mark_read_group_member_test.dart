import 'package:chatas/features/chat_message/data/datasources/chat_message_remote_data_source.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_thread/constants/chat_thread_remote_constants.dart';
import 'package:chatas/features/chat_message/constants/chat_message_remote_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageRemoteDataSource - Group Member Mark as Read', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ChatMessageRemoteDataSource dataSource;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      dataSource = ChatMessageRemoteDataSource(firestore: fakeFirestore);
    });

    testWidgets(
      'should only mark messages visible to group member as read (after joinedAt)',
      (tester) async {
        // Setup: Create a group chat thread
        const threadId = 'group_thread_123';
        const adminId = 'admin_user';
        const memberId = 'member_user';
        final adminJoinTime = DateTime(
          2024,
          1,
          1,
          10,
          0,
        ); // Admin created group at 10:00
        final memberJoinTime = DateTime(
          2024,
          1,
          1,
          12,
          0,
        ); // Member joined at 12:00

        // Create chat thread document
        await fakeFirestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(threadId)
            .set({
              'id': threadId,
              'name': 'Test Group',
              'lastMessage': 'Latest message',
              'lastMessageTime': DateTime(2024, 1, 1, 13, 0).toIso8601String(),
              'avatarUrl': '',
              'members': [adminId, memberId],
              'isGroup': true,
              'unreadCounts': {adminId: 0, memberId: 2}, // Member has 2 unread
              'createdAt': adminJoinTime.toIso8601String(),
              'updatedAt': DateTime(2024, 1, 1, 13, 0).toIso8601String(),
              'groupAdminId': adminId,
              'hiddenFor': [],
              'joinedAt': {
                adminId: adminJoinTime
                    .toIso8601String(), // Admin joined at creation
                memberId: memberJoinTime
                    .toIso8601String(), // Member joined later
              },
              'visibilityCutoff': {},
            });

        // Create messages:
        // Message 1: Before member joined (should NOT be marked as read)
        // Message 2: After member joined (should be marked as read)
        // Message 3: From member themselves (should be ignored)

        final message1BeforeJoin = ChatMessageModel(
          id: 'msg_1',
          chatThreadId: threadId,
          senderId: adminId,
          senderName: 'Admin User',
          senderAvatarUrl: '',
          content: 'Message before member joined',
          type: 'text',
          status: 'sent',
          sentAt: DateTime(2024, 1, 1, 11, 0), // Before member join time
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 11, 0),
          updatedAt: DateTime(2024, 1, 1, 11, 0),
          deletedFor: [],
        );

        final message2AfterJoin = ChatMessageModel(
          id: 'msg_2',
          chatThreadId: threadId,
          senderId: adminId,
          senderName: 'Admin User',
          senderAvatarUrl: '',
          content: 'Message after member joined',
          type: 'text',
          status: 'sent', // Not read yet
          sentAt: DateTime(2024, 1, 1, 13, 0), // After member join time
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 13, 0),
          updatedAt: DateTime(2024, 1, 1, 13, 0),
          deletedFor: [],
        );

        final message3FromMember = ChatMessageModel(
          id: 'msg_3',
          chatThreadId: threadId,
          senderId: memberId,
          senderName: 'Member User',
          senderAvatarUrl: '',
          content: 'Message from member themselves',
          type: 'text',
          status: 'sent',
          sentAt: DateTime(2024, 1, 1, 14, 0),
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 14, 0),
          updatedAt: DateTime(2024, 1, 1, 14, 0),
          deletedFor: [],
        );

        // Add messages to Firestore
        await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_1')
            .set(message1BeforeJoin.toJson());

        await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_2')
            .set(message2AfterJoin.toJson());

        await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_3')
            .set(message3FromMember.toJson());

        // Act: Member marks messages as read
        await dataSource.markMessagesAsRead(threadId, memberId);

        // Assert: Check which messages were marked as read
        final message1Doc = await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_1')
            .get();
        final message2Doc = await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_2')
            .get();
        final message3Doc = await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_3')
            .get();

        // Message 1 (before join) should NOT be marked as read
        expect(message1Doc.data()!['status'], equals('sent'));

        // Message 2 (after join) should be marked as read
        expect(message2Doc.data()!['status'], equals('read'));

        // Message 3 (from member) should remain unchanged
        expect(message3Doc.data()!['status'], equals('sent'));

        // Check that unread count was reset to 0 for the member
        final threadDoc = await fakeFirestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(threadId)
            .get();

        final unreadCounts = Map<String, dynamic>.from(
          threadDoc.data()!['unreadCounts'] ?? {},
        );
        expect(unreadCounts[memberId], equals(0));
      },
    );

    testWidgets(
      'should mark all visible messages as read for group admin (no joinedAt restriction)',
      (tester) async {
        // Setup: Create a group chat thread
        const threadId = 'group_thread_456';
        const adminId = 'admin_user';
        const memberId = 'member_user';
        final adminJoinTime = DateTime(
          2024,
          1,
          1,
          10,
          0,
        ); // Admin created group at 10:00
        final memberJoinTime = DateTime(
          2024,
          1,
          1,
          12,
          0,
        ); // Member joined at 12:00

        // Create chat thread document
        await fakeFirestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(threadId)
            .set({
              'id': threadId,
              'name': 'Test Group',
              'lastMessage': 'Latest message',
              'lastMessageTime': DateTime(2024, 1, 1, 13, 0).toIso8601String(),
              'avatarUrl': '',
              'members': [adminId, memberId],
              'isGroup': true,
              'unreadCounts': {adminId: 1, memberId: 0}, // Admin has 1 unread
              'createdAt': adminJoinTime.toIso8601String(),
              'updatedAt': DateTime(2024, 1, 1, 13, 0).toIso8601String(),
              'groupAdminId': adminId,
              'hiddenFor': [],
              'joinedAt': {
                adminId: adminJoinTime
                    .toIso8601String(), // Admin joined at creation
                memberId: memberJoinTime
                    .toIso8601String(), // Member joined later
              },
              'visibilityCutoff': {},
            });

        // Create messages from member that admin should be able to read
        final messageFromMember = ChatMessageModel(
          id: 'msg_from_member',
          chatThreadId: threadId,
          senderId: memberId,
          senderName: 'Member User',
          senderAvatarUrl: '',
          content: 'Message from member to admin',
          type: 'text',
          status: 'sent', // Not read yet
          sentAt: DateTime(2024, 1, 1, 13, 0), // After member join time
          isDeleted: false,
          reactions: const {},
          replyToMessageId: null,
          createdAt: DateTime(2024, 1, 1, 13, 0),
          updatedAt: DateTime(2024, 1, 1, 13, 0),
          deletedFor: [],
        );

        // Add message to Firestore
        await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_from_member')
            .set(messageFromMember.toJson());

        // Act: Admin marks messages as read
        await dataSource.markMessagesAsRead(threadId, adminId);

        // Assert: Message should be marked as read
        final messageDoc = await fakeFirestore
            .collection(ChatMessageRemoteConstants.collectionName)
            .doc('msg_from_member')
            .get();

        expect(messageDoc.data()!['status'], equals('read'));

        // Check that unread count was reset to 0 for the admin
        final threadDoc = await fakeFirestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(threadId)
            .get();

        final unreadCounts = Map<String, dynamic>.from(
          threadDoc.data()!['unreadCounts'] ?? {},
        );
        expect(unreadCounts[adminId], equals(0));
      },
    );
  });
}
