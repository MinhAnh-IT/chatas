# Tích hợp Notifications vào Friends Feature

## 📋 Tổng quan

Hệ thống notifications đã được tích hợp hoàn toàn vào Friends feature với các chức năng:

- ✅ Thông báo lời mời kết bạn mới
- ✅ Thông báo lời mời được chấp nhận 
- ✅ Thông báo lời mời bị từ chối
- ✅ Thông báo tin nhắn mới (sẵn sàng)
- ✅ Hiển thị badge số lượng thông báo chưa đọc
- ✅ Local notifications trên thanh thông báo của thiết bị

## 🚀 Cách sử dụng

### 1. Khởi tạo trong main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Thiết lập background message handler cho FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize dependencies
  FriendsDependencyInjection.init();
  setupNotificationDependencies(); // ✅ Đã được thêm

  runApp(MyApp());
}
```

### 2. Sử dụng trong Friends UI

```dart
// Trong AppBar
AppBar(
  title: Text('ChatAs'),
  actions: [
    NotificationIcon(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationRouterHelper.buildNotificationsPage(context),
        ),
      ),
    ),
  ],
)

// Hoặc sử dụng widget tích hợp sẵn
FriendsWithNotificationsWidget(
  currentUserId: 'user123',
)
```

### 3. Gửi thông báo trong Friends Logic

**Trong FriendSearchCubit** (gửi lời mời):
```dart
// ✅ Đã được tích hợp
await friendNotificationService.sendFriendRequestNotification(
  fromUserName: fromUserName,
  fromUserId: currentUserId,
);
```

**Trong FriendRequestCubit** (chấp nhận/từ chối):
```dart
// ✅ Đã được tích hợp
await friendNotificationService.sendFriendAcceptedNotification(
  accepterName: accepterName,
  accepterId: accepterId,
);
```

### 4. Sử dụng Extension Methods

```dart
// Extension methods để dễ sử dụng
context.sendFriendRequestNotification(
  fromUserName: 'John Doe',
  fromUserId: 'user123',
);

context.sendFriendAcceptedNotification(
  accepterName: 'Jane Smith', 
  accepterId: 'user456',
);

context.navigateToNotifications();
```

## 📁 Cấu trúc Files đã được cập nhật

### Friends Feature:
```
features/friends/
├── services/
│   ├── friend_notification_service.dart          ✅ Service xử lý notifications
│   ├── notification_router_helper.dart           ✅ Helper routing từ notifications
│   └── friends_notifications_integration.dart    ✅ Widget demo & extensions
├── injection/
│   └── friends_injection.dart                    ✅ Đã thêm NotificationService
├── presentation/cubit/
│   ├── friend_search_cubit.dart                  ✅ Đã tích hợp notifications
│   └── friend_request_cubit.dart                 ✅ Đã tích hợp notifications
└── presentation/pages/
    ├── friend_search_page.dart                   ✅ Đã cập nhật method calls
    └── friend_requests_page.dart                 ✅ Đã cập nhật method calls
```

### Notifications Feature:
```
features/notifications/
├── data/
│   ├── datasources/
│   │   ├── notification_remote_datasource.dart      ✅ Firebase Messaging
│   │   ├── notification_local_datasource.dart       ✅ SQLite storage  
│   │   └── notification_local_notification_datasource.dart ✅ Local notifications
│   ├── models/
│   │   └── notification_model.dart                  ✅ Data models
│   └── repositories/
│       └── notification_repository_impl.dart       ✅ Repository implementation
├── domain/
│   ├── entities/
│   │   └── notification.dart                       ✅ Notification entity
│   ├── repositories/
│   │   └── notification_repository.dart            ✅ Repository interface
│   └── usecases/
│       ├── initialize_notifications.dart           ✅ Khởi tạo
│       ├── get_notifications.dart                  ✅ Lấy danh sách
│       ├── mark_notification_as_read.dart          ✅ Đánh dấu đã đọc
│       ├── get_unread_notifications_count.dart     ✅ Đếm chưa đọc
│       ├── send_friend_request_notification.dart   ✅ Thông báo lời mời KB
│       └── send_friend_accepted_notification.dart  ✅ Thông báo chấp nhận KB
└── presentation/
    ├── cubit/
    │   ├── notification_cubit.dart                 ✅ State management
    │   └── notification_state.dart                ✅ States definition
    ├── pages/
    │   └── notifications_page.dart                ✅ Trang danh sách thông báo
    └── widgets/
        ├── notification_item.dart                 ✅ Widget item thông báo
        └── notification_badge.dart                ✅ Badge số lượng chưa đọc
```

## 🔧 Configuration Files

### Android Manifest (đã cập nhật):
```xml
<!-- Permissions for notifications -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Firebase Cloud Messaging Service -->
<service android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService" />

<!-- Local notifications receiver -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
```

### Dependencies (đã thêm):
```yaml
dependencies:
  firebase_messaging: ^15.2.10
  flutter_local_notifications: ^17.2.2
  sqflite: ^2.3.0
```

## 🎯 Luồng hoạt động

1. **Gửi lời mời kết bạn**:
   - User A gửi lời mời → `FriendSearchCubit.sendFriendRequest()`
   - Cubit gọi `FriendNotificationService.sendFriendRequestNotification()`
   - Hiển thị local notification: "John đã gửi lời mời kết bạn cho bạn"

2. **Chấp nhận lời mời**:
   - User B chấp nhận → `FriendRequestCubit.acceptRequest()`
   - Cubit gọi `FriendNotificationService.sendFriendAcceptedNotification()`
   - Hiển thị local notification cho User A: "Jane đã chấp nhận lời mời kết bạn của bạn"

3. **Xem thông báo**:
   - User tap vào notification icon (có badge số lượng)
   - Mở `NotificationsPage` với danh sách thông báo
   - Tap vào item → navigate tới trang tương ứng

## 🚨 Lưu ý

1. **File service account**: Đã được di chuyển ra khỏi `lib/` để đảm bảo bảo mật
2. **Background handler**: Đã thiết lập cho FCM background messages
3. **Local database**: Sử dụng SQLite để lưu trữ lịch sử thông báo
4. **Clean Architecture**: Tuân thủ cấu trúc Clean Architecture như các feature khác

## 🔄 Các bước tiếp theo

1. **Tích hợp routing**: Thêm notification routes vào `app_router.dart`
2. **Backend integration**: Sử dụng service account key để gửi FCM từ server
3. **Real-time sync**: Tích hợp với Firestore để sync notifications real-time
4. **User preferences**: Thêm settings để user quản lý loại thông báo muốn nhận
