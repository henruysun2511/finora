import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';

/// Nhóm phân loại tiện ích
enum QuickActionGroup {
  transaction,
  planning,
  management,
  social,
  extended,
}

/// Model đại diện cho một tiện ích trong thanh Thao tác nhanh
class QuickActionItemModel {
  final String id;
  final String label;
  final IconData icon;
  final Color bgColor;
  final String routePath;
  final QuickActionGroup group;
  final bool isDefaultEnabled;

  const QuickActionItemModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.routePath,
    required this.group,
    this.isDefaultEnabled = true,
  });
}

/// Danh mục toàn diện các tiện ích tài chính của FINORA
/// Bảng màu đa dạng, tương phản cao, tươi sáng và chuẩn FinTech hiện đại
const List<QuickActionItemModel> allQuickActionsCatalog = [
  // ── 12 TIỆN ÍCH MẶC ĐỊNH HIỂN THỊ (Lưới 3 hàng x 4 cột - Phối màu đa sắc không trùng lặp) ──
  // 1. Thu/Chi thủ công -> Xanh thương hiệu Finora Primary
  QuickActionItemModel(
    id: 'create_transaction',
    label: 'Thu/Chi',
    icon: Icons.add_circle_outline_rounded,
    bgColor: AppColors.primary, // #0072D6
    routePath: RoutePaths.createTransaction,
    group: QuickActionGroup.transaction,
    isDefaultEnabled: true,
  ),
  // 2. Chuyển tiền -> Tím Thạch anh (Vibrant Violet)
  QuickActionItemModel(
    id: 'transfer',
    label: 'Chuyển tiền',
    icon: Icons.swap_horiz_rounded,
    bgColor: Color(0xFF8B5CF6),
    routePath: RoutePaths.transfer,
    group: QuickActionGroup.transaction,
    isDefaultEnabled: true,
  ),
  // 3. Sổ giao dịch -> Cam Hoàng Hôn rực rỡ (Sunset Orange)
  QuickActionItemModel(
    id: 'transactions',
    label: 'Sổ GD',
    icon: Icons.receipt_long_rounded,
    bgColor: Color(0xFFFF6B00),
    routePath: RoutePaths.transactions,
    group: QuickActionGroup.transaction,
    isDefaultEnabled: true,
  ),
  // 4. Ngân sách chi tiêu -> Hồng Cánh Sen nổi bật (Rose Pink)
  QuickActionItemModel(
    id: 'budgets',
    label: 'Ngân sách',
    icon: Icons.calendar_month_rounded,
    bgColor: Color(0xFFF43F5E),
    routePath: RoutePaths.budgets,
    group: QuickActionGroup.planning,
    isDefaultEnabled: true,
  ),
  // 5. Chia tiền nhóm -> Xanh Ngọc Bích Cyber (Cyber Cyan)
  QuickActionItemModel(
    id: 'split_expenses',
    label: 'Chia tiền',
    icon: Icons.call_split_rounded,
    bgColor: Color(0xFF06B6D4),
    routePath: RoutePaths.splitExpenses,
    group: QuickActionGroup.planning,
    isDefaultEnabled: true,
  ),
  // 6. Sổ nợ & Cho vay -> Vàng Hổ Phách ấm áp (Warm Amber)
  QuickActionItemModel(
    id: 'loans',
    label: 'Sổ nợ',
    icon: Icons.handshake_rounded,
    bgColor: Color(0xFFF59E0B),
    routePath: RoutePaths.loans,
    group: QuickActionGroup.planning,
    isDefaultEnabled: true,
  ),
  // 7. Giao dịch định kỳ -> Xanh Lục Bảo tuần hoàn (Fresh Emerald)
  QuickActionItemModel(
    id: 'recurring',
    label: 'Định kỳ',
    icon: Icons.event_repeat_rounded,
    bgColor: Color(0xFF10B981),
    routePath: RoutePaths.recurringTransactions,
    group: QuickActionGroup.planning,
    isDefaultEnabled: true,
  ),
  // 8. Báo cáo & Phân tích -> Tím Neon Fuchsia sắc nét
  QuickActionItemModel(
    id: 'dashboard',
    label: 'Báo cáo',
    icon: Icons.pie_chart_rounded,
    bgColor: Color(0xFFD946EF),
    routePath: RoutePaths.dashboard,
    group: QuickActionGroup.management,
    isDefaultEnabled: true,
  ),
  // 9. Quản lý Ví tiền -> Xanh Coban Hải quân uy tín (Royal Cobalt)
  QuickActionItemModel(
    id: 'wallets',
    label: 'Ví tiền',
    icon: Icons.account_balance_wallet_rounded,
    bgColor: Color(0xFF2563EB),
    routePath: RoutePaths.wallets,
    group: QuickActionGroup.management,
    isDefaultEnabled: true,
  ),
  // 10. Quỹ nhóm / Ví chung -> Xanh Bạc Hà tươi mát (Mint Teal)
  QuickActionItemModel(
    id: 'shared_wallets',
    label: 'Quỹ nhóm',
    icon: Icons.groups_rounded,
    bgColor: Color(0xFF0D9488),
    routePath: RoutePaths.sharedWallets,
    group: QuickActionGroup.planning,
    isDefaultEnabled: true,
  ),
  // 11. Nhắn tin tài chính -> Xanh Da Trời Điện thoại (Electric Sky)
  QuickActionItemModel(
    id: 'social_chat',
    label: 'Tin nhắn',
    icon: Icons.chat_bubble_rounded,
    bgColor: Color(0xFF0284C7),
    routePath: RoutePaths.socialChat,
    group: QuickActionGroup.social,
    isDefaultEnabled: true,
  ),
  // 12. Danh mục thu chi -> Xanh Chuối Năng động (Energetic Lime)
  QuickActionItemModel(
    id: 'categories',
    label: 'Danh mục',
    icon: Icons.category_rounded,
    bgColor: Color(0xFF84CC16),
    routePath: RoutePaths.categorySettings,
    group: QuickActionGroup.management,
    isDefaultEnabled: true,
  ),

  // ── CÁC TIỆN ÍCH MỞ RỘNG (Người dùng có thể bật thêm) ──
  // 13. Tỷ giá ngoại tệ & Vàng -> Vàng Kim loại (Golden Yellow)
  QuickActionItemModel(
    id: 'exchange_rates',
    label: 'Tỷ giá',
    icon: Icons.currency_exchange_rounded,
    bgColor: Color(0xFFEAB308),
    routePath: RoutePaths.exchangeRates,
    group: QuickActionGroup.extended,
    isDefaultEnabled: false,
  ),
  // 14. Nora AI Chatbot Copilot -> Tím Trí Tuệ Sâu (Deep AI Purple)
  QuickActionItemModel(
    id: 'ai_chat',
    label: 'Nora AI',
    icon: Icons.auto_awesome_rounded,
    bgColor: Color(0xFF7C3AED),
    routePath: RoutePaths.aiChat,
    group: QuickActionGroup.extended,
    isDefaultEnabled: false,
  ),
  // 15. Bảng tin tài chính (Feed) -> Đỏ San Hô Nổi bật (Coral Orange)
  QuickActionItemModel(
    id: 'social_feed',
    label: 'Bảng tin',
    icon: Icons.dynamic_feed_rounded,
    bgColor: Color(0xFFFF5722),
    routePath: RoutePaths.socialFeed,
    group: QuickActionGroup.social,
    isDefaultEnabled: false,
  ),
  // 16. Bạn bè -> Xanh Băng Tuyết (Ice Blue)
  QuickActionItemModel(
    id: 'friends',
    label: 'Bạn bè',
    icon: Icons.people_alt_rounded,
    bgColor: Color(0xFF38BDF8),
    routePath: RoutePaths.friends,
    group: QuickActionGroup.social,
    isDefaultEnabled: false,
  ),
  // 17. Linh vật tài chính -> Đỏ Ruby Quyến rũ (Ruby Red)
  QuickActionItemModel(
    id: 'mascot',
    label: 'Linh vật',
    icon: Icons.pets_rounded,
    bgColor: Color(0xFFE11D48),
    routePath: RoutePaths.mascotShowcase,
    group: QuickActionGroup.extended,
    isDefaultEnabled: false,
  ),
  // 18. Báo cáo Dòng tiền chuyên sâu -> Xanh Nước Biển Sâu (Deep Ocean)
  QuickActionItemModel(
    id: 'cashflow_report',
    label: 'Dòng tiền',
    icon: Icons.waterfall_chart_rounded,
    bgColor: Color(0xFF1D4ED8),
    routePath: RoutePaths.cashflowReport,
    group: QuickActionGroup.management,
    isDefaultEnabled: false,
  ),
  // 19. Báo cáo Cơ cấu Danh mục chi tiêu -> Tím Mận Đậm (Plum Purple)
  QuickActionItemModel(
    id: 'category_report',
    label: 'Cơ cấu chi',
    icon: Icons.donut_small_rounded,
    bgColor: Color(0xFF9333EA),
    routePath: RoutePaths.categoryReport,
    group: QuickActionGroup.management,
    isDefaultEnabled: false,
  ),
  // 20. Hộp thư Thông báo -> Đỏ Báo Động (Bright Red)
  QuickActionItemModel(
    id: 'notifications',
    label: 'Thông báo',
    icon: Icons.notifications_rounded,
    bgColor: Color(0xFFEF4444),
    routePath: RoutePaths.notifications,
    group: QuickActionGroup.extended,
    isDefaultEnabled: false,
  ),
];
