import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/reaction_icons_service.dart';
import '../../domain/models/reaction_icon_item.dart';

final reactionIconsServiceProvider = Provider<ReactionIconsService>((ref) {
  return ReactionIconsService();
});

final reactionIconsProvider = FutureProvider<List<ReactionIconItem>>((ref) async {
  final service = ref.watch(reactionIconsServiceProvider);
  return service.fetchReactionIcons();
});

