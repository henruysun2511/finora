import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../domain/models/account_model.dart';
import '../providers/account_detail_provider.dart';
import '../widgets/adjust_balance_dialog.dart';

/// Màn hình Chi tiết tài khoản nguồn tiền chuẩn FinTech
class AccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  bool _includeInTotal = true;
  bool _trackExpenses = true;

  void _openAdjustBalance(AccountModel? account) {
    if (account == null) {
      AppToast.error(context, 'Chưa tải xong dữ liệu tài khoản để đối soát');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AdjustBalanceDialog(account: account),
    );
  }

  void _confirmDelete(AccountModel? account) {
    final accountName = account?.name ?? 'tài khoản';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa tài khoản nguồn tiền?'),
        content: Text(
          'Dữ liệu tài khoản "$accountName" sẽ bị xóa khỏi ví. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (account != null) {
                try {
                  await ref
                      .read(accountDetailActionsProvider(account.id))
                      .deleteAccount(account.walletId);
                  if (mounted) {
                    AppToast.success(
                        context, 'Đã xóa tài khoản nguồn tiền thành công.');
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RoutePaths.wallets);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    AppToast.error(context, e.toString());
                  }
                }
              }
            },
            child: const Text(
              'XÓA TÀI KHOẢN',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(accountDetailProvider(widget.accountId));

    final account = detailAsync.valueOrNull?.account;
    final recentTxs = detailAsync.valueOrNull?.recentTransactions ?? [];

    final subtitle =
        account != null ? '${account.name} · ${account.type.displayName}' : 'Quản lý thông tin & số dư nguồn tiền';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Chi tiết tài khoản',
        subtitle: subtitle,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(accountDetailProvider(widget.accountId).future);
            ref.invalidate(walletsOverviewProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Thẻ Hero thông tin tài khoản nguồn tiền
                  _buildAccountHeroCard(isDark, account),

                  const SizedBox(height: 16),

                  // 2. Cài đặt bổ sung dạng Switch (Tuân thủ Quy chuẩn 3 GEMINI.md)
                  _buildSettingsCard(isDark),

                  const SizedBox(height: 20),

                  // 3. Nút Điều chỉnh số dư thực tế (Đối soát)
                  ElevatedButton.icon(
                    onPressed: () => _openAdjustBalance(account),
                    icon: const Icon(Icons.tune_rounded, color: Colors.white),
                    label: Text(
                      'Điều chỉnh số dư thực tế',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Nút Xóa tài khoản nguồn tiền
                  TextButton.icon(
                    onPressed: () => _confirmDelete(account),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger, size: 20),
                    label: Text(
                      'Xóa tài khoản nguồn tiền này',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // 5. Danh sách giao dịch gần đây
                  if (recentTxs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'GIAO DỊCH GẦN ĐÂY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: recentTxs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final tx = entry.value;
                          final isLast = idx == recentTxs.length - 1;
                          final isIncome = tx.type == 'INCOME';

                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (isIncome
                                            ? AppColors.success
                                            : AppColors.danger)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isIncome
                                        ? AppColors.success
                                        : AppColors.danger,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  tx.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkForeground
                                        : AppColors.lightForeground,
                                  ),
                                ),
                                subtitle: Text(
                                  '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: isIncome
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Thẻ Hero thông tin tài khoản nguồn tiền
  Widget _buildAccountHeroCard(bool isDark, AccountModel? account) {
    final title = account?.name ?? 'Chi tiết tài khoản';
    final balanceText = account != null
        ? CurrencyFormatter.format(account.balance, currency: account.currency)
        : CurrencyFormatter.format(0, currency: 'VND');
    final cardLast4 = account?.accountNumberLast4 != null &&
            account!.accountNumberLast4!.isNotEmpty
        ? '•••• ${account.accountNumberLast4}'
        : null;
    final typeLabel = account?.type.displayName ?? 'Nguồn tiền';
    final displayColor = account?.displayColor ?? AppColors.primary;
    final displayIcon =
        account?.displayIcon ?? Icons.account_balance_wallet_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF0F172A).withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon đại diện của tài khoản
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: displayColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: displayColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              displayIcon,
              color: displayColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),

          // Tên tài khoản
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),

          // Phân loại nguồn tiền & 4 số cuối
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                typeLabel,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              if (cardLast4 != null) ...[
                const SizedBox(width: 6),
                Text(
                  '•',
                  style: TextStyle(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  cardLast4,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Khối số dư nổi bật
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'SỐ DƯ HIỆN TẠI',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    balanceText,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trạng thái hoạt động
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Đang hoạt động',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Khối Cài đặt bổ sung dạng Switch chuẩn Quy chuẩn 3 GEMINI.md
  Widget _buildSettingsCard(bool isDark) {
    return FormCard(
      title: 'Cài đặt bổ sung',
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            title: Text(
              'Tính vào tổng tài sản',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            subtitle: Text(
              'Bao gồm số dư nguồn tiền này khi tính tổng tài sản ròng',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            value: _includeInTotal,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _includeInTotal = val),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.insights_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            title: Text(
              'Theo dõi phân tích chi tiêu',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkForeground
                    : AppColors.lightForeground,
              ),
            ),
            subtitle: Text(
              'Ghi nhận các giao dịch từ nguồn tiền này vào báo cáo tài chính',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              ),
            ),
            value: _trackExpenses,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _trackExpenses = val),
          ),
        ],
      ),
    );
  }
}
