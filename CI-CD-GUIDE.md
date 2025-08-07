# 🚀 Hướng dẫn CI/CD với GitHub Actions cho Dự án Chatas

## 📋 Tổng quan

Dự án này đã được setup với một hệ thống CI/CD hoàn chỉnh sử dụng GitHub Actions, bao gồm:

- **CI (Continuous Integration)**: Tự động test, build và kiểm tra code quality
- **CD (Continuous Deployment)**: Tự động deploy lên Firebase khi release
- **PR Checks**: Kiểm tra code quality cho Pull Requests
- **Dependency Management**: Tự động update dependencies với Dependabot

## 🔄 Workflows

### 1. CI Workflow (`ci.yml`)
**Khi nào chạy:**
- Push code lên các nhánh: `main`, `develop`, `feature/*`
- Tạo Pull Request vào `main` hoặc `develop`

**Những gì được thực hiện:**
- ✅ Kiểm tra code formatting
- ✅ Analyze code với Flutter analyzer
- ✅ Chạy tất cả unit tests với coverage
- ✅ Build APK cho Android
- ✅ Build cho iOS (không sign)
- ✅ Build web app
- ✅ Security scan (chỉ trên main branch)

### 2. CD Workflow (`cd.yml`)
**Khi nào chạy:**
- Push tag version (ví dụ: `v1.0.0`, `v2.1.3`)

**Những gì được thực hiện:**
- 🚀 Deploy APK lên Firebase App Distribution
- 🌐 Deploy web app lên Firebase Hosting
- 📦 Tạo GitHub Release với artifacts
- 📱 Gửi notification đến testers

### 3. PR Check Workflow (`pr-check.yml`)
**Khi nào chạy:**
- Tạo hoặc update Pull Request

**Những gì được thực hiện:**
- 🔍 Kiểm tra formatting chỉ cho files đã thay đổi
- 📊 Chạy tests liên quan đến thay đổi
- 📈 Comment coverage report trên PR
- 🔒 Scan dependencies vulnerabilities
- 📏 Analyze app size impact

## 🛠️ Setup Instructions

### Bước 1: Setup GitHub Repository

1. **Enable GitHub Actions:**
   ```bash
   # Clone repository
   git clone https://github.com/MinhAnh-IT/chatas.git
   cd chatas
   
   # Run setup script
   ./setup-ci.sh
   ```

2. **Branch Protection Rules:**
   - Đi đến Settings > Branches
   - Add rule cho `main` branch:
     - ✅ Require pull request reviews
     - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - ✅ Include administrators

### Bước 2: Setup Firebase

1. **Tạo Firebase Project:**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login
   firebase login
   
   # Init project
   firebase init
   ```

2. **Enable App Distribution:**
   - Đi đến Firebase Console > App Distribution
   - Add Android app
   - Lưu App ID

3. **Enable Hosting:**
   - Đi đến Firebase Console > Hosting
   - Setup domain (nếu cần)

4. **Tạo Service Account:**
   ```bash
   # Đi đến Google Cloud Console
   # IAM & Admin > Service Accounts
   # Create Service Account với Editor role
   # Download JSON key file
   ```

### Bước 3: Setup GitHub Secrets

Đi đến GitHub repository > Settings > Secrets and variables > Actions:

**Firebase Secrets:**
```
FIREBASE_APP_ID=1:123456789:android:abcdef123456
FIREBASE_PROJECT_ID=chatas-app-12345
FIREBASE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}
```

**Android Signing (Production):**
```
ANDROID_KEYSTORE_BASE64=base64_encoded_keystore_content
ANDROID_KEY_ALIAS=chatas-key
ANDROID_KEY_PASSWORD=your_key_password
ANDROID_STORE_PASSWORD=your_store_password
```

### Bước 4: Configure Android Signing

1. **Tạo keystore:**
   ```bash
   keytool -genkey -v -keystore chatas-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias chatas-key
   ```

2. **Convert to base64:**
   ```bash
   base64 -i chatas-key.jks | tr -d '\n' | pbcopy
   ```

3. **Update `android/app/build.gradle`:**
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               if (System.getenv("CI")) {
                   storeFile file("../keystore.jks")
                   storePassword System.getenv("ANDROID_STORE_PASSWORD")
                   keyAlias System.getenv("ANDROID_KEY_ALIAS")
                   keyPassword System.getenv("ANDROID_KEY_PASSWORD")
               }
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
               ...
           }
       }
   }
   ```

## 🚀 Usage Guide

