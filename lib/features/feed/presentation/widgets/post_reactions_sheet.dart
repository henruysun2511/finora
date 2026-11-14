import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/models/post_reaction.dart';

class PostReactionsSheet extends StatefulWidget {
  const PostReactionsSheet({
    super.key,
    this.reactions,
    this.onFetchReactions,
  });

  final List<PostReaction>? reactions;
  final Future<List<PostReaction>> Function()? onFetchReactions;

  static Future<void> show(
    BuildContext context, {
    List<PostReaction>? reactions,
    Future<List<PostReaction>> Function()? onFetchReactions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostReactionsSheet(
        reactions: reactions,
        onFetchReactions: onFetchReactions,
      ),
    );
  }

  @override
  State<PostReactionsSheet> createState() => _PostReactionsSheetState();
}

class _PostReactionsSheetState extends State<PostReactionsSheet> {
  late bool _isLoading;
  late List<PostReaction> _reactions;

  @override
  void initState() {
    super.initState();
    if (widget.reactions != null) {
      _reactions = widget.reactions!;
      _isLoading = false;
    } else {
      _reactions = [];
      _isLoading = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (widget.onFetchReactions == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final list = await widget.onFetchReactions!();
      if (mounted) {
        setState(() {
          _reactions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reactions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final foreground =
        dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.65,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách tương tác',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                  ),
                  if (!_isLoading && _reactions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_reactions.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            else if (_reactions.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: muted.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: LucideIcon(
                        name: 'users',
                        size: 24,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có hoạt động',
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _reactions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: border.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = _reactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            backgroundImage: item.avatar != null
                                ? NetworkImage(item.avatar!)
                                : null,
                            child: item.avatar == null
                                ? Text(
                                    item.initials,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: foreground,
                              ),
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: dark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: border.withValues(alpha: 0.6),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.emoji.symbol,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
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
