import '../../data/dto/create_transfer_request.dart';
import '../models/convert_preview.dart';
import '../models/transfer.dart';

abstract class TransferRepository {
  Future<Transfer> create(CreateTransferRequest request);

  Future<ConvertPreview> convertPreview(
    String fromAccountId,
    String toAccountId,
    double amount,
  );

  Future<({List<Transfer> items, int total, int page, int limit})> getList({
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<Transfer> getById(String id);
}
