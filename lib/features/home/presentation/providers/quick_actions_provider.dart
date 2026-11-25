import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/quick_action_item_model.dart';

const String _kQuickActionsStorageKey = 'finora_quick_actions_order_v1';

/// Trạng thái quản lý cấu hình các tiện ích thao tác nhanh
class QuickActionsState {
  final List<String> enabledIds;

  const QuickActionsState({required this.enabledIds});

  /// Danh sách các tiện ích đang được bật theo đúng thứ tự người dùng sắp xếp
  List<QuickActionItemModel> get enabledItems {
    final Map<String, QuickActionItemModel> map = {
      for (final item in allQuickActionsCatalog) item.id: item,
    };
    final List<QuickActionItemModel> result = [];
    for (final id in enabledIds) {
      if (map.containsKey(id)) {
        result.add(map[id]!);
      }
    }
    return result;
  }

  /// Danh sách các tiện ích còn lại chưa được kích hoạt
  List<QuickActionItemModel> get disabledItems {
    final Set<String> enabledSet = enabledIds.toSet();
    return allQuickActionsCatalog
        .where((item) => !enabledSet.contains(item.id))
        .toList();
  }

  QuickActionsState copyWith({List<String>? enabledIds}) {
    return QuickActionsState(enabledIds: enabledIds ?? this.enabledIds);
  }
}

final quickActionsProvider =
    AsyncNotifierProvider<QuickActionsNotifier, QuickActionsState>(() {
  return QuickActionsNotifier();
});

class QuickActionsNotifier extends AsyncNotifier<QuickActionsState> {
  /// 12 tiện ích mặc định ban đầu
  static List<String> get defaultEnabledIds {
    return allQuickActionsCatalog
        .where((item) => item.isDefaultEnabled)
        .map((item) => item.id)
        .toList();
  }

  @override
  Future<QuickActionsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_kQuickActionsStorageKey);

    if (savedList != null && savedList.isNotEmpty) {
      // Lọc các id hợp lệ trong catalog hiện tại
      final validIds = allQuickActionsCatalog.map((e) => e.id).toSet();
      final filtered = savedList.where((id) => validIds.contains(id)).toList();
      if (filtered.length >= 4) {
        return QuickActionsState(enabledIds: filtered);
      }
    }

    return QuickActionsState(enabledIds: defaultEnabledIds);
  }

  /// Bật hoặc tắt một tiện ích
  Future<bool> toggleAction(String id) async {
    final current = state.valueOrNull;
    if (current == null) return false;

    final list = List<String>.from(current.enabledIds);
    if (list.contains(id)) {
      // Ràng buộc: Giữ tối thiểu 4 tiện ích hiển thị
      if (list.length <= 4) {
        return false;
      }
      list.remove(id);
    } else {
      list.add(id);
    }

    state = AsyncData(current.copyWith(enabledIds: list));
    await _saveToStorage(list);
    return true;
  }

  /// Kéo thả sắp xếp lại thứ tự tiện ích
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final list = List<String>.from(current.enabledIds);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    state = AsyncData(current.copyWith(enabledIds: list));
    await _saveToStorage(list);
  }

  /// Khôi phục cấu hình mặc định (12 tiện ích ban đầu)
  Future<void> resetToDefault() async {
    final list = List<String>.from(defaultEnabledIds);
    state = AsyncData(QuickActionsState(enabledIds: list));
    await _saveToStorage(list);
  }

  Future<void> _saveToStorage(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kQuickActionsStorageKey, ids);
  }
}

