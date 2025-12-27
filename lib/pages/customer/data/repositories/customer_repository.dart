import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/customer_model.dart';

class CustomerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب جميع العملاء
  Future<List<CustomerModel>> getAllCustomers() async {
    final response = await _supabase
        .from('customers')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((customer) => CustomerModel.fromMap(customer))
        .toList();
  }

  // إضافة عميل جديد
  Future<void> addCustomer(CustomerModel customer) async {
    await _supabase.from('customers').insert(customer.toMap());
  }

  // تحديث بيانات عميل
  Future<void> updateCustomer(CustomerModel customer) async {
    await _supabase
        .from('customers')
        .update(customer.toMap())
        .eq('id', customer.id!);
  }

  // حذف عميل
  Future<void> deleteCustomer(String id) async {
    await _supabase.from('customers').delete().eq('id', id);
  }

  // البحث عن عملاء
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final response = await _supabase
        .from('customers')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%');

    return (response as List)
        .map((customer) => CustomerModel.fromMap(customer))
        .toList();
  }
}
