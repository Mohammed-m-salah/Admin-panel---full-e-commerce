import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 1. جلب جميع المنتجات
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب المنتجات: $e');
    }
  }

  /// 2. إضافة منتج جديد
  Future<void> addProduct(ProductModel product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
    } catch (e) {
      throw Exception('فشل إضافة المنتج: $e');
    }
  }

  /// 3. تحديث منتج موجود
  Future<void> updateProduct(ProductModel product) async {
    if (product.id == null) throw Exception('المعرف (ID) مطلوب للتحديث');
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id!);
    } catch (e) {
      throw Exception('فشل تحديث المنتج: $e');
    }
  }

  /// 4. حذف منتج
  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف المنتج: $e');
    }
  }

  /// 5. جلب المنتجات حسب التصنيف (فلترة)
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('category', categoryName);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب منتجات التصنيف: $e');
    }
  }
}
