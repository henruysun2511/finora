import '../../domain/models/friend.dart';
import '../../domain/repositories/friends_repository.dart';
import '../services/friends_api_service.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  FriendsRepositoryImpl(this._apiService);

  final FriendsApiService _apiService;

  @override
  Future<List<Friend>> getFriends({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final dtos = await _apiService.getFriends(
      page: page,
      limit: limit,
      search: search,
    );
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}

