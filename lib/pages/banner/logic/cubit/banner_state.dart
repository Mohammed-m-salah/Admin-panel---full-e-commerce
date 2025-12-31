import 'package:core_dashboard/pages/banner/data/model/banner_model.dart';

abstract class BannerState {}

// الحالة الأولية
class BannerInitial extends BannerState {}

// جاري التحميل
class BannerLoading extends BannerState {}

// تم التحميل بنجاح
class BannerLoaded extends BannerState {
  final List<BannerModel> banners;
  BannerLoaded(this.banners);
}

// جاري إضافة بانر
class BannerAdding extends BannerState {}

// تمت الإضافة بنجاح
class BannerAdded extends BannerState {
  final BannerModel banner;
  BannerAdded(this.banner);
}

// جاري تحديث بانر
class BannerUpdating extends BannerState {}

// تم التحديث بنجاح
class BannerUpdated extends BannerState {
  final BannerModel banner;
  BannerUpdated(this.banner);
}

// جاري حذف بانر
class BannerDeleting extends BannerState {}

// تم الحذف بنجاح
class BannerDeleted extends BannerState {
  final String bannerId;
  BannerDeleted(this.bannerId);
}

// جاري رفع صورة
class BannerImageUploading extends BannerState {}

// تم رفع الصورة بنجاح
class BannerImageUploaded extends BannerState {
  final String imageUrl;
  BannerImageUploaded(this.imageUrl);
}

// حدث خطأ
class BannerError extends BannerState {
  final String message;
  BannerError(this.message);
}
