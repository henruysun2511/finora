import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

part 'local_storage.g.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  const LocalStorage(this._prefs);

  bool get isFirstLaunch =>
      _prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;

  Future<void> setFirstLaunchDone() =>
      _prefs.setBool(AppConstants.keyIsFirstLaunch, false);

  String? getThemeMode() => _prefs.getString(AppConstants.keyThemeMode);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.keyThemeMode, mode);

  String? getCachedUser() => _prefs.getString(AppConstants.keyCachedUser);

  Future<void> saveCachedUser(String userJson) =>
      _prefs.setString(AppConstants.keyCachedUser, userJson);

  Future<void> clearCachedUser() =>
      _prefs.remove(AppConstants.keyCachedUser);

  Future<void> clear() => _prefs.clear();
}

@riverpod
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider phải được override trong main.dart',
  );
}

@riverpod
LocalStorage localStorage(LocalStorageRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
}
