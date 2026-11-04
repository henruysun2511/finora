/// Barrel export file cho feature Categories
/// Tuân thủ quy chuẩn FEATURE_GUIDE.md
library categories;

// Domain Models & Repositories
export 'domain/models/category.dart';
export 'domain/models/category_input.dart';
export 'domain/models/category_type.dart';
export 'domain/repositories/category_repository.dart';
export 'domain/validators/category_validators.dart';

// Presentation Providers & Screens
export 'presentation/providers/category_form_provider.dart';
export 'presentation/providers/category_list_provider.dart';
export 'presentation/providers/category_providers.dart';
export 'presentation/screens/category_list_screen.dart';
export 'presentation/widgets/category_form_sheet.dart';
export 'presentation/widgets/category_type_toggle.dart';

