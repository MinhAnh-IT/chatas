# Hướng dẫn Cài đặt Firebase Credentials

## Tổng quan

Dự án này sử dụng Firebase Admin SDK cho push notifications. Vì lý do bảo mật, các thông tin xác thực service account không được bao gồm trong repository.

## Hướng dẫn Cài đặt

### 1. Lấy Firebase Service Account Credentials

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn (`chatas-9469d`)
3. Vào **Project Settings** > **Service Accounts **
4. Nhấp **Generate new private key**
5. Tải file JSON về

### 2. Thêm Credentials vào Project Local

#### Phương pháp 1: Thư mục Assets (Khuyến nghị cho Development)

1. Tạo thư mục `assets` ở thư mục gốc project nếu chưa có
2. Copy file JSON đã tải về `assets/firebase_credentials.json`
3. Thêm vào `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/firebase_credentials.json
```

#### Phương pháp 2: Environment Variables (Khuyến nghị cho Production)

Thiết lập các environment variables sau:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`
- v.v.

### 3. Cấu trúc File

```
project_root/
├── assets/
│   └── firebase_credentials.json  # ← Thêm file này (đã gitignore)
├── lib/
└── pubspec.yaml
```

### 4. Ghi chú Bảo mật

- ✅ File credentials được tự động gitignore
- ✅ Không bao giờ commit credentials vào version control
- ✅ Sử dụng environment variables trong production
- ✅ Thay đổi keys định kỳ

### 5. Kiểm tra

Chạy app và kiểm tra console logs:

- ✅ `Firebase credentials loaded successfully`
- ❌ `Error loading Firebase credentials`

## Khắc phục Sự cố

### Không nhận được Notifications

1. Kiểm tra credentials đã được load đúng chưa
2. Xác minh FCM tokens đã được lưu vào Firestore
3. Kiểm tra quyền thông báo
4. Kiểm tra Firebase Console logs

### Lỗi: "Service account credentials chưa được khởi tạo"

- Đảm bảo `firebase_credentials.json` có trong thư mục `assets/`
- Kiểm tra `pubspec.yaml` đã include đường dẫn assets
- Chạy `flutter clean && flutter pub get`
