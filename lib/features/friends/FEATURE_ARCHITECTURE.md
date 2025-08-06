# Kiến trúc chức năng Bạn bè (Friends Feature)

## 📋 Tổng quan

Chức năng bạn bè được xây dựng theo kiến trúc Clean Architecture với 3 lớp chính: Domain, Data, và Presentation. Chức năng này cho phép người dùng quản lý danh sách bạn bè, gửi/nhận lời mời kết bạn, và theo dõi trạng thái online.

## 🏗️ Cấu trúc thư mục và chức năng

### 📁 `domain/` - Lớp Business Logic (Miền nghiệp vụ)

Chứa các quy tắc nghiệp vụ và logic cốt lõi của ứng dụng, độc lập với framework và UI.

#### 📄 `entities/`

**`friend.dart`**

- **Chức năng**: Định nghĩa entity Friend đại diện cho một mối quan hệ bạn bè
- **Thuộc tính chính**:
  - `friendId`: ID duy nhất của mối quan hệ
  - `userId`: ID người dùng chủ sở hữu
  - `friendUserId`: ID của bạn bè
  - `status`: Trạng thái kết bạn ("accepted", "pending")
  - `isOnline`: Trạng thái online
  - `lastActive`: Thời gian hoạt động cuối
  - `lastMessageId`, `lastMessageAt`: Thông tin tin nhắn cuối
- **Liên kết**: Được sử dụng bởi tất cả các use case và repository

**`friendRequest.dart`**

- **Chức năng**: Định nghĩa entity FriendRequest đại diện cho lời mời kết bạn
- **Thuộc tính chính**:
  - `id`: ID duy nhất của lời mời
  - `senderId`: ID người gửi lời mời
  - `receiverId`: ID người nhận lời mời
  - `status`: Trạng thái ("pending", "accepted", "rejected")
  - `senderName`, `senderPhotoURL`: Thông tin người gửi
  - `createdAt`, `updatedAt`: Timestamps
- **Liên kết**: Được sử dụng trong friend request use cases

#### 📄 `repositories/`

**`friend_repository.dart`**

- **Chức năng**: Interface (contract) định nghĩa các phương thức cần thiết cho việc quản lý bạn bè
- **Phương thức chính**:
  - `getFriends()`: Lấy danh sách bạn bè
  - `addFriend()`: Thêm bạn mới
  - `removeFriend()`: Xóa bạn
  - `sendFriendRequest()`: Gửi lời mời kết bạn
  - `acceptFriendRequest()`, `rejectFriendRequest()`: Xử lý lời mời
  - `updateOnlineStatus()`: Cập nhật trạng thái online
- **Liên kết**: Được implement bởi `FriendRepositoryImpl` trong data layer

#### 📄 `usecases/` - Các ca sử dụng

Mỗi use case đại diện cho một hành động cụ thể mà người dùng có thể thực hiện:

**`get_friends_usecase.dart`**

- **Chức năng**: Lấy danh sách tất cả bạn bè của người dùng
- **Input**: userId (String)
- **Output**: List<Friend>
- **Liên kết**: Sử dụng FriendRepository.getFriends()

**`send_friend_request_usecase.dart`**

- **Chức năng**: Gửi lời mời kết bạn đến người dùng khác
- **Input**: FriendRequest object
- **Output**: void
- **Liên kết**: Sử dụng FriendRepository.sendFriendRequest()

**`accept_friend_request_usecase.dart`**

- **Chức năng**: Chấp nhận lời mời kết bạn
- **Input**: requestId (String)
- **Output**: void
- **Logic**: Cập nhật status thành "accepted" và tạo mối quan hệ bạn bè hai chiều

**`reject_friend_request_usecase.dart`**

- **Chức năng**: Từ chối lời mời kết bạn
- **Input**: requestId (String)
- **Output**: void

**`remove_friend_usecase.dart` & `remove_friend_usecase_new.dart`**

- **Chức năng**: Xóa bạn khỏi danh sách
- **Input**: userId, friendUserId
- **Output**: void
- **Logic**: Xóa mối quan hệ bạn bè từ cả hai phía

**`cancel_friend_request_usecase.dart`**

- **Chức năng**: Hủy lời mời kết bạn đã gửi
- **Input**: requestId (String)
- **Output**: void

**`get_received_friend_requests_usecase.dart`**

- **Chức năng**: Lấy danh sách lời mời kết bạn nhận được
- **Input**: userId (String)
- **Output**: List<FriendRequest>

**`get_sent_friend_requests_usecase.dart`**

- **Chức năng**: Lấy danh sách lời mời kết bạn đã gửi
- **Input**: userId (String)
- **Output**: List<FriendRequest>

**`get_friendship_status_usecase.dart`**

- **Chức năng**: Kiểm tra trạng thái kết bạn giữa hai người dùng
- **Input**: userId, otherUserId
- **Output**: String (status)

**`update_friend_online_status_usecase.dart`**

- **Chức năng**: Cập nhật trạng thái online của bạn bè
- **Input**: userId, isOnline
- **Output**: void

