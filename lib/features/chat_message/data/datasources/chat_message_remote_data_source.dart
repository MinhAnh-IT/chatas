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
    final snapshot = await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .where(ChatMessageRemoteConstants.chatThreadIdField, isEqualTo: chatThreadId)
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: false)
        .limit(ChatMessageRemoteConstants.defaultMessageLimit)
        .get();

    // Filter out deleted messages in code instead of query
    return snapshot.docs
        .map((doc) => ChatMessageModel.fromJson(doc.data()))
        .where((message) => !message.isDeleted)
        .toList();
  }

  /// Provides a real-time stream of messages for a specific chat thread.
  /// Automatically updates when new messages are added or existing ones are modified.
  Stream<List<ChatMessageModel>> messagesStream(String chatThreadId) {
    return firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .where(ChatMessageRemoteConstants.chatThreadIdField, isEqualTo: chatThreadId)
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: false)
        .limit(ChatMessageRemoteConstants.defaultMessageLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.data()))
            .where((message) => !message.isDeleted)
            .toList());
  }

  /// Adds a new message to Firestore.
  /// Creates a new document in the messages collection.
  Future<void> addMessage(ChatMessageModel model) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(model.id)
        .set(model.toJson());
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
      ChatMessageRemoteConstants.updatedAtField: FieldValue.serverTimestamp(),
    });
  }

  /// Adds a reaction to a specific message.
  /// Updates the reactions map with the user's reaction.
  Future<void> addReaction(String messageId, String userId, String reaction) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
      '${ChatMessageRemoteConstants.reactionsField}.$userId': reaction,
      ChatMessageRemoteConstants.updatedAtField: FieldValue.serverTimestamp(),
    });
  }

  /// Removes a reaction from a specific message.
  /// Deletes the user's reaction from the reactions map.
  Future<void> removeReaction(String messageId, String userId) async {
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
      '${ChatMessageRemoteConstants.reactionsField}.$userId': FieldValue.delete(),
      ChatMessageRemoteConstants.updatedAtField: FieldValue.serverTimestamp(),
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
      ChatMessageRemoteConstants.updatedAtField: FieldValue.serverTimestamp(),
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
        .where(ChatMessageRemoteConstants.chatThreadIdField, isEqualTo: chatThreadId)
        .where(ChatMessageRemoteConstants.isDeletedField, isEqualTo: false)
        .orderBy(ChatMessageRemoteConstants.createdAtField, descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChatMessageModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
