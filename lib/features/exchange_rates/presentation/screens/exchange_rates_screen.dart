import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../providers/currency_converter_provider.dart';
import '../providers/popular_rates_provider.dart';
import '../widgets/currency_converter_card.dart';
import '../widgets/default_currency_card.dart';
import '../widgets/popular_rates_table.dart';
import '../widgets/transfer_wallet_cta_button.dart';

class ExchangeRatesScreen extends ConsumerWidget {
  const ExchangeRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PageHeader.subPage(
        title: 'Quy đổi tiền tệ & Tỷ giá',
        subtitle: 'Tỷ giá thị trường thời gian thực',
        action: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          tooltip: 'Cập nhật tỷ giá',
          onPressed: () {
            ref.read(popularRatesProvider.notifier).refresh();
            ref.read(currencyConverterProvider.notifier).recalculate();
          },
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            ref.read(popularRatesProvider.notifier).refresh(),
            ref.read(currencyConverterProvider.notifier).recalculate(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // 1. Bộ quy đổi tiền tệ thời gian thực
              CurrencyConverterCard(),
              SizedBox(height: 18),

              // 2. Bảng tỷ giá ngoại tệ hôm nay
              PopularRatesTable(),
              SizedBox(height: 20),

              // 3. Nút CTA: Chuyển tiền vào ví đa tiền tệ
              TransferWalletCtaButton(),
              SizedBox(height: 20),

              // 4. Mục cài đặt tiền tệ mặc định ở dưới cùng
              DefaultCurrencyCard(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

