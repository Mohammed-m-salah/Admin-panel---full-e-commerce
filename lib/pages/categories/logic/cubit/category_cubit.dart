import 'package:core_dashboard/pages/categories/data/repositories/category_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/category_model.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  Future<void> fetchCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repository.addCategory(category);
      emit(CategoryOperationSuccess("تم إضافة التصنيف بنجاح"));
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      emit(CategoryOperationSuccess("تم حذف التصنيف"));
      await fetchCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(
      {required String id, required String newName}) async {
    print('🔄 جاري تحديث التصنيف ذو المعرف: $id'); // للتصحيح
    try {
      await _repository.updateCategory(
        CategoryModel(id: id, name: newName),
      );

      print('✅ تم التحديث بنجاح!'); // للتصحيح
      emit(CategoryOperationSuccess("تم تحديث التصنيف بنجاح"));

      await fetchCategories();
    } catch (e) {
      print('❌ خطأ في تحديث التصنيف: $e'); // للتصحيح
      emit(CategoryError("فشل تحديث التصنيف: ${e.toString()}"));
    }
  }
}
