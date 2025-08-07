# RefreshableListView Widget

## 📋 Tổng quan
`RefreshableListView` là một widget có thể tái sử dụng cung cấp chức năng pull-to-refresh cho bất kỳ danh sách nào trong ứng dụng. Widget này tuân thủ nguyên tắc Clean Architecture và có thể được sử dụng trên nhiều feature khác nhau.

## ✨ Tính năng
- ✅ Pull-to-refresh functionality
- ✅ Loading state management
- ✅ Error state với retry functionality
- ✅ Empty state customizable
- ✅ Custom scroll controller support
- ✅ Generic type support (`<T>`)
- ✅ Fully customizable UI components
- ✅ Consistent với design system

## 🏗️ Cấu trúc file
```
lib/shared/
├── constants/
│   └── refreshable_list_view_constants.dart  # Constants cho widget
└── widgets/
    ├── refreshable_list_view.dart            # Main widget
    └── refreshable_list_view_examples.dart   # Examples và usage
```

## 🚀 Cách sử dụng cơ bản

### 1. Import widget
```dart
import 'package:chatas/shared/widgets/refreshable_list_view.dart';
```

### 2. Sử dụng trong widget
```dart
RefreshableListView<String>(
  items: myStringList,
  onRefresh: _handleRefresh,
  itemBuilder: (context, item, index) => ListTile(
    title: Text(item),
  ),
)
```

## 📖 API Documentation

### Required Parameters
| Parameter | Type | Mô tả |
|-----------|------|-------|
| `items` | `List<T>` | Danh sách items để hiển thị |
| `onRefresh` | `Future<void> Function()` | Callback khi user pull-to-refresh |
| `itemBuilder` | `Widget Function(BuildContext, T, int)` | Builder cho từng item |

### Optional Parameters
| Parameter | Type | Default | Mô tả |
|-----------|------|---------|-------|
| `isLoading` | `bool` | `false` | Trạng thái loading |
| `errorMessage` | `String?` | `null` | Error message để hiển thị |
| `onRetry` | `VoidCallback?` | `null` | Callback cho retry button |
| `scrollController` | `ScrollController?` | `null` | Custom scroll controller |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(16)` | Padding cho list |
| `emptyWidget` | `Widget?` | `null` | Custom empty state widget |
| `errorWidgetBuilder` | `Widget Function(String)?` | `null` | Custom error widget builder |
| `loadingWidget` | `Widget?` | `null` | Custom loading widget |
| `refreshedMessage` | `String?` | `null` | Custom refresh success message |
| `showRefreshMessage` | `bool` | `true` | Có hiện refresh message hay không |

## 🎨 Customization Examples

### 1. Basic List
```dart
RefreshableListView<String>(
  items: ['Item 1', 'Item 2', 'Item 3'],
  onRefresh: () async {
    // Refresh logic
  },
  itemBuilder: (context, item, index) => ListTile(
    title: Text(item),
  ),
)
```

### 2. With Error Handling
```dart
RefreshableListView<User>(
  items: users,
  onRefresh: _refreshUsers,
  isLoading: isLoading,
  errorMessage: errorMessage,
  onRetry: _retryLoadUsers,
  itemBuilder: (context, user, index) => UserTile(user: user),
)
```

### 3. Custom Empty State
```dart
RefreshableListView<ChatMessage>(
  items: messages,
  onRefresh: _refreshMessages,
  emptyWidget: CustomEmptyWidget(),
  itemBuilder: (context, message, index) => MessageBubble(message: message),
)
```

### 4. With Scroll Controller
```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableListView<Item>(
      items: items,
      onRefresh: _refreshItems,
      scrollController: _scrollController,
      itemBuilder: (context, item, index) => ItemWidget(item: item),
    );
  }
}
```

## 🧪 Testing
Widget đã được test đầy đủ với coverage:
- ✅ Loading state display
- ✅ Error state display
- ✅ Empty state display  
- ✅ Custom widgets rendering
- ✅ Pull-to-refresh functionality
- ✅ Retry button functionality
- ✅ Scroll controller integration
- ✅ Custom padding application

Chạy test:
```bash
flutter test test/shared/widgets/refreshable_list_view_test.dart
```

## 🔧 Constants
Tất cả hardcoded values được khai báo trong `RefreshableListViewConstants`:

```dart
class RefreshableListViewConstants {
  static const String defaultRefreshTooltip = 'Kéo xuống để làm mới';
  static const String defaultRefreshedMessage = 'Đã làm mới';
  static const String defaultEmptyMessage = 'Không có dữ liệu';
  // ... more constants
}
```

## 🎯 Use Cases
Widget này có thể được sử dụng cho:
- ✅ Chat message lists
- ✅ Chat thread lists  
- ✅ User lists
- ✅ News feeds
- ✅ Product catalogs
- ✅ Notification lists
- ✅ Bất kỳ danh sách nào cần refresh functionality

## 🔄 Integration với BLoC/Cubit
```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    return RefreshableListView<MyItem>(
      items: state.items,
      isLoading: state is MyLoadingState,
      errorMessage: state is MyErrorState ? state.message : null,
      onRefresh: () => context.read<MyCubit>().refresh(),
      onRetry: () => context.read<MyCubit>().retry(),
      itemBuilder: (context, item, index) => MyItemWidget(item: item),
    );
  },
)
```

## 📝 Best Practices
1. **Always dispose scroll controllers** khi không sử dụng
2. **Use generic types** để type safety
3. **Handle errors gracefully** với custom error widgets
4. **Implement proper refresh logic** trong onRefresh callback
5. **Test thoroughly** với đầy đủ test cases
6. **Follow constants pattern** - không hardcode strings
7. **Keep itemBuilder simple** - tách complex widgets ra riêng

## 🚫 What NOT to do
- ❌ Hardcode strings trong widget
- ❌ Quên dispose scroll controller
- ❌ Implement complex logic trong itemBuilder
- ❌ Ignore error states
- ❌ Skip testing

## 🔮 Future Enhancements
- [ ] Infinite scroll support
- [ ] Animated item insertion/removal
- [ ] Pull-to-refresh customization
- [ ] Performance optimizations
- [ ] Accessibility improvements
