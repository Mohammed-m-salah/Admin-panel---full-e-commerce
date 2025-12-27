import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository = CustomerRepository();

  CustomerCubit(CustomerRepository customerRepository)
      : super(CustomerInitial());

  Future<void> fetchCustomers() async {
    emit(CustomerLoading());
    try {
      final customers = await _repository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError('فشل في تحميل العملاء: $e'));
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _repository.addCustomer(customer);
      emit(CustomerOperationSuccess('تم إضافة العميل بنجاح'));
      await fetchCustomers();
    } catch (e) {
      emit(CustomerError('فشل في إضافة العميل: $e'));
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
      emit(CustomerOperationSuccess('تم تحديث العميل بنجاح'));
      await fetchCustomers();
    } catch (e) {
      emit(CustomerError('فشل في تحديث العميل: $e'));
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      emit(CustomerOperationSuccess('تم حذف العميل بنجاح'));
      await fetchCustomers();
    } catch (e) {
      emit(CustomerError('فشل في حذف العميل: $e'));
    }
  }
}
