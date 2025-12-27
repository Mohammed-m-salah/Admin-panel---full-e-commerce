import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/offer_model.dart';

class OfferRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب جميع العروض
  Future<List<OfferModel>> getAllOffers() async {
    final response = await _supabase
        .from('offers')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((offer) => OfferModel.fromMap(offer))
        .toList();
  }

  // جلب العروض النشطة فقط
  Future<List<OfferModel>> getActiveOffers() async {
    final now = DateTime.now().toIso8601String();
    final response = await _supabase
        .from('offers')
        .select()
        .eq('status', 'active')
        .lte('start_date', now)
        .gte('end_date', now)
        .order('created_at', ascending: false);

    return (response as List)
        .map((offer) => OfferModel.fromMap(offer))
        .toList();
  }

  // إضافة عرض جديد
  Future<void> addOffer(OfferModel offer) async {
    await _supabase.from('offers').insert(offer.toMap());
  }

  // تحديث عرض
  Future<void> updateOffer(OfferModel offer) async {
    await _supabase.from('offers').update(offer.toMap()).eq('id', offer.id!);
  }

  // حذف عرض
  Future<void> deleteOffer(String id) async {
    await _supabase.from('offers').delete().eq('id', id);
  }

  // البحث عن عروض
  Future<List<OfferModel>> searchOffers(String query) async {
    final response = await _supabase.from('offers').select().or(
        'title.ilike.%$query%,code.ilike.%$query%,description.ilike.%$query%');

    return (response as List)
        .map((offer) => OfferModel.fromMap(offer))
        .toList();
  }

  // جلب عرض بالكود
  Future<OfferModel?> getOfferByCode(String code) async {
    final response =
        await _supabase.from('offers').select().eq('code', code).maybeSingle();

    if (response != null) {
      return OfferModel.fromMap(response);
    }
    return null;
  }

  // زيادة عداد الاستخدام
  Future<void> incrementUsageCount(String id) async {
    await _supabase.rpc('increment_offer_usage', params: {'offer_id': id});
  }

  // تحديث حالة العروض المنتهية
  Future<void> updateExpiredOffers() async {
    final now = DateTime.now().toIso8601String();
    await _supabase
        .from('offers')
        .update({'status': 'expired'})
        .lt('end_date', now)
        .neq('status', 'expired');
  }
}
