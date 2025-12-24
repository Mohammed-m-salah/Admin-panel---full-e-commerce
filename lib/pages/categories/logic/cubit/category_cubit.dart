import 'package:core_dashboard/pages/categories/data/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/category_model.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  /// 1. دالة جلب جميع التصنيفات
  Future<void> fetchCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// 2. دالة إضافة تصنيف جديد
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repository.addCategory(category);
      emit(CategoryOperationSuccess("تم إضافة التصنيف بنجاح"));
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// 3. دالة حذف تصنيف
  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      emit(CategoryOperationSuccess("تم حذف التصنيف"));
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// 4. دالة تعديل تصنيف (إضافة جديدة)
  Future<void> updateCategory(
      {required String id, required String newName}) async {
    print('🔄 جاري تحديث التصنيف ذو المعرف: $id'); // للتصحيح
    try {
      // استدعاء المستودع لتنفيذ عملية التحديث في قاعدة البيانات
      await _repository.updateCategory(
        CategoryModel(id: id, name: newName),
      );

      print('✅ تم التحديث بنجاح!'); // للتصحيح
      emit(CategoryOperationSuccess("تم تحديث التصنيف بنجاح"));

      // إعادة جلب البيانات لتحديث واجهة المستخدم (الجدول) بالبيانات الجديدة
      await fetchCategories();
    } catch (e) {
      print('❌ خطأ في تحديث التصنيف: $e'); // للتصحيح
      emit(CategoryError("فشل تحديث التصنيف: ${e.toString()}"));
    }
  }
}
