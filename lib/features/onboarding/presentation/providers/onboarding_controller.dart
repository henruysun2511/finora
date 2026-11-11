import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../mascot/domain/models/mascot_enums.dart';
import '../../../mascot/domain/models/mascot_settings_input.dart';
import '../../../mascot/presentation/providers/current_mascot_provider.dart';
import '../../../mascot/presentation/providers/mascot_providers.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../domain/models/onboarding_data.dart';

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingData>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<OnboardingData> {
  @override
  OnboardingData build() {
    final authUser = ref.watch(authNotifierProvider).valueOrNull;
    final defaultName = (authUser?.name != null && authUser!.name.trim().isNotEmpty)
        ? authUser.name.trim()
        : 'Nguyễn Minh';

    return OnboardingData(name: defaultName);
  }

  /// Cập nhật thông tin hồ sơ (Bước 2)
  void updateProfile({
    String? name,
    String? language,
    String? currency,
  }) {
    state = state.copyWith(
      name: name,
      language: language,
      currency: currency,
    );
  }

  /// Cập nhật nguồn tiền & số dư khởi điểm (Bước 3)
  void updateWallet({
    String? walletName,
    String? walletType,
    String? walletTypeLabel,
    double? balance,
  }) {
    state = state.copyWith(
      walletName: walletName,
      walletType: walletType,
      walletTypeLabel: walletTypeLabel,
      balance: balance,
    );
  }

  /// Cập nhật phong cách phản hồi của Trợ lý AI (Bước 4)
  void updateMascotSettings({
    MascotTone? tone,
    MascotSensitivity? sensitivity,
  }) {
    state = state.copyWith(
      mascotTone: tone,
      mascotSensitivity: sensitivity,
    );
  }

  /// Hoàn tất thiết lập ban đầu (Bước 5):
  /// Lưu THẬT toàn bộ dữ liệu vào hệ thống Backend & Local Storage:
  /// 1. Cập nhật tên hiển thị người dùng (PATCH /users/profile)
  /// 2. Tạo Ví tài chính mới (POST /wallets)
  /// 3. Tạo Nguồn tiền & Số dư khởi điểm (POST /accounts)
  /// 4. Lưu Cấu hình Giọng điệu & Độ nhạy Linh vật (PUT /mascots/settings)
  /// 5. Kích hoạt tính toán tiến hóa Linh vật theo tài sản mới
  Future<void> completeOnboarding() async {
    final dio = ref.read(dioProvider);

    // 1. Cập nhật hồ sơ & cài đặt chung người dùng (Tên, Ngôn ngữ, Tiền tệ mặc định)
    try {
      await dio.patch<dynamic>('/users/profile', data: {
        'fullName': state.name,
      });
      developer.log('[Onboarding] Profile name updated: ${state.name}');

      await dio.patch<dynamic>('/settings/general', data: {
        'language': state.language,
        'defaultCurrency': state.currency,
      });
      developer.log('[Onboarding] General settings updated: lang=${state.language}, cur=${state.currency}');
    } catch (e) {
      developer.log('[Onboarding] Profile/Settings update skipped/failed: $e');
    }

    // 2. Tạo Ví tài chính đầu tiên
    String? createdWalletId;
    try {
      final walletRes = await dio.post<dynamic>('/wallets', data: {
        'name': state.walletName,
        'currency': state.currency,
        'icon': '💼',
        'description': 'Ví chính được tạo từ luồng Onboarding',
      });
      final resData = walletRes.data;
      if (resData is Map<String, dynamic>) {
        final inner = resData['data'] ?? resData;
        if (inner is Map<String, dynamic>) {
          createdWalletId = inner['id']?.toString();
        }
      }
      developer.log('[Onboarding] Created wallet ID: $createdWalletId');
    } catch (e) {
      developer.log('[Onboarding] Create wallet skipped/failed: $e');
    }

    // 3. Tạo Tài khoản Nguồn tiền & Số dư khởi điểm nếu có walletId
    if (createdWalletId != null) {
      try {
        await dio.post<dynamic>('/accounts', data: {
          'walletId': createdWalletId,
          'name': state.walletTypeLabel,
          'type': state.walletType, // 'cash' | 'bank' | 'ewallet' | 'credit'
          'currency': state.currency,
          'initialBalance': state.balance,
        });
        developer.log('[Onboarding] Created account: ${state.walletTypeLabel} with balance: ${state.balance}');
      } catch (e) {
        developer.log('[Onboarding] Create account skipped/failed: $e');
      }
    }

    // 4. Lưu cài đặt Giọng điệu & Độ nhạy của Trợ lý AI
    try {
      final mascotRepo = ref.read(mascotRepositoryProvider);
      await mascotRepo.updateMascotSettings(
        MascotSettingsInput(
          mascotTone: state.mascotTone,
          mascotSensitivity: state.mascotSensitivity,
          showMascot: true,
        ),
      );
      developer.log('[Onboarding] Mascot settings saved: ${state.mascotTone.value}');

      // Đồng bộ nấc thang tiến hóa linh vật theo số dư mới
      await mascotRepo.syncEvolution();
    } catch (e) {
      developer.log('[Onboarding] Mascot settings skipped/failed: $e');
    }

    // 5. Đánh dấu đã hoàn thành Onboarding trong Local Storage
    try {
      final prefs = ref.read(localStorageProvider);
      await prefs.setFirstLaunchDone();
    } catch (_) {}

    // 6. Invalidate các Provider liên quan để UI Dashboard tải dữ liệu thật ngay
    ref.invalidate(walletsListProvider);
    ref.invalidate(currentMascotProvider);
    ref.invalidate(authNotifierProvider);
  }
}
