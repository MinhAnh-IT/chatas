import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_thread_model.dart';
import '../../domain/entities/chat_thread.dart';
import '../../constants/chat_thread_remote_constants.dart';

class ChatThreadRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatThreadRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ChatThread>> fetchChatThreads() async {
    final snapshot = await firestore.collection(ChatThreadRemoteConstants.collectionName).get();
    return snapshot.docs
        .map((doc) => ChatThreadModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  Future<void> addChatThread(ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    await firestore.collection(ChatThreadRemoteConstants.collectionName).add(model.toJson());
  }

  Future<void> updateChatThread(String id, ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    await firestore.collection(ChatThreadRemoteConstants.collectionName).doc(id).update(model.toJson());
  }

  Future<void> deleteChatThread(String id) async {
    await firestore.collection(ChatThreadRemoteConstants.collectionName).doc(id).delete();
  }

  Stream<List<ChatThread>> chatThreadsStream() {
    return firestore.collection(ChatThreadRemoteConstants.collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatThreadModel.fromJson(doc.data()).toEntity())
          .toList();
    });
  }
}
