import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import '../../constants/chat_message_remote_constants.dart';

/// Remote data source for chat message operations using Firestore.
/// Handles all Firebase Firestore interactions for chat messages.
class ChatMessageRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatMessageRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all messages for a specific chat thread from Firestore.
  /// Returns messages sorted by creation time in ascending order.
  Future<List<ChatMessageModel>> fetchMessages(String chatThreadId) async {
    print(
      'ChatMessageRemoteDataSource: Fetching messages for thread: $chatThreadId',
    );

    final snapshot = await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .where(
          ChatMessageRemoteConstants.chatThreadIdField,
          isEqualTo: chatThreadId,
        )
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: false)
        .limit(ChatMessageRemoteConstants.defaultMessageLimit)
        .get();

    print(
      'ChatMessageRemoteDataSource: Fetched ${snapshot.docs.length} documents',
    );

    // Debug: print all thread IDs in the collection
    final allDocsSnapshot = await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .limit(10)
        .get();
    print('ChatMessageRemoteDataSource: All thread IDs in collection:');
    for (final doc in allDocsSnapshot.docs) {
      final data = doc.data();
      print(
        '  - Thread ID: ${data['chatThreadId']}, Message: ${data['content']?.toString().substring(0, math.min(20, data['content']?.toString().length ?? 0))}...',
      );
    }

    // Filter out deleted messages in code instead of query
    return snapshot.docs
        .map((doc) => ChatMessageModel.fromJson(doc.data()))
        .where((message) => !message.isDeleted)
        .toList();
  }

  /// Provides a real-time stream of messages for a specific chat thread.
  /// Automatically updates when new messages are added or existing ones are modified.
  Stream<List<ChatMessageModel>> messagesStream(String chatThreadId) {
    print(
      'ChatMessageRemoteDataSource: Setting up messages stream for thread: $chatThreadId',
    );
    return firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .where(
          ChatMessageRemoteConstants.chatThreadIdField,
          isEqualTo: chatThreadId,
        )
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: false)
        .limit(ChatMessageRemoteConstants.defaultMessageLimit)
        .snapshots()
        .map((snapshot) {
          print(
            'ChatMessageRemoteDataSource: Stream received ${snapshot.docs.length} documents for thread $chatThreadId',
          );
          final messages = snapshot.docs
              .map((doc) => ChatMessageModel.fromJson(doc.data()))
              .where((message) => !message.isDeleted)
              .toList();
          print(
            'ChatMessageRemoteDataSource: After filtering, ${messages.length} messages for thread $chatThreadId',
          );
          return messages;
        });
  }

  /// Adds a new message to Firestore.
  /// Creates a new document in the messages collection.
  /// Also updates the lastMessage and lastMessageTime in the chat thread.
  Future<void> addMessage(ChatMessageModel model) async {
    print(
      'ChatMessageRemoteDataSource: Adding message to Firestore - ID: ${model.id}, ThreadID: ${model.chatThreadId}',
    );

    // Add the message
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(model.id)
        .set(model.toJson());
    print('ChatMessageRemoteDataSource: Message added successfully');

    // Update the chat thread's lastMessage and lastMessageTime
    try {
      await firestore
          .collection('chat_threads') // Using literal collection name
          .doc(model.chatThreadId)
          .update({
            'lastMessage': model.content,
            'lastMessageTime': model.sentAt.toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
      print(
        'ChatMessageRemoteDataSource: Updated chat thread lastMessage for thread: ${model.chatThreadId}',
      );
    } catch (e) {
      print(
        'ChatMessageRemoteDataSource: Error updating chat thread lastMessage: $e',
      );
      // Don't throw error, message was already sent successfully
    }
  }

  /// Updates an existing message in Firestore.
  /// Modifies the document with the specified message ID.
  Future<void> updateMessage(String messageId, ChatMessageModel model) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update(model.toJson());
  }

  /// Soft deletes a message by setting isDeleted flag to true.
  /// Does not permanently remove the message from Firestore.
  Future<void> deleteMessage(String messageId) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          ChatMessageRemoteConstants.isDeletedField: true,
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Adds a reaction to a specific message.
  /// Updates the reactions map with the user's reaction.
  Future<void> addReaction(
    String messageId,
    String userId,
    String reaction,
  ) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          '${ChatMessageRemoteConstants.reactionsField}.$userId': reaction,
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Removes a reaction from a specific message.
  /// Deletes the user's reaction from the reactions map.
  Future<void> removeReaction(String messageId, String userId) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          '${ChatMessageRemoteConstants.reactionsField}.$userId':
              FieldValue.delete(),
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Updates message status (e.g., delivered, read).
  /// Modifies the status field of the specified message.
  Future<void> updateMessageStatus(String messageId, String status) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          ChatMessageRemoteConstants.statusField: status,
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Edits the content of an existing message with ownership validation.
  /// Validates that the user owns the message before allowing edit.
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String userId,
  }) async {
    // First, get the message to validate ownership
    final messageDoc = await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .get();

    if (!messageDoc.exists) {
      throw Exception('Message not found');
    }

    final messageData = messageDoc.data()!;
    final messageSenderId =
        messageData[ChatMessageRemoteConstants.senderIdField];

    if (messageSenderId != userId) {
      throw Exception('You can only edit your own messages');
    }

    // Update the message content and editedAt timestamp
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          ChatMessageRemoteConstants.contentField: newContent,
          ChatMessageRemoteConstants.editedAtField:
              FieldValue.serverTimestamp(),
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Deletes a message with ownership validation.
  /// Validates that the user owns the message before allowing deletion.
  Future<void> deleteMessageWithValidation({
    required String messageId,
    required String userId,
  }) async {
    // First, get the message to validate ownership
    final messageDoc = await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .get();

    if (!messageDoc.exists) {
      throw Exception('Message not found');
    }

    final messageData = messageDoc.data()!;
    final messageSenderId =
        messageData[ChatMessageRemoteConstants.senderIdField];

    if (messageSenderId != userId) {
      throw Exception('You can only delete your own messages');
    }

    // Soft delete the message
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          ChatMessageRemoteConstants.isDeletedField: true,
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });
  }

  /// Fetches messages with pagination support.
  /// Uses the last document for cursor-based pagination.
  Future<List<ChatMessageModel>> fetchMessagesWithPagination(
    String chatThreadId, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .where(
          ChatMessageRemoteConstants.chatThreadIdField,
          isEqualTo: chatThreadId,
        )
        .where(ChatMessageRemoteConstants.isDeletedField, isEqualTo: false)
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
