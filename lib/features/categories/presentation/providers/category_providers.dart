import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/services/category_api_service.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_type.dart';
import '../../domain/repositories/category_repository.dart';

final categoryApiServiceProvider = Provider<CategoryApiService>((ref) {
  return DioCategoryApiService(ref.watch(dioProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryApiServiceProvider));
});

/// Provider lấy danh sách danh mục CHI TIÊU (Expense) từ API GET /categories?type=EXPENSE
final expenseCategoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories(type: CategoryType.expense);
});

/// Provider lấy danh sách danh mục THU NHẬP (Income) từ API GET /categories?type=INCOME
final incomeCategoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories(type: CategoryType.income);
});

