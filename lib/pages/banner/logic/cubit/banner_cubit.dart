// lib/pages/banner/logic/cubit/banner_cubit.dart

import 'dart:typed_data';

import 'package:core_dashboard/pages/banner/data/repository/banner_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/banner_model.dart';
import 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerRepository _repository;

  List<BannerModel> _banners = [];
  List<BannerModel> get banners => _banners;

  BannerCubit(this._repository) : super(BannerInitial());

  // تحميل جميع البانرات
  Future<void> loadBanners() async {
    emit(BannerLoading());

    try {
      _banners = await _repository.getAllBanners();
      emit(BannerLoaded(_banners));
    } catch (e) {
      emit(BannerError('فشل في تحميل البانرات: $e'));
    }
  }

  // رفع صورة البانر
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    emit(BannerImageUploading());

    try {
      final imageUrl = await _repository.uploadImage(imageBytes, fileName);
      emit(BannerImageUploaded(imageUrl));
      return imageUrl;
    } catch (e) {
      emit(BannerError('فشل في رفع الصورة: $e'));
      return null;
    }
  }

  // إضافة بانر جديد
  Future<void> addBanner({
    required String title,
    String? description,
    required String imageUrl,
    required String linkType,
    String? linkId,
    String? externalUrl,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(BannerAdding());

    try {
      // تحديد الترتيب (آخر موضع + 1)
      final newPosition = _banners.isEmpty
          ? 1
          : _banners.map((b) => b.position).reduce((a, b) => a > b ? a : b) + 1;

      // إنشاء نموذج البانر
      final banner = BannerModel(
        title: title,
        description: description,
        imageUrl: imageUrl,
        linkType: linkType,
        linkId: linkId,
        position: newPosition,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      // إضافة للـ Supabase
      final addedBanner = await _repository.addBanner(banner);

      // تحديث القائمة المحلية
      _banners.add(addedBanner);

      // إرسال حالة النجاح
      emit(BannerAdded(addedBanner));
      emit(BannerLoaded(_banners));
    } catch (e) {
      emit(BannerError('فشل في إضافة البانر: $e'));
    }
  }

  // تحديث بانر موجود
  Future<void> updateBanner({
    required String id,
    required String title,
    String? description,
    required String imageUrl,
    required String linkType,
    String? linkId,
    String? externalUrl,
    required String status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(BannerUpdating());

    try {
      // البحث عن البانر الحالي للحفاظ على الموضع
      final currentBanner = _banners.firstWhere((b) => b.id == id);

      // إنشاء نموذج البانر المحدث
      final banner = BannerModel(
        id: id,
        title: title,
        description: description,
        imageUrl: imageUrl,
        linkType: linkType,
        linkId: linkId,
        position: currentBanner.position,
        status: status,
        startDate: startDate,
        endDate: endDate,
        views: currentBanner.views,
        clicks: currentBanner.clicks,
      );

      // تحديث في Supabase
      final updatedBanner = await _repository.updateBanner(banner);

      // تحديث القائمة المحلية
      final index = _banners.indexWhere((b) => b.id == id);
      if (index != -1) {
        _banners[index] = updatedBanner;
      }

      // إرسال حالة النجاح
      emit(BannerUpdated(updatedBanner));
      emit(BannerLoaded(_banners));
    } catch (e) {
      emit(BannerError('فشل في تحديث البانر: $e'));
    }
  }

  // حذف بانر
  Future<void> deleteBanner(String bannerId) async {
    emit(BannerDeleting());

    try {
      // البحث عن البانر للحصول على رابط الصورة
      final banner = _banners.firstWhere((b) => b.id == bannerId);

      // حذف الصورة من التخزين
      await _repository.deleteImage(banner.imageUrl);

      // حذف من Supabase
      await _repository.deleteBanner(bannerId);

      // تحديث القائمة المحلية
      _banners.removeWhere((b) => b.id == bannerId);

      // إرسال حالة النجاح
      emit(BannerDeleted(bannerId));
      emit(BannerLoaded(_banners));
    } catch (e) {
      emit(BannerError('فشل في حذف البانر: $e'));
    }
  }

  // تحديث ترتيب البانرات (السحب والإفلات)
  Future<void> reorderBanners(int oldIndex, int newIndex) async {
    try {
      // تحديث القائمة المحلية أولاً
      final banner = _banners.removeAt(oldIndex);
      _banners.insert(newIndex, banner);

      // تحديث الترتيب محلياً
      for (int i = 0; i < _banners.length; i++) {
        _banners[i] = _banners[i].copyWith(position: i + 1);
      }

      emit(BannerLoaded(_banners));

      // تحديث في Supabase
      await _repository.updateBannerPositions(_banners);
    } catch (e) {
      emit(BannerError('فشل في تحديث الترتيب: $e'));
      // إعادة تحميل البانرات في حالة الفشل
      await loadBanners();
    }
  }

  // تبديل حالة البانر (نشط/غير نشط)
  Future<void> toggleBannerStatus(String bannerId) async {
    try {
      final index = _banners.indexWhere((b) => b.id == bannerId);
      if (index == -1) return;

      final banner = _banners[index];
      final newStatus = banner.status == 'active' ? 'inactive' : 'active';

      final updatedBanner = banner.copyWith(status: newStatus);
      final result = await _repository.updateBanner(updatedBanner);

      _banners[index] = result;
      emit(BannerLoaded(_banners));
    } catch (e) {
      emit(BannerError('فشل في تغيير حالة البانر: $e'));
    }
  }
}
