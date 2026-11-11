import 'package:flutter/material.dart';

import 'wallets_overview_screen.dart';

/// Màn hình quản lý Không gian Ví & Tài khoản (FINORA WALLET HUB)
/// Tương thích ngược với định danh WalletsScreen
class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletsOverviewScreen();
  }
}
