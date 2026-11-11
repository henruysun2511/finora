import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/conversation_list_provider.dart';
import '../widgets/conversation_tile.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final filter = ref.watch(conversationTabFilterProvider);
    final convsAsync = ref.watch(conversationListProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: PageHeader.subPage(
        title: 'Hội thoại',
        subtitle: 'Chat bạn bè & nhóm ví chung',
        action: IconButton(
          icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
          tooltip: 'Tìm bạn mới',
          onPressed: () => context.push(RoutePaths.friends),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                ref.read(conversationListProvider.notifier).onSearchChanged(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm cuộc trò chuyện, nhóm ví...',
                hintStyle: TextStyle(fontSize: 13.5, color: muted),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: muted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(conversationListProvider.notifier).onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),

          // ── Filter Chips: Tất cả | Bạn bè 1-1 | Nhóm ví chung ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 0, filter, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Bạn bè (1-1)', 1, filter, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Nhóm ví chung 👥', 2, filter, isDark),
              ],
            ),
          ),

          // ── Conversation List ──
          Expanded(
            child: convsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Không thể tải tin nhắn: $err', style: TextStyle(color: muted)),
              ),
              data: (list) {
                final filtered = list.where((c) {
                  if (filter == 1) return !c.isGroup;
                  if (filter == 2) return c.isGroup;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: muted),
                          const SizedBox(height: 12),
                          Text(
                            filter == 2 ? 'Chưa có nhóm ví chung nào' : 'Chưa có cuộc trò chuyện nào',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: foreground),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bắt đầu nhắn tin với bạn bè hoặc tạo nhóm chia bill ngay!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24, top: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      indent: 76,
                      height: 1,
                      thickness: 0.5,
                      color: border.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (ctx, i) {
                      final conv = filtered[i];
                      return ConversationTile(
                        conversation: conv,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(conversation: conv),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int currentFilter, bool isDark) {
    final isSelected = currentFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) {
        ref.read(conversationTabFilterProvider.notifier).state = index;
      },
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.darkForeground : AppColors.lightForeground),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
    );
  }
}
