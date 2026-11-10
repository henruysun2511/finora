import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../data/services/reaction_icons_service.dart';
import '../../domain/models/reaction_emoji.dart';
import '../../domain/models/reaction_icon_item.dart';
import '../providers/reaction_icons_provider.dart';

class FeedReactionPickerSheet extends ConsumerStatefulWidget {
  const FeedReactionPickerSheet({
    super.key,
    this.currentReaction,
    this.currentSymbol,
  });

  final ReactionEmoji? currentReaction;
  final String? currentSymbol;

  static Future<ReactionIconItem?> show(
    BuildContext context, {
    ReactionEmoji? currentReaction,
    String? currentSymbol,
  }) {
    return showModalBottomSheet<ReactionIconItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedReactionPickerSheet(
        currentReaction: currentReaction,
        currentSymbol: currentSymbol,
      ),
    );
  }

  @override
  ConsumerState<FeedReactionPickerSheet> createState() =>
      _FeedReactionPickerSheetState();
}

class _FeedReactionPickerSheetState
    extends ConsumerState<FeedReactionPickerSheet> {
  String _selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        isDark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final iconsAsync = ref.watch(reactionIconsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag Handle ──
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            // ── Header Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const LucideIcon(
                      name: 'flame',
                      size: 17,
                      color: AppColors.primary,
                      strokeWidth: 2.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Chọn biểu tượng tương tác',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: foreground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: LucideIcon(
                      name: 'x',
                      size: 18,
                      color: muted,
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Content ──
            iconsAsync.when(
              data: (icons) => _buildContent(icons, isDark, foreground, muted, border),
              loading: () => _buildContent(
                ReactionIconsService.defaultIcons,
                isDark,
                foreground,
                muted,
                border,
              ),
              error: (_, __) => _buildContent(
                ReactionIconsService.defaultIcons,
                isDark,
                foreground,
                muted,
                border,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    List<ReactionIconItem> icons,
    bool isDark,
    Color foreground,
    Color muted,
    Color border,
  ) {
    final categories = ['Tất cả', ...{for (final item in icons) item.category}];

    final filteredIcons = _selectedCategory == 'Tất cả'
        ? icons
        : icons.where((i) => i.category == _selectedCategory).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Category Filter Bar ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Icons Grid ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final item = filteredIcons[index];
                final isSelected = widget.currentSymbol != null
                    ? widget.currentSymbol == item.symbol
                    : widget.currentReaction == item.emoji;

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(item);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : border.withValues(alpha: 0.7),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.symbol,
                          style: const TextStyle(fontSize: 27),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? AppColors.primary : muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

