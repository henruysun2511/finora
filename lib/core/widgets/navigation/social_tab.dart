import '../../../app/router/route_names.dart';

/// Enum định danh các Tab trên thanh điều hướng Social
enum SocialTab {
  feed(
    label: 'Bảng tin',
    iconName: 'newspaper',
    routePath: RoutePaths.feed,
  ),
  feedGrid(
    label: 'Dạng lưới',
    iconName: 'layout-grid',
    routePath: RoutePaths.feed,
  ),
  friends(
    label: 'Bạn bè',
    iconName: 'users',
    routePath: RoutePaths.friends,
  ),
  splitBill(
    label: 'Chia bill',
    iconName: 'receipt',
    routePath: RoutePaths.splitExpenses,
  ),
  messages(
    label: 'Nhắn tin',
    iconName: 'message-circle',
    routePath: RoutePaths.socialChat,
  );

  const SocialTab({
    required this.label,
    required this.iconName,
    required this.routePath,
  });

  final String label;
  final String iconName;
  final String routePath;
}
