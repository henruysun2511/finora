import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class CommentItem {
  const CommentItem({
    required this.id,
    required this.userName,
    required this.userInitials,
    required this.content,
    required this.timeAgo,
    this.avatarGradient,
    this.isMe = false,
  });

  final String id;
  final String userName;
  final String userInitials;
  final String content;
  final String timeAgo;
  final List<Color>? avatarGradient;
  final bool isMe;
}

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({
    super.key,
    required this.transactionId,
    required this.postTitle,
  });

  final String transactionId;
  final String postTitle;

  static Future<void> show(
    BuildContext context, {
    required String transactionId,
    required String postTitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(
        transactionId: transactionId,
        postTitle: postTitle,
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<CommentItem> _comments = [
    const CommentItem(
      id: 'c1',
      userName: 'Trần Ngọc',
      userInitials: 'TN',
      content: 'Quán này ngon mà giá hợp lý ghê! Lần sau cho mình đi ké với nhé 🍜🤤',
      timeAgo: '15 phút trước',
      avatarGradient: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    ),
    const CommentItem(
      id: 'c2',
      userName: 'Hùng Minh',
      userInitials: 'HM',
      content: 'Tuyệt vời luôn! Tiết kiệm được một khoản lớn vào ví chung rồi nè 👏💸',
      timeAgo: '45 phút trước',
      avatarGradient: [Color(0xFF0072D6), Color(0xFF0284C7)],
    ),
    const CommentItem(
      id: 'c3',
      userName: 'Anh Thư',
      userInitials: 'AT',
      content: 'Đỉnh quá bạn ơi, kiên trì giữ mục tiêu chi tiêu thông minh nha! 🦊✨',
      timeAgo: '2 giờ trước',
      avatarGradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(
        CommentItem(
          id: 'c-${DateTime.now().millisecondsSinceEpoch}',
          userName: 'Bạn',
          userInitials: 'ME',
          content: text,
          timeAgo: 'Vừa xong',
          avatarGradient: const [Color(0xFF0072D6), Color(0xFF00C6FF)],
          isMe: true,
        ),
      );
      _commentCtrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final bg = dark ? AppColors.darkBackground : AppColors.lightBackground;
    final foreground = dark ? AppColors.darkForeground : AppColors.lightForeground;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bình luận',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: foreground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_comments.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.postTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có bình luận nào. Hãy là người đầu tiên!',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      final c = _comments[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: c.avatarGradient ??
                                    const [AppColors.primary, Color(0xFF00C6FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              c.userInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: c.isMe ? AppColors.primary.withValues(alpha: 0.08) : bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: c.isMe ? AppColors.primary.withValues(alpha: 0.25) : border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: c.isMe ? AppColors.primary : foreground,
                                        ),
                                      ),
                                      Text(
                                        c.timeAgo,
                                        style: TextStyle(fontSize: 10.5, color: muted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.content,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: foreground,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Input
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).viewPadding.bottom +
                  10,
            ),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: border),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận động viên bạn bè...',
                        hintStyle: TextStyle(fontSize: 13, color: muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      style: TextStyle(fontSize: 13.5, color: foreground),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendComment,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
