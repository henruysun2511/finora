import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../data/services/loan_api_service.dart';
import '../../data/services/mock_loan_api_service.dart';
import '../../domain/repositories/loan_repository.dart';

const bool kUseMockLoanApi =
    bool.fromEnvironment('USE_MOCK_API', defaultValue: true);

/// Dependency Injection cho feature Loans.
/// Mặc định dùng Mock để chạy demo, set USE_MOCK_API=false để dùng backend thật.
final loanApiServiceProvider = Provider<LoanApiService>((ref) {
  if (kUseMockLoanApi) {
    return MockLoanApiService();
  }
  return DioLoanApiService(ref.watch(dioProvider));
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl(ref.watch(loanApiServiceProvider));
});
