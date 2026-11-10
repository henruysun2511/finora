import '../models/friend.dart';

abstract class FriendsRepository {
  Future<List<Friend>> getFriends({
    int page = 1,
    int limit = 50,
    String? search,
  });
}

