import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum NotificationType {
  // Ngân sách
  budgetWarning('BUDGET_WARNING', 'Cảnh báo ngân sách', Icons.warning_amber_rounded, Color(0xFFF59E0B)),
  budgetExceeded('BUDGET_EXCEEDED', 'Vượt quá ngân sách', Icons.error_outline_rounded, Color(0xFFEF4444)),

  // Giao dịch định kỳ & Vay nợ
  recurringExecuted('RECURRING_EXECUTED', 'Giao dịch định kỳ', Icons.repeat_rounded, AppColors.primary),
  loanDue('LOAN_DUE', 'Khoản nợ sắp đến hạn', Icons.event_note_rounded, Color(0xFFE11D48)),
  loanPaymentReceived('LOAN_PAYMENT_RECEIVED', 'Nhận tiền trả nợ', Icons.payments_rounded, Color(0xFF10B981)),

  // Tiết kiệm & Hạng tài sản
  savingsGoalCompleted('SAVINGS_GOAL_COMPLETED', 'Mục tiêu hoàn thành', Icons.savings_rounded, Color(0xFF10B981)),
  savingsGoalMilestone('SAVINGS_GOAL_MILESTONE', 'Cột mốc tiết kiệm', Icons.star_rounded, Color(0xFFF59E0B)),
  assetTierUp('ASSET_TIER_UP', 'Thăng hạng tài sản', Icons.trending_up_rounded, Color(0xFF8B5CF6)),
  assetTierDown('ASSET_TIER_DOWN', 'Hạ hạng tài sản', Icons.trending_down_rounded, Color(0xFF6B7280)),

  // Ví chung & Thành viên
  walletInvite('WALLET_INVITE', 'Lời mời ví chung', Icons.mail_outline_rounded, Color(0xFF0072D6)),
  walletMemberChanged('WALLET_MEMBER_CHANGED', 'Thành viên ví chung', Icons.group_rounded, Color(0xFF3B82F6)),

  // Bạn bè & Xã hội
  friendRequest('FRIEND_REQUEST', 'Lời mời kết bạn', Icons.person_add_rounded, Color(0xFF06B6D4)),
  friendAccepted('FRIEND_ACCEPTED', 'Chấp nhận kết bạn', Icons.how_to_reg_rounded, Color(0xFF10B981)),
  friendTransactionPosted('FRIEND_TRANSACTION_POSTED', 'Giao dịch từ bạn bè', Icons.feed_rounded, Color(0xFF3B82F6)),
  postReacted('POST_REACTED', 'Tương tác bài đăng', Icons.favorite_rounded, Color(0xFFEC4899)),

  // Tin nhắn
  newDirectMessage('NEW_DIRECT_MESSAGE', 'Tin nhắn mới', Icons.chat_bubble_outline_rounded, Color(0xFF0072D6)),
  messageReacted('MESSAGE_REACTED', 'Thả cảm xúc', Icons.thumb_up_rounded, Color(0xFFF59E0B)),

  // Chia tiền nhóm
  splitRequest('SPLIT_REQUEST', 'Yêu cầu chia tiền', Icons.call_split_rounded, Color(0xFF8B5CF6)),
  splitProposal('SPLIT_PROPOSAL', 'Đề xuất chia tiền', Icons.receipt_long_rounded, Color(0xFF8B5CF6)),
  splitAccepted('SPLIT_ACCEPTED', 'Đã đồng ý chia tiền', Icons.check_circle_rounded, Color(0xFF10B981)),
  splitConfirmed('SPLIT_CONFIRMED', 'Xác nhận thanh toán nhóm', Icons.done_all_rounded, Color(0xFF10B981)),

  // Hệ thống & Bảo mật
  securityAlert('SECURITY_ALERT', 'Cảnh báo bảo mật', Icons.shield_rounded, Color(0xFFDC2626)),
  systemAnnouncement('SYSTEM_ANNOUNCEMENT', 'Thông báo hệ thống', Icons.campaign_rounded, Color(0xFF06B6D4)),

  // Chung
  general('GENERAL', 'Thông báo chung', Icons.notifications_rounded, AppColors.primary);

  const NotificationType(this.backendValue, this.displayName, this.icon, this.color);

  final String backendValue;
  final String displayName;
  final IconData icon;
  final Color color;

  static NotificationType fromBackend(String? value) {
    if (value == null) return NotificationType.general;
    return NotificationType.values.firstWhere(
      (e) => e.backendValue.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationType.general,
    );
  }
}

