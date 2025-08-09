import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/features/chat_thread/constants/chat_thread_remote_constants.dart';

/// Migration script to update existing chat threads with new fields:
/// - visibilityCutoff: Map<String, DateTime> for 1-1 chats
/// - joinedAt: Map<String, DateTime> for group chats
/// - Ensure isGroup field exists
/// - Normalize members for 1-1 chats (sorted)
void main() async {
  print('Starting chat threads migration...');
  
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  int updatedCount = 0;
  
  try {
    // Get all chat threads
    final threadsSnapshot = await firestore.collection(ChatThreadRemoteConstants.collectionName).get();
    
    for (final doc in threadsSnapshot.docs) {
      final data = doc.data();
      bool needsUpdate = false;
      final updates = <String, dynamic>{};
      
      // Ensure isGroup field exists
      if (!data.containsKey('isGroup')) {
        final members = List<String>.from(data['members'] ?? []);
        final isGroup = members.length > 2;
        updates['isGroup'] = isGroup;
        needsUpdate = true;
        print('Added isGroup field: $isGroup for thread ${doc.id}');
      }
      
      // Add visibilityCutoff for 1-1 chats
      if (!data.containsKey('visibilityCutoff')) {
        updates['visibilityCutoff'] = {};
        needsUpdate = true;
        print('Added visibilityCutoff field for thread ${doc.id}');
      }
      
      // Add joinedAt for group chats
      if (!data.containsKey('joinedAt')) {
        updates['joinedAt'] = {};
        needsUpdate = true;
        print('Added joinedAt field for thread ${doc.id}');
      }
      
      // Ensure hiddenFor field exists
      if (!data.containsKey('hiddenFor')) {
        updates['hiddenFor'] = [];
        needsUpdate = true;
        print('Added hiddenFor field for thread ${doc.id}');
      }
      
      // Normalize members for 1-1 chats (sort them)
      final isGroup = data['isGroup'] ?? false;
      if (!isGroup) {
        final members = List<String>.from(data['members'] ?? []);
        if (members.length == 2) {
          final sortedMembers = [...members]..sort();
          if (members[0] != sortedMembers[0] || members[1] != sortedMembers[1]) {
            updates['members'] = sortedMembers;
            needsUpdate = true;
            print('Normalized members for 1-1 thread ${doc.id}: $members -> $sortedMembers');
          }
        }
      }
      
      // Apply updates if needed
      if (needsUpdate) {
        batch.update(doc.reference, updates);
        updatedCount++;
      }
    }
    
    // Commit all updates
    if (updatedCount > 0) {
      await batch.commit();
      print('Successfully updated $updatedCount chat threads');
    } else {
      print('No updates needed - all threads are already up to date');
    }
    
  } catch (e) {
    print('Error during migration: $e');
    rethrow;
  }
  
  print('Migration completed successfully!');
}
