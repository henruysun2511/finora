import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../accounts/data/dto/create_account_request.dart';
import '../../../accounts/domain/enums/account_type.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../data/dto/create_wallet_request.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallet_providers.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Thêm tài khoản ngân hàng chuẩn 1:1 theo `device-preview/screens/accounts/add.html`
class CreateAccountScreen extends ConsumerStatefulWidget {
  final String? walletId;

  const CreateAccountScreen({super.key, this.walletId});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final List<Map<String, dynamic>> _banks = [
    {
      'name': 'Vietcombank',
      'app': 'VCB Digibank',
      'color': const Color(0xFF0072D5),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Techcombank',
      'app': 'TCB Mobile',
      'color': const Color(0xFFEF4444),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'MB Bank',
      'app': 'Quân Đội',
      'color': const Color(0xFF2563EB),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'VPBank',
      'app': 'VPBank NEO',
      'color': const Color(0xFF16A34A),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'MoMo',
      'app': 'Ví điện tử MoMo',
      'color': const Color(0xFFA50064),
      'icon': Icons.smartphone_rounded,
    },
    {
      'name': 'ZaloPay',
      'app': 'Ví điện tử ZaloPay',
      'color': const Color(0xFF0088FF),
      'icon': Icons.smartphone_rounded,
    },
  ];

  Future<String> _resolveWalletId() async {
    if (widget.walletId != null && widget.walletId!.isNotEmpty) {
      return widget.walletId!;
    }
    final overview = ref.read(walletsOverviewProvider).valueOrNull;
    if (overview != null && overview.wallets.isNotEmpty) {
      return overview.wallets.first.id;
    }
    try {
      final wallets = await ref.read(walletRepositoryProvider).getWallets();
      if (wallets.isNotEmpty) {
        return wallets.first.id;
      }
    } catch (_) {}

    final newWallet = await ref.read(walletRepositoryProvider).createWallet(
          const CreateWalletRequest(
            name: 'Ví Cá nhân',
            defaultCurrency: 'VND',
          ),
        );
    return newWallet.id;
  }

  Future<void> _selectBank(String bankName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Đang kết nối tới $bankName...',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chuyển sang cổng xác thực an toàn chuẩn 256-bit SSL...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final walletId = await _resolveWalletId();
      final isEWallet = bankName.toLowerCase().contains('momo') ||
          bankName.toLowerCase().contains('zalopay');
      final type = isEWallet ? AccountType.ewallet : AccountType.bank;

      final account = await ref.read(accountRepositoryProvider).createAccount(
            CreateAccountRequest(
              walletId: walletId,
              name: bankName,
              type: type,
              currency: 'VND',
              initialBalance: 0.0,
              accountNumberLast4: '8899',
            ),
          );

      if (mounted) {
        Navigator.pop(context); // Đóng dialog đang kết nối
        ref.invalidate(walletsOverviewProvider);
        ref.invalidate(walletDetailProvider(walletId));
        AppToast.success(context, 'Đã liên kết thành công tài khoản $bankName!');
        context.push(RoutePaths.accountDetailWithId(account.id));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        AppToast.error(context, e.toString());
      }
    }
  }

  void _openManualDialog() {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final balCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thêm tài khoản thủ công',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên nguồn tiền / Thẻ',
                hintText: 'VD: Thẻ Visa ACB, Tiền tiết kiệm...',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '4 số cuối tài khoản / thẻ (tùy chọn)',
                hintText: 'VD: 6789',
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: balCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư ban đầu (₫)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  AppToast.error(context, 'Vui lòng nhập tên tài khoản');
                  return;
                }
                final cleanBal = balCtrl.text
                    .replaceAll(',', '')
                    .replaceAll('.', '')
                    .replaceAll(' ', '')
                    .trim();
                final bal = double.tryParse(cleanBal) ?? 0.0;
                final last4 =
                    numCtrl.text.trim().isNotEmpty ? numCtrl.text.trim() : null;

                try {
                  final walletId = await _resolveWalletId();
                  final account = await ref
                      .read(accountRepositoryProvider)
                      .createAccount(
                        CreateAccountRequest(
                          walletId: walletId,
                          name: name,
                          type: AccountType.bank,
                          currency: 'VND',
                          initialBalance: bal,
                          accountNumberLast4: last4,
                        ),
                      );

                  if (mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(walletsOverviewProvider);
                    ref.invalidate(walletDetailProvider(walletId));
                    AppToast.success(context, 'Đã thêm nguồn tiền thành công!');
                    context.push(RoutePaths.accountDetailWithId(account.id));
                  }
                } catch (e) {
                  if (mounted) {
                    AppToast.error(context, e.toString());
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Thêm tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: PageHeader.subPage(
        title: 'Liên kết Ngân hàng',
        subtitle: 'Kết nối Open Banking & Ví điện tử',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Chọn ngân hàng của bạn để kết nối tự động:',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Grid 2x2 ngân hàng
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.35,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _banks.length,
                      itemBuilder: (context, index) {
                        final bank = _banks[index];
                        return InkWell(
                          onTap: () => _selectBank(bank['name'] as String),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  bank['icon'] as IconData,
                                  color: bank['color'] as Color,
                                  size: 26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bank['name'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: bank['color'] as Color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bank['app'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Tùy chọn thêm thủ công
                    OutlinedButton.icon(
                      onPressed: _openManualDialog,
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                      label: Text(
                        'Thêm nguồn tiền thủ công',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
