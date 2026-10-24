import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_category.dart';
import '../../domain/models/product_input.dart';
import '../../domain/validators/product_validators.dart';
import '../providers/product_detail_provider.dart';
import '../providers/product_form_provider.dart';

/// Dùng cho cả tạo mới (productId == null) và chỉnh sửa.
class ProductFormScreen extends ConsumerWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  bool get isEdit => productId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới';

    if (!isEdit) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const _ProductForm(),
      );
    }

    // Chế độ sửa: tải sản phẩm trước rồi mới dựng form.
    final async = ref.watch(productDetailProvider(productId!));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final msg = e is AppException ? e.message : e.toString();
          return Center(child: Text(msg));
        },
        data: (p) => _ProductForm(initial: p),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({this.initial});

  final Product? initial;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _imageUrl;
  late ProductCategory _category;
  late bool _isAvailable;

  String? get _productId => widget.initial?.id;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(
      text: p == null
          ? ''
          : (p.price == p.price.roundToDouble()
              ? p.price.toStringAsFixed(0)
              : p.price.toString()),
    );
    _stock = TextEditingController(text: p == null ? '10' : '${p.stock}');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _category = p?.category ?? ProductCategory.other;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final image = _imageUrl.text.trim();
    final input = ProductInput(
      name: _name.text.trim(),
      sku: _sku.text.trim().toUpperCase(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim().replaceAll(',', '.')),
      stock: int.parse(_stock.text.trim()),
      category: _category,
      imageUrl: image.isEmpty ? null : image,
      isAvailable: _isAvailable,
    );

    final saved =
        await ref.read(productFormProvider(_productId).notifier).submit(input);

    if (saved != null && mounted) {
      AppToast.success(
        context,
        _productId == null
            ? 'Đã tạo sản phẩm thành công!'
            : 'Đã cập nhật sản phẩm thành công!',
      );
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider(_productId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (formState.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formState.errorMessage!,
                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên sản phẩm *',
              hintText: 'VD: Bàn phím cơ không dây Finora Pro',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
            validator: ProductValidators.validateName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _sku,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Mã SKU *',
              hintText: 'VD: KB-FINORA-PRO-01',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
            validator: ProductValidators.validateSku,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProductCategory>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Danh mục *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              for (final c in ProductCategory.values)
                DropdownMenuItem(value: c, child: Text(c.label)),
            ],
            onChanged: (c) {
              if (c != null) setState(() => _category = c);
            },
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Giá (₫) *',
                    hintText: 'VD: 1450000',
                    border: OutlineInputBorder(),
                    suffixText: '₫',
                  ),
                  validator: ProductValidators.validatePrice,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Tồn kho *',
                    hintText: 'VD: 50',
                    border: OutlineInputBorder(),
                  ),
                  validator: ProductValidators.validateStock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Mô tả chi tiết',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _imageUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL ảnh (tuỳ chọn)',
              hintText: 'https://images.unsplash.com/...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.image_outlined),
            ),
            validator: ProductValidators.validateImageUrl,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mở bán sản phẩm'),
            subtitle: Text(
              _isAvailable
                  ? 'Sản phẩm đang hiển thị và mở bán'
                  : 'Sản phẩm tạm dừng bán',
              style: AppTextStyles.caption,
            ),
            value: _isAvailable,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isAvailable = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
              ),
            ),
            onPressed: formState.isSubmitting ? null : _submit,
            child: formState.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _productId == null ? 'Tạo sản phẩm' : 'Lưu thay đổi',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
