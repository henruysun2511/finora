import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../network/api_exception.dart';
import '../network/dio_client.dart';

class CloudinaryUploadResult {
  final String publicId;
  final String url;
  final String secureUrl;
  final String? format;
  final int? width;
  final int? height;
  final int? bytes;

  const CloudinaryUploadResult({
    required this.publicId,
    required this.url,
    required this.secureUrl,
    this.format,
    this.width,
    this.height,
    this.bytes,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      publicId: json['publicId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      secureUrl: json['secureUrl'] as String? ?? json['url'] as String? ?? '',
      format: json['format'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      bytes: (json['bytes'] as num?)?.toInt(),
    );
  }
}

class CloudinaryService {
  final Dio _dio;

  CloudinaryService(this._dio);

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  /// 1. POST /cloudinary/upload - Tải lên hình ảnh, hóa đơn hoặc avatar
  Future<CloudinaryUploadResult> uploadMedia({
    required List<int> bytes,
    required String filename,
    String folder = 'finora/receipts',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'folder': folder,
      });

      final res = await _dio.post(
        ApiConstants.cloudinaryUpload,
        data: formData,
      );

      final raw = _extractData(res.data);
      if (raw is Map) {
        return CloudinaryUploadResult.fromJson(
          Map<String, dynamic>.from(raw),
        );
      }
      throw const AppException('Phản hồi không hợp lệ từ dịch vụ Cloudinary');
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Không thể tải ảnh lên: $e');
    }
  }

  /// 2. DELETE /cloudinary/media - Xóa tệp khỏi Cloudinary theo publicId
  Future<bool> deleteMedia({
    required String publicId,
    String resourceType = 'image',
  }) async {
    try {
      final res = await _dio.delete(
        ApiConstants.cloudinaryDelete,
        data: {
          'publicId': publicId,
          'resourceType': resourceType,
        },
      );

      final raw = _extractData(res.data);
      if (raw is Map && raw['result'] == 'ok') {
        return true;
      }
      return res.statusCode == 200;
    } on DioException catch (e) {
      throw mapDioExceptionToAppException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Không thể xóa ảnh: $e');
    }
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final dioClient = ref.read(dioProvider);
  return CloudinaryService(dioClient);
});
