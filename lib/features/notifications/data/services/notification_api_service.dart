import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../dto/notification_response.dart';

class NotificationApiService {
  NotificationApiService(this._dio);
  final Dio _dio;

  Future<List<NotificationResponse>> getNotifications(
      Map<String, dynamic> queryParams) async {
    final res = await _dio.get(
      ApiConstants.notifications,
      queryParameters: queryParams,
    );
    final responseData = res.data['data'];
    final List items = responseData is Map
        ? (responseData['items'] ?? responseData['data'] ?? [])
        : (responseData is List ? responseData : []);
    return items
        .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get(ApiConstants.unreadNotificationsCount);
    final data = res.data['data'];
    if (data is Map) {
      return (data['unreadCount'] ?? data['count'] ?? 0) as int;
    }
    if (data is int) return data;
    return 0;
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConstants.markAllNotificationsAsRead);
  }

  Future<NotificationResponse> markAsRead(String id) async {
    final res = await _dio.patch(ApiConstants.markNotificationAsRead(id));
    return NotificationResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiConstants.deleteNotification(id));
  }
}

