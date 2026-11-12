import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../dto/create_wallet_request.dart';
import '../dto/invite_member_request.dart';
import '../dto/update_member_role_request.dart';
import '../dto/update_wallet_request.dart';

abstract class WalletApiService {
  Future<List<Map<String, dynamic>>> getWallets({int page = 1, int limit = 50});
  Future<Map<String, dynamic>> getWalletById(String id);
  Future<Map<String, dynamic>> getWalletBalance(String id);
  Future<List<Map<String, dynamic>>> getWalletAccounts(String id);
  Future<Map<String, dynamic>> createWallet(CreateWalletRequest request);
  Future<Map<String, dynamic>> updateWallet(
    String id,
    UpdateWalletRequest request,
  );
  Future<void> deleteWallet(String id);
  Future<List<Map<String, dynamic>>> getMembers(String walletId);
  Future<Map<String, dynamic>> inviteMember(
    String walletId,
    InviteMemberRequest request,
  );
  Future<Map<String, dynamic>> updateMemberRole(
    String walletId,
    String userId,
    UpdateMemberRoleRequest request,
  );
  Future<void> kickMember(String walletId, String userId);
}

class DioWalletApiService implements WalletApiService {
  final Dio _dio;

  DioWalletApiService(this._dio);

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
    }
    return responseData;
  }

  @override
  Future<List<Map<String, dynamic>>> getWallets({
    int page = 1,
    int limit = 50,
  }) => _guard(() async {
    final res = await _dio.get(
      '/wallets',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = _extractData(res.data);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    } else if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  });

  @override
  Future<Map<String, dynamic>> getWalletById(String id) => _guard(() async {
    final res = await _dio.get('/wallets/$id');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> getWalletBalance(String id) => _guard(() async {
    final res = await _dio.get('/wallets/$id/balance');
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<List<Map<String, dynamic>>> getWalletAccounts(String id) =>
      _guard(() async {
        final res = await _dio.get('/wallets/$id/accounts');
        final data = _extractData(res.data);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          return (data['items'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      });

  @override
  Future<Map<String, dynamic>> createWallet(CreateWalletRequest request) =>
      _guard(() async {
        final res = await _dio.post('/wallets', data: request.toJson());
        final data = _extractData(res.data);
        return data as Map<String, dynamic>;
      });

  @override
  Future<Map<String, dynamic>> updateWallet(
    String id,
    UpdateWalletRequest request,
  ) => _guard(() async {
    final res = await _dio.patch('/wallets/$id', data: request.toJson());
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<void> deleteWallet(String id) => _guard(() async {
    await _dio.delete('/wallets/$id');
  });

  @override
  Future<List<Map<String, dynamic>>> getMembers(String walletId) =>
      _guard(() async {
        final res = await _dio.get('/wallets/$walletId/members');
        final data = _extractData(res.data);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          return (data['items'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      });

  @override
  Future<Map<String, dynamic>> inviteMember(
    String walletId,
    InviteMemberRequest request,
  ) => _guard(() async {
    final res = await _dio.post(
      '/wallets/$walletId/members/invite',
      data: request.toJson(),
    );
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<Map<String, dynamic>> updateMemberRole(
    String walletId,
    String userId,
    UpdateMemberRoleRequest request,
  ) => _guard(() async {
    final res = await _dio.patch(
      '/wallets/$walletId/members/$userId/role',
      data: request.toJson(),
    );
    final data = _extractData(res.data);
    return data as Map<String, dynamic>;
  });

  @override
  Future<void> kickMember(String walletId, String userId) => _guard(() async {
    await _dio.delete('/wallets/$walletId/members/$userId');
  });
}

