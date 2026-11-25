import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../friends/domain/models/friend.dart';
import '../../../friends/presentation/providers/friends_list_provider.dart';
import '../../../split_expenses/presentation/providers/split_providers.dart';
import '../../domain/models/transaction_item.dart';

enum SplitMode { equal, custom }

class SplitBillBottomSheet extends ConsumerStatefulWidget {
  const SplitBillBottomSheet({
    super.key,
    required this.transaction,
    this.onSplitCreated,
  });

  final TransactionItem transaction;
  final VoidCallback? onSplitCreated;

  static Future<bool?> show(
    BuildContext context, {
    required TransactionItem transaction,
    VoidCallback? onSplitCreated,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SplitBillBottomSheet(
        transaction: transaction,
        onSplitCreated: onSplitCreated,
      ),
    );
  }

  @override
  ConsumerState<SplitBillBottomSheet> createState() =>
      _SplitBillBottomSheetState();
}

class _SplitBillBottomSheetState extends ConsumerState<SplitBillBottomSheet> {
  SplitMode _mode = SplitMode.equal;
  final Set<String> _selectedFriendIds = {};
  final Map<String, TextEditingController> _customAmountControllers = {};
  bool _isSubmitting = false;
  String _searchQuery = '';

  @override
  void dispose() {
    for (final c in _customAmountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String friendId, double defaultVal) {
    if (!_customAmountControllers.containsKey(friendId)) {
      _customAmountControllers[friendId] = TextEditingController(
        text: defaultVal > 0 ? defaultVal.round().toString() : '',
      );
    }
    return _customAmountControllers[friendId]!;
  }

  double _calculateOwnerShare(double totalAmount) {
    if (_mode == SplitMode.equal) {
      final totalPeople = _selectedFriendIds.length + 1;
      return (totalAmount / totalPeople).roundToDouble();
    } else {
      double totalAssigned = 0;
      for (final id in _selectedFriendIds) {
        final ctrl = _customAmountControllers[id];
        final val = double.tryParse(
                ctrl?.text.replaceAll('.', '').replaceAll(',', '') ?? '0') ??
            0;
        totalAssigned += val;
      }
      return (totalAmount - totalAssigned).roundToDouble();
    }
  }

  Future<void> _submitSplit() async {
    if (_selectedFriendIds.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng chọn ít nhất 1 người bạn để chia tiền',
        type: ToastType.warning,
      );
      return;
    }

    final totalAmount = widget.transaction.amount;
    final dio = ref.read(dioProvider);

    List<Map<String, dynamic>> participants = [];

    if (_mode == SplitMode.equal) {
      participants = _selectedFriendIds.map((id) => {'userId': id}).toList();
    } else {
      double totalAssigned = 0;
      for (final id in _selectedFriendIds) {
        final ctrl = _customAmountControllers[id];
        final val = double.tryParse(
              ctrl?.text.replaceAll('.', '').replaceAll(',', '') ?? '0',
            ) ??
            0;
        if (val <= 0) {
          AppToast.show(
            context,
            message: 'Vui lòng nhập số tiền hợp lệ (> 0) cho bạn bè được chọn',
            type: ToastType.warning,
          );
          return;
        }
        totalAssigned += val;
        participants.add({
          'userId': id,
          'assignedAmount': val,
        });
      }

      if (totalAssigned >= totalAmount) {
        AppToast.show(
          context,
          message:
              'Tổng số tiền bạn bè trả phải nhỏ hơn tổng hóa đơn (${CurrencyFormatter.format(totalAmount)})',
          type: ToastType.warning,
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await dio.post(
        '/transactions/${widget.transaction.id}/splits',
        data: {
          'splitType': _mode == SplitMode.equal ? 'equal' : 'custom',
          'participants': participants,
        },
      );

      ref.invalidate(mySplitsProvider);
      ref.invalidate(splitSummaryProvider);

      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Đã tạo phiên chia tiền thành công!',
        type: ToastType.success,
      );
      widget.onSplitCreated?.call();
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ??
          'Không thể tạo phiên chia tiền. Vui lòng thử lại!';
      AppToast.show(context, message: msg.toString(), type: ToastType.error);
    } catch (e) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: 'Đã xảy ra lỗi: ${e.toString()}',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final friendsState = ref.watch(friendsListProvider);
    final totalAmount = widget.transaction.amount;
    final ownerShare = _calculateOwnerShare(totalAmount);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_work_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chia tiền cho bạn bè',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hóa đơn: ${CurrencyFormatter.format(totalAmount)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Tab lựa chọn phương thức chia (Chuẩn GEMINI.md Phần 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeTab(
                    label: 'Chia đều (Equal)',
                    icon: Icons.pie_chart_outline_rounded,
                    selected: _mode == SplitMode.equal,
                    onTap: () => setState(() => _mode = SplitMode.equal),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModeTab(
                    label: 'Tùy chỉnh (Custom)',
                    icon: Icons.tune_rounded,
                    selected: _mode == SplitMode.custom,
                    onTap: () => setState(() => _mode = SplitMode.custom),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // Tóm tắt phân bổ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Phần bạn trả:',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(ownerShare > 0 ? ownerShare : 0),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ownerShare >= 0
                          ? AppColors.primary
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Thanh tìm kiếm bạn bè
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bạn bè...',
                hintStyle: GoogleFonts.inter(fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Danh sách bạn bè
          Expanded(
            child: friendsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Không thể tải danh sách bạn bè.\n$err',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
              data: (data) {
                final allFriends = data.friends;
                if (allFriends.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 48,
                            color: isDark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bạn chưa có bạn bè nào trong danh bạ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkForeground
                                  : AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kết bạn để cùng chia hóa đơn tiền trọ, ăn uống nhanh chóng!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push(RoutePaths.friends);
                            },
                            icon:
                                const Icon(Icons.person_add_rounded, size: 18),
                            label: const Text('Tìm & Thêm bạn bè'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = allFriends.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return f.displayName.toLowerCase().contains(q) ||
                      f.username.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy bạn bè phù hợp',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color:
                            isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      ),
                    ),
                  );
                }

                final splitEach = _selectedFriendIds.isNotEmpty
                    ? (totalAmount / (_selectedFriendIds.length + 1))
                        .roundToDouble()
                    : totalAmount;

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, index) {
                    final friend = filtered[index];
                    final isSelected =
                        _selectedFriendIds.contains(friend.userId);

                    return _buildFriendItem(
                      friend: friend,
                      isSelected: isSelected,
                      isDark: isDark,
                      splitAmount: splitEach,
                    );
                  },
                );
              },
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSplit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                              child: Text(
                            _selectedFriendIds.isEmpty
                                ? 'Chọn bạn bè để chia'
                                : 'Chia cho ${_selectedFriendIds.length} người bạn',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    // Tuân thủ quy chuẩn GEMINI.md Mục 2
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.darkMuted : AppColors.lightMuted),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkForeground
                            : AppColors.lightForeground),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendItem({
    required Friend friend,
    required bool isSelected,
    required bool isDark,
    required double splitAmount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Checkbox toggle
          Checkbox(
            value: isSelected,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedFriendIds.add(friend.userId);
                } else {
                  _selectedFriendIds.remove(friend.userId);
                }
              });
            },
          ),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage:
                friend.avatar != null ? NetworkImage(friend.avatar!) : null,
            child: friend.avatar == null
                ? Text(
                    friend.initials,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),

          // Tên bạn bè
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                Text(
                  '@${friend.username}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),

          // Số tiền hiển thị hoặc ô nhập (tùy mode)
          if (isSelected)
            if (_mode == SplitMode.equal)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CurrencyFormatter.format(splitAmount),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _getController(friend.userId, splitAmount),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    suffixText: '₫',
                    suffixStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
        ],
      ),
    );
  }
}
