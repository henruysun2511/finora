# 🔐 Hướng Dẫn Kiến Trúc & Luồng Code Feature: Xác Thực (Auth)
> **Kiến trúc:** Pragmatic Feature-First Architecture (Riverpod 2.x)  
> **Ngôn ngữ thiết kế:** SOLARN FinTech Design System chuẩn 1:1 từ `static-ui/device-preview/screens/auth` & `static-ui/ui-sample-3/styles.css`

---

## 🎨 1. Bảng Màu Chuẩn Trích Xuất 100% Từ `styles.css` (OKLCH ⇄ sRGB)

Toàn bộ giao diện Auth (Đăng nhập, Đăng ký) tuân thủ bảng màu chuyển đổi chính xác từ không gian màu **OKLCH** sang **Hex / sRGB**:

| Tên biến CSS (`styles.css`) | Giá trị OKLCH gốc | Mã Hex Flutter | Thuộc tính `AppColors` | Ứng dụng thực tế trên Auth UI |
| :--- | :--- | :--- | :--- | :--- |
| `--primary` | `oklch(0.55 0.18 250)` | **`#0072D5`** | `AppColors.primary` | Nền nút bấm chính "Đăng nhập", text link "Đăng ký ngay", checkbox active |
| `--primary-fore` | `oklch(0.99 0.01 250)` | **`#F5FDFF`** | `AppColors.darkForeground` | Màu chữ trắng tương phản trên nền xanh |
| `--secondary` | `oklch(0.78 0.16 65)` | **`#FC9F30`** | `AppColors.secondary` | Màu vàng cam hổ phách, vòng tròn phát sáng trang trí |
| `--accent` | `oklch(0.55 0.18 250 / .12)`| **`#EAF3FF`** | `AppColors.primaryLight` | Viền focus ô nhập liệu |
| `--dash-bg` | `oklch(0.97 0.01 240)` | **`#EFF6FB`** | `AppColors.lightBackground` | Màu nền app xám phấn nhẹ |
| `--background` | `oklch(0.99 0.01 230)` | **`#FFFFFF`** | `AppColors.lightSurface` | Nền trắng thẻ Bottom Sheet bo tròn 32px |
| `--foreground` | `oklch(0.25 0.06 240)` | **`#00243B`** | `AppColors.lightForeground` | Tiêu đề chính "Chào trở lại", "Đăng ký tài khoản" |
| `--ink-soft` | `oklch(0.6 0.02 240)` | **`#76828B`** | `AppColors.lightMuted` | Chữ phụ, nhãn UPPERCASE ô input (`EMAIL`, `MẬT KHẨU`) |
| `--ink-faint` | `oklch(0.75 0.02 240)` | **`#A3B0BA`** | `AppColors.lightFaint` | Chữ placeholder mờ, chữ phân cách `HOẶC` |
| `--border` | `oklch(0.92 0.01 240)` | **`#DFE6EB`** | `AppColors.lightBorder` | Viền ô nhập liệu 1.5px, viền nút Google |
| `--danger` | `oklch(0.62 0.22 25)` | **`#EE343B`** | `AppColors.danger` | Thông báo lỗi đăng nhập (Floating SnackBar) |

---

## 🏛️ 2. Cấu Trúc Thư Mục Chuẩn Pragmatic Feature-First

Cấu trúc module Xác thực nằm gọn tại `lib/features/auth/`, loại bỏ hoàn toàn các lớp phân tầng cồng kềnh (Clean Architecture over-engineering) để đồng bộ 100% với `features/budgets`:

```text
lib/features/auth/
├── data/
│   ├── models/
│   │   ├── user.dart             # Model thực thể Người dùng (Entity + DTO gộp chung, fromJson, toJson)
│   │   └── auth_requests.dart    # Request DTOs (LoginRequest, RegisterRequest)
│   │
│   └── auth_repository.dart      # Xử lý Dio HTTP, Token lưu SecureStorage & Cache LocalStorage
│
└── presentation/
    ├── providers/
    │   └── auth_provider.dart    # Riverpod Notifier: Quản lý trạng thái Auth (AsyncValue<User?>)
    │
    └── screens/
        ├── login_screen.dart     # Màn hình Đăng nhập (Brand Mark + Bottom Sheet)
        └── register_screen.dart  # Màn hình Đăng ký tài khoản mới
```

### Ý nghĩa chi tiết từng file:

#### 🔹 Nhóm 1: Tầng Dữ Liệu (`data/`)
1. **`user.dart`**:
   * Đại diện cho thực thể người dùng: `id`, `email`, `name`, `avatarUrl`.
   * Gộp chung Entity và Model vào một nơi duy nhất.
   * Cung cấp `fromJson()`, `toJson()` và `copyWith()`.
2. **`auth_requests.dart`**:
   * `LoginRequest`: Đóng gói payload gửi lên server khi đăng nhập (`email`, `password`).
   * `RegisterRequest`: Đóng gói payload gửi lên server khi đăng ký (`fullName`, `email`, `password`).
