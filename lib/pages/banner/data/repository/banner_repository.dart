import 'dart:typed_data';

import 'package:core_dashboard/pages/banner/data/model/banner_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BannerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب جميع البانرات مرتبة حسب الموضع
  Future<List<BannerModel>> getAllBanners() async {
    final response = await _supabase
        .from('banners')
        .select()
        .order('position', ascending: true);

    return (response as List).map((json) => BannerModel.fromMap(json)).toList();
  }

  // إضافة بانر جديد
  Future<BannerModel> addBanner(BannerModel banner) async {
    final response = await _supabase
        .from('banners')
        .insert(banner.toMap())
        .select()
        .single();

    return BannerModel.fromMap(response);
  }

  // تحديث بانر موجود
  Future<BannerModel> updateBanner(BannerModel banner) async {
    final response = await _supabase
        .from('banners')
        .update(banner.toMap())
        .eq('id', banner.id!)
        .select()
        .single();

    return BannerModel.fromMap(response);
  }

  // حذف بانر
  Future<void> deleteBanner(String bannerId) async {
    await _supabase.from('banners').delete().eq('id', bannerId);
  }

  // تحديث ترتيب البانرات
  Future<void> updateBannerPositions(List<BannerModel> banners) async {
    for (int i = 0; i < banners.length; i++) {
      await _supabase
          .from('banners')
          .update({'position': i + 1})
          .eq('id', banners[i].id!);
    }
  }

  // رفع صورة البانر
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    // اسم الملف فقط (بدون مجلد لأن الـ bucket هو banners)
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // تحديد نوع الملف
    String mimeType = 'image/jpeg';
    if (fileName.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (fileName.toLowerCase().endsWith('.webp')) {
      mimeType = 'image/webp';
    } else if (fileName.toLowerCase().endsWith('.gif')) {
      mimeType = 'image/gif';
    }

    await _supabase.storage.from('banners').uploadBinary(
      path,
      imageBytes,
      fileOptions: FileOptions(contentType: mimeType),
    );

    final imageUrl = _supabase.storage.from('banners').getPublicUrl(path);

    return imageUrl;
  }

  // حذف صورة من التخزين
  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      // البحث عن اسم الملف (آخر جزء من المسار)
      if (pathSegments.isNotEmpty) {
        // اسم الملف هو آخر segment
        final fileName = pathSegments.last;
        await _supabase.storage.from('banners').remove([fileName]);
      }
    } catch (e) {
      // تجاهل أخطاء حذف الصور
    }
  }

  // زيادة عدد المشاهدات
  Future<void> incrementViews(String bannerId) async {
    await _supabase.rpc('increment_banner_views', params: {'banner_id': bannerId});
  }

  // زيادة عدد النقرات
  Future<void> incrementClicks(String bannerId) async {
    await _supabase.rpc('increment_banner_clicks', params: {'banner_id': bannerId});
  }
}
