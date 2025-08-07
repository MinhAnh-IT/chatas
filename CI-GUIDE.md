# Hướng dẫn CI với GitHub Actions cho Dự án Chatas

## Tổng quan

Dự án này đã được setup với hệ thống CI (Continuous Integration) đơn giản sử dụng GitHub Actions, bao gồm:

- **CI (Continuous Integration)**: Kiểm tra code formatting, analyze và run tests
- **PR Checks**: Kiểm tra code quality cho Pull Requests  
- **Dependency Management**: Tự động update dependencies với Dependabot

**Không bao gồm:** Build applications, deployment, hay artifacts

## Workflows

### 1. CI Workflow (`ci.yml`)
**Khi nào chạy:**
- Push code lên các nhánh: `main`, `develop`, `feature/*`
- Tạo Pull Request vào `main` hoặc `develop`

**Những gì được thực hiện:**
- Kiểm tra code formatting
- Analyze code với Flutter analyzer
- Chạy tất cả unit tests

### 2. PR Check Workflow (`pr-check.yml`)
**Khi nào chạy:**
- Tạo hoặc update Pull Request

**Những gì được thực hiện:**
- Kiểm tra formatting chỉ cho files đã thay đổi
- Analyze code
- Chạy tests

## Setup Instructions

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
     - Require pull request reviews
     - Require status checks to pass before merging
     - Require branches to be up to date before merging
     - Include administrators

### Bước 2: Setup GitHub Secrets (Tùy chọn)

Đi đến GitHub repository > Settings > Secrets and variables > Actions:

**Android Signing (Chỉ nếu muốn build signed APK):**
```
ANDROID_KEYSTORE_BASE64=base64_encoded_keystore_content
ANDROID_KEY_ALIAS=chatas-key
ANDROID_KEY_PASSWORD=your_key_password
ANDROID_STORE_PASSWORD=your_store_password
```

## Usage Guide

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

### Monitor CI

1. **Xem workflow progress:**
   - Đi đến GitHub Actions tab
   - Click vào workflow run để xem chi tiết

2. **Download artifacts:**
   - APK files sẽ có sẵn trong GitHub Actions artifacts
   - Web build cũng có thể download

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
- Không áp dụng vì chỉ dùng CI

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

# Verify CI setup
firebase projects:list  # Chỉ nếu cần Firebase
firebase apps:list       # Chỉ nếu cần Firebase
```

## 📊 Metrics & Monitoring

### Code Quality Metrics
- **Test Coverage**: Target 80%+
- **Code Analysis**: 0 errors, warnings
- **Performance**: App size tracking

### Deployment Metrics
- **Build Success Rate**: Monitor failed builds
- **CI Duration**: Track CI workflow duration

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

Nếu gặp vấn đề với CI setup:

1. Check [GitHub Actions documentation](https://docs.github.com/en/actions)
2. Review workflow logs trong GitHub Actions tab
3. Test các commands locally trước
4. Create issue trên repository với detailed logs

---

**Happy coding with automated CI! 🚀**
