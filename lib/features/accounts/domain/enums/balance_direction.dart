import 'package:flutter/material.dart';

enum BalanceDirection {
  increase,
  decrease;

  static BalanceDirection fromString(String? val) {
    if (val?.toUpperCase() == 'DECREASE') {
      return BalanceDirection.decrease;
    }
    return BalanceDirection.increase;
  }

  String toServerString() {
    switch (this) {
      case BalanceDirection.increase:
        return 'INCREASE';
      case BalanceDirection.decrease:
        return 'DECREASE';
    }
  }

  String get displayName {
    switch (this) {
      case BalanceDirection.increase:
        return 'Tăng số dư';
      case BalanceDirection.decrease:
        return 'Giảm số dư';
    }
  }

  Color get color {
    switch (this) {
      case BalanceDirection.increase:
        return const Color(0xFF10B981);
      case BalanceDirection.decrease:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case BalanceDirection.increase:
        return Icons.arrow_upward_rounded;
      case BalanceDirection.decrease:
        return Icons.arrow_downward_rounded;
    }
  }
}

