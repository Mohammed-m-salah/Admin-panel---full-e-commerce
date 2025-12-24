import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/category_model.dart'; // تأكد من المسار الصحيح للموديل

class CategoryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// 1. جلب جميع التصنيفات
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('created_at', ascending: false); // جلب الأحدث أولاً

      print('✅ Supabase Response: $response'); // للتصحيح
      print('📊 عدد العناصر: ${(response as List).length}'); // للتصحيح

      return (response as List)
          .map((category) => CategoryModel.fromMap(category))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب التصنيفات: $e'); // للتصحيح
      throw Exception('فشل جلب التصنيفات: $e');
    }
  }

  /// 2. إضافة تصنيف جديد
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _client.from('categories').insert(category.toMap());
    } catch (e) {
      throw Exception('فشل إضافة التصنيف: $e');
    }
  }

  /// 3. تحديث تصنيف موجود
  Future<void> updateCategory(CategoryModel category) async {
    if (category.id == null) throw Exception('المعرف (ID) غير موجود للتعديل');

    try {
      await _client
          .from('categories')
          .update(category.toMap())
          .eq('id', category.id!);
    } catch (e) {
      throw Exception('فشل تحديث التصنيف: $e');
    }
  }

  /// 4. حذف تصنيف
  Future<void> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف التصنيف: $e');
    }
  }

  /// 5. جلب التصنيفات كـ Stream (تحديث فوري Real-time)
  /// استخدم هذه الدالة إذا كنت تريد للواجهة أن تتحدث تلقائياً عند أي تغيير في قاعدة البيانات
  Stream<List<CategoryModel>> categoriesStream() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
            (data) => data.map((item) => CategoryModel.fromMap(item)).toList());
  }
}
