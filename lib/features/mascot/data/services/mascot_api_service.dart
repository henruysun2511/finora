import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/current_mascot_response.dart';
import '../dto/mascot_evolution_response.dart';
import '../dto/mascot_tier_response.dart';
import '../dto/update_mascot_settings_request.dart';

abstract class MascotApiService {
  Future<CurrentMascotResponse> getCurrentMascot();
  Future<List<MascotTierResponse>> getAllMascotTiers();
  Future<MascotEvolutionResponse> syncEvolution();
  Future<void> updateMascotSettings(UpdateMascotSettingsRequest request);
}

class DioMascotApiService implements MascotApiService {
  DioMascotApiService(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? data['error'] as String?;
      }
      throw AppException(
        message ?? e.message ?? 'Đã xảy ra lỗi khi kết nối máy chủ',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    }
    return responseData;
  }

  @override
  Future<CurrentMascotResponse> getCurrentMascot() => _guard(() async {
        final res = await _dio.get<dynamic>('/mascots/current');
        final raw = _extractData(res.data);
        return CurrentMascotResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<List<MascotTierResponse>> getAllMascotTiers() => _guard(() async {
        final res = await _dio.get<dynamic>('/mascots');
        final raw = _extractData(res.data);
        List<dynamic> list = [];
        if (raw is List) {
          list = raw;
        } else if (raw is Map<String, dynamic> && raw['items'] is List) {
          list = raw['items'] as List;
        }
        return list
            .map((e) => MascotTierResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<MascotEvolutionResponse> syncEvolution() => _guard(() async {
        final res = await _dio.post<dynamic>('/mascots/sync-evolution');
        final raw = _extractData(res.data);
        return MascotEvolutionResponse.fromJson(raw as Map<String, dynamic>);
      });

  @override
  Future<void> updateMascotSettings(UpdateMascotSettingsRequest request) =>
      _guard(() async {
        // Hỗ trợ cả 2 endpoint: /settings/mascot hoặc /settings
        try {
          await _dio.patch<dynamic>('/settings/mascot', data: request.toJson());
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            await _dio.patch<dynamic>('/settings', data: request.toJson());
          } else {
            rethrow;
          }
        }
      });
}

