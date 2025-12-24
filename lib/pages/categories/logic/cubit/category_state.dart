import 'package:core_dashboard/pages/categories/data/model/category_model.dart';

abstract class CategoryState {}

// الحالة الابتدائية
class CategoryInitial extends CategoryState {}

// حالة التحميل (عند طلب البيانات من سوبابيز)
class CategoryLoading extends CategoryState {}

// حالة النجاح (عندما تعود القائمة بنجاح)
class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

// حالة الخطأ
class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

// حالة نجاح عملية معينة (مثل الحذف أو الإضافة بنجاح)
class CategoryOperationSuccess extends CategoryState {
  final String message;
  CategoryOperationSuccess(this.message);
}
