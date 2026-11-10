import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../data/services/messages_api_service.dart';
import '../../domain/repositories/messages_repository.dart';

final messagesApiServiceProvider = Provider<MessagesApiService>((ref) {
  return MessagesApiService(ref.watch(dioProvider));
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final api = ref.watch(messagesApiServiceProvider);
  return MessagesRepositoryImpl(api);
});
