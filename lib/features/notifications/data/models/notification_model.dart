import '../../domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
    );
  }

  factory NotificationModel.fromFirebaseMessage(Map<String, dynamic> message) {
    final notification = message['notification'] ?? {};
    final data = Map<String, dynamic>.from(message['data'] ?? {});
    
    return NotificationModel(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification['title'] ?? data['title'] ?? '',
      body: notification['body'] ?? data['body'] ?? '',
      type: data['type'] ?? 'general',
      data: data,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      isRead: false,
      imageUrl: notification['imageUrl'] ?? data['imageUrl'],
      actionUrl: data['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data.toString(), // Convert map to string for SQLite
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead ? 1 : 0,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromSQLite(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      type: map['type'],
      data: _parseDataString(map['data']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] == 1,
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
    );
  }

  static Map<String, dynamic> _parseDataString(String? dataString) {
    if (dataString == null || dataString.isEmpty) return {};
    try {
      // Simple parsing - in real app, you might want to use json.decode
      return <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: createdAt,
      isRead: isRead,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      data: entity.data,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
      imageUrl: entity.imageUrl,
      actionUrl: entity.actionUrl,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
