import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/services/budget_api_service.dart';
import '../../domain/repositories/budget_repository.dart';

/// Dependency injection cho feature budgets.
final budgetApiServiceProvider = Provider<BudgetApiService>((ref) {
  return DioBudgetApiService(ref.watch(dioProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(budgetApiServiceProvider));
});