### Development Workflow

1. **Feature Development:**
   ```bash
   # Tạo feature branch
   git checkout -b feature/chat-improvements
   
   # Code changes...
   
   # Commit và push
   git add .
   git commit -m "feat: improve chat performance"
   git push origin feature/chat-improvements
   ```

2. **Tạo Pull Request:**
   - GitHub sẽ tự động chạy PR checks
   - Review code và merge sau khi pass tất cả checks

3. **Release Process:**
   ```bash
   # Merge vào main
   git checkout main
   git pull origin main
   
   # Tạo tag
   git tag v1.0.0
   git push origin v1.0.0
   ```

### Monitor CI/CD

1. **Xem workflow progress:**
   - Đi đến GitHub Actions tab
   - Click vào workflow run để xem chi tiết

2. **Download artifacts:**
   - APK files sẽ có sẵn trong GitHub Actions artifacts
   - Web build cũng có thể download

3. **Check deployment:**
   - Firebase App Distribution: Check email notification
   - Firebase Hosting: Visit deployed URL

## 🔍 Troubleshooting

### Common Issues

**1. Tests fail trên CI nhưng pass locally:**
```bash
# Ensure dependencies are locked
flutter pub deps
git add pubspec.lock
git commit -m "lock dependencies"
```

**2. Android build fail:**
```bash
# Check Java version
java -version

# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version=8.0
```

**3. Firebase deployment fail:**
- Verify service account permissions
- Check Firebase project ID
- Ensure App Distribution is enabled

**4. Coverage thấp:**
```bash
# Generate coverage report locally
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Debug Commands

```bash
# Run CI steps locally
flutter analyze
flutter test --coverage
flutter build apk --debug
flutter build web --debug

# Check formatting
dart format --output=none --set-exit-if-changed .

# Verify Firebase setup
firebase projects:list
firebase apps:list
```

## 📊 Metrics & Monitoring

### Code Quality Metrics
- **Test Coverage**: Target 80%+
- **Code Analysis**: 0 errors, warnings
- **Performance**: App size tracking

### Deployment Metrics
- **Build Success Rate**: Monitor failed builds
- **Deployment Time**: Track CI/CD duration
- **App Distribution**: Track download rates

### Setup Monitoring Dashboard
Có thể setup monitoring với:
- GitHub Insights để track workflow success rate
- Firebase Analytics cho app usage
- CodeCov cho detailed coverage reports

## 🛡️ Security Best Practices

1. **Secrets Management:**
   - Không commit secrets vào code
   - Use GitHub Secrets cho sensitive data
   - Rotate secrets định kỳ

2. **Dependency Security:**
   - Dependabot sẽ tự động update vulnerable dependencies
   - Review security advisories thường xuyên

3. **Code Security:**
   - Enable security scanning workflows
   - Use signed APKs cho production
   - Validate inputs trong code

## 📚 Advanced Configuration

### Custom Workflows

Có thể tạo thêm workflows cho:
- **Nightly builds**: Build hàng đêm với latest code
- **Performance testing**: Automated performance tests
- **E2E testing**: Integration tests với real devices

### Integration với Third-party Services

```yaml
# Slack notifications
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}

# Discord notifications  
- name: Discord notification
  uses: Ilshidur/action-discord@master
  with:
    args: 'Build completed: ${{ job.status }}'
  env:
    DISCORD_WEBHOOK: ${{ secrets.DISCORD_WEBHOOK }}
```

### Performance Optimization

```yaml
# Cache Flutter dependencies
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: /opt/hostedtoolcache/flutter
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}

# Parallel builds
jobs:
  build-android:
    strategy:
      matrix:
        target: [android-arm, android-arm64, android-x64]
```

## 🎯 Best Practices

1. **Git Workflow:**
   - Use conventional commits
   - Keep commits atomic
   - Write descriptive commit messages

2. **Testing:**
   - Write tests trước khi implement features
   - Maintain high test coverage
   - Include integration tests

3. **Release Management:**
   - Use semantic versioning
   - Write detailed changelog
   - Test trên staging environment trước production

4. **Code Quality:**
   - Enable all linting rules
   - Use code formatters
   - Regular code reviews

## 📞 Support

Nếu gặp vấn đề với CI/CD setup:

1. Check [GitHub Actions documentation](https://docs.github.com/en/actions)
2. Review workflow logs trong GitHub Actions tab
3. Test các commands locally trước
4. Create issue trên repository với detailed logs

---

**Happy coding with automated CI/CD! 🚀**
