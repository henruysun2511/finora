# TÀI LIỆU KỸ THUẬT NỘI BỘ
## Hướng Dẫn Xây Dựng Feature Hoàn Chỉnh (Clean Architecture)

| Thông tin | Chi tiết |
| :--- | :--- |
| **Dự án** | FINORA Mobile (Flutter) |
| **Feature chuẩn mẫu** | `lib/features/products` |
| **Kiến trúc** | Clean Architecture: Presentation, Domain, Data |
| **State management** | Riverpod |
| **Network** | DioClient |
| **Đối tượng đọc** | Lập trình viên mobile tham gia phát triển feature mới |

---

### MỤC TIÊU
Tài liệu này là kim chỉ nam (Golden Standard) hướng dẫn lập trình viên xây dựng một feature mới từ A đến Z theo mô hình Clean Architecture kết hợp Riverpod 2.x Notifier, dựa trên kiến trúc thực tế của feature chuẩn mẫu `lib/features/products`.

---

## Mục lục
1. [Triết lý kiến trúc và luồng dữ liệu](#1-triết-lý-kiến-trúc-và-luồng-dữ-liệu)
   - [1.1. Sơ đồ luồng dữ liệu tổng quát](#11-sơ-đồ-luồng-dữ-liệu-tổng-quát)
   - [1.2. Hai luồng tương tác thực tế](#12-hai-luồng-tương-tác-thực-tế)
   - [1.3. Nguyên tắc bất biến (Dependency Rule)](#13-nguyên-tắc-bất-biến-dependency-rule)
2. [Cấu trúc thư mục chuẩn](#2-cấu-trúc-thư-mục-chuẩn)
3. [Quy trình 3 bước triển khai](#3-quy-trình-3-bước-triển-khai)
   - [3.1. Bước 1: Tầng Domain (Core Business)](#31-bước-1-tầng-domain-core-business)
   - [3.2. Bước 2: Tầng Data (API và DTO)](#32-bước-2-tầng-data-api-và-dto)
   - [3.3. Bước 3: Tầng Presentation (State Management và UI)](#33-bước-3-tầng-presentation-state-management-và-ui)
4. [Tối ưu UX và xử lý lỗi theo chuẩn FinTech](#4-tối-ưu-ux-và-xử-lý-lỗi-theo-chuẩn-fintech)
5. [Quy chuẩn kiểm thử (Unit Testing)](#5-quy-chuẩn-kiểm-thử-unit-testing)
6. [Checklist nghiệm thu feature](#6-checklist-nghiệm-thu-feature)
7. [Quy trình làm việc với Git](#7-quy-trình-làm-việc-với-git)
   - [7.1. Quy ước đặt tên nhánh](#71-quy-ước-đặt-tên-nhánh)
   - [7.2. Các bước thực hiện chi tiết](#72-các-bước-thực-hiện-chi-tiết)

---

## 1. Triết lý kiến trúc và luồng dữ liệu

Dự án **FINORA Mobile** tuân thủ nghiêm ngặt Clean Architecture với 3 tầng chính. Mỗi tầng chỉ làm đúng một nhiệm vụ, nhờ vậy khi cần đổi giao diện, đổi API hay viết test, ta không phải đụng vào toàn bộ hệ thống.

```
+-----------------------------------------------------------------------+
|                             PRESENTATION                              |
|           Screens · Widgets · Providers / Notifiers · States          |
+-----------------------------------------------------------------------+
                                    |
                                    | phụ thuộc vào (depends on)
                                    v
+-----------------------------------------------------------------------+
|                                DOMAIN                                 |
|            Entities / Models · Repository Interfaces · Validators      |
+-----------------------------------------------------------------------+
                                    ^
                                    | triển khai (implements)
                                    |
+-----------------------------------------------------------------------+
|                                 DATA                                  |
|            DTOs · Mappers · Api Services · Repository Impl            |
+-----------------------------------------------------------------------+
```
*Hình 1. Kiến trúc 3 tầng của một feature: mọi mũi tên phụ thuộc đều hướng về Domain.*

#### Bảng 1. Vai trò và ranh giới của từng tầng
| Tầng | Trách nhiệm | Thành phần chính | Được phụ thuộc vào | Không được import |
| :--- | :--- | :--- | :--- | :--- |
| **Presentation** | Hiển thị UI, nhận thao tác người dùng và quản lý state. | Screens, Widgets, Providers / Notifiers, States | Domain | DTO, ApiService (trừ file DI) |
| **Domain** | Nghiệp vụ cốt lõi: feature này làm gì, dữ liệu gồm những gì. | Entities / Models, Repository Interfaces, Validators | Chỉ Dart thuần | Data, Presentation, Flutter UI, Dio / HTTP |
| **Data** | Làm việc với nguồn dữ liệu (API) và chuyển đổi dữ liệu. | DTOs, Mappers, Api Services, Repository Impl | Domain, DioClient | Presentation |

> **Lưu ý:** File DI `<model>_providers.dart` trong `presentation/providers/` là ngoại lệ duy nhất, vì nó cần import `ProductApiService` và `ProductRepositoryImpl` để khai báo provider.

---

### 1.1. Sơ đồ luồng dữ liệu tổng quát

Sơ đồ dưới đây cho thấy các thành phần phối hợp với nhau thế nào khi xử lý một yêu cầu, từ lúc người dùng thao tác trên màn hình cho tới khi backend trả kết quả và UI được cập nhật. Số thứ tự trên mũi tên tương ứng với bảng giải thích phía dưới.

```
TẦNG PRESENTATION
┌─────────────────────────┐   (2) submit / loadMore   ┌──────────────────────────┐
│     Screen / Widget     │ ────────────────────────> │      State Notifier      │
│                         │ <──────────────────────── │        (Riverpod)        │
└────────────┬────────────┘  (10) cập nhật state      └────────────┬─────────────┘
             │                    & rebuild UI                     │
         (1) │                                                 (3) │
             v                                                     v
TẦNG DOMAIN  │                                                     │
┌────────────┴────────────┐                           ┌────────────┴─────────────┐    ┌─────────────────┐
│       Validators        │                           │   Repository Interface   │    │  Entity Models  │
└─────────────────────────┘                           └────────────┬─────────────┘    └────────┬────────┘
                                                                   ┊                           ^
                                                             thực thi bởi (implements)        │ (10)
                                                                   ┊                           │
TẦNG DATA                                                          v                           │
                                                      ┌──────────────────────────┐             │
                                                      │     Repository Impl      │             │
                                                      └──────┬────────────^──────┘             │
                                                         (4) │            │ (8)                │
                                                             v            │                    │ (9)
                                                      ┌───────────────────┴──────┐             │
                                                      │         Mappers          │─────────────┘
                                                      └──────────────────────────┘
                                                                   ┊
                                                          DTOs (Request / Response)
                                                                   ┊
                                                      ┌────────────┴─────────────┐
                                                      │       Api Service        │
                                                      │       (DioClient)        │
                                                      └──────┬────────────^──────┘
                                                         (6) │            │ (7) JSON Response
                                                             v            │
HE THONG BACKEND                                      ┌──────────────────────────┐
                                                      │   NestJS Backend API     │
                                                      └──────────────────────────┘
```
*Hình 2. Luồng dữ liệu đi qua các tầng.*

#### Bảng 2. Giải thích 10 bước của luồng dữ liệu
| # | Bước | Thành phần tham gia | Mô tả |
| :-: | :--- | :--- | :--- |
| **1** | Validate dữ liệu đầu vào | Screen → Validators | Màn hình gọi các hàm validator (Domain) để kiểm tra dữ liệu trước khi gửi đi. |
| **2** | Kích hoạt action | Screen → Notifier | Người dùng bấm lưu / cuộn tới cuối danh sách, Screen gọi `submit()` hoặc `loadMore()`. |
| **3** | Gọi nghiệp vụ qua Interface | Notifier → Repository Interface | Notifier chỉ biết Interface, không biết dữ liệu đến từ API hay local DB. |
| **4** | Entity → Request DTO | Repository Impl → Mapper | Chuyển dữ liệu nghiệp vụ sang định dạng mà backend yêu cầu. |
| **5** | Gọi HTTP request | Repository Impl → Api Service | Api Service đóng gói lời gọi HTTP qua DioClient. |
| **6** | Gửi API qua Dio | Api Service → NestJS Backend | Request được gửi tới backend. |
| **7** | Nhận JSON Response | NestJS Backend → Api Service | Backend trả JSON, Api Service parse thành Response DTO. |
| **8** | Response DTO → Entity | Repository Impl → Mapper | Chuyển dữ liệu mạng sang Domain Entity. |
| **9** | Trả Domain Entity | Mapper → Notifier | Entity (hoặc `PagedResult<Entity>`) được trả ngược lên Notifier. |
| **10** | Cập nhật State & rebuild UI | Notifier → Screen | Notifier cập nhật state, Riverpod rebuild các widget đang theo dõi. |

---

### 1.2. Hai luồng tương tác thực tế

#### A. Luồng hiển thị và tìm kiếm danh sách (Read Flow)
Luồng này mô tả quá trình người dùng tìm kiếm sản phẩm, có cơ chế chống spam bằng **debounce 400ms** để không gửi request liên tục lên backend.

```
Người dùng    ProductSearchBar    ProductListNotifier    ProductRepository    ProductApiService    NestJS API    ProductsScreen
   │                 │                    │                      │                   │                 │               │
   │──Gõ từ khóa────>│                    │                      │                   │                 │               │
   │  tìm kiếm       │                    │                      │                   │                 │               │
   │                 │──[Chờ 400ms]──────>│                      │                   │                 │               │
   │                 │  Update Filter     │                      │                   │                 │               │
   │                 │                    │──state=AsyncLoading─>│                   │                 │               │
   │                 │                    │                      │                   │                 │               │
   │                 │                    │──getProducts(filter)─>│                   │                 │               │
   │                 │                    │                      │──getProducts()───>│                 │               │
   │                 │                    │                      │                   │──GET /products─>│               │
   │                 │                    │                      │                   │<─200 OK (JSON)──│               │
   │                 │                    │                      │<─DTO Page Response│                 │               │
   │                 │                    │                      │                   │                 │               │
   │                 │                    │                      │ [ProductMapper    │                 │               │
   │                 │                    │                      │  .toDomain()]     │                 │               │
   │                 │                    │<─PagedResult<Product>│                   │                 │               │
   │                 │                    │                      │                   │                 │               │
   │                 │                    │───────────────────────────────────────────────────────────>│
   │                 │                    │                   Emit AsyncData                           │
   │<──────────────────────────────────────────────────────────────────────────────────────────────────│
   │                                   Hiển thị danh sách ProductCard                                  │
```
*Hình 3. Sequence diagram: Tìm kiếm sản phẩm với debounce 400ms.*

**Những điểm cần nhớ ở luồng đọc:**
- Ô tìm kiếm chờ 400ms sau lần gõ cuối cùng mới cập nhật `ProductFilter`.
- `ProductListNotifier` theo dõi filter (`ref.watch`), nên khi filter đổi, nó tự chuyển state sang `AsyncLoading()` rồi tải lại trang 1.
- Việc chuyển DTO sang Entity (`ProductMapper.toDomain()`) diễn ra trong Repository, Notifier và UI không bao giờ nhìn thấy DTO.

#### B. Luồng tạo mới / chỉnh sửa và validate (Write Flow)
Luồng này mô tả người dùng nhập form, hệ thống validate ở 2 lớp và cập nhật state tương ứng với từng kết quả.

#### Bảng 3. Hai lớp validation trong luồng ghi dữ liệu
| Lớp | Thực hiện ở đâu | Phát hiện loại lỗi nào | Cách hiển thị cho người dùng |
| :--- | :--- | :--- | :--- |
| **Lớp 1: Client** | `ProductValidators` + `formKey.currentState.validate()` | Dữ liệu rỗng, quá ngắn / quá dài, sai định dạng (ví dụ SKU chứa ký tự đặc biệt). | Viền đỏ và thông báo ngay dưới ô nhập liệu. |
| **Lớp 2: Backend** | NestJS API trả lỗi, Repository ném `AppException` | Ràng buộc cần dữ liệu phía server, ví dụ trùng SKU / tên (409 Conflict). | Banner lỗi màu đỏ ở đầu form, lấy từ `errorMessage` trong state. |

---

### 1.3. Nguyên tắc bất biến (Dependency Rule)
- **Domain độc lập tuyệt đối:** không import code từ tầng Data hay Presentation, không phụ thuộc bất kỳ thư viện UI hay HTTP nào.
- **Data phụ thuộc Domain:** triển khai các Repository Interface của Domain, đồng thời chuyển đổi qua lại giữa DTO (dữ liệu mạng) và Domain Model (dữ liệu nghiệp vụ).
- **Presentation phụ thuộc Domain:** chỉ làm việc với Domain Entities và Repository Interface thông qua các Riverpod Provider.

> 💡 **MẸO - Cách tự kiểm tra nhanh:**  
> Mở bất kỳ file nào trong `domain/` và nhìn phần import. Nếu thấy `package:flutter/...`, `package:dio/...` hoặc đường dẫn chứa `/data/` hay `/presentation/` thì cấu trúc đang bị sai.

---

## 2. Cấu trúc thư mục chuẩn

Khi tạo một feature mới (ví dụ `customers`, `debts`, `transactions`), hãy tổ chức thư mục giống hệt feature mẫu `features/products`. Đặt tên theo đúng quy ước giúp cả nhóm mở feature nào cũng biết file nằm ở đâu.

```text
lib/features/<feature_name>/
├── domain/
│   ├── models/                    # Thực thể nghiệp vụ (Entities)
│   │   ├── <model>.dart           # Entity chính (Product)
│   │   ├── <model>_input.dart     # Dữ liệu đầu vào khi Create/Update
│   │   ├── <model>_filter.dart    # Tiêu chí lọc/sắp xếp
│   │   └── <model>_category.dart  # Enums liên quan
│   ├── repositories/
│   │   └── <model>_repository.dart# Interface (hợp đồng dữ liệu)
│   └── validators/
│       └── <model>_validators.dart# Pure functions kiểm tra dữ liệu
│
├── data/
│   ├── dto/                       # Data Transfer Objects khớp API Backend
│   │   ├── <model>_response.dart
│   │   ├── <model>_page_response.dart
│   │   ├── create_<model>_request.dart
│   │   └── update_<model>_request.dart
│   ├── mappers/                   # Chuyển đổi DTO <-> Domain Model
│   │   └── <model>_mapper.dart
│   ├── services/                  # Gọi HTTP qua DioClient
│   │   ├── <model>_api_service.dart
│   │   └── mock_<model>_api_service.dart (tuỳ chọn)
│   └── repositories/              # Thực thi Repository Interface
│       └── <model>_repository_impl.dart
│
├── presentation/
│   ├── providers/                 # State management với Riverpod Notifier
│   │   ├── <model>_providers.dart # DI cho Service, Repository
│   │   ├── <model>_list_provider.dart
│   │   ├── <model>_list_state.dart
│   │   ├── <model>_detail_provider.dart
│   │   ├── <model>_form_provider.dart
│   │   ├── <model>_form_state.dart
│   │   └── <model>_filter_provider.dart
│   ├── screens/                   # Các màn hình chính
│   │   ├── <model>s_screen.dart       # Danh sách
│   │   ├── <model>_detail_screen.dart # Chi tiết
│   │   └── <model>_form_screen.dart   # Thêm mới / Chỉnh sửa
│   └── widgets/                   # Các thành phần giao diện nhỏ
│       ├── <model>_card.dart
│       ├── <model>_search_bar.dart
│       ├── <model>_filter_sheet.dart
│       └── <model>_filter_chips.dart
│
└── <feature_name>.dart            # Barrel file export các file cần thiết
```

#### Bảng 4. Ý nghĩa các thư mục và file chính
| Đường dẫn | Tầng | Vai trò |
| :--- | :--- | :--- |
| `domain/models/` | Domain | Entity chính, Input (dữ liệu form), Filter (lọc / sắp xếp) và các enum liên quan. |
| `domain/repositories/` | Domain | Interface mô tả những gì feature cần từ nguồn dữ liệu, không quan tâm triển khai bên dưới. |
| `domain/validators/` | Domain | Các hàm static thuần (pure function) kiểm tra dữ liệu, dùng được cả trong UI lẫn unit test. |
| `data/dto/` | Data | Class map 1-1 với JSON của backend NestJS (response, page response, create / update request). |
| `data/mappers/` | Data | Chuyển đổi hai chiều DTO ↔ Domain Model. |
| `data/services/` | Data | Api Service gọi HTTP qua DioClient; có thể thêm mock service để chạy khi backend chưa sẵn sàng. |
| `data/repositories/` | Data | Triển khai Repository Interface bằng Api Service + Mapper. |
| `presentation/providers/` | Presentation | DI, list / detail / form / filter notifier và các class state tương ứng. |
| `presentation/screens/` | Presentation | Màn hình danh sách, chi tiết, thêm mới / chỉnh sửa. |
| `presentation/widgets/` | Presentation | Widget nhỏ tái sử dụng: card, thanh tìm kiếm, bottom sheet lọc, filter chips. |
| `<feature_name>.dart` | Gốc feature | Barrel file: chỉ export những gì bên ngoài feature được phép dùng. |

---

## 3. Quy trình 3 bước triển khai

Luôn làm theo thứ tự **Domain → Data → Presentation**. Domain không phụ thuộc gì nên có thể hoàn thiện và test trước; Data và Presentation sau đó chỉ việc bám vào hợp đồng mà Domain đã định nghĩa.

#### Bảng 5. Tổng quan 3 bước triển khai
| Bước | Tầng | Việc cần làm | Kết quả đầu ra |
| :-: | :--- | :--- | :--- |
| **Bước 1** | Domain | Định nghĩa Entity, Input, Filter, Repository Interface và Validators. | Hợp đồng nghiệp vụ, test được ngay. |
| **Bước 2** | Data | Viết DTO, Mapper, Api Service và Repository Impl. | Kết nối được với backend NestJS. |
| **Bước 3** | Presentation | Khai báo Provider, viết Notifier / State, dựng Screen và Widget. | Feature chạy được trên app. |

---

### 3.1. Bước 1: Tầng Domain (Core Business)

Luôn bắt đầu từ Domain vì đây là nơi trả lời câu hỏi "feature này làm gì và chứa dữ liệu gì".

#### Bước 1.1: Entity chính
File `domain/models/product.dart`. Entity chỉ chứa các trường dữ liệu thuần Dart: id, ngày tạo và các thuộc tính nghiệp vụ.

```dart
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.category,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final double price;
  final int stock;
  final ProductCategory category;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

#### Bước 1.2: Dữ liệu đầu vào của form
File `domain/models/product_input.dart`. Dùng khi người dùng nhập liệu ở màn hình Tạo / Sửa. Input không có `id` và các trường do server sinh ra (`createdAt`, `updatedAt`).

```dart
class ProductInput {
  const ProductInput({
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.category,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  final String name;
  final String sku;
  final double price;
  final int stock;
  final ProductCategory category;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
}
```

#### Bước 1.3: Repository Interface
File `domain/repositories/product_repository.dart`. Định nghĩa hợp đồng dữ liệu, không phụ thuộc vào nguồn (API hay local DB).

```dart
abstract class ProductRepository {
  Future<PagedResult<Product>> getProducts(ProductFilter filter);
  Future<Product> getProductById(String id);
  Future<Product> createProduct(ProductInput input);
  Future<Product> updateProduct(String id, ProductInput input);
  Future<void> deleteProduct(String id);
}
```

#### Bước 1.4: Validator độc lập
File `domain/validators/product_validators.dart`. Tách hoàn toàn phần validation ra khỏi UI, viết dưới dạng pure static function. Nhờ vậy cùng một bộ luật dùng được cho form, và test được mà không cần dựng widget.

```dart
class ProductValidators {
  ProductValidators._();

  static final _skuRegex = RegExp(r'^[A-Z0-9\-_]+$');

  static String? validateName(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập tên sản phẩm';
    if (t.length < 2) return 'Tên quá ngắn (tối thiểu 2 ký tự)';
    if (t.length > 200) return 'Tên tối đa 200 ký tự';
    return null;
  }

  static String? validateSku(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng nhập mã SKU';
    if (t.length < 2) return 'Mã SKU tối thiểu 2 ký tự';
    if (!_skuRegex.hasMatch(t.toUpperCase())) {
      return 'Mã SKU chỉ gồm chữ cái, số, gạch ngang (-) hoặc gạch dưới (_)';
    }
    return null;
  }
}
```

> 📌 **GHI CHÚ - Quy ước validator:**  
> Hàm trả về `null` khi dữ liệu hợp lệ, trả về chuỗi thông báo lỗi (tiếng Việt) khi không hợp lệ. Đây cũng là chữ ký mà `TextFormField.validator` yêu cầu.  
> Luôn `trim()` trước khi kiểm tra và xử lý cả trường hợp `null`.

---

### 3.2. Bước 2: Tầng Data (API và DTO)

#### Bước 2.1: DTOs
Thư mục `data/dto/`. DTO map 1-1 với JSON của backend NestJS, nên kiểu dữ liệu bám sát những gì API trả về (ví dụ `price` là `num`, `category` là `String`).

```dart
class ProductResponse {
  final String id;
  final String name;
  final String sku;
  final num price;
  final int stock;
  final String category;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  factory ProductResponse.fromJson(Map<String, dynamic> json) => ...;
}
```

#### Bước 2.2: Mapper
File `data/mappers/product_mapper.dart`. Chuyển đổi giữa DTO và Domain Entity. Đây là nơi duy nhất biết cả hai phía, nên mọi logic "đổi kiểu" (như `num` → `double`, `String` → `enum`) đều nằm ở đây.

```dart
class ProductMapper {
  static Product toDomain(ProductResponse dto) {
    return Product(
      id: dto.id,
      name: dto.name,
      sku: dto.sku,
      price: dto.price.toDouble(),
      stock: dto.stock,
      category: ProductCategory.fromValue(dto.category),
      description: dto.description,
      imageUrl: dto.imageUrl,
      isAvailable: dto.isAvailable,
    );
  }

  static CreateProductRequest toCreateRequest(ProductInput input) {
    return CreateProductRequest(
      name: input.name,
      sku: input.sku,
      price: input.price,
      stock: input.stock,
      category: input.category.name,
      description: input.description,
      imageUrl: input.imageUrl,
      isAvailable: input.isAvailable,
    );
  }
}
```

#### Bước 2.3: API Service
File `data/services/product_api_service.dart`. Sử dụng DioClient dùng chung của hệ thống. Lớp này chỉ lo gọi HTTP và parse JSON thành DTO, không chứa logic nghiệp vụ.

```dart
class ProductApiService {
  ProductApiService(this._dio);
  final DioClient _dio;

  Future<ProductPageResponse> getProducts(ProductListQuery query) async {
    final res = await _dio.get('/products', queryParameters: query.toJson());
    return ProductPageResponse.fromJson(res.data['data']);
  }

  Future<ProductResponse> createProduct(CreateProductRequest req) async {
    final res = await _dio.post('/products', data: req.toJson());
    return ProductResponse.fromJson(res.data['data']);
  }
}
```

#### Bước 2.4: Repository Implementation
File `data/repositories/product_repository_impl.dart`. Gọi API Service rồi dùng Mapper để trả về Domain Entity cho tầng trên.

```dart
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._api);
  final ProductApiService _api;

  @override
  Future<Product> createProduct(ProductInput input) async {
    final req = ProductMapper.toCreateRequest(input);
    final res = await _api.createProduct(req);
    return ProductMapper.toDomain(res);
  }
}
```

---

### 3.3. Bước 3: Tầng Presentation (State Management và UI)

#### Bước 3.1: Dependency Injection
File `presentation/providers/product_providers.dart`. Khai báo provider cho API Service và Repository. Phía trên chỉ cần `ref.watch(productRepositoryProvider)` là có Repository, không cần biết nó được tạo ra thế nào.

```dart
final productApiServiceProvider = Provider<ProductApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProductApiService(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final api = ref.watch(productApiServiceProvider);
  return ProductRepositoryImpl(api);
});
```

#### Bước 3.2: List State Notifier
File `presentation/providers/product_list_provider.dart`. Notifier này chịu trách nhiệm:
- Tải trang đầu và phân trang vô hạn (`loadMore`).
- Pull-to-refresh.
- Lọc và sắp xếp: khi filter đổi thì danh sách tự động tải lại.
- Xóa sản phẩm khỏi danh sách ngay sau khi API xóa thành công, không cần tải lại toàn bộ.

```dart
class ProductListNotifier extends AsyncNotifier<ProductListState> {
  @override
  Future<ProductListState> build() async {
    final filter = ref.watch(productFilterProvider);
    return _fetchPage(page: 1, filter: filter);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    // Tải trang tiếp theo và gộp dữ liệu
  }

  Future<void> deleteProduct(String id) async {
    await ref.read(productRepositoryProvider).deleteProduct(id);
    // Cập nhật state cục bộ, loại bỏ item
    final cur = state.value;
    if (cur != null) {
      state = AsyncData(cur.copyWith(
        items: cur.items.where((p) => p.id != id).toList(),
        total: cur.total - 1,
      ));
    }
  }
}
```

#### Bước 3.3: Form State Notifier
File `presentation/providers/product_form_provider.dart`. Dùng `AutoDisposeFamilyNotifier<ProductFormState, String?>`: tham số `String?` là id của sản phẩm. `null` nghĩa là đang tạo mới, có giá trị nghĩa là đang chỉnh sửa.

```dart
class ProductFormNotifier extends AutoDisposeFamilyNotifier<ProductFormState, String?> {
  @override
  ProductFormState build(String? id) => const ProductFormState();

  Future<Product?> submit(ProductInput input) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(productRepositoryProvider);
      final saved = arg == null
          ? await repo.createProduct(input)
          : await repo.updateProduct(arg!, input);

      // Invalidate các provider liên quan
      ref.invalidate(productListProvider);
      if (arg != null) ref.invalidate(productDetailProvider(arg!));

      state = state.copyWith(isSubmitting: false);
      return saved;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return null;
    }
  }
}
```

> 💡 **MẸO - Vì sao có dòng `if (state.isSubmitting) return null;`?**  
> Dòng này chặn việc người dùng bấm nút lưu nhiều lần liên tiếp. Với feature tài chính, gửi trùng một request tạo mới có thể sinh ra dữ liệu bị nhân đôi.

#### Bước 3.4: Form UI
File `presentation/screens/product_form_screen.dart`. Màn hình form cần tích hợp:
- `FormKey` để kiểm tra dữ liệu trước khi gửi.
- Dùng `ProductValidators` cho thuộc tính `validator` của từng ô.
- Bổ sung `inputFormatters` để chặn ký tự sai ngay lúc gõ.
- Hiển thị banner đỏ nếu backend ném lỗi (như SKU đã tồn tại).

```dart
TextFormField(
  controller: _name,
  decoration: const InputDecoration(
    labelText: 'Tên sản phẩm *',
    border: OutlineInputBorder(),
  ),
  validator: ProductValidators.validateName,
),
const SizedBox(height: 16),
TextFormField(
  controller: _sku,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
  ],
  validator: ProductValidators.validateSku,
),
```

---

## 4. Tối ưu UX và xử lý lỗi theo chuẩn FinTech

Ứng dụng tài chính cần phản hồi rõ ràng, nhất quán và an toàn với thao tác nhạy cảm. Vì vậy mọi feature phải dùng chung các thành phần của `core/` thay vì tự viết lại.

#### Bảng 6. Các quy định UX bắt buộc
| Hạng mục | Quy định | Thành phần dùng chung | Không được làm |
| :--- | :--- | :--- | :--- |
| **Thông báo (Toast)** | Dùng `AppToast.success(context, '...')` hoặc `AppToast.error(context, '...')`. | `core/widgets/app_toast.dart` | Tuyệt đối không dùng `ScaffoldMessenger.showSnackBar` tự phát. |
| **Xác nhận trước khi xóa** | Mọi thao tác xóa phải qua hộp thoại xác nhận dùng chung `showConfirmDialog`. | `core/widgets/confirm_dialog.dart` | Không xóa ngay khi bấm nút. |
| **Tìm kiếm mượt mà** | Luôn tích hợp debounce 400ms trong ô tìm kiếm (`ProductSearchBar`) để tránh gửi request liên tục lên backend. | Search bar của feature | Không gọi API trên từng ký tự gõ. |
| **Màu sắc** | Dùng token chuẩn từ `AppColors`, ví dụ `AppColors.primary`, `AppColors.danger`, `AppColors.darkBackground`. | `AppColors` | Không hard-code mã màu. |
| **Kiểu chữ** | Dùng `AppTextStyles` cho mọi văn bản. | `AppTextStyles` | Không tự gõ `fontSize` / `fontWeight`. |

---

## 5. Quy chuẩn kiểm thử (Unit Testing)

Tất cả validator và mapper của feature đều phải có unit test tương ứng, đặt trong thư mục `test/features/<feature>/`. Vì Domain không phụ thuộc UI hay mạng nên các test này chạy rất nhanh và không cần mock phức tạp.

```dart
// test/features/products/product_validators_test.dart
void main() {
  group('ProductValidators - validateName', () {
    test('trả về lỗi khi để trống', () {
      expect(ProductValidators.validateName(''), 'Vui lòng nhập tên sản phẩm');
    });

    test('hợp lệ khi tên từ 2 đến 200 ký tự', () {
      expect(ProductValidators.validateName('Bàn phím cơ Finora'), isNull);
    });
  });
}
```

#### Bảng 7. Phạm vi cần test
| Thành phần | Cần kiểm tra | Ví dụ test case |
| :--- | :--- | :--- |
| **Validators** | Toàn bộ nhánh trả lỗi và nhánh hợp lệ, đặc biệt các giá trị biên. | Chuỗi rỗng, đúng 2 ký tự, đúng 200 ký tự, 201 ký tự, SKU chứa ký tự đặc biệt. |
| **Mappers** | Chuyển đổi đúng cả hai chiều DTO ↔ Entity. | `price` kiểu int được đổi thành double; category lạ không làm app crash; trường null. |

**Chạy kiểm thử cho một feature:**
```bash
flutter test test/features/<feature_name>/
```

---

## 6. Checklist nghiệm thu feature

Trước khi bàn giao một feature, hãy đối chiếu từng mục trong danh sách dưới đây. Chỉ khi tất cả đều đạt mới tạo Pull Request.

#### Bảng 8. Danh sách nghiệm thu
| # | Hạng mục | Tiêu chí | Đạt |
| :-: | :--- | :--- | :-: |
| **1** | Kiến trúc | Đầy đủ 3 tầng domain, data, presentation và độc lập với nhau. | [ ] |
| **2** | Validation | Có class *Validators riêng; test đầy đủ các trường hợp biên min / max / rỗng. | [ ] |
| **3** | Input UX | Có inputFormatters cho ô số, SKU và mã định danh. | [ ] |
| **4** | Lọc và tìm kiếm | Ô tìm kiếm có debounce để chống spam API. | [ ] |
| **5** | Xóa | Dùng showConfirmDialog và cập nhật state danh sách ngay khi xóa thành công. | [ ] |
| **6** | Thông báo | Toàn bộ phản hồi cho người dùng đều dùng AppToast. | [ ] |
| **7** | Static analysis | Chạy `flutter analyze lib/` đạt 0 issues (0 errors, 0 warnings). | [ ] |

---

## 7. Quy trình làm việc với Git

Để bảo đảm tính toàn vẹn của mã nguồn và an toàn khi làm việc nhóm, mọi thành viên khi phát triển feature mới bắt buộc tuân thủ quy trình dưới đây.

```
[1] Pull develop mới nhất
       │
       v
[2] Tạo nhánh feature/<tên>
       │
       v
[3] Code & commit (Semantic Commits)
       │
       v
[4] flutter analyze & flutter test ────(Chỉ push khi 0 issues)────┐
                                                                 │
                                                                 v
[7] Tech Lead review & Merge <─── [6] Tạo PR vào develop <─── [5] git push -u origin feature/<tên>
   (Lập trình viên KHÔNG tự merge)
```
*Hình 5. Quy trình Git từ lúc nhận feature tới khi được merge.*

---

### 7.1. Quy ước đặt tên nhánh

Mỗi thành viên khi được giao một feature sẽ tạo một nhánh riêng từ nhánh chính (`main` hoặc `develop`) theo định dạng:
`feature/<ten_feature>`

#### Bảng 9. Ví dụ tên nhánh theo feature
| Feature | Tên nhánh | Ghi chú |
| :--- | :--- | :--- |
| Quản lý ngân sách | `feature/budgets` | Budgets |
| Quản lý thu chi / giao dịch | `feature/transactions` | Transactions |
| Quản lý sổ nợ | `feature/debts` | Debts |
| Quản lý đối tác / khách hàng | `feature/customers` | Customers |
| Báo cáo và thống kê | `feature/reports` | Reports |

---

### 7.2. Các bước thực hiện chi tiết

#### Bước 1: Kéo code mới nhất và tạo nhánh tính năng
```bash
# Chuyển về nhánh chính và cập nhật bản mới nhất
git checkout develop
git pull origin develop

# Tạo nhánh mới và chuyển sang nhánh đó
git checkout -b feature/<ten_feature>
# Ví dụ: git checkout -b feature/budgets
```

#### Bước 2: Phát triển và commit theo chuẩn Semantic Commits
Nên commit thường xuyên theo từng giai đoạn hoàn thiện, thay vì dồn tất cả vào một commit khổng lồ.

```bash
git add .
git commit -m "feat(budgets): add domain models, repository interface and validators"

git add .
git commit -m "feat(budgets): implement api service, dtos and mapper"

git add .
git commit -m "feat(budgets): create budget list, detail and form screens"
```

#### Bảng 10. Các loại commit thường dùng
| Loại | Dùng khi | Ví dụ |
| :--- | :--- | :--- |
| **feat** | Thêm tính năng mới. | `feat(budgets): add budget list screen` |
| **fix** | Sửa lỗi. | `fix(budgets): handle empty list state` |
| **refactor** | Tái cấu trúc code, không đổi hành vi. | `refactor(budgets): extract mapper` |
| **test** | Thêm hoặc sửa test. | `test(budgets): add validator tests` |
| **docs** | Cập nhật tài liệu. | `docs(budgets): update readme` |
| **chore** | Công việc phụ trợ (cấu hình, dependency...). | `chore: bump riverpod version` |

> 💡 **MẸO - Trước khi `git add .`:**  
> Chạy `git status` để chắc chắn bạn không vô tình đưa file tạm, file cấu hình cá nhân hay khóa bí mật vào commit.

#### Bước 3: Kiểm tra chất lượng trước khi push
Trước khi đẩy mã nguồn lên máy chủ, chạy kiểm tra tĩnh và test:

```bash
flutter analyze lib/
flutter test test/features/<ten_feature>/
```

> ⚠️ **QUAN TRỌNG:** Chỉ đẩy code khi `flutter analyze` báo **0 issues found**.

#### Bước 4: Đẩy nhánh lên Remote Repository
```bash
git push -u origin feature/<ten_feature>
# Ví dụ: git push -u origin feature/budgets
```

#### Bước 5: Tạo Pull Request (PR)
1. Truy cập giao diện GitHub / GitLab của dự án.
2. Tạo một Pull Request mới với cấu hình nhánh như bảng bên dưới.
3. Điền tiêu đề và nội dung PR rõ ràng.
4. Gán Reviewers là Tech Lead hoặc người được chỉ định review.

#### Bảng 11. Cấu hình nhánh của Pull Request
| Mục | Giá trị | Giải thích |
| :--- | :--- | :--- |
| **Base branch** | `develop` | Nhánh đích, nơi code sẽ được merge vào. |
| **Compare branch** | `feature/<ten_feature>` | Nhánh nguồn, chứa code bạn vừa phát triển. |

**Nội dung PR cần có:**
- Danh sách màn hình và chức năng đã hoàn thành.
- Ảnh chụp màn hình hoặc video demo (nếu có).
- Kết quả pass của `flutter analyze` và `flutter test`.

> ⛔ **QUAN TRỌNG - KHÔNG ĐƯỢC TỰ Ý MERGE:**  
> Lập trình viên tạo feature **TUYỆT ĐỐI KHÔNG ĐƯỢC** bấm nút "Merge Pull Request".  
> Sau khi tạo PR, bạn gửi link PR cho người phụ trách review. Chỉ Tech Lead hoặc Code Reviewer được chỉ định mới có thẩm quyền Approve và Merge vào nhánh chính.

#### Bảng 12. Tiêu chí reviewer kiểm tra trước khi merge
| # | Tiêu chí | Nội dung kiểm tra |
| :-: | :--- | :--- |
| **1** | Kiến trúc | Tuân thủ chuẩn Clean Architecture và cấu trúc thư mục quy định trong tài liệu này. |
| **2** | Xung đột | Không phát sinh xung đột (conflict) với nhánh chính. |
| **3** | UI / UX | Đạt chuẩn UI/UX FinTech: dùng AppColors, AppToast, confirm dialog. |
| **4** | CI/CD | Toàn bộ checks (analyze và test) ở trạng thái xanh (Passed). |