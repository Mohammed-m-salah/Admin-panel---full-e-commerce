import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/offer_model.dart';
import '../../data/repositories/offer_repository.dart';
import 'offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _repository;

  OfferCubit(this._repository) : super(OfferInitial());

  // جلب جميع العروض
  Future<void> fetchOffers() async {
    emit(OfferLoading());
    try {
      final offers = await _repository.getAllOffers();
      emit(OfferLoaded(offers));
    } catch (e) {
      emit(OfferError('Failed to load offers: $e'));
    }
  }

  // جلب العروض النشطة فقط
  Future<void> fetchActiveOffers() async {
    emit(OfferLoading());
    try {
      final offers = await _repository.getActiveOffers();
      emit(OfferLoaded(offers));
    } catch (e) {
      emit(OfferError('Failed to load active offers: $e'));
    }
  }

  // إضافة عرض جديد
  Future<void> addOffer(OfferModel offer) async {
    try {
      await _repository.addOffer(offer);
      emit(OfferOperationSuccess('Offer added successfully'));
      await fetchOffers();
    } catch (e) {
      emit(OfferError('Failed to add offer: $e'));
    }
  }

  // تحديث عرض
  Future<void> updateOffer(OfferModel offer) async {
    try {
      await _repository.updateOffer(offer);
      emit(OfferOperationSuccess('Offer updated successfully'));
      await fetchOffers();
    } catch (e) {
      emit(OfferError('Failed to update offer: $e'));
    }
  }

  // حذف عرض
  Future<void> deleteOffer(String id) async {
    try {
      await _repository.deleteOffer(id);
      emit(OfferOperationSuccess('Offer deleted successfully'));
      await fetchOffers();
    } catch (e) {
      emit(OfferError('Failed to delete offer: $e'));
    }
  }

  // البحث عن عروض
  Future<void> searchOffers(String query) async {
    emit(OfferLoading());
    try {
      final offers = await _repository.searchOffers(query);
      emit(OfferLoaded(offers));
    } catch (e) {
      emit(OfferError('Failed to search offers: $e'));
    }
  }
}
