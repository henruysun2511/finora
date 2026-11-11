import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../data/services/friends_api_service.dart';
import '../../domain/models/friend.dart';
import '../../domain/repositories/friends_repository.dart';

final friendsApiServiceProvider = Provider<FriendsApiService>((ref) {
  return FriendsApiService(ref.watch(dioProvider));
});

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  final api = ref.watch(friendsApiServiceProvider);
  return FriendsRepositoryImpl(api);
});

final friendsListProvider =
    AsyncNotifierProvider.autoDispose<FriendsListNotifier, List<Friend>>(() {
  return FriendsListNotifier();
});

class FriendsListNotifier extends AutoDisposeAsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() async {
    final repo = ref.read(friendsRepositoryProvider);
    return repo.getFriends();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(friendsRepositoryProvider);
      return repo.getFriends();
    });
  }
}