**`update_last_message_usecase.dart`**

- **Chức năng**: Cập nhật thông tin tin nhắn cuối cùng
- **Input**: friendId, messageId, messageTime
- **Output**: void

### 📁 `data/` - Lớp Data (Dữ liệu)

Chứa implementation cụ thể để truy cập và xử lý dữ liệu từ các nguồn khác nhau.

#### 📄 `models/`

**`friendModel.dart`**

- **Chức năng**: Data Transfer Object cho Friend entity
- **Phương thức chính**:
  - `fromJson()`: Chuyển đổi từ JSON (Firestore) sang model
  - `toJson()`: Chuyển đổi từ model sang JSON
  - `toEntity()`: Chuyển đổi sang domain entity
  - `fromEntity()`: Chuyển đổi từ domain entity
- **Liên kết**: Cầu nối giữa Firestore data và domain entities

**`friendRequestModel.dart`**

- **Chức năng**: Data Transfer Object cho FriendRequest entity
- **Phương thức tương tự**: fromJson, toJson, toEntity, fromEntity
- **Xử lý đặc biệt**: Timestamp conversion giữa Firestore và DateTime

#### 📄 `datasources/`

**`friend_remote_datasource.dart`**

- **Chức năng**: Tương tác trực tiếp với Firebase Firestore
- **Phương thức chính**:
  - `getFriends()`: Query Firestore để lấy friends
  - `addFriend()`: Thêm document vào friends collection
  - `removeFriend()`: Xóa document từ friends collection
  - `sendFriendRequest()`: Thêm vào friend_requests collection
  - `acceptFriendRequest()`: Batch operation: update request + create friends
  - `rejectFriendRequest()`: Update request status
  - `updateOnlineStatus()`: Update friend online status
- **Firebase Collections sử dụng**:
  - `friends`: Lưu trữ mối quan hệ bạn bè
  - `friend_requests`: Lưu trữ lời mời kết bạn
- **Liên kết**: Được sử dụng bởi FriendRepositoryImpl

#### 📄 `repositories/`

**`friend_repository_impl.dart`**

- **Chức năng**: Implementation của FriendRepository interface
- **Vai trò**: Adapter pattern - chuyển đổi giữa domain layer và data layer
- **Logic**:
  - Nhận calls từ use cases
  - Delegate sang remote data source
  - Chuyển đổi models thành entities
- **Error handling**: Catch và re-throw exceptions với proper error messages

### 📁 `presentation/` - Lớp UI (Giao diện)

Chứa tất cả components liên quan đến giao diện người dùng và state management.

#### 📄 `cubit/` - State Management

**`friends_cubit.dart`**

- **Chức năng**: Quản lý state cho danh sách bạn bè
- **State properties**:
  - `isLoading`: Trạng thái loading
  - `friends`: Danh sách bạn bè hiện tại
  - `error`: Thông báo lỗi
  - `successMessage`: Thông báo thành công
- **Methods**:
  - `loadFriends()`: Tải danh sách bạn bè
  - `removeFriend()`: Xóa bạn với UI feedback
  - `updateOnlineStatus()`: Cập nhật trạng thái online
  - `clearMessages()`: Xóa thông báo
- **Liên kết**: Sử dụng GetFriendsUseCase, RemoveFriendUseCase, UpdateFriendOnlineStatusUseCase

**`friend_requests_cubit.dart`**

- **Chức năng**: Quản lý state cho lời mời kết bạn
- **State properties**:
  - `isLoading`: Trạng thái loading
  - `receivedRequests`: Lời mời nhận được
  - `sentRequests`: Lời mời đã gửi
  - `error`, `successMessage`: Thông báo
- **Methods**:
  - `loadReceivedRequests()`, `loadSentRequests()`: Tải danh sách requests
  - `sendFriendRequest()`: Gửi lời mời mới
  - `acceptFriendRequest()`: Chấp nhận lời mời
  - `rejectFriendRequest()`: Từ chối lời mời
  - `cancelFriendRequest()`: Hủy lời mời đã gửi
- **Liên kết**: Sử dụng multiple friend request use cases

#### 📄 `pages/` - Màn hình chính

**`friends_page.dart`**

- **Chức năng**: Màn hình chính hiển thị danh sách bạn bè
- **UI Components**:
  - AppBar với search và friend requests navigation
  - RefreshIndicator cho pull-to-refresh
  - ListView hiển thị danh sách bạn bè
  - FloatingActionButton để add friends
- **State Management**: Sử dụng BlocConsumer<FriendsCubit>
- **User Interactions**:
  - Xem danh sách bạn bè
  - Xóa bạn (với confirmation dialog)
  - Navigate đến friend requests
  - Refresh danh sách
- **Liên kết**: Sử dụng FriendItem widget, EmptyFriends widget

**`friend_requests_page.dart`**

- **Chức năng**: Màn hình quản lý lời mời kết bạn
- **UI Structure**: TabBar với 2 tabs (Received/Sent)
- **Features**:
  - Hiển thị lời mời nhận được và đã gửi
  - Accept/reject received requests
  - Cancel sent requests
  - Pull-to-refresh cho cả hai tabs