3. **`auth_repository.dart`**:
   * Lớp chịu trách nhiệm duy nhất cho các tác vụ Auth cấp dữ liệu:
     * Gửi request HTTP qua `Dio` đến `/auth/login`, `/auth/register`, `/users/me`.
     * Tự động lưu `accessToken` và `refreshToken` vào `SecureStorage` (mã hóa an toàn).
     * Tự động cache profile người dùng dưới dạng JSON vào `LocalStorage` (hỗ trợ offline/khởi động tức thì).
     * Bắt lỗi `DioException`, chuyển đổi thành `AppException` chuẩn xác.
   * Cung cấp `authRepositoryProvider` để Notifier và các phân hệ khác sử dụng.

#### 🔹 Nhóm 2: Tầng Quản Lý Trạng Thái (`presentation/providers/`)
4. **`auth_provider.dart`**:
   * Notifier chính toàn app: `AuthNotifier` kế thừa `_$AuthNotifier` (Riverpod 2.x).
   * Quản lý trạng thái `AsyncValue<User?>`:
     * `build()`: Tự động khôi phục phiên đăng nhập khi mở app, lắng nghe stream `AuthInterceptor.onUnauthorized` để tự động logout khi token hết hạn.
     * `login(email, password)`: Thực hiện đăng nhập, cập nhật `AsyncValue.data(user)`.
     * `register(name, email, password)`: Đăng ký tài khoản mới và lưu session.
     * `logout()`: Xóa sạch token và session, cập nhật state về `null` (kích hoạt GoRouter redirect về login).
     * `updateLocalUser(user)`: Cập nhật nhanh thông tin người dùng (Demo Mode).

#### 🔹 Nhóm 3: Tầng Giao Diện (`presentation/screens/`)
5. **`login_screen.dart`**:
   * Màn hình chuẩn Device Preview:
     * Nền Gradient thương hiệu Cobalt Blue cùng Ambient Glowing Rings.
     * Top Bar có nút Back hình tròn glassmorphism và nhãn `XÁC THỰC`.
     * Brand Mark: Logo glassmorphism với Spark Tag `✦` và Typography `Outfit` / `Inter`.
     * Thẻ Bottom Sheet bo tròn 32px: Ô nhập Email/Password, Ghi nhớ tài khoản, Quên mật khẩu, Nút Đăng nhập gradient, Nút Google và Demo Mode.
6. **`register_screen.dart`**:
   * Màn hình đăng ký: Nhập Họ tên, Email, Mật khẩu $\ge 6$ ký tự, liên kết chuyển đổi mượt mà với màn Đăng nhập.

---

## 🔄 3. Luồng Chạy Code Khi Người Dùng Thao Tác (Workflow)

```
[ Người Dùng Mở App Hoặc Bấm Đăng Nhập ]
                 │
                 ▼
1. presentation/screens/login_screen.dart
   ├── Điền Email & Mật khẩu
   └── Nhấn "Đăng nhập" ➔ Gọi ref.read(authNotifierProvider.notifier).login(...)
                 │
                 ▼
2. presentation/providers/auth_provider.dart
   ├── Set state = AsyncValue.loading()
   └── Gọi ref.read(authRepositoryProvider).login(...)
                 │
                 ▼
3. data/auth_repository.dart
   ├── Gửi POST: dio.post('/auth/login', data: LoginRequest)
   ├── Nhận Response: { user, accessToken, refreshToken }
   ├── Lưu tokens: SecureStorage.saveAccessToken(...)
   ├── Lưu cache: LocalStorage.saveCachedUser(...)
   └── Trả về đối tượng User
                 │
                 ▼
4. presentation/providers/auth_provider.dart
   └── Cập nhật state = AsyncValue.data(user)
                 │
                 ▼
5. app/router/app_router.dart (GoRouter redirect)
   ├── Phát hiện authState.valueOrNull != null
   └── Tự động điều hướng từ `/login` về `/home` (Trang chủ)
```

---

## 💡 4. Điểm Vượt Trội Của Kiến Trúc Mới So Với Code Cũ

| Điểm khác biệt | Kiến trúc cũ (Over-engineered) | Kiến trúc mới (Pragmatic Feature-First) | Lợi ích đạt được |
| :--- | :--- | :--- | :--- |
| **Số lượng file/tầng** | 10+ file rời rạc (`datasources/`, `repositories/impl`, `domain/entities/`, `domain/repositories/`) | 5 file tinh gọn, đúng trọng tâm | Giảm 50% boilerplate, dễ bảo trì, dễ onboarding |
| **Model & Entity** | Tách đôi `User` và `UserModel` kế thừa nhau chỉ để thêm hàm JSON | Gộp thành 1 file duy nhất `data/models/user.dart` | Không còn tình trạng convert qua lại giữa Entity $\leftrightarrow$ Model |
| **Gọi Mạng & Cache** | Tách rời Datasource và Repository chỉ để ủy quyền (forwarding) cuộc gọi | Tích hợp tập trung vào `data/auth_repository.dart` | Code liền mạch, dễ debug luồng lưu Token và bắt Exception |
| **Đồng bộ toàn dự án** | Lệch chuẩn so với `budgets`, `transactions` | Đồng bộ 100% với kiến trúc của `budgets` | Toàn bộ dự án nói chung một "ngôn ngữ kiến trúc" |
