import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../wallets/presentation/providers/wallet_detail_provider.dart';
import '../../../wallets/presentation/providers/wallets_overview_provider.dart';
import '../../data/dto/create_account_request.dart';
import '../../domain/enums/account_type.dart';
import '../providers/account_providers.dart';

class CreateAccountSheet extends ConsumerStatefulWidget {
  final String? defaultWalletId;

  const CreateAccountSheet({super.key, this.defaultWalletId});

  @override
  ConsumerState<CreateAccountSheet> createState() => _CreateAccountSheetState();
}

class _CreateAccountSheetState extends ConsumerState<CreateAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _last4Controller = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');

  String? _selectedWalletId;
  AccountType _selectedType = AccountType.bank;
  String _selectedCurrency = 'VND';
  String _selectedColor = '#0072d5';
  String _selectedIcon = 'bank';
  bool _isLoading = false;

  final List<String> _colors = ['#0072d5', '#10B981', '#A50064', '#F59E0B'];

  final List<Map<String, dynamic>> _iconOptions = [
    {'key': 'bank', 'icon': Icons.account_balance_rounded},
    {'key': 'card', 'icon': Icons.credit_card_rounded},
    {'key': 'wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'key': 'cash', 'icon': Icons.payments_rounded},
    {'key': 'savings', 'icon': Icons.savings_rounded},
    {'key': 'store', 'icon': Icons.storefront_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.defaultWalletId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String? defaultWalletId) async {
    if (!_formKey.currentState!.validate()) return;

    final targetWalletId = _selectedWalletId ?? defaultWalletId;
    if (targetWalletId == null || targetWalletId.isEmpty) {
      AppToast.error(context, 'Vui lòng chọn ví chứa tài khoản này');
      return;
    }

    final initBalance =
        double.tryParse(
          _initialBalanceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;

    setState(() => _isLoading = true);
    try {
      final req = CreateAccountRequest(
        walletId: targetWalletId,
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: initBalance,
        accountNumberLast4: _last4Controller.text.trim().isNotEmpty
            ? _last4Controller.text.trim()
            : null,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      final repo = ref.read(accountRepositoryProvider);
      await repo.createAccount(req);

      ref.invalidate(walletsOverviewProvider);
      ref.invalidate(walletDetailProvider(targetWalletId));

      if (mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Tạo tài khoản thành công!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletsAsync = ref.watch(walletsOverviewProvider);
    final wallets = walletsAsync.valueOrNull?.items ?? [];

    final hasMatchingWallet =
        wallets.any((w) => w.wallet.id == _selectedWalletId);
    final effectiveWalletId = hasMatchingWallet
        ? _selectedWalletId
        : (wallets.isNotEmpty ? wallets.first.wallet.id : null);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thêm tài khoản mới',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chọn ví chứa
              if (walletsAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: AppShimmer(height: 52, borderRadius: 12),
                )
              else if (wallets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chưa có Không gian Ví nào. Vui lòng tạo ví trước!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: effectiveWalletId,
                  decoration: InputDecoration(
                    labelText: 'Chọn ví chứa tài khoản (*)',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: wallets.map((w) {
                    return DropdownMenuItem<String>(
                      value: w.wallet.id,
                      child: Row(
                        children: [
                          Text(w.wallet.icon ?? '💼'),
                          const SizedBox(width: 8),
                          Text(w.wallet.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedWalletId = val);
                  },
                  validator: (val) => val == null ? 'Vui lòng chọn ví' : null,
                ),
              const SizedBox(height: 16),

              // Chọn loại tài khoản
              Text(
                'Loại tài khoản (*):',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AccountType.values.map((t) {
                  final isSel = t == _selectedType;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          t.defaultIcon,
                          size: 16,
                          color: isSel ? Colors.white : t.defaultColor,
                        ),
                        const SizedBox(width: 6),
                        Text(t.displayName),
                      ],
                    ),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedType = t;
                          if (t == AccountType.bank) {
                            _selectedColor = '#0072d5';
                            _selectedIcon = 'bank';
                          } else if (t == AccountType.ewallet) {
                            _selectedColor = '#A50064';
                            _selectedIcon = 'wallet';
                          } else if (t == AccountType.cash) {
                            _selectedColor = '#10B981';
                            _selectedIcon = 'cash';
                          } else if (t == AccountType.credit) {
                            _selectedColor = '#F59E0B';
                            _selectedIcon = 'card';
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Tên tài khoản
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Đơn vị phát hành / Tên tài khoản (*)',
                  hintText: 'VD: Vietcombank, MB Bank, MoMo, Tiền mặt...',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên tài khoản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 4 số cuối
              TextFormField(
                controller: _last4Controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: '4 số cuối số thẻ/tài khoản (Tùy chọn)',
                  hintText: 'VD: 6789',
                  counterText: '',
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Số dư ban đầu
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Số dư ban đầu (*)',
                  hintText: '5000000',
                  suffixText: _selectedCurrency,
                  helperText: 'Số dư tại thời điểm bắt đầu theo dõi trên Finora',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số dư ban đầu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Đơn vị tiền tệ
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Đơn vị tiền tệ',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'VND', child: Text('VND - Đồng Việt Nam')),
                  DropdownMenuItem(value: 'USD', child: Text('USD - Đô la Mỹ')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),
              const SizedBox(height: 16),

              // Chọn biểu tượng & Mã màu
              Text(
                'Chọn biểu tượng & Mã màu hiển thị:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ..._iconOptions.map((opt) {
                    final isSel = opt['key'] == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = opt['key']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          opt['icon'] as IconData,
                          size: 18,
                          color: isSel
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),

              // Color choices
              Row(
                children: _colors.map((c) {
                  final isSel = c == _selectedColor;
                  final colorVal = Color(
                    int.parse('0xFF${c.replaceAll('#', '')}'),
                  );
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorVal,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSel ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: colorVal.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSel
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Button Create
              AppButton(
                text: 'TẠO TÀI KHOẢN',
                isLoading: _isLoading,
                onPressed: () => _handleSubmit(effectiveWalletId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

