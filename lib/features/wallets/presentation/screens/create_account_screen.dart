import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/form_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../accounts/data/dto/create_account_request.dart';
import '../../../accounts/domain/enums/account_type.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../../data/dto/create_wallet_request.dart';
import '../providers/wallet_detail_provider.dart';
import '../providers/wallet_providers.dart';
import '../providers/wallets_overview_provider.dart';

/// Màn hình Thêm tài khoản nguồn tiền (chuẩn form nhập liệu FinTech)
class CreateAccountScreen extends ConsumerStatefulWidget {
  final String? walletId;

  const CreateAccountScreen({super.key, this.walletId});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _last4Controller = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');

  String? _selectedWalletId;
  AccountType _selectedType = AccountType.bank;
  String _selectedCurrency = 'VND';
  String _selectedColor = '#0072D5';
  String _selectedIcon = 'bank';
  bool _isLoading = false;

  final List<String> _colors = [
    '#0072D5',
    '#10B981',
    '#A50064',
    '#F59E0B',
    '#8B5CF6',
    '#06B6D4',
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {
      'key': 'bank',
      'icon': Icons.account_balance_rounded,
      'label': 'Ngân hàng'
    },
    {
      'key': 'wallet',
      'icon': Icons.account_balance_wallet_rounded,
      'label': 'Ví ĐT',
    },
    {'key': 'cash', 'icon': Icons.payments_rounded, 'label': 'Tiền mặt'},
    {'key': 'card', 'icon': Icons.credit_card_rounded, 'label': 'Tín dụng'},
    {'key': 'savings', 'icon': Icons.savings_rounded, 'label': 'Tiết kiệm'},
    {'key': 'store', 'icon': Icons.storefront_rounded, 'label': 'Cửa hàng'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.walletId;
    _syncIconAndColor(_selectedType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _syncIconAndColor(AccountType type) {
    switch (type) {
      case AccountType.bank:
        _selectedColor = '#0072D5';
        _selectedIcon = 'bank';
        break;
      case AccountType.cash:
        _selectedColor = '#10B981';
        _selectedIcon = 'cash';
        break;
      case AccountType.ewallet:
        _selectedColor = '#A50064';
        _selectedIcon = 'wallet';
        break;
      case AccountType.credit:
        _selectedColor = '#F59E0B';
        _selectedIcon = 'card';
        break;
    }
  }

  Future<String> _resolveWalletId() async {
    if (_selectedWalletId != null && _selectedWalletId!.isNotEmpty) {
      return _selectedWalletId!;
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final walletId = await _resolveWalletId();
      final cleanBal = _initialBalanceController.text
          .replaceAll(',', '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .trim();
      final initialBal = double.tryParse(cleanBal) ?? 0.0;
      final last4 = _last4Controller.text.trim().isNotEmpty
          ? _last4Controller.text.trim()
          : null;

      final req = CreateAccountRequest(
        walletId: walletId,
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: initialBal,
        accountNumberLast4: last4,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      final account =
          await ref.read(accountRepositoryProvider).createAccount(req);

      ref.invalidate(walletsOverviewProvider);
      ref.invalidate(walletDetailProvider(walletId));

      if (mounted) {
        AppToast.success(context, 'Thêm tài khoản nguồn tiền thành công!');
        if (context.canPop()) {
          context.pop();
        } else {
          context.pushReplacement(RoutePaths.accountDetailWithId(account.id));
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getNameHint() {
    switch (_selectedType) {
      case AccountType.bank:
        return 'VD: Vietcombank Digibank, Techcombank...';
      case AccountType.cash:
        return 'VD: Tiền mặt trong ví, Heo đất...';
      case AccountType.ewallet:
        return 'VD: Ví MoMo, ZaloPay, ShopeePay...';
      case AccountType.credit:
        return 'VD: Thẻ Visa ACB, HSBC Platinum...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletsAsync = ref.watch(walletsOverviewProvider);
    final wallets = walletsAsync.valueOrNull?.wallets ?? [];

    final hasMatching = wallets.any((w) => w.id == _selectedWalletId);
    final effectiveWalletId = hasMatching
        ? _selectedWalletId
        : (wallets.isNotEmpty ? wallets.first.id : _selectedWalletId);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Thêm tài khoản nguồn tiền',
        subtitle: 'Tạo tài khoản ngân hàng, ví điện tử hoặc tiền mặt',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.wallets);
          }
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // THẺ 1: VÍ CHỨA NGUỒN TIỀN
              FormCard(
                title: 'Ví chứa nguồn tiền',
                child: wallets.isEmpty
                    ? Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sẽ tự động liên kết với Ví Cá nhân mặc định',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                            ),
                          ),
                        ],
                      )
                    : DropdownButtonFormField<String>(
                        value: effectiveWalletId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Chọn ví chứa nguồn tiền (*)',
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkBackground
                              : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                        ),
                        items: wallets.map((w) {
                          return DropdownMenuItem<String>(
                            value: w.id,
                            child: Row(
                              children: [
                                Icon(
                                  w.isShared
                                      ? Icons.group_rounded
                                      : Icons.account_balance_wallet_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${w.name} (${w.isShared ? "Quỹ nhóm" : "Cá nhân"})',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedWalletId = val);
                          }
                        },
                      ),
              ),

              // THẺ 2: LOẠI NGUỒN TIỀN
              FormCard(
                title: 'Loại nguồn tiền',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AccountType.values.map((type) {
                    final isSelected = type == _selectedType;
                    return ChoiceChip(
                      showCheckmark: false,
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor:
                          isDark ? AppColors.darkSurface : Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      avatar: Icon(
                        type.defaultIcon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted),
                      ),
                      label: Text(
                        type.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground),
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedType = type;
                            _syncIconAndColor(type);
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),

              // THẺ 3: THÔNG TIN CHI TIẾT NGUỒN TIỀN
              FormCard(
                title: 'Thông tin tài khoản',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tên tài khoản
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên nguồn tiền / Đơn vị (*)',
                        hintText: _getNameHint(),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Vui lòng nhập tên nguồn tiền';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4 số cuối tài khoản / thẻ
                    TextFormField(
                      controller: _last4Controller,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '4 số cuối số thẻ / tài khoản (Tùy chọn)',
                        hintText: 'VD: 6868',
                        counterText: '',
                        prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Số dư ban đầu & Đơn vị tiền tệ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _initialBalanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Số dư ban đầu (*)',
                              hintText: 'VD: 5000000',
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Vui lòng nhập số dư';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCurrency,
                            decoration: InputDecoration(
                              labelText: 'Tiền tệ',
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkBackground
                                  : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'VND', child: Text('₫ VND')),
                              DropdownMenuItem(
                                  value: 'USD', child: Text('\$ USD')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCurrency = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // THẺ 4: TÙY BIẾN NHẬN DIỆN
              FormCard(
                title: 'Nhận diện & Màu sắc',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu tượng:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _iconOptions.map((opt) {
                          final isSel = opt['key'] == _selectedIcon;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _selectedIcon = opt['key']),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primary
                                          .withValues(alpha: 0.15)
                                      : (isDark
                                          ? AppColors.darkBackground
                                          : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      opt['icon'] as IconData,
                                      size: 18,
                                      color: isSel
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkMuted
                                              : AppColors.lightMuted),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                        child: Text(
                                      opt['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: isSel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSel
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkForeground
                                                : AppColors.lightForeground),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Màu sắc đại diện:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _colors.map((c) {
                        final isSel =
                            c.toLowerCase() == _selectedColor.toLowerCase();
                        final colorVal =
                            Color(int.parse('0xFF${c.replaceAll('#', '')}'));
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: colorVal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSel ? Colors.white : Colors.transparent,
                                width: 2.5,
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
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // NÚT SUBMIT: THÊM TÀI KHOẢN
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded,
                              size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Thêm tài khoản nguồn tiền',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
