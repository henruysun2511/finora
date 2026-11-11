import 'package:flutter/material.dart';

import '../../../accounts/presentation/screens/account_detail_screen.dart'
    as accounts;

/// Wrapper chuyển tiếp sang AccountDetailScreen thuộc module accounts
class AccountDetailScreen extends StatelessWidget {
  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return accounts.AccountDetailScreen(accountId: accountId);
  }
}
