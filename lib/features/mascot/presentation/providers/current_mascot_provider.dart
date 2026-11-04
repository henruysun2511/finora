import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/current_mascot.dart';
import '../../domain/models/mascot_enums.dart';
import '../../domain/models/mascot_evolution.dart';
import '../../domain/models/mascot_settings_input.dart';
import 'mascot_providers.dart';

final currentMascotProvider =
    AsyncNotifierProvider<CurrentMascotNotifier, CurrentMascot>(
  CurrentMascotNotifier.new,
);

class CurrentMascotNotifier extends AsyncNotifier<CurrentMascot> {
  @override
  Future<CurrentMascot> build() async {
    final repo = ref.watch(mascotRepositoryProvider);
    return repo.getCurrentMascot();
  }

  /// Làm mới thông tin linh vật
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(mascotRepositoryProvider).getCurrentMascot());
  }

  /// Đồng bộ tiến hóa / thăng hạng linh vật
  Future<MascotEvolution?> syncEvolution() async {
    try {
      final repo = ref.read(mascotRepositoryProvider);
      final evolution = await repo.syncEvolution();

      // Cập nhật lại thông tin mới nhất
      final updated = await repo.getCurrentMascot();
      state = AsyncData(updated);

      return evolution;
    } catch (_) {
      return null;
    }
  }

  /// Cập nhật cờ bật/tắt hiển thị linh vật (Optimistic update)
  Future<void> updateShowMascot(bool show) async {
    final cur = state.value;
    if (cur != null) {
      state = AsyncData(cur.copyWith(showMascot: show));
    }

    try {
      await ref.read(mascotRepositoryProvider).updateMascotSettings(
            MascotSettingsInput(showMascot: show),
          );
    } catch (_) {
      // Revert nếu lỗi
      if (cur != null) state = AsyncData(cur);
      rethrow;
    }
  }

  /// Cập nhật giọng điệu phản hồi của linh vật (Optimistic update)
  Future<void> updateTone(MascotTone tone) async {
    final cur = state.value;
    if (cur != null) {
      state = AsyncData(cur.copyWith(mascotTone: tone));
    }

    try {
      await ref.read(mascotRepositoryProvider).updateMascotSettings(
            MascotSettingsInput(mascotTone: tone),
          );
    } catch (_) {
      if (cur != null) state = AsyncData(cur);
      rethrow;
    }
  }

  /// Cập nhật độ nhạy cảnh báo (Optimistic update)
  Future<void> updateSensitivity(MascotSensitivity sensitivity) async {
    final cur = state.value;
    if (cur != null) {
      state = AsyncData(cur.copyWith(mascotSensitivity: sensitivity));
    }

    try {
      await ref.read(mascotRepositoryProvider).updateMascotSettings(
            MascotSettingsInput(mascotSensitivity: sensitivity),
          );
    } catch (_) {
      if (cur != null) state = AsyncData(cur);
      rethrow;
    }
  }
}

