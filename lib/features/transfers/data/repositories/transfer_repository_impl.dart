import '../../domain/models/convert_preview.dart';
import '../../domain/models/transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../dto/convert_currency_request.dart';
import '../dto/create_transfer_request.dart';
import '../services/transfer_api_service.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferApiService _service;

  TransferRepositoryImpl(this._service);

  @override
  Future<Transfer> create(CreateTransferRequest request) async {
    final data = await _service.createTransfer(request);
    return Transfer.fromJson(data);
  }

  @override
  Future<ConvertPreview> convertPreview(
    String fromAccountId,
    String toAccountId,
    double amount,
  ) async {
    final req = ConvertCurrencyRequest(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
    );
    final data = await _service.convertPreview(req);
    return ConvertPreview.fromJson(data);
  }

  @override
  Future<({List<Transfer> items, int total, int page, int limit})> getList({
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _service.getTransfers(
      accountId: accountId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );

    List<Transfer> items = [];
    int total = 0;
    int respPage = page;
    int respLimit = limit;

    // NestJS ApiResponse or PaginatedResponse
    dynamic rawItems = response['items'];
    if (rawItems == null && response['data'] is Map<String, dynamic>) {
      final inner = response['data'] as Map<String, dynamic>;
      rawItems = inner['items'];
      total = (inner['total'] as num?)?.toInt() ?? 0;
      respPage = (inner['page'] as num?)?.toInt() ?? page;
      respLimit = (inner['limit'] as num?)?.toInt() ?? limit;
    } else if (rawItems == null && response['data'] is List) {
      rawItems = response['data'];
      total = (response['total'] as num?)?.toInt() ?? (rawItems as List).length;
    } else {
      total = (response['total'] as num?)?.toInt() ?? 0;
      respPage = (response['page'] as num?)?.toInt() ?? page;
      respLimit = (response['limit'] as num?)?.toInt() ?? limit;
    }

    if (rawItems is List) {
      items = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => Transfer.fromJson(e))
          .toList();
    }

    return (items: items, total: total, page: respPage, limit: respLimit);
  }

  @override
  Future<Transfer> getById(String id) async {
    final data = await _service.getTransferById(id);
    return Transfer.fromJson(data);
  }
}
