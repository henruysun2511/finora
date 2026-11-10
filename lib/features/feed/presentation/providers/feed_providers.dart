import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../data/services/feed_api_service.dart';
import '../../domain/repositories/feed_repository.dart';

final feedApiServiceProvider = Provider<FeedApiService>((ref) {
  return FeedApiService(ref.watch(dioProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final api = ref.watch(feedApiServiceProvider);
  return FeedRepositoryImpl(api);
});

