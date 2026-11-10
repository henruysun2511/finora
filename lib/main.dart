import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo định dạng ngày tháng tiếng Việt cho thư viện intl
  try {
    await initializeDateFormatting('vi', null);
    await initializeDateFormatting('vi_VN', null);
  } catch (e) {
    debugPrint('Lỗi khởi tạo initializeDateFormatting: $e');
  }

  // Nạp cấu hình từ file .env (có fallback nếu thiếu file)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Không tìm thấy hoặc không thể đọc file .env: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
