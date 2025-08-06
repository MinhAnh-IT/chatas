# 📌 Nguyên tắc bắt buộc phải tuân thủ – Dự án Flutter "Chatas"

## 🏗️ KIẾN TRÚC DỰ ÁN
- Dự án sử dụng kiến trúc **Clean Architecture** kết hợp **Feature-First**.
- Mã nguồn chính nằm trong thư mục `lib/`.
- Mỗi tính năng nằm trong `lib/features/<tên_tính_năng>/`, gồm 3 phần:
  - `data/`: chứa DTO, nguồn dữ liệu, triển khai repository.
  - `domain/`: chứa entity, use case, interface.
  - `presentation/`: chứa UI, widget, controller, logic hiển thị.

## 📦 ĐỊNH TUYẾN (ROUTING)
- Sử dụng thư viện `GoRouter`, cấu hình tại `lib/core/routing/app_router.dart`.
- Các đường dẫn và tên route được khai báo trong `lib/core/constants/app_route_constants.dart`.
- Luôn sử dụng `context.goNamed()` để điều hướng. ❌ Không dùng đường dẫn thủ công.

### Ví dụ:
```dart
context.goNamed(AppRouteConstants.chatDetailPathName, pathParameters: {'id': chatId});
```

---

## 🧱 QUY ƯỚC THƯ MỤC

### ✅ Trong `features/<feature_name>/`
| Layer         | Trách nhiệm                            |
|---------------|----------------------------------------|
| `data/`       | Logic tầng thấp: gọi API, lưu trữ       |
| `domain/`     | Logic nghiệp vụ: entity, use case      |
| `presentation/` | UI, widget, controller, navigation  |

### ✅ Trong `core/`
| Thư mục       | Mục đích                               |
|---------------|----------------------------------------|
| `constants/`  | Các hằng số toàn app (route, asset...) |
| `routing/`    | Khai báo router GoRouter               |
| `config/`     | Cấu hình Firebase, provider toàn cục   |

---

## ✅ NGUYÊN TẮC LẬP TRÌNH

### 🧱 SOLID
- **S**: Mỗi class chỉ có một trách nhiệm duy nhất.
- **O**: Mở rộng được mà không sửa đổi code cũ.
- **L**: Class con thay thế được class cha mà không thay đổi logic.
- **I**: Interface nhỏ gọn, dễ triển khai.
- **D**: Phụ thuộc vào abstraction, không phụ thuộc implementation.

### 🧹 CLEAN CODE
- Dùng `const` khi có thể.
- Không viết logic trong hàm `build()`.
- Tách biệt rõ UI ↔ Logic ↔ Data.
- Không để các lớp import chéo không cần thiết.
- Ưu tiên test được, mở rộng được, dễ đọc.

---

## 📚 TÀI LIỆU VÀ COMMENT
- Tất cả method (public và private) phải có comment bằng tiếng Anh theo chuẩn DartDoc.
```dart
/// Fetches the list of chat threads from Firestore.
Future<List<ChatThread>> fetchChatThreads();
```
- Đối với Cubit:
```dart
/// Loads all chat threads and emits corresponding states.
Future<void> loadChatThreads() async { ... }
```

---

## 🔒 BẢO MẬT VÀ AN TOÀN
- Toàn bộ collection name của Firestore phải đặt trong file `*_remote_constants.dart`.
- Không hard-code bất kỳ chuỗi quan trọng hoặc nhạy cảm nào.
- Sử dụng environment config cho API key và secret.

---

## 🧪 VIẾT TEST
- Mọi phần code được tạo mới hoặc thay đổi đều **phải có test**.
- Loại test:
  - Unit Test cho use case, repository.
  - Widget Test cho page, component có logic.
- Mỗi sửa đổi phải đi kèm test tương ứng để đảm bảo độ tin cậy.

---

## 🚫 CẤM HARD-CODE
- Không được hardcode text hoặc số trong code.
- Toàn bộ string, double, int... phải khai báo trong `constants/` riêng từng feature.
```dart
Text(ChatThreadListPageConstants.noChats);
```
❌ Không được viết: `Text("Không có đoạn chat nào")`

---

## ✅ SỬ DỤNG BLOC / CUBIT
- Phải sử dụng `flutter_bloc` để quản lý trạng thái.
- Mỗi feature sẽ có Cubit hoặc Bloc riêng.
- Tổ chức file:
```
presentation/
├── pages/
├── cubit/         ✅ chứa các Cubit/Bloc + State
├── widgets/
```

---

## 📦 QUẢN LÝ FEATURE RIÊNG BIỆT
- Mỗi tính năng chỉ được phép sửa trong folder `features/<feature_name>` của nó.
- ❌ Không được chỉnh sửa file của feature khác (tránh xung đột và lỗi logic).

---

## 🤖 HƯỚNG DẪN DÀNH CHO COPILOT
- ❌ Không được viết code trong `main.dart`.
- ❌ Không hard-code route, string, collection name.
- ✅ Mọi phần code phải thuộc đúng feature và đúng layer.
- ✅ Luôn comment rõ ràng bằng tiếng Anh.
- ✅ Ưu tiên viết các method nhỏ, dễ test, dễ đọc.

---

## 🧠 GỢI Ý BỔ SUNG
- Widget nên là `const` nếu không thay đổi.
- Tách UI phức tạp thành các widget con.
- Tách logic riêng thành method phụ để dễ test.

---

## ✅ TỔNG KẾT

| Quy tắc                 | Mô tả |
|--------------------------|-------|
| ⛔ Không hardcode         | Text/số phải nằm trong file constants |
| ✅ Dùng Cubit/BLoC        | Mỗi feature có Cubit riêng |
| 📝 Bắt buộc comment       | Mọi method phải có DartDoc tiếng Anh |
| 🧪 Viết test mọi thay đổi | Có test cho mọi logic được sửa |
| 🧩 Không sửa feature khác | Không can thiệp vào code ngoài feature |
| 📁 Tổ chức chuẩn mực      | Feature → Layer → File rõ ràng |