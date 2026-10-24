import 'dart:math' as math;

import '../../../../core/errors/app_exception.dart';
import '../dto/create_product_request.dart';
import '../dto/product_list_query.dart';
import '../dto/product_page_response.dart';
import '../dto/product_response.dart';
import '../dto/update_product_request.dart';
import 'product_api_service.dart';

/// Backend giả lập lưu trong bộ nhớ, để chạy demo không cần server.
class MockProductApiService implements ProductApiService {
  MockProductApiService() {
    _seed();
  }

  final List<ProductResponse> _items = [];
  int _nextId = 1;
  static const _latency = Duration(milliseconds: 400);

  void _seed() {
    const cats = ['electronics', 'fashion', 'home', 'books', 'sports', 'other'];
    const names = [
      'Tai nghe Bluetooth Solarn Pro',
      'Áo thun cotton Finora FinTech',
      'Đèn ngủ LED thông minh Nora',
      'Sách Lập trình Tài chính Cá nhân',
      'Giày chạy bộ thể thao Solarn',
      'Bàn phím cơ không dây Finora Pro',
      'Quần jean phong cách trẻ',
      'Nồi chiên không dầu điện tử',
      'Sổ tay Tài chính Thông minh',
      'Vợt cầu lông thi đấu',
    ];
    final now = DateTime.now();
    for (var i = 0; i < 57; i++) {
      final created = now.subtract(Duration(hours: i * 5));
      _items.add(
        ProductResponse(
          id: '${_nextId++}',
          name: '${names[i % names.length]} #${i + 1}',
          sku: 'FNO-${cats[i % cats.length].substring(0, 3).toUpperCase()}-${100 + i}',
          description: 'Mô tả chi tiết sản phẩm cao cấp số ${i + 1} của hệ sinh thái Finora.',
          price: (50 + (i * 37) % 950) * 1000.0,
          stock: i % 7 == 0 ? 0 : (i * 3) % 40 + 1,
          category: cats[i % cats.length],
          isAvailable: true,
          createdAt: created,
          updatedAt: created,
        ),
      );
    }
  }

  @override
  Future<ProductPageResponse> getProducts(ProductListQuery q) async {
    await Future<void>.delayed(_latency);

    final keyword = q.search?.toLowerCase();
    final list = _items.where((p) {
      if (keyword != null &&
          !'${p.name} ${p.sku} ${p.description}'.toLowerCase().contains(keyword)) {
        return false;
      }
      if (q.category != null && p.category != q.category) return false;
      if (q.minPrice != null && p.price < q.minPrice!) return false;
      if (q.maxPrice != null && p.price > q.maxPrice!) return false;
      if (q.isAvailable != null && p.isAvailable != q.isAvailable) return false;
      return true;
    }).toList();

    int cmp(ProductResponse a, ProductResponse b) {
      switch (q.sortBy) {
        case 'price':
          return a.price.compareTo(b.price);
        case 'name':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        default:
          return a.createdAt.compareTo(b.createdAt);
      }
    }

    final isDesc = q.sortOrder.toLowerCase() == 'desc';
    list.sort((a, b) => isDesc ? cmp(b, a) : cmp(a, b));

    final total = list.length;
    final totalPages = math.max(1, (total / q.limit).ceil());
    final start = (q.page - 1) * q.limit;
    final slice = start >= total
        ? <ProductResponse>[]
        : list.sublist(start, math.min(start + q.limit, total));

    return ProductPageResponse(
      data: slice,
      page: q.page,
      limit: q.limit,
      total: total,
      totalPages: totalPages,
    );
  }

  @override
  Future<ProductResponse> getProduct(String id) async {
    await Future<void>.delayed(_latency);
    return _items.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const AppException(
        'Không tìm thấy sản phẩm.',
        statusCode: 404,
      ),
    );
  }

  @override
  Future<ProductResponse> createProduct(CreateProductRequest r) async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now();
    final created = ProductResponse(
      id: '${_nextId++}',
      name: r.name,
      sku: r.sku,
      description: r.description,
      price: r.price,
      stock: r.stock,
      category: r.category,
      imageUrl: r.imageUrl,
      isAvailable: r.isAvailable,
      createdAt: now,
      updatedAt: now,
    );
    _items.insert(0, created);
    return created;
  }

  @override
  Future<ProductResponse> updateProduct(
    String id,
    UpdateProductRequest r,
  ) async {
    await Future<void>.delayed(_latency);
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw const AppException('Không tìm thấy sản phẩm.', statusCode: 404);
    }
    final old = _items[index];
    final image = r.imageUrl;
    final updated = ProductResponse(
      id: old.id,
      name: r.name ?? old.name,
      sku: r.sku ?? old.sku,
      description: r.description ?? old.description,
      price: r.price ?? old.price,
      stock: r.stock ?? old.stock,
      category: r.category ?? old.category,
      imageUrl: image == null ? old.imageUrl : (image.isEmpty ? null : image),
      isAvailable: r.isAvailable ?? old.isAvailable,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future<void>.delayed(_latency);
    final before = _items.length;
    _items.removeWhere((p) => p.id == id);
    if (_items.length == before) {
      throw const AppException('Không tìm thấy sản phẩm.', statusCode: 404);
    }
  }
}
