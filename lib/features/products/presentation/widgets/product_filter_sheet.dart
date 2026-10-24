import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/product_category.dart';
import '../../domain/models/product_filter.dart';
import '../providers/product_filter_provider.dart';

Future<void> showProductFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusLg)),
    ),
    builder: (_) => const _ProductFilterSheet(),
  );
}

class _ProductFilterSheet extends ConsumerStatefulWidget {
  const _ProductFilterSheet();

  @override
  ConsumerState<_ProductFilterSheet> createState() =>
      _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<_ProductFilterSheet> {
  ProductCategory? _category;
  bool? _inStock;
  late ProductSortField _sortBy;
  late SortOrder _sortOrder;
  late final TextEditingController _min;
  late final TextEditingController _max;

  @override
  void initState() {
    super.initState();
    final f = ref.read(productFilterProvider);
    _category = f.category;
    _inStock = f.inStock;
    _sortBy = f.sortBy;
    _sortOrder = f.sortOrder;
    _min = TextEditingController(text: _fmt(f.minPrice));
    _max = TextEditingController(text: _fmt(f.maxPrice));
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  String _fmt(double? v) => v == null ? '' : v.toStringAsFixed(0);

  double? _parse(String s) {
    final cleaned = s.replaceAll('.', '').replaceAll(',', '').trim();
    return cleaned.isEmpty ? null : double.tryParse(cleaned);
  }

  void _resetDraft() {
    setState(() {
      _category = null;
      _inStock = null;
      _sortBy = ProductSortField.createdAt;
      _sortOrder = SortOrder.desc;
      _min.clear();
      _max.clear();
    });
  }

  void _apply() {
    var min = _parse(_min.text);
    var max = _parse(_max.text);
    if (min != null && max != null && min > max) {
      final t = min;
      min = max;
      max = t;
    }

    final current = ref.read(productFilterProvider);
    ref.read(productFilterProvider.notifier).apply(
          ProductFilter(
            search: current.search,
            category: _category,
            minPrice: min,
            maxPrice: max,
            inStock: _inStock,
            sortBy: _sortBy,
            sortOrder: _sortOrder,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Bộ lọc & Sắp xếp', style: theme.textTheme.titleLarge),
                  ),
                  TextButton(onPressed: _resetDraft, child: const Text('Đặt lại')),
                ],
              ),
              const SizedBox(height: 8),

              const _SectionTitle('Danh mục'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final c in ProductCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              const _SectionTitle('Khoảng giá (₫)'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _min,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Từ',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _max,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Đến',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const _SectionTitle('Tồn kho'),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _inStock == null,
                    onSelected: (_) => setState(() => _inStock = null),
                  ),
                  ChoiceChip(
                    label: const Text('Còn hàng'),
                    selected: _inStock == true,
                    onSelected: (_) => setState(() => _inStock = true),
                  ),
                  ChoiceChip(
                    label: const Text('Hết hàng'),
                    selected: _inStock == false,
                    onSelected: (_) => setState(() => _inStock = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const _SectionTitle('Sắp xếp theo'),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in ProductSortField.values)
                    ChoiceChip(
                      label: Text(s.label),
                      selected: _sortBy == s,
                      onSelected: (_) => setState(() => _sortBy = s),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final o in SortOrder.values)
                    ChoiceChip(
                      label: Text(o.label),
                      selected: _sortOrder == o,
                      onSelected: (_) => setState(() => _sortOrder = o),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _apply,
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
