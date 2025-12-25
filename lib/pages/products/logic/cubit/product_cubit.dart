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
      await _repository.addProduct(product);
      emit(const ProductOperationSuccess("تم إضافة المنتج بنجاح"));
      // انتظار قليل ثم تحديث القائمة
      await Future.delayed(const Duration(milliseconds: 100));
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      emit(const ProductOperationSuccess("تم تحديث المنتج بنجاح"));
      // انتظار قليل ثم تحديث القائمة
      await Future.delayed(const Duration(milliseconds: 100));
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      emit(const ProductOperationSuccess("تم حذف المنتج بنجاح"));
      // انتظار قليل ثم تحديث القائمة
      await Future.delayed(const Duration(milliseconds: 100));
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
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
