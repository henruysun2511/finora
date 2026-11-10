import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/services/notification_api_service.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref.watch(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.watch(notificationApiServiceProvider);
  return NotificationRepositoryImpl(api);
});

