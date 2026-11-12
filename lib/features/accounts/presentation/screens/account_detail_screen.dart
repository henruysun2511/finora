import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../domain/models/account_model.dart';
import '../providers/account_detail_provider.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../widgets/adjust_balance_dialog.dart';

/// Màn hình Chi tiết tài khoản & Đồng bộ Open Banking chuẩn 1:1 theo `device-preview/screens/accounts/detail.html`
class AccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  bool _autoReadTx = true;
  bool _aiNoraCategorize = true;
  bool _isSyncing = false;

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

  Future<void> _syncNow(AccountModel? account) async {
    setState(() => _isSyncing = true);
    try {
      await ref.refresh(accountDetailProvider(widget.accountId).future);
      ref.invalidate(walletsOverviewProvider);
      if (mounted) {
        AppToast.success(
          context,
          'Đã ép làm mới và tải các giao dịch mới nhất từ ${account?.name ?? 'Ngân hàng'}!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _confirmUnlink(AccountModel? account) {
    final accountName = account?.name ?? 'tài khoản';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hủy liên kết tài khoản?'),
        content: Text(
          'Dữ liệu giao dịch đã đồng bộ của "$accountName" sẽ được giữ lại, nhưng hệ thống sẽ dừng tự động đọc biến động số dư.',
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
                    AppToast.success(context, 'Đã hủy liên kết Open Banking thành công.');
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
              } else {
                AppToast.success(context, 'Đã hủy liên kết Open Banking thành công.');
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.wallets);
                }
              }
            },
            child: const Text('HỦY LIÊN KẾT', style: TextStyle(color: AppColors.danger)),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: PageHeader.subPage(
        title: 'Đồng bộ Open Banking',
        subtitle: 'Vietcombank API Sync',
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
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──────────────── 1. BODY CONTENT ──────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Card: Trạng thái kết nối Open Banking
                      _buildSyncStatusCard(isDark, account),

                      const SizedBox(height: 16),

                      // Card Tùy chọn cấu hình đồng bộ
                      _buildSettingsCard(isDark),

                      const SizedBox(height: 24),

                      // Nút: Đồng bộ ngay bây giờ
                      ElevatedButton.icon(
                        onPressed: _isSyncing ? null : () => _syncNow(account),
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync_rounded, color: Colors.white),
                        label: Text(
                          _isSyncing ? 'Đang đồng bộ...' : 'Đồng bộ ngay bây giờ',
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

                      // Nút phụ: Điều chỉnh số dư đối soát thực tế
                      OutlinedButton.icon(
                        onPressed: () => _openAdjustBalance(account),
                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                        label: Text(
                          'Điều chỉnh số dư thực tế',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Nút: Hủy liên kết tài khoản
                      TextButton(
                        onPressed: () => _confirmUnlink(account),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Hủy liên kết tài khoản',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.danger,
                          ),
                        ),
                      ),

                      if (recentTxs.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'GIAO DỊCH GẦN ĐÂY',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: recentTxs.map((tx) {
                              final isIncome = tx.type == 'INCOME';
                              return ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: (isIncome ? AppColors.success : AppColors.danger)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                    color: isIncome ? AppColors.success : AppColors.danger,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  tx.title,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isIncome ? AppColors.success : AppColors.danger,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(bool isDark, AccountModel? account) {
    final title = account?.name ?? 'Chi tiết tài khoản';
    final balanceText = account != null
        ? CurrencyFormatter.format(account.balance, currency: account.currency)
        : CurrencyFormatter.format(0, currency: 'VND');
    final cardLast4 = account?.accountNumberLast4 != null
        ? '•••• ${account!.accountNumberLast4}'
        : account?.type.displayName ?? 'Tài khoản Finora';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$cardLast4 · Số dư: $balanceText',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kết nối trực tiếp chuẩn bảo mật 256-bit SSL',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Đang kết nối tự động (Real-time)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
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

  Widget _buildSettingsCard(bool isDark) {
    return FormCard(
      title: 'Cài đặt đồng bộ',
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Tự động đọc biến động số dư',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
              ),
            ),
            value: _autoReadTx,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _autoReadTx = val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'AI Nora tự gán danh mục',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkForeground : const Color(0xFF334155),
              ),
            ),
            value: _aiNoraCategorize,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _aiNoraCategorize = val),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lần đồng bộ cuối',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '12:30 hôm nay',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
