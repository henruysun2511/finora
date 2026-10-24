# 🪙 FINORA - AI-Powered Personal Finance Management

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2.5-blue?style=for-the-badge)
![GoRouter](https://img.shields.io/badge/Go_Router-14.x-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Finora** là ứng dụng quản lý tài chính cá nhân thông minh thế hệ mới, tích hợp linh vật AI Mascot tương tác cá nhân hóa dựa trên tình trạng tài chính của người dùng, cùng giao diện FinTech hiện đại mang phong cách Solarn.

</div>

---

## 📑 Mục lục
- [Giới thiệu dự án](#-giới-thiệu-dự-án)
- [Tính năng nổi bật](#-tính-năng-nổi-bật)
- [Hệ thống AI Mascot (7 Tiers)](#-hệ-thống-ai-mascot-7-tiers)
- [Kiến trúc & Cấu trúc thư mục](#-kiến-trúc--cấu-trúc-thư-mục)
- [Yêu cầu môi trường](#-yêu-cầu-môi-trường)
- [Hướng dẫn cài đặt & Chạy dự án](#-hướng-dẫn-cài-đặt--chạy-dự-án)
- [Các câu lệnh thường dùng](#-các-câu-lệnh-thường-dùng)
- [Xử lý lỗi thường gặp (Troubleshooting)](#-xử-lý-lỗi-thường-gặp-troubleshooting)
- [Quy ước đóng góp (Contribution)](#-quy-ước-đóng-góp)

---

## 💡 Giới thiệu dự án

Finora giúp người dùng dễ dàng theo dõi dòng tiền, phân bổ ngân sách, quản lý đa tài khoản/ví điện tử và hướng tới sự tự do tài chính. Điểm khác biệt lớn nhất của Finora là hệ thống **AI Mascot tương tác** – một "huấn luyện viên tài chính" với biểu cảm và lời khuyên thay đổi linh hoạt theo mức tài sản thực tế của bạn.

---

## 🌟 Tính năng nổi bật

- 💼 **Quản lý đa tài khoản & Ví:** Hỗ trợ tiền mặt, tài khoản ngân hàng, ví điện tử (MoMo, ZaloPay, ViettelPay,...), tự động tính toán tổng giá trị tài sản ròng.
- 💸 **Quản lý giao dịch nhanh chóng:** Thêm thu/chi với danh mục trực quan, ghi chú thông minh, hỗ trợ bộ lọc đa dạng theo thời gian và ví.
- 🤖 **Linh vật AI tương tác (AI Mascot):** Biến đổi theo 7 mốc sức khỏe tài chính, đưa ra phản hồi và lời nhắc chi tiêu cá nhân hóa.
- 🎙️ **Sẵn sàng tích hợp AI Input:** Hỗ trợ nhập liệu bằng giọng nói (PhoWhisper) và nhận diện hóa đơn qua ảnh chụp (VietOCR).
- 📊 **Báo cáo & Phân tích chuyên sâu:** Biểu đồ dòng tiền thu chi, phân bổ tỷ trọng chi tiêu, cảnh báo hạn mức ngân sách.
- 🎨 **Giao diện Modern FinTech:** Hỗ trợ đầy đủ **Dark Mode** & **Light Mode**, hiệu ứng chuyển tab mượt mà với GoRouter StatefulShellRoute.
- 🔐 **Bảo mật cao:** Lưu trữ token an toàn qua `flutter_secure_storage`, mã hóa phiên đăng nhập JWT.

---

## 🎭 Hệ thống AI Mascot (7 Tiers)

| # | Mascot | Khoảng tài sản | Vai trò | Phong cách & Màu sắc |
|---|--------|---------------|---------|----------------------|
| 1 | **Ash** | Nợ (`< 0`) | Kẻ Sinh Tồn | Thắt lưng buộc bụng, cảnh báo nợ quyết liệt (`#718096`) |
| 2 | **Penny** | 0 – 1 triệu | Kế Toán Săn Sale | Cẩn thận chi tiêu từng đồng, ưu tiên tiết kiệm (`#d97706`) |
| 3 | **Sage** | 1 – 5 triệu | Người Làm Vườn Nhẫn Nại | Ổn định dòng tiền, tích lũy từng bước (`#48bb78`) |
| 4 | **Nora** | 5 – 20 triệu | Huấn Luyện Viên Đời Sống | Cân bằng tài chính và tận hưởng cuộc sống (`#0072d5`) |
| 5 | **Jade** | 20 – 100 triệu | Chiến Lược Gia | Bắt đầu đầu tư, phân bổ danh mục tài sản (`#059669`) |
| 6 | **Ruby** | 100 – 500 triệu | Quý Cô Hưởng Thụ | Tự tin tài chính, tối ưu nguồn vốn (`#ec4899`) |
| 7 | **Bellingham** | 500 triệu+ | Chủ Tịch | Tự do tài chính, quản lý tài sản lớn (`#b7791f`) |

---

## 🏗️ Kiến trúc & Cấu trúc thư mục

Dự án áp dụng mô hình **Feature-driven Clean Architecture** kết hợp với **Riverpod 2.x**:

```text
finora_mb/
├── android/                 # Mã nguồn nền tảng Android
├── ios/                     # Mã nguồn nền tảng iOS
├── lib/
│   ├── app/                 # Cấu hình app gốc, AppRouter, Theme & Settings
│   │   ├── router/          # Cấu hình GoRouter, StatefulShellRoute, Bottom Navigation
│   │   ├── theme/           # Định nghĩa màu sắc, typography, Dark/Light theme
│   │   └── app.dart         # Entry point MaterialApp.router
│   ├── core/                # Các thành phần dùng chung toàn ứng dụng
│   │   ├── constants/       # API endpoints, cấu hình chung
│   │   ├── errors/          # Xử lý ngoại lệ, Failure mapping
│   │   ├── network/         # Dio client, Auth interceptor
│   │   ├── storage/         # Secure storage, SharedPreferences providers
│   │   ├── utils/           # Format tiền tệ VNĐ, ngày tháng, helper
│   │   ├── validation/      # Form validation (formz)
│   │   └── widgets/         # UI components tái sử dụng (Button, TextField, Error...)
│   ├── features/            # Các module chức năng theo miền nghiệp vụ
│   │   ├── auth/            # Đăng nhập, đăng ký, xác thực JWT
│   │   ├── dashboard/       # Màn hình chính, tổng quan số dư, danh sách ví
│   │   ├── transactions/    # Danh sách giao dịch, lọc, thêm/sửa giao dịch
│   │   ├── wallets/         # Quản lý ví, tài khoản ngân hàng
│   │   ├── analytics/       # Báo cáo tài chính, biểu đồ chi tiêu
│   │   └── profile/         # Hồ sơ người dùng, cài đặt Dark/Light mode
│   └── main.dart            # Khởi tạo App & ProviderScope
├── pubspec.yaml             # Khai báo thư viện & dependencies
└── README.md                # Tài liệu dự án
```

---

## 💻 Yêu cầu môi trường

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt:

- **Flutter SDK:** Phiên bản `3.19.0` trở lên (Khuyến nghị `3.22.x` hoặc `3.24.x`).
- **Dart SDK:** Phiên bản `>=3.3.0 <4.0.0` (Tự động đi kèm theo Flutter).
- **IDE:** Visual Studio Code (khuyên dùng extension *Flutter* & *Dart*) hoặc Android Studio.
- **Thiết bị chạy thử:**
  - Android Emulator (Android 8.0 / API level 26 trở lên) hoặc thiết bị thật đã bật USB Debugging.
  - iOS Simulator (Yêu cầu macOS và Xcode 15+).
- **Git:** Đã cài đặt trên hệ thống.

Kiểm tra tính sẵn sàng của môi trường:
```bash
flutter doctor
```
> Đảm bảo các mục Flutter, Android toolchain hoặc Xcode hiển thị dấu tích xanh `[✓]`.

---

## 🚀 Hướng dẫn cài đặt & Chạy dự án

### Bước 1: Điều hướng vào thư mục ứng dụng Mobile

Nếu đang ở thư mục gốc của repository:
```bash
cd finora_mb
```

### Bước 2: Tải các gói phụ thuộc (Dependencies)

Tải toàn bộ các package được khai báo trong `pubspec.yaml`:
```bash
flutter pub get
```

### Bước 3: Chạy sinh mã nguồn (Code Generation)

Dự án sử dụng `riverpod_generator` và `build_runner` để tự động sinh code cho router và providers. Chạy lệnh:
```bash
dart run build_runner build --delete-conflicting-outputs
```
*(Nếu bạn đang phát triển và muốn tự động cập nhật code gen khi lưu file, dùng lệnh `dart run build_runner watch --delete-conflicting-outputs`).*

### Bước 4: Cấu hình API Endpoint (Nếu cần)

Mặc định, cấu hình kết nối API được đặt tại:
`lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // Thay đổi sang IP local máy chủ của bạn nếu test qua Backend nội bộ
  // Đối với Android Emulator: sử dụng 'http://10.0.2.2:3000/v1' thay cho 'localhost'
  static const String baseUrl = 'https://api.finora.vn/v1';
}
```

### Bước 5: Kiểm tra thiết bị khả dụng

Liệt kê danh sách các thiết bị / máy ảo đang sẵn sàng:
```bash
flutter devices
```

### Bước 6: Khởi chạy ứng dụng

Chạy trên thiết bị mặc định:
```bash
flutter run
```

Hoặc chỉ định rõ thiết bị mục tiêu (ví dụ máy ảo chrome, android emulator):
```bash
# Chạy trên Android Emulator
flutter run -d emulator-5554

# Chạy trên trình duyệt Web (nếu muốn xem layout)
flutter run -d chrome
```

---

## 🛠️ Các câu lệnh thường dùng

| Tác vụ | Câu lệnh |
|--------|----------|
| **Cài đặt thư viện** | `flutter pub get` |
| **Cập nhật thư viện** | `flutter pub upgrade` |
| **Sinh code Riverpod (1 lần)** | `dart run build_runner build --delete-conflicting-outputs` |
| **Sinh code liên tục (Watch mode)** | `dart run build_runner watch --delete-conflicting-outputs` |
| **Kiểm tra cú pháp & Lint** | `flutter analyze` |
| **Chạy unit & widget tests** | `flutter test` |
| **Xóa cache & thư mục build** | `flutter clean` |
| **Build file APK release** | `flutter build apk --release` |
| **Build Android App Bundle (AAB)** | `flutter build appbundle --release` |
| **Build iOS App (chỉ macOS)** | `flutter build ipa --release` |

---

## ❓ Xử lý lỗi thường gặp (Troubleshooting)

### 1. Lỗi xung đột mã nguồn tự sinh (`*.g.dart`)
**Hiện tượng:** Báo lỗi compile liên quan đến missing file `.g.dart` hoặc trùng lặp class.  
**Khắc phục:**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Lỗi mạng khi kết nối Backend từ Android Emulator
**Hiện tượng:** Gọi API báo `DioException [connection error]` hoặc timeout.  
**Nguyên nhân:** Máy ảo Android xem máy tính host là `10.0.2.2`, không phải `localhost` hay `127.0.0.1`.  
**Khắc phục:** Sửa `baseUrl` trong `lib/core/constants/api_constants.dart` thành `http://10.0.2.2:<PORT>/v1`.

### 3. Lỗi CocoaPods trên iOS (macOS)
**Hiện tượng:** `pod install` thất bại hoặc lỗi Podfile version mismatch.  
**Khắc phục:**
```bash
cd ios
pod deintegrate
pod repo update
pod install
cd ..
flutter run
```

---

## 👥 Nhóm phát triển & Giấy phép

- **Sản phẩm:** Finora Team
- **Giấy phép:** Phân phối nội bộ / Giấy phép nguồn mở theo quy chuẩn dự án.
- Mọi thắc mắc hoặc báo lỗi, vui lòng tạo issue hoặc liên hệ nhóm phụ trách kỹ thuật.
