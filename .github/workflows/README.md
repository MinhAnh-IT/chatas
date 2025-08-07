# GitHub Actions Workflows

Thư mục này chứa các workflow tự động cho dự án Chatas.

## Workflows

### 1. CI (`ci.yml`)
**Mục đích:** Kiểm tra code quality và chạy tests

**Khi chạy:**
- Push code lên branches: `main`, `develop`, `feature/*`
- Tạo Pull Request vào `main` hoặc `develop`

**Những gì kiểm tra:**
- Code formatting (dart format)
- Static analysis (flutter analyze)  
- Unit tests (flutter test)

### 2. PR Check (`pr-check.yml`)
**Mục đích:** Kiểm tra Pull Requests

**Khi chạy:**
- Tạo hoặc update Pull Request

**Những gì kiểm tra:**
- Format của files đã thay đổi
- Analyze code
- Chạy tests

## Dependencies

### Dependabot (`dependabot.yml`)
Tự động tạo PR để update dependencies:
- Flutter packages hàng tuần
- GitHub Actions hàng tuần

## Templates

- **Bug Report:** Template cho báo cáo lỗi
- **Feature Request:** Template cho đề xuất tính năng  
- **Pull Request:** Template cho PR reviews

---

*Workflows được thiết kế đơn giản để chỉ kiểm tra code quality và tests, không build applications.*
