import 'package:core_dashboard/pages/products/data/model/product_model.dart';
import 'package:core_dashboard/pages/products/data/repositories/product_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      // لا نحتاج لتحويل الحالة لـ Loading هنا إذا كنت تريد بقاء القائمة ظاهرة
      await _repository.addProduct(product);
      emit(const ProductOperationSuccess("تم إضافة المنتج بنجاح"));
      await fetchProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      emit(const ProductOperationSuccess("تم تحديث المنتج بنجاح"));
      await fetchProducts(); // تحديث القائمة بعد التعديل
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      emit(const ProductOperationSuccess("تم حذف المنتج بنجاح"));
      await fetchProducts(); // تحديث القائمة بعد الحذف
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> filterByCategory(String categoryName) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getProductsByCategory(categoryName);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
