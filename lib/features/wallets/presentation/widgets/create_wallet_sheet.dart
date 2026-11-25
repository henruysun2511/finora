import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/dto/create_wallet_request.dart';
import '../providers/wallet_providers.dart';
import '../providers/wallets_overview_provider.dart';

class CreateWalletSheet extends ConsumerStatefulWidget {
  const CreateWalletSheet({super.key});

  @override
  ConsumerState<CreateWalletSheet> createState() => _CreateWalletSheetState();
}

class _CreateWalletSheetState extends ConsumerState<CreateWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedIcon = '💼';
  String _selectedCurrency = 'VND';
  bool _isShared = false;
  bool _isLoading = false;

  final List<String> _icons = ['💼', '🏠', '✈️', '🛍️', '🎓', '💰', '🚗', '🏥'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final req = CreateWalletRequest(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        defaultCurrency: _selectedCurrency,
        isShared: _isShared,
      );

      final repo = ref.read(walletRepositoryProvider);
      await repo.createWallet(req);

      ref.invalidate(walletsOverviewProvider);
      if (mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Tạo không gian ví thành công!');
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
              Text(
                'Tạo Không gian Ví mới',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Một ví chứa nhiều nguồn tiền (tiền mặt, thẻ, ngân hàng)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Chọn Icon
              Text(
                'Biểu tượng ví:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final ic = _icons[index];
                    final isSel = ic == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = ic),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(ic, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Tên ví
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên không gian ví (*)',
                  hintText: 'VD: Quỹ gia đình, Chi tiêu cá nhân...',
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
                    return 'Vui lòng nhập tên ví';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Tiền tệ mặc định
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Đồng tiền cơ sở',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'VND', child: Text('VND (₫) - Đồng')),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('USD (\$) - Đô la Mỹ'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),
              const SizedBox(height: 14),

              // Toggle Ví dùng chung
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.group_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ví dùng chung (Shared Wallet)',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          Text(
                            'Cho phép mời thành viên gia đình hoặc nhóm bạn',
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
                    Switch(
                      value: _isShared,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isShared = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Button Submit
              AppButton(
                text: 'TẠO KHÔNG GIAN VÍ',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

