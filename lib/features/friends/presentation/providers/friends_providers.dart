import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../data/services/friends_api_service.dart';
import '../../domain/repositories/friends_repository.dart';

final friendsApiServiceProvider = Provider<FriendsApiService>((ref) {
  return FriendsApiService(ref.watch(dioProvider));
});

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepositoryImpl(ref.watch(friendsApiServiceProvider));
});
