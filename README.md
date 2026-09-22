# Finora Mobile (`finora_mb`)

> **Finora** - AI-Powered Personal Finance Management Mobile App  
> Ứng dụng quản lý tài chính cá nhân thông minh tích hợp trí tuệ nhân tạo (hỗ trợ nhập liệu giọng nói qua PhoWhisper, quét hóa đơn bằng VietOCR,...).

---

## 📋 Yêu cầu môi trường (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt các công cụ sau:

- **Flutter SDK**: `>= 3.3.0` (Khuyến nghị bản Flutter mới nhất từ kênh Stable).
- **Dart SDK**: Tương thích với Flutter SDK.
- **Android Studio** (kèm Android SDK & Emulator) hoặc **Xcode** (nếu chạy trên macOS/iOS).
- **VS Code** hoặc **Android Studio** có cài đặt tiện ích mở rộng *Flutter* & *Dart*.

Kiểm tra tính sẵn sàng của môi trường:
```bash
flutter doctor
```

---

## 🚀 Hướng dẫn thiết lập khi mới Clone dự án

Thực hiện lần lượt các bước sau sau khi clone source code về máy:

### 1. Di chuyển vào thư mục dự án
```bash
cd finora
```

### 2. Cài đặt các thư viện (Dependencies)
Tải và cài đặt toàn bộ package khai báo trong `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Sinh mã nguồn tự động (Code Generation)
Dự án sử dụng **Riverpod Generator** và **Build Runner** để tự động tạo ra các file provider (`*.g.dart`). Hãy chạy lệnh sau:

- **Sinh mã 1 lần:**
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- **Hoặc chạy chế độ lắng nghe (Watch mode khi code):**
  ```bash
  dart run build_runner watch --delete-conflicting-outputs
  ```

### 4. Khởi chạy ứng dụng
Kết nối thiết bị thật (bật USB Debugging) hoặc khởi động Emulator/Simulator, sau đó chạy:

```bash
flutter run
```

---

## 🛠️ Tech Stack & Thư viện chính

- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
- **Routing & Navigation**: [go_router](https://pub.dev/packages/go_router)
- **Networking**: [dio](https://pub.dev/packages/dio)
- **Local Storage & Cache**: `flutter_secure_storage`, `shared_preferences`
- **Form & Validation**: `formz`
- **Formatting**: `intl`

---

## 📁 Cấu trúc thư mục (Feature-First Architecture)

```text
lib/
├── app/                  # Cấu hình app gốc, theme, router chung
│   └── router/           # Định tuyến GoRouter, Bottom Navigation Bar
├── core/                 # Tài nguyên & logic dùng chung toàn hệ thống
│   ├── constants/        # Hằng số (API endpoints, App config)
│   ├── errors/           # Xử lý ngoại lệ, Failure classes
│   ├── network/          # Cấu hình Dio client, Interceptor
│   ├── storage/          # Wrapper lưu trữ an toàn (Secure Storage, Prefs)
│   ├── utils/            # Helper, formatters, extensions
│   ├── validation/       # Logic validate form
│   └── widgets/          # Common reusable UI components
├── features/             # Phân tách theo từng tính năng độc lập
│   ├── auth/             # Xác thực (Đăng nhập, Đăng ký, Quên mật khẩu)
│   ├── dashboard/        # Bảng điều khiển tổng quan
│   ├── home/             # Trang chủ
│   ├── transactions/     # Quản lý giao dịch thu / chi
│   ├── wallets/          # Quản lý ví & tài khoản ngân hàng
│   ├── analytics/        # Thống kê & báo cáo tài chính
│   └── profile/          # Trang cá nhân & cài đặt
└── main.dart             # Điểm khởi chạy ứng dụng
```

---

## 💡 Các lệnh hữu ích thường dùng

| Mục đích | Lệnh thực thi |
| :--- | :--- |
| Tải lại thư viện | `flutter pub get` |
| Kiểm tra lỗi tĩnh / Lint | `flutter analyze` |
| Build lại file gen | `dart run build_runner build --delete-conflicting-outputs` |
| Xóa cache & build lại | `flutter clean && flutter pub get` |
| Chạy trên thiết bị cụ thể | `flutter run -d <device_id>` |

