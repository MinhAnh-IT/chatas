# GitHub Actions Workflows

Thư mục này chứa các GitHub Actions workflows cho dự án Chatas.

## 📁 Cấu trúc Workflows

### 🔄 CI (Continuous Integration) - `ci.yml`
**Trigger:** Push và Pull Request tới các nhánh chính

**Jobs:**
- **test**: Chạy tests, kiểm tra formatting và analyze code
- **build-android**: Build APK cho Android
- **build-ios**: Build cho iOS (chỉ trên macOS)
- **build-web**: Build web app
- **security-scan**: Scan lỗ hổng bảo mật (chỉ trên main branch)

### 🚀 CD (Continuous Deployment) - `cd.yml`
**Trigger:** Push tags version (v*.*.*)

**Jobs:**
- **deploy-android-staging**: Deploy APK lên Firebase App Distribution
- **deploy-web**: Deploy web app lên Firebase Hosting
- **create-release**: Tạo GitHub Release với artifacts

### 🔍 PR Check - `pr-check.yml`
**Trigger:** Pull Request

**Jobs:**
- **pr-check**: Kiểm tra code quality cho files đã thay đổi
- **dependency-check**: Kiểm tra lỗ hổng bảo mật dependencies
- **size-analysis**: Phân tích impact về kích thước app

## 🔑 Required Secrets

Để workflows hoạt động đầy đủ, bạn cần setup các secrets sau trong GitHub repository:

### Firebase Integration
```
FIREBASE_APP_ID=your_android_app_id
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_SERVICE_ACCOUNT_KEY=your_service_account_json
```

### Code Signing (cho production builds)
```
ANDROID_KEYSTORE_BASE64=base64_encoded_keystore
ANDROID_KEY_ALIAS=your_key_alias
ANDROID_KEY_PASSWORD=your_key_password
ANDROID_STORE_PASSWORD=your_store_password
```

## 📋 Setup Checklist

### 1. Firebase Setup
- [ ] Tạo Firebase project
- [ ] Enable App Distribution
- [ ] Enable Hosting
- [ ] Tạo service account với quyền Editor
- [ ] Download service account JSON

### 2. GitHub Secrets Setup
- [ ] Thêm các secrets vào GitHub repository
- [ ] Test Firebase service account permissions

### 3. Android Signing Setup (Production)
- [ ] Tạo keystore file
- [ ] Convert keystore sang base64
- [ ] Cập nhật android/app/build.gradle

### 4. Branch Protection
- [ ] Setup branch protection rules cho main
- [ ] Require PR reviews
- [ ] Require status checks to pass

## 🔧 Customization

### Thay đổi Flutter version
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.32.0'  # Thay đổi version ở đây
```

### Thay đổi test coverage threshold
```yaml
- name: Coverage Comment
  uses: 5monkeys/cobertura-action@master
  with:
    minimum_coverage: 80  # Thay đổi threshold ở đây
```

### Thêm notification
Có thể thêm Slack/Discord notifications:
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🚀 Usage Guide

### 1. Chạy CI cho feature branch
```bash
git checkout -b feature/new-feature
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

### 2. Tạo Pull Request
- PR sẽ trigger `pr-check.yml`
- Review và merge vào develop/main

### 3. Release version mới
```bash
git checkout main
git tag v1.0.0
git push origin v1.0.0
```

### 4. Monitor workflows
- Xem progress tại GitHub Actions tab
- Check artifacts sau khi build xong
- Verify deployment trên Firebase

## 🐛 Troubleshooting

### Common Issues:

**1. Flutter version không match**
- Cập nhật flutter-version trong workflows
- Check pubspec.yaml environment constraints

**2. Firebase deployment fail**
- Verify service account permissions
- Check project ID và app ID

**3. Android build fail**
- Check Java version compatibility
- Verify NDK requirements

**4. Tests fail**
- Run tests locally trước
- Check dependencies conflicts

### Debug Tips:
- Enable debug output: `run: flutter doctor -v`
- Check workflow logs chi tiết
- Test secrets với simple echo (nhớ xóa sau)

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/ci)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