- **State Management**: BlocConsumer<FriendRequestsCubit>
- **Liên kết**: Sử dụng FriendRequestItem, EmptyFriendRequests widgets

#### 📄 `widgets/` - UI Components tái sử dụng

**`friend_item.dart`**

- **Chức năng**: Widget hiển thị một item trong danh sách bạn bè
- **UI Elements**:
  - CircleAvatar với online status indicator
  - Tên và thông tin trạng thái
  - Last message time
  - PopupMenuButton với actions (Chat, Remove)
- **Props**: Friend object, onRemove callback, onChat callback
- **Liên kết**: Được sử dụng trong FriendsPage

**`friend_request_item.dart`**

- **Chức năng**: Widget hiển thị một lời mời kết bạn
- **UI Elements**:
  - Avatar với sender photo
  - Sender name và request info
  - Action buttons (Accept/Reject hoặc Cancel)
- **Props**: FriendRequest object, action callbacks
- **Logic**: Conditional UI dựa trên isReceived parameter

**`empty_friends.dart`**

- **Chức năng**: Empty state khi chưa có bạn bè
- **UI**: Icon, text, và action button
- **User Guidance**: Hướng dẫn user tìm kiếm bạn bè

**`empty_friend_requests.dart`**

- **Chức năng**: Empty state cho friend requests
- **Customizable**: Nhận message parameter để hiển thị different messages

### 📁 `constants/`

**`FriendRemoteConstants.dart`**

- **Chức năng**: Định nghĩa constants cho Firebase collections và fields
- **Collections**:
  - `friendCollection = "friends"`
  - `friendRequestCollection = "friend_requests"`
- **Lợi ích**: Centralized constants, dễ maintain và change

### 📁 `injection/` - Dependency Injection

**`friends_injection.dart`**

- **Chức năng**: Quản lý dependencies và initialization
- **Pattern**: Service Locator pattern
- **Components được inject**:
  - Data sources (FriendRemoteDataSource)
  - Repositories (FriendRepositoryImpl)
  - Use cases (tất cả friend use cases)
- **Factory methods**: Tạo Cubit instances với proper dependencies
- **Liên kết**: Được sử dụng trong app initialization và widget creation

### 📁 `examples/`

**`friends_app_example.dart`**

- **Chức năng**: Demo cách sử dụng friends feature
- **Patterns**: MultiBlocProvider setup
- **Usage examples**: Navigation, integration patterns

## 🔄 Luồng dữ liệu (Data Flow)

### 1. Khởi tạo và Dependencies

```
main.dart → FriendsDependencyInjection.init()
  ↓
FriendRemoteDataSource ← FirebaseFirestore
  ↓
FriendRepositoryImpl ← FriendRemoteDataSource
  ↓
Use Cases ← FriendRepositoryImpl
  ↓
Cubits ← Use Cases
```

### 2. User Actions Flow

```
User Interaction → Widget → Cubit → Use Case → Repository → DataSource → Firebase
                    ↑                                                        ↓
                 UI Update ← State Change ← Result ← Model ← Response ← Firestore
```

### 3. Ví dụ: Xóa bạn

```
1. FriendsPage: User taps "Remove Friend"
2. friends_page.dart: Shows confirmation dialog
3. friends_page.dart: Calls context.read<FriendsCubit>().removeFriend()
4. friends_cubit.dart: Calls removeFriendUseCase(userId, friendUserId)
5. remove_friend_usecase.dart: Calls repository.removeFriend()
6. friend_repository_impl.dart: Calls remoteDataSource.removeFriend()
7. friend_remote_datasource.dart: Executes Firestore batch delete
8. Result bubbles back up with success/error
9. friends_cubit.dart: Updates state with new friends list
10. friends_page.dart: Rebuilds UI with updated data
```

## 🎯 Ưu điểm của kiến trúc này

### 1. **Separation of Concerns**

- Mỗi layer có trách nhiệm riêng biệt
- Business logic tách biệt khỏi UI và data access

### 2. **Testability**

- Mỗi component có thể test độc lập
- Mock dependencies dễ dàng

### 3. **Maintainability**

- Thay đổi UI không ảnh hưởng business logic
- Thay đổi data source không ảnh hưởng domain layer

### 4. **Scalability**

- Dễ dàng thêm features mới
- Reusable components và use cases

### 5. **SOLID Principles**

- Single Responsibility: Mỗi class có một trách nhiệm
- Open/Closed: Mở cho extension, đóng cho modification
- Dependency Inversion: Depend on abstractions, not concretions

## 🚀 Cách mở rộng

### Thêm tính năng mới:

1. **Domain**: Tạo use case mới
2. **Data**: Thêm method vào repository và data source
3. **Presentation**: Tạo cubit method và UI mới

### Thêm data source mới:

1. Implement FriendRepository interface
2. Update dependency injection
3. Business logic giữ nguyên

Kiến trúc này đảm bảo code clean, maintainable và scalable cho việc phát triển long-term.
