import 'package:core_dashboard/pages/categories/data/model/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  CategoryOperationSuccess(this.message);
}
