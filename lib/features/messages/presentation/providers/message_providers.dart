import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/services/message_api_service.dart';
import '../../data/services/mock_message_api_service.dart';
import '../../domain/repositories/message_repository.dart';

const bool kUseMockApi = bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

/// Dependency injection cho module messages
final messageApiServiceProvider = Provider<MessageApiService>((ref) {
  if (kUseMockApi) {
    return MockMessageApiService();
  }
  return DioMessageApiService(ref.watch(dioProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(ref.watch(messageApiServiceProvider));
});

