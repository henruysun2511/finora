import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/mascot_tier.dart';
import 'mascot_providers.dart';

final mascotLineupProvider = FutureProvider<List<MascotTier>>((ref) async {
  final repo = ref.watch(mascotRepositoryProvider);
  return repo.getAllMascotTiers();
});

