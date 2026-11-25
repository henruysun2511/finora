import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../../wallets/domain/models/wallet_model.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';

/// Một dòng trong danh sách: tiêu đề ví hoặc tài khoản
class _PickerEntry {
  final WalletModel? walletHeader;
  final AccountModel? account;
  final WalletModel? wallet;

  const _PickerEntry.wallet(WalletModel this.walletHeader)
      : account = null,
        wallet = null;

  const _PickerEntry.account(AccountModel this.account, WalletModel this.wallet)
      : walletHeader = null;
}

/// BottomSheet chọn tài khoản nguồn hoặc tài khoản đích.
///
/// Danh sách được lọc theo ví: [initialWalletId] là ví được chọn sẵn,
/// người dùng vẫn có thể đổi sang ví khác hoặc xem "Tất cả ví".
class AccountPickerSheet extends ConsumerStatefulWidget {
  final String title;
  final String? selectedAccountId;
  final String? excludedAccountId;
  final String? initialWalletId;

  const AccountPickerSheet({
    super.key,
    required this.title,
    this.selectedAccountId,
    this.excludedAccountId,
    this.initialWalletId,
  });

  static Future<AccountModel?> show(
    BuildContext context, {
    required String title,
    String? selectedAccountId,
    String? excludedAccountId,
    String? initialWalletId,
  }) {
    return showModalBottomSheet<AccountModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountPickerSheet(
        title: title,
        selectedAccountId: selectedAccountId,
        excludedAccountId: excludedAccountId,
        initialWalletId: initialWalletId,
      ),
    );
  }

  @override
  ConsumerState<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends ConsumerState<AccountPickerSheet> {
  final _searchController = TextEditingController();
  String _keyword = '';
  String? _walletIdFilter;

  @override
  void initState() {
    super.initState();
    _walletIdFilter = widget.initialWalletId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelectable(AccountModel acc) {
    if (widget.excludedAccountId != null &&
        acc.id == widget.excludedAccountId) {
      return false;
    }
    if (acc.isArchived) return false;
    if (_keyword.isEmpty) return true;
    return acc.name.toLowerCase().contains(_keyword) ||
        acc.currency.toLowerCase().contains(_keyword);
  }

  Widget _walletChip(WalletModel? wallet, String label, bool isDark) {
    final selected = _walletIdFilter == wallet?.id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _walletIdFilter = wallet?.id),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overviewAsync = ref.watch(walletsOverviewProvider);
    final walletItems =
        overviewAsync.valueOrNull?.items ?? const <WalletItemState>[];

    // Chỉ hiển thị ví còn tài khoản khả dụng
    final availableWallets =
        walletItems.where((item) => item.allAccounts.any(_isSelectable)).toList();

    // Ví đã chọn không còn khả dụng thì quay về "Tất cả ví"
    final effectiveWalletId = availableWallets
            .any((item) => item.wallet.id == _walletIdFilter)
        ? _walletIdFilter
        : null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _keyword = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tài khoản...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Bộ lọc theo ví
            if (availableWallets.isNotEmpty) ...[
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _walletChip(null, 'Tất cả ví', isDark),
                    for (final item in availableWallets)
                      _walletChip(item.wallet, item.wallet.name, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // List Accounts
            Flexible(
              child: overviewAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Lỗi: $err',
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                ),
                data: (_) {
                  // Gom tài khoản khả dụng, nhóm theo ví khi xem "Tất cả ví"
                  final entries = <_PickerEntry>[];
                  for (final item in availableWallets) {
                    if (effectiveWalletId != null &&
                        item.wallet.id != effectiveWalletId) {
                      continue;
                    }
                    final accounts =
                        item.allAccounts.where(_isSelectable).toList();
                    if (accounts.isEmpty) continue;
                    if (effectiveWalletId == null) {
                      entries.add(_PickerEntry.wallet(item.wallet));
                    }
                    for (final acc in accounts) {
                      entries.add(_PickerEntry.account(acc, item.wallet));
                    }
                  }

                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      child: Center(
                        child: Text(
                          _keyword.isEmpty
                              ? 'Không có tài khoản khả dụng'
                              : 'Không tìm thấy tài khoản phù hợp',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];

                      // Tiêu đề nhóm ví
                      final headerWallet = entry.walletHeader;
                      if (headerWallet != null) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 4 : 16,
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 15,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  headerWallet.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.lightMuted,
                                  ),
                                ),
                              ),
                              if (headerWallet.isShared)
                                Text(
                                  'Ví chung',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      final acc = entry.account!;
                      final isSelected = acc.id == widget.selectedAccountId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => Navigator.pop(context, acc),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : (isDark
                                      ? AppColors.darkBackground
                                      : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        acc.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkForeground
                                              : AppColors.lightForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        acc.currency,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.darkMuted
                                              : AppColors.lightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(
                                        acc.balance,
                                        currency: acc.currency,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkForeground
                                            : AppColors.lightForeground,
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
