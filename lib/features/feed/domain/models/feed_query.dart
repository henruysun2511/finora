class FeedQuery {
  const FeedQuery({
    this.friendId,
    this.page = 1,
    this.limit = 10,
  });

  final String? friendId;
  final int page;
  final int limit;

  Map<String, dynamic> toQueryParams() {
    return {
      'page': page,
      'limit': limit,
      if (friendId != null && friendId!.isNotEmpty) 'friendId': friendId,
    };
  }
}

