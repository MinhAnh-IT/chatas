import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_thread.dart';

class ChatThreadModel extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final List<String> members;
  final bool isGroup;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupAdminId;
  final String? groupDescription;
  final List<String> hiddenFor;
  final DateTime? lastRecreatedAt;
  final Map<String, DateTime> visibilityCutoff;
  final Map<String, DateTime> joinedAt;

  const ChatThreadModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    required this.members,
    required this.isGroup,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
    this.groupAdminId,
    this.groupDescription,
    this.hiddenFor = const [],
    this.lastRecreatedAt,
    this.visibilityCutoff = const {},
    this.joinedAt = const {},
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> map) {
    return ChatThreadModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: _parseDate(map['lastMessageTime']),
      avatarUrl: map['avatarUrl'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      isGroup: map['isGroup'] ?? false,
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      groupAdminId: map['groupAdminId'],
      groupDescription: map['groupDescription'],
      hiddenFor: List<String>.from(map['hiddenFor'] ?? []),
      lastRecreatedAt: map['lastRecreatedAt'] != null
          ? _parseDate(map['lastRecreatedAt'])
          : null,
      visibilityCutoff: _parseDateTimeMap(map['visibilityCutoff'] ?? {}),
      joinedAt: _parseDateTimeMap(map['joinedAt'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'avatarUrl': avatarUrl,
      'members': members,
      'isGroup': isGroup,
      'unreadCounts': unreadCounts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'groupAdminId': groupAdminId,
      'groupDescription': groupDescription,
      'hiddenFor': hiddenFor,
      'lastRecreatedAt': lastRecreatedAt?.toIso8601String(),
      'visibilityCutoff': _serializeDateTimeMap(visibilityCutoff),
      'joinedAt': _serializeDateTimeMap(joinedAt),
    };
  }

  factory ChatThreadModel.fromEntity(ChatThread entity) {
    return ChatThreadModel(
      id: entity.id,
      name: entity.name,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      avatarUrl: entity.avatarUrl,
      members: entity.members,
      isGroup: entity.isGroup,
      unreadCounts: entity.unreadCounts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      groupAdminId: entity.groupAdminId,
      groupDescription: entity.groupDescription,
      hiddenFor: entity.hiddenFor,
      lastRecreatedAt: entity.lastRecreatedAt,
      visibilityCutoff: entity.visibilityCutoff,
      joinedAt: entity.joinedAt,
    );
  }

  ChatThread toEntity() {
    return ChatThread(
      id: id,
      name: name,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      avatarUrl: avatarUrl,
      members: members,
      isGroup: isGroup,
      unreadCounts: unreadCounts,
      createdAt: createdAt,
      updatedAt: updatedAt,
      groupAdminId: groupAdminId,
      groupDescription: groupDescription,
      hiddenFor: hiddenFor,
      lastRecreatedAt: lastRecreatedAt,
      visibilityCutoff: visibilityCutoff,
      joinedAt: joinedAt,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else if (date is DateTime) {
      return date;
    }
    return DateTime.now();
  }

  static Map<String, DateTime> _parseDateTimeMap(dynamic map) {
    if (map is! Map) return {};

    final result = <String, DateTime>{};
    for (final entry in map.entries) {
      if (entry.key is String) {
        final date = _parseDate(entry.value);
        result[entry.key as String] = date;
      }
    }
    return result;
  }

  static Map<String, String> _serializeDateTimeMap(Map<String, DateTime> map) {
    final result = <String, String>{};
    for (final entry in map.entries) {
      result[entry.key] = entry.value.toIso8601String();
    }
    return result;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    lastMessage,
    lastMessageTime,
    avatarUrl,
    members,
    isGroup,
    unreadCounts,
    createdAt,
    updatedAt,
    groupAdminId,
    groupDescription,
    hiddenFor,
    lastRecreatedAt,
    visibilityCutoff,
    joinedAt,
  ];
}
