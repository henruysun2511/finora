# HƯỚNG DẪN THIẾT KẾ GIAO DIỆN & QUY TẮC PHÁT TRIỂN FINORA (UI DESIGN SYSTEM)

Tài liệu này là quy chuẩn bắt buộc mà AI Agent (Antigravity) phải tự động đọc và tuân thủ trong mọi tác vụ phát triển giao diện của ứng dụng FINORA (`finora_mb`).

---

## 1. QUY CHUẨN HEADER (APPBAR & PAGE HEADER)
* **Trang chính (Tabs / Dashboard)**: Dùng `PageHeader.page(title: ..., subtitle: ..., action: ...)`.
* **Trang có Banner Hero lớn (như Sổ nợ, Tài khoản & Nguồn tiền)**: Dùng [`BannerHeader`](file:///f:/Project/FINORA/finora_mb/lib/core/widgets/banner_header.dart) bọc ngoài (`title`, `onBack`, `action`, `gradient`, `child`) theo chuẩn `.acc-hero` của `static-ui/device-preview`.
* **Trang con / Form / Chi tiết (Sub-pages)**: **BẮT BUỘC** dùng `PageHeader.subPage` làm `appBar` của `Scaffold`:
  ```dart
  appBar: PageHeader.subPage(
    title: 'Tiêu đề màn hình',
    subtitle: 'Mô tả ngắn gọn hoặc ngữ cảnh',
    action: Widget?, // Menu 3 chấm hoặc nút hành động nếu có
  )
  ```
* **NGHIÊM CẤM**: Tự ý vẽ các khối gradient Container làm header thủ công trong `body` chứa nút back trùng lặp hoặc AppBar mặc định không có bo góc FinTech.

---

## 2. QUY CHUẨN TABS & NÚT LỰA CHỌN (CHOICECHIP / FILTER / TOGGLE)
Toàn bộ thanh lọc tab, bộ chọn phân loại, toggle kỳ hạn trong ứng dụng đều phải tuân thủ chuẩn **Phần 4 Chu kỳ ngân sách (`BudgetFormScreen`)**:
* **Active State (Khi được chọn)**:
  - Nền: Solid màu xanh thương hiệu `AppColors.primary` (`#0072D6`).
  - Chữ & Icon: **Màu trắng** (`Colors.white`), `FontWeight.w700`.
  - Viền: `BorderSide(color: AppColors.primary)`.
  - Checkmark: **Luôn tắt** (`showCheckmark: false`) để tránh che chữ hoặc làm biến dạng tab.
* **Inactive State (Khi chưa chọn)**:
  - Nền: `isDark ? AppColors.darkSurface : Colors.white`.
  - Chữ: `isDark ? AppColors.darkForeground : AppColors.lightForeground`, `FontWeight.w500`.
  - Icon: `isDark ? AppColors.darkMuted : AppColors.lightMuted`.
  - Viền: `BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)`.
* **Bo góc**: `BorderRadius.circular(12)` (hoặc `16` tùy kích cỡ).

---

## 3. QUY CHUẨN NÚT SWITCH & THẺ CÀI ĐẶT (`FormCard`)
Toàn bộ các nút Switch hoặc nhóm cài đặt cấu hình dạng toggle (như đồng bộ ví, lãi suất, rollover, mở bán, hiển thị linh vật) phải được đóng gói theo khối **Cài đặt bổ sung**:
* **Bọc trong [`FormCard`](file:///f:/Project/FINORA/finora_mb/lib/core/widgets/form_card.dart)**:
  - Bo góc `18px`, viền `darkBorder / lightBorder`, nền `darkSurface / white`.
  - Tiêu đề nhóm in hoa: `title.toUpperCase()`, `fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5`.
* **Bên trong thẻ**:
  - Dùng `SwitchListTile(contentPadding: EdgeInsets.zero, title: ..., subtitle: ...)`.
  - Nếu có từ 2 switch trở lên: Phân tách bằng `const Divider()`.
* **Kiểu dáng Switch**: Track màu `AppColors.primary`, Thumb màu trắng `Colors.white`, outline trong suốt khi active (được bảo đảm bởi `switchTheme` trong `AppTheme`).

---

## 4. QUY CHUẨN MÀU SẮC & THEME ([`AppColors`](file:///f:/Project/FINORA/finora_mb/lib/app/theme/app_colors.dart))
* Primary Brand: `#0072D6` (`AppColors.primary`).
* Không hardcode mã màu hex rải rác trong code giao diện, luôn dùng qua `AppColors` hoặc `Theme.of(context)`.
* Luôn hỗ trợ hoàn hảo cả 2 chế độ **Light Mode** và **Dark Mode**.
