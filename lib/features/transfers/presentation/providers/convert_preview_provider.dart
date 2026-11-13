import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/convert_preview.dart';
import 'transfer_providers.dart';

class ConvertPreviewArgs {
  final String fromAccountId;
  final String toAccountId;
  final double amount;

  const ConvertPreviewArgs({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConvertPreviewArgs &&
          runtimeType == other.runtimeType &&
          fromAccountId == other.fromAccountId &&
          toAccountId == other.toAccountId &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(fromAccountId, toAccountId, amount);
}

final convertPreviewProvider =
    FutureProvider.autoDispose.family<ConvertPreview?, ConvertPreviewArgs>(
  (ref, args) async {
    if (args.fromAccountId.isEmpty ||
        args.toAccountId.isEmpty ||
        args.fromAccountId == args.toAccountId ||
        args.amount <= 0) {
      return null;
    }

    final repo = ref.watch(transferRepositoryProvider);
    return repo.convertPreview(
      args.fromAccountId,
      args.toAccountId,
      args.amount,
    );
  },
);
