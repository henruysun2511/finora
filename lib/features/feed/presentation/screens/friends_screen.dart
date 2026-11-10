import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:finora_mb/app/theme/app_colors.dart';
import 'package:finora_mb/core/widgets/lucide_icon.dart';
import 'package:finora_mb/core/widgets/navigation/social_bottom_bar.dart';
import 'package:finora_mb/core/widgets/navigation/social_tab.dart';
import 'package:finora_mb/core/widgets/page_header.dart';
import 'package:finora_mb/features/friends/friends.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFFF59E0B), Color(0xFFEA580C)],
    [Color(0xFF0072D6), Color(0xFF0284C7)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    [Color(0xFF06B6D4), Color(0xFF0284C7)],
  ];

  List<Color> _getAvatarGradient(String seed) {
    final hash = seed.hashCode.abs();
    return _avatarGradients[hash % _avatarGradients.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final friendsAsync = ref.watch(friendsListProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: const PageHeader.subPage(
        title: 'Bạn bè & Kết nối',
        subtitle: 'Quản lý kết nối & danh sách bạn bè',
      ),
      body: Column(
        children: [
          // ── Search Friend Input ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bạn bè theo tên hoặc email...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: muted,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: LucideIcon(
                      name: 'search',
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const LucideIcon(name: 'x', size: 14),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: GoogleFonts.inter(fontSize: 13, color: foreground),
              ),
            ),
          ),

          // ── Friends List ──
          Expanded(
            child: friendsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LucideIcon(
                        name: 'alert-circle',
                        size: 40,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Không thể tải danh sách bạn bè',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () =>
                            ref.read(friendsListProvider.notifier).refresh(),
                        icon: const LucideIcon(
                          name: 'refresh-cw',
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (friends) {
                final filtered = friends.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  return f.fullName.toLowerCase().contains(_searchQuery) ||
                      f.email.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: const LucideIcon(
                              name: 'users',
                              color: AppColors.primary,
                              size: 32,
                              strokeWidth: 2.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            friends.isEmpty
                                ? 'Chưa có bạn bè nào'
                                : 'Không tìm thấy kết quả phù hợp',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            friends.isEmpty
                                ? 'Kết nối bạn bè trên Finora để chia sẻ chi tiêu và trò chuyện cùng nhau!'
                                : 'Vui lòng thử tìm kiếm bằng từ khóa khác',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(friendsListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = filtered[index];
                      final gradient = _getAvatarGradient(
                          friend.id.isNotEmpty ? friend.id : friend.fullName);
                      final hasAvatar = friend.avatar != null &&
                          friend.avatar!.trim().isNotEmpty;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: hasAvatar
                                    ? null
                                    : LinearGradient(
                                        colors: gradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                image: hasAvatar
                                    ? DecorationImage(
                                        image: NetworkImage(friend.avatar!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: hasAvatar
                                  ? null
                                  : Text(
                                      friend.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Name & Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.displayName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: foreground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    friend.email,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: muted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Bạn bè',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SocialBottomBar(currentTab: SocialTab.friends),
    );
  }
}
