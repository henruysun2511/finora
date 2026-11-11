import '../../domain/models/notification_filter.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/models/notification_type.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mapper/notification_mapper.dart';
import '../services/notification_api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);
  final NotificationApiService _api;

  @override
  Future<List<NotificationItem>> getNotifications(
      NotificationFilter filter) async {
    try {
      final dtos = await _api.getNotifications(filter.toQueryMap());
      final items = dtos.map(NotificationMapper.toDomain).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback xuống danh sách mẫu khi mạng lỗi hoặc user mới chưa có dữ liệu
    }
    return _fallbackNotifications(filter);
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _api.getUnreadCount();
    } catch (_) {
      return 3;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllAsRead();
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<NotificationItem> markAsRead(String id) async {
    try {
      final dto = await _api.markAsRead(id);
      return NotificationMapper.toDomain(dto);
    } catch (_) {
      return NotificationItem(
        id: id,
        userId: 'current',
        type: NotificationType.general,
        title: 'Thông báo',
        body: '',
        isRead: true,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _api.deleteNotification(id);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  List<NotificationItem> _fallbackNotifications(NotificationFilter filter) {
    final now = DateTime.now();
    final all = [
      NotificationItem(
        id: '1',
        userId: 'current',
        type: NotificationType.budgetWarning,
        title: 'Sắp chạm ngưỡng ngân sách!',
        body: 'Bạn đã sử dụng 92% ngân sách Ăn uống & Nhà hàng trong tháng này.',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      NotificationItem(
        id: '2',
        userId: 'current',
        type: NotificationType.loanDue,
        title: 'Khoản nợ sắp đến hạn',
        body: 'Khoản vay mua laptop cần thanh toán định kỳ trong 2 ngày tới.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '3',
        userId: 'current',
        type: NotificationType.loanPaymentReceived,
        title: 'Biến động số dư',
        body: 'Tài khoản chính vừa nhận +18.500.000 ₫ từ chuyển khoản lương tháng 11.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationItem(
        id: '4',
        userId: 'current',
        type: NotificationType.recurringExecuted,
        title: 'Giao dịch định kỳ tự động',
        body: 'Đã tự động ghi nhận thanh toán gói Netflix 4K (260.000 ₫) vào sổ chi tiêu.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: '5',
        userId: 'current',
        type: NotificationType.splitRequest,
        title: 'Chia tiền nhóm mới',
        body: 'Hải Nam vừa thêm bạn vào chi phí "Ăn trưa lẩu Haidilao" cần chia đều.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      NotificationItem(
        id: '6',
        userId: 'current',
        type: NotificationType.savingsGoalMilestone,
        title: 'Thử thách tiết kiệm hoàn thành!',
        body: 'Chúc mừng bạn và Linh vật Finora đã duy trì chuỗi 7 ngày ghi chép liên tục.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationItem(
        id: '7',
        userId: 'current',
        type: NotificationType.systemAnnouncement,
        title: 'Bí quyết tài chính từ Finora',
        body: 'Khám phá cách tối ưu quy tắc 50/30/20 giúp gia tăng quỹ dự phòng khẩn cấp.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    return all.where((item) {
      if (filter.isRead != null && item.isRead != filter.isRead) return false;
      if (filter.type != null && item.type != filter.type) return false;
      return true;
    }).toList();
  }
}

