import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import '../../constants/chat_message_remote_constants.dart';
import '../../../chat_thread/constants/chat_thread_remote_constants.dart';

/// Remote data source for chat message operations using Firestore.
/// Handles all Firebase Firestore interactions for chat messages.
class ChatMessageRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatMessageRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all messages for a specific chat thread from Firestore.
  /// Returns messages sorted by creation time in ascending order.
  Future<List<ChatMessageModel>> fetchMessages(
    String chatThreadId,
    String currentUserId,
  ) async {
    print(
      'ChatMessageRemoteDataSource: Fetching messages for thread: $chatThreadId',
    );

    try {
      // First, get the chat thread to check visibility settings
      final threadDoc = await firestore
          .collection(ChatThreadRemoteConstants.collectionName)
          .doc(chatThreadId)
          .get();

      DateTime? visibilityCutoff;
      if (threadDoc.exists) {
        final threadData = threadDoc.data()!;
        final isGroup = threadData['isGroup'] ?? false;

        if (isGroup) {
          // For group chats: check joinedAt timestamp
          final joinedAtData = threadData['joinedAt'] as Map<String, dynamic>?;
          if (joinedAtData != null && joinedAtData[currentUserId] != null) {
            final joinedAtString = joinedAtData[currentUserId] as String;
            visibilityCutoff = DateTime.parse(joinedAtString);
            print(
              'ChatMessageRemoteDataSource: Found joinedAt for group: $visibilityCutoff',
            );
          }
        } else {
          // For 1-1 chats: check visibilityCutoff timestamp
          final visibilityCutoffData =
              threadData['visibilityCutoff'] as Map<String, dynamic>?;
          if (visibilityCutoffData != null &&
              visibilityCutoffData[currentUserId] != null) {
            final cutoffString = visibilityCutoffData[currentUserId] as String;
            visibilityCutoff = DateTime.parse(cutoffString);
            print(
              'ChatMessageRemoteDataSource: Found visibilityCutoff for 1-1: $visibilityCutoff',
            );
          }
        }
      }

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

      final messages = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ChatMessageModel.fromJson(data);
          })
          .where((message) {
            // Filter by global isDeleted
            if (message.isDeleted) return false;

            // Filter by user-specific deletion
            if (message.deletedFor.contains(currentUserId)) return false;

            // Filter by visibility cutoff (for both 1-1 and group chats)
            if (visibilityCutoff != null) {
              final messageTime = message.createdAt;
              if (messageTime.isBefore(visibilityCutoff)) {
                print(
                  'ChatMessageRemoteDataSource: Filtering out message ${message.id} created at $messageTime (before $visibilityCutoff)',
                );
                return false;
              }
            }

            return true;
          })
          .toList();

      print(
        'ChatMessageRemoteDataSource: Returning ${messages.length} messages after filtering',
      );
      return messages;
    } catch (e) {
      print('ChatMessageRemoteDataSource: Error fetching messages: $e');
      rethrow;
    }
  }

  /// Fetches ALL messages for a specific chat thread from Firestore without filtering by deletedFor.
  /// Used for administrative operations like marking all messages as deleted.
  Future<List<ChatMessageModel>> fetchAllMessages(String chatThreadId) async {
    print(
      'ChatMessageRemoteDataSource: Fetching ALL messages for thread: $chatThreadId (no filtering)',
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
      'ChatMessageRemoteDataSource: Fetched ${snapshot.docs.length} documents (no filtering)',
    );

    // Return all messages without filtering by deletedFor
    final messages = snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ChatMessageModel.fromJson(data);
        })
        .where(
          (message) => !message.isDeleted,
        ) // Only filter by global isDeleted
        .toList();

    print(
      'ChatMessageRemoteDataSource: Returning ${messages.length} messages (no user filtering)',
    );

    return messages;
  }

  /// Provides a real-time stream of messages for a specific chat thread.
  /// Automatically updates when new messages are added or existing ones are modified.
  Stream<List<ChatMessageModel>> messagesStream(
    String chatThreadId,
    String currentUserId,
  ) {
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
        .asyncMap((snapshot) async {
          // Get the chat thread to check visibility settings
          final threadDoc = await firestore
              .collection(ChatThreadRemoteConstants.collectionName)
              .doc(chatThreadId)
              .get();

          DateTime? visibilityCutoff;
          if (threadDoc.exists) {
            final threadData = threadDoc.data()!;
            final isGroup = threadData['isGroup'] ?? false;

            if (isGroup) {
              // For group chats: check joinedAt timestamp
              final joinedAtData =
                  threadData['joinedAt'] as Map<String, dynamic>?;
              if (joinedAtData != null && joinedAtData[currentUserId] != null) {
                final joinedAtString = joinedAtData[currentUserId] as String;
                visibilityCutoff = DateTime.parse(joinedAtString);
              }
            } else {
              // For 1-1 chats: check visibilityCutoff timestamp
              final visibilityCutoffData =
                  threadData['visibilityCutoff'] as Map<String, dynamic>?;
              if (visibilityCutoffData != null &&
                  visibilityCutoffData[currentUserId] != null) {
                final cutoffString =
                    visibilityCutoffData[currentUserId] as String;
                visibilityCutoff = DateTime.parse(cutoffString);
              }
            }
          }

          final messages = snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return ChatMessageModel.fromJson(data);
              })
              .where((message) {
                // Filter by global isDeleted
                if (message.isDeleted) return false;

                // Filter by user-specific deletion
                if (message.deletedFor.contains(currentUserId)) return false;

                // Filter by visibility cutoff (for both 1-1 and group chats)
                if (visibilityCutoff != null) {
                  final messageTime = message.createdAt;
                  if (messageTime.isBefore(visibilityCutoff)) {
                    return false;
                  }
                }

                return true;
              })
              .toList();

          return messages;
        });
  }

  /// Adds a new message to Firestore.
  /// Creates a new document in the messages collection.
  /// Also updates the lastMessage, lastMessageTime, and increments unread count in the chat thread.
  /// Automatically revives the thread for the sender if they had hidden it.
  Future<void> addMessage(ChatMessageModel model) async {
    print(
      'ChatMessageRemoteDataSource: Adding message to Firestore - ID: ${model.id}, ThreadID: ${model.chatThreadId}',
    );

    // STEP 1: Check and revive thread for any members who should see this message
    final threadDoc = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(model.chatThreadId)
        .get();

    if (threadDoc.exists) {
      final threadData = threadDoc.data()!;
      final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);
      // final members = List<String>.from(threadData['members'] ?? []); // Currently unused
      final isGroup = threadData['isGroup'] ?? false;
      final visibilityCutoffData =
          threadData['visibilityCutoff'] as Map<String, dynamic>?;
      final joinedAtData = threadData['joinedAt'] as Map<String, dynamic>?;

      bool needsUpdate = false;
      final usersToRevive = <String>[];

      // Check each member in hiddenFor to see if they should see this new message
      for (final userId in List<String>.from(hiddenFor)) {
        bool shouldRevive = false;

        if (userId == model.senderId) {
          // Always revive for sender
          shouldRevive = true;
        } else {
          // For other members, check if this message is visible to them
          if (isGroup) {
            // For group chats: check joinedAt
            if (joinedAtData != null && joinedAtData[userId] != null) {
              final joinedAtString = joinedAtData[userId] as String;
              final joinedAt = DateTime.parse(joinedAtString);
              if (model.createdAt.isAfter(joinedAt) ||
                  model.createdAt.isAtSameMomentAs(joinedAt)) {
                shouldRevive = true;
              }
            } else {
              // No joinedAt means they can see all messages
              shouldRevive = true;
            }
          } else {
            // For 1-1 chats: check visibilityCutoff
            if (visibilityCutoffData != null &&
                visibilityCutoffData[userId] != null) {
              final cutoffString = visibilityCutoffData[userId] as String;
              final visibilityCutoff = DateTime.parse(cutoffString);
              if (model.createdAt.isAfter(visibilityCutoff) ||
                  model.createdAt.isAtSameMomentAs(visibilityCutoff)) {
                shouldRevive = true;
              }
            } else {
              // No visibilityCutoff means they can see all messages
              shouldRevive = true;
            }
          }
        }

        if (shouldRevive) {
          usersToRevive.add(userId);
        }
      }

      // Remove users who should be revived from hiddenFor
      for (final userId in usersToRevive) {
        if (hiddenFor.contains(userId)) {
          hiddenFor.remove(userId);
          needsUpdate = true;
          print(
            'ChatMessageRemoteDataSource: User $userId should see this message, reviving thread ${model.chatThreadId}',
          );
        }
      }

      // Update hiddenFor if needed
      if (needsUpdate) {
        await firestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(model.chatThreadId)
            .update({
              'hiddenFor': hiddenFor,
              'updatedAt': DateTime.now().toIso8601String(),
            });

        print(
          'ChatMessageRemoteDataSource: Successfully revived thread ${model.chatThreadId} for users: $usersToRevive',
        );
      }
    }

    // STEP 2: Add the message
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(model.id)
        .set(model.toJson());
    print('ChatMessageRemoteDataSource: Message added successfully');

    // Update the chat thread's lastMessage, lastMessageTime, and increment unread count for other users
    try {
      // Get chat thread to find other members
      final threadDoc = await firestore
          .collection(ChatThreadRemoteConstants.collectionName)
          .doc(model.chatThreadId)
          .get();

      if (threadDoc.exists) {
        final threadData = threadDoc.data()!;
        final members = List<String>.from(threadData['members'] ?? []);
        final currentUnreadCounts = Map<String, int>.from(
          threadData['unreadCounts'] ?? {},
        );

        // Increment unread count for members EXCEPT the sender,
        // but only if the message is visible to them (respecting visibilityCutoff/joinedAt)
        final isGroup = threadData['isGroup'] ?? false;
        final visibilityCutoffData =
            threadData['visibilityCutoff'] as Map<String, dynamic>?;
        final joinedAtData = threadData['joinedAt'] as Map<String, dynamic>?;

        for (final memberId in members) {
          if (memberId != model.senderId) {
            bool shouldIncrementUnread = true;

            // Check if this message is visible to the member
            if (isGroup) {
              // For group chats: check if member joined before this message
              if (joinedAtData != null && joinedAtData[memberId] != null) {
                final joinedAtString = joinedAtData[memberId] as String;
                final joinedAt = DateTime.parse(joinedAtString);
                if (model.createdAt.isBefore(joinedAt)) {
                  shouldIncrementUnread = false;
                }
              }
            } else {
              // For 1-1 chats: check visibilityCutoff
              if (visibilityCutoffData != null &&
                  visibilityCutoffData[memberId] != null) {
                final cutoffString = visibilityCutoffData[memberId] as String;
                final visibilityCutoff = DateTime.parse(cutoffString);
                if (model.createdAt.isBefore(visibilityCutoff)) {
                  shouldIncrementUnread = false;
                }
              }
            }

            if (shouldIncrementUnread) {
              currentUnreadCounts[memberId] =
                  (currentUnreadCounts[memberId] ?? 0) + 1;
            }
          }
        }

        await firestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(model.chatThreadId)
            .update({
              'lastMessage': model.content,
              'lastMessageTime': model.sentAt.toIso8601String(),
              'unreadCounts': currentUnreadCounts,
              'updatedAt': DateTime.now().toIso8601String(),
            });
      }
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

  /// Marks all messages in a chat thread as read for a specific user.
  /// Updates the chat thread's unread count and message read status.
  Future<void> markMessagesAsRead(String chatThreadId, String userId) async {
    try {
      print(
        'ChatMessageRemoteDataSource: markMessagesAsRead called for thread: $chatThreadId, user: $userId',
      );

      // Get all messages in this thread that are not deleted
      // We'll filter in code to avoid Firestore's limit on != queries
      final allMessagesQuery = await firestore
          .collection(ChatMessageRemoteConstants.collectionName)
          .where(
            ChatMessageRemoteConstants.chatThreadIdField,
            isEqualTo: chatThreadId,
          )
          .where(ChatMessageRemoteConstants.isDeletedField, isEqualTo: false)
          .get();

      // Filter in code: messages NOT from current user AND status != 'read'
      final unreadMessagesDocs = allMessagesQuery.docs.where((doc) {
        final data = doc.data();
        final senderId =
            data[ChatMessageRemoteConstants.senderIdField] as String?;
        final status = data[ChatMessageRemoteConstants.statusField] as String?;
        return senderId != userId && status != 'read';
      }).toList();

      print(
        'ChatMessageRemoteDataSource: Found ${unreadMessagesDocs.length} unread messages from others',
      );

      if (unreadMessagesDocs.isNotEmpty) {
        // Mark all messages as read
        final batch = firestore.batch();
        for (final doc in unreadMessagesDocs) {
          final data = doc.data();
          print(
            'ChatMessageRemoteDataSource: Marking message as read - ID: ${doc.id}, from: ${data['senderId']}, status: ${data['status']}',
          );
          batch.update(doc.reference, {
            ChatMessageRemoteConstants.statusField: 'read',
            ChatMessageRemoteConstants.updatedAtField:
                FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        print(
          'ChatMessageRemoteDataSource: Batch commit completed for ${unreadMessagesDocs.length} messages',
        );

        // Reset unread count for this specific user
        await firestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(chatThreadId)
            .update({
              'unreadCounts.$userId': 0,
              'updatedAt': DateTime.now().toIso8601String(),
            });

        print(
          'ChatMessageRemoteDataSource: Reset unread count to 0 for user: $userId in thread: $chatThreadId',
        );
      } else {
        print(
          'ChatMessageRemoteDataSource: No unread messages found to mark as read',
        );
      }
    } catch (e) {
      print('ChatMessageRemoteDataSource: Error marking messages as read: $e');
      // Don't throw - this is not critical
    }
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

    final chatThreadId =
        messageData[ChatMessageRemoteConstants.chatThreadIdField];

    // Get current deletedFor list
    final currentDeletedFor = List<String>.from(
      messageData['deletedFor'] ?? [],
    );

    // Add user to deletedFor list if not already there
    if (!currentDeletedFor.contains(userId)) {
      currentDeletedFor.add(userId);
    }

    // Update the message with new deletedFor list
    await firestore
        .collection(ChatMessageRemoteConstants.collectionName)
        .doc(messageId)
        .update({
          'deletedFor': currentDeletedFor,
          ChatMessageRemoteConstants.updatedAtField:
              FieldValue.serverTimestamp(),
        });

    // Update chat thread lastMessage if this was the last message
    await _updateLastMessageAfterDelete(chatThreadId);
  }

  /// Updates the lastMessage in chat thread after a message is deleted.
  /// Finds the most recent non-deleted message and updates the thread.
  Future<void> _updateLastMessageAfterDelete(String chatThreadId) async {
    try {
      // Get the chat thread to check if it has lastRecreatedAt
      final threadDoc = await firestore
          .collection(ChatThreadRemoteConstants.collectionName)
          .doc(chatThreadId)
          .get();

      DateTime? lastRecreatedAt;
      if (threadDoc.exists) {
        final threadData = threadDoc.data()!;
        final lastRecreatedAtString = threadData['lastRecreatedAt'] as String?;
        if (lastRecreatedAtString != null) {
          lastRecreatedAt = DateTime.parse(lastRecreatedAtString);
        }
      }

      // Get the most recent non-deleted message
      final recentMessagesQuery = await firestore
          .collection(ChatMessageRemoteConstants.collectionName)
          .where(
            ChatMessageRemoteConstants.chatThreadIdField,
            isEqualTo: chatThreadId,
          )
          .where(ChatMessageRemoteConstants.isDeletedField, isEqualTo: false)
          .orderBy(ChatMessageRemoteConstants.createdAtField, descending: true)
          .limit(10) // Get more messages to filter by lastRecreatedAt
          .get();

      // Filter messages by lastRecreatedAt if needed
      // Note: We can't filter by user here since we don't have the currentUserId
      // This method is called during message deletion, so we'll consider all messages
      // The user-specific filtering happens in the message fetching methods
      final validMessages = recentMessagesQuery.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data()))
          .where((message) {
            // If lastRecreatedAt is set, only consider messages after that timestamp
            // This ensures the lastMessage reflects the most recent visible message
            if (lastRecreatedAt != null) {
              return message.createdAt.isAfter(lastRecreatedAt);
            }
            return true;
          })
          .toList();

      if (validMessages.isNotEmpty) {
        // There's still a valid message
        final latestMessage = validMessages.first;

        await firestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(chatThreadId)
            .update({
              'lastMessage': latestMessage.content,
              'lastMessageTime': latestMessage.sentAt.toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

        print(
          'ChatMessageRemoteDataSource: Updated lastMessage after deletion for thread: $chatThreadId',
        );
      } else {
        // No non-deleted messages left
        await firestore
            .collection(ChatThreadRemoteConstants.collectionName)
            .doc(chatThreadId)
            .update({
              'lastMessage': '',
              'lastMessageTime': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

        print(
          'ChatMessageRemoteDataSource: Cleared lastMessage (no messages left) for thread: $chatThreadId',
        );
      }
    } catch (e) {
      print(
        'ChatMessageRemoteDataSource: Error updating lastMessage after delete: $e',
      );
      // Don't throw - message deletion was successful
    }
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
