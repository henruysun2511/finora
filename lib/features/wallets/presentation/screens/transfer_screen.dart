import 'package:flutter/material.dart';

import '../../../transfers/presentation/screens/transfer_form_screen.dart';

/// Legacy screen wrapper delegating to [TransferFormScreen]
class TransferScreen extends StatelessWidget {
  final String? fromAccountId;
  final String? fromWalletId;

  const TransferScreen({
    super.key,
    this.fromAccountId,
    this.fromWalletId,
  });

  @override
  Widget build(BuildContext context) {
    return TransferFormScreen(
      fromAccountId: fromAccountId,
      fromWalletId: fromWalletId,
    );
  }
}
