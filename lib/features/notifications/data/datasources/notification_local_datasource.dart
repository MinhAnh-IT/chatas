import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/notification_model.dart';

class NotificationLocalDataSource {
  static Database? _database;
  static const String _tableName = 'notifications';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'notifications.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT,
        createdAt INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        imageUrl TEXT,
        actionUrl TEXT
      )
    ''');
  }

  /// Lưu thông báo
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      _tableName,
      notification.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy tất cả thông báo (sắp xếp theo thời gian mới nhất)
  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromSQLite(maps[i]);
    });
  }

  /// Lấy thông báo theo ID
  Future<NotificationModel?> getNotificationById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NotificationModel.fromSQLite(maps.first);
    }
    return null;
  }

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String id) async {
    final db = await database;
    await db.update(
      _tableName,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    final db = await database;
    await db.update(
      _tableName,
      {'isRead': 1},
    );
  }

  /// Xóa thông báo
  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Đếm số thông báo chưa đọc
  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE isRead = 0',
    );
    return result.first['count'] as int;
  }

  /// Lấy thông báo theo loại
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromSQLite(maps[i]);
    });
  }

  /// Lấy thông báo chưa đọc
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'isRead = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromSQLite(maps[i]);
    });
  }

  /// Xóa thông báo cũ (giữ lại chỉ N thông báo mới nhất)
  Future<void> cleanOldNotifications({int keepCount = 100}) async {
    final db = await database;
    
    // Lấy ID của thông báo thứ keepCount
    final result = await db.rawQuery('''
      SELECT id FROM $_tableName 
      ORDER BY createdAt DESC 
      LIMIT 1 OFFSET ?
    ''', [keepCount]);
    
    if (result.isNotEmpty) {
      final oldestKeptId = result.first['id'];
      await db.rawDelete('''
        DELETE FROM $_tableName 
        WHERE createdAt < (
          SELECT createdAt FROM $_tableName WHERE id = ?
        )
      ''', [oldestKeptId]);
    }
  }

  /// Đóng database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
