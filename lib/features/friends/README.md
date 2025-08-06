# Friends Feature - Clean Architecture Implementation

This is a comprehensive friends management feature built with Clean Architecture principles for Flutter with Firebase Firestore backend.

## 📁 Project Structure

```
lib/features/friends/
├── constants/
│   └── FriendRemoteConstants.dart      # Firebase collection constants
├── data/
│   ├── datasources/
│   │   └── friend_remote_datasource.dart # Firebase Firestore data source
│   ├── models/
│   │   ├── friendModel.dart             # Friend data model
│   │   └── friendRequestModel.dart      # Friend request data model
│   └── repositories/
│       └── friend_repository_impl.dart  # Repository implementation
├── domain/
│   ├── entities/
│   │   ├── friend.dart                  # Friend business entity
│   │   └── friendRequest.dart           # Friend request business entity
│   ├── repositories/
│   │   └── friend_repository.dart       # Repository interface
│   └── usecases/
│       ├── accept_friend_request_usecase_new.dart
│       ├── cancel_friend_request_usecase.dart
│       ├── get_friends_usecase.dart
│       ├── get_friendship_status_usecase.dart
│       ├── get_received_friend_requests_usecase.dart
│       ├── get_sent_friend_requests_usecase.dart
│       ├── reject_friend_request_usecase.dart
│       ├── remove_friend_usecase_new.dart
│       ├── send_friend_request_usecase.dart
│       ├── update_friend_online_status_usecase.dart
│       └── update_last_message_usecase.dart
├── presentation/
│   ├── cubit/
│   │   ├── friends_cubit.dart           # Friends list state management
│   │   └── friend_requests_cubit.dart   # Friend requests state management
│   ├── pages/
│   │   ├── friends_page.dart            # Main friends list page
│   │   └── friend_requests_page.dart    # Friend requests management page
│   └── widgets/
│       ├── friend_item.dart             # Individual friend list item
│       ├── friend_request_item.dart     # Individual friend request item
│       ├── empty_friends.dart           # Empty state for friends list
│       └── empty_friend_requests.dart   # Empty state for friend requests
├── examples/
│   └── friends_app_example.dart         # Usage example
├── friends_injection.dart               # Dependency injection setup
└── README.md                           # This file
```

## 🚀 Features

### ✅ Implemented Features

1. **Friends Management**

   - View friends list with online status
   - Remove friends with confirmation dialog
   - Real-time online status updates
   - Last active time display
   - Last message information

2. **Friend Requests**

   - Send friend requests
   - Accept/reject incoming requests
   - Cancel sent requests
   - View received and sent requests separately
   - Real-time request updates

3. **Enhanced Data Model**

   - Rich friend information (online status, last active, messages)
   - Sender details in friend requests
   - Timestamps for all operations

4. **State Management**
   - BLoC/Cubit pattern implementation
   - Loading states and error handling
   - Success message feedback
   - Reactive UI updates

## 📦 Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  cloud_firestore: ^4.13.6
  firebase_core: ^2.24.2

dev_dependencies:
  flutter_test:
    sdk: flutter
```

## 🔧 Setup

### 1. Firebase Configuration

Ensure you have Firebase configured in your project with Firestore enabled.

### 2. Data Structure

The feature expects these Firestore collections:

#### Friends Collection: `friends`

```json
{
  "friendId": "unique_friend_id",
  "userId": "user1_id",
  "friendUserId": "user2_id",
  "status": "accepted",
  "isOnline": true,
  "lastActive": "2024-01-15T10:30:00Z",
  "lastMessageId": "message_id",
  "lastMessageAt": "2024-01-15T12:00:00Z"
}
```

#### Friend Requests Collection: `friend_requests`

```json
{
  "id": "request_id",
  "senderId": "sender_user_id",
  "receiverId": "receiver_user_id",
  "status": "pending",
  "createdAt": "2024-01-15T09:00:00Z",
  "updatedAt": "2024-01-15T09:00:00Z",
  "senderName": "John Doe",
  "senderPhotoURL": "https://example.com/photo.jpg"
}
```

## 📱 Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/friends/friends_injection.dart';
import 'features/friends/presentation/pages/friends_page.dart';
import 'features/friends/presentation/cubit/friends_cubit.dart';
import 'features/friends/presentation/cubit/friend_requests_cubit.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FriendsCubit>(
            create: (_) => FriendsDependencyInjection.createFriendsCubit(),
          ),
          BlocProvider<FriendRequestsCubit>(
            create: (_) => FriendsDependencyInjection.createFriendRequestsCubit(),
          ),
        ],
        child: FriendsPage(userId: 'current_user_id'),
      ),
    );
  }
}
```

### Advanced Usage with Navigation

```dart
// In your main app routing
routes: {
  '/friends': (context) => MultiBlocProvider(
    providers: [
      BlocProvider<FriendsCubit>(
        create: (_) => FriendsDependencyInjection.createFriendsCubit(),
      ),
      BlocProvider<FriendRequestsCubit>(
        create: (_) => FriendsDependencyInjection.createFriendRequestsCubit(),
      ),
    ],
    child: FriendsPage(userId: getCurrentUserId()),
  ),
}

// Navigate to friends page
Navigator.pushNamed(context, '/friends');
```

## 🏗️ Architecture

### Clean Architecture Layers

1. **Presentation Layer** (`presentation/`)

   - UI components (Pages, Widgets)
   - State management (Cubits)
   - User interaction handling

2. **Domain Layer** (`domain/`)

   - Business entities
   - Use cases (business logic)
   - Repository interfaces

3. **Data Layer** (`data/`)
   - Data sources (Firebase)
   - Data models
   - Repository implementations

### Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↓       ↑
  UI Pages → Use Cases → Repository → DataSource → Firebase
```

## 🔄 State Management

The feature uses BLoC pattern with Cubit for state management:

### FriendsCubit States

- `isLoading`: Loading indicator
- `friends`: List of friends
- `error`: Error message
- `successMessage`: Success feedback

### FriendRequestsCubit States

- `isLoading`: Loading indicator
- `receivedRequests`: Incoming friend requests
- `sentRequests`: Outgoing friend requests
- `error`: Error message
- `successMessage`: Success feedback

## 🎨 UI Components

### FriendsPage

- Main friends list view
- Refresh capability
- Navigation to friend requests
- Friend removal with confirmation

### FriendRequestsPage

- Tabbed interface (Received/Sent)
- Accept/reject incoming requests
- Cancel sent requests

### Custom Widgets

- `FriendItem`: Individual friend display
- `FriendRequestItem`: Request display with actions
- `EmptyFriends`: Empty state UI
- `EmptyFriendRequests`: Empty requests UI

## 🔧 Customization

### Styling

Customize the UI by modifying the widget files in `presentation/widgets/`.

### Business Logic

Add new use cases in `domain/usecases/` and update the repository interface.

### Data Source

Extend `FriendRemoteDataSource` to add new Firebase operations.

## 🚧 Future Enhancements

- [ ] Search functionality for finding new friends
- [ ] Friend suggestions based on mutual connections
- [ ] Group friend management
- [ ] Integration with chat feature
- [ ] Push notifications for friend requests
- [ ] Offline support with local caching

## 🐛 Troubleshooting

### Common Issues

1. **Firebase not initialized**

   ```dart
   // Ensure Firebase is initialized in main()
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

2. **Missing dependencies**

   ```bash
   flutter pub get
   ```

3. **Firestore rules**
   ```javascript
   // Ensure your Firestore rules allow read/write access
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

## 📄 License

This friends feature implementation follows Clean Architecture principles and is part of a larger Flutter chat application project.
