import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/customer_model.dart';
import '../logic/cubit/customer_cubit.dart';
import '../logic/cubit/customer_state.dart';
import 'widgets/add_customer.dart';
import 'widgets/update_customer.dart';
import 'widgets/delete_customer.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    return customers.where((customer) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = customer.name.toLowerCase();
        final email = customer.email.toLowerCase();
        final phone = (customer.phone ?? '').toLowerCase();

        matchesSearch = name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }

      bool matchesStatus = true;
      if (_statusFilter != 'All') {
        matchesStatus =
            customer.status?.toLowerCase() == _statusFilter.toLowerCase();
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerCubit, CustomerState>(
      // listener: للاستماع وعرض الرسائل
      listener: (context, state) {
        if (state is CustomerOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      // builder: لبناء الـ UI
      builder: (context, state) {
        // استخراج قائمة العملاء من الحالة
        List<CustomerModel> customers = [];
        if (state is CustomerLoaded) {
          customers = state.customers;
        }

        // ═══════════════════════════════════════════════════════════════════
        // تطبيق الفلترة على القائمة
        // ═══════════════════════════════════════════════════════════════════
        final filteredCustomers = _filterCustomers(customers);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              'Customers Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cubit = context.read<CustomerCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: const AddCustomerDialog(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5542F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Search customers by name, email or phone...',
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF6B7280)),
                          // زر مسح البحث
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Color(0xFF6B7280)),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF5542F6), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // فلتر الحالة
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'All',
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: ['All', 'Active', 'Inactive']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // إحصائيات سريعة - تتغير حسب الفلترة
                // ═══════════════════════════════════════════════════════════
                Row(
                  children: [
                    _buildStatCard(
                      'Total Customers',
                      filteredCustomers.length.toString(),
                      Icons.people_outline,
                      const Color(0xFF5542F6),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Active Customers',
                      filteredCustomers
                          .where((c) => c.status?.toLowerCase() == 'active')
                          .length
                          .toString(),
                      Icons.check_circle_outline,
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Total Orders',
                      filteredCustomers
                          .fold<int>(0, (sum, c) => sum + (c.ordersCount ?? 0))
                          .toString(),
                      Icons.shopping_bag_outlined,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Total Revenue',
                      '\$${filteredCustomers.fold<double>(0, (sum, c) => sum + (c.totalSpent ?? 0)).toStringAsFixed(2)}',
                      Icons.attach_money,
                      const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // جدول العملاء
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // رأس الجدول
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              // الصورة الرمزية
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              // الاسم
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Customer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // البريد الإلكتروني
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // الهاتف
                              Expanded(
                                child: Text(
                                  'Phone',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // المدينة
                              Expanded(
                                child: Text(
                                  'City',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // عدد الطلبات
                              Expanded(
                                child: Text(
                                  'Orders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // إجمالي المصروف
                              Expanded(
                                child: Text(
                                  'Total Spent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // الحالة
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              // الإجراءات
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Actions',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),

                        // محتوى الجدول - يتغير حسب الحالة والفلترة
                        Expanded(
                          child: _buildTableContent(state, filteredCustomers),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableContent(
      CustomerState state, List<CustomerModel> customers) {
    if (state is CustomerLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5542F6),
        ),
      );
    }

    if (state is CustomerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CustomerCubit>().fetchCustomers(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // حالة عدم وجود نتائج
    // ─────────────────────────────────────────────────────────────────────────
    if (customers.isEmpty) {
      // التحقق إذا كان بسبب البحث أم لا يوجد عملاء أصلاً
      final bool isFiltering = _searchQuery.isNotEmpty || _statusFilter != 'All';

      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFiltering ? Icons.search_off : Icons.people_outline,
                  size: 48,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  isFiltering
                      ? 'No customers match your search'
                      : 'No customers yet',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
                if (isFiltering) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _statusFilter = 'All';
                      });
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return CustomerRow(
          id: customer.id ?? '',
          name: customer.name,
          email: customer.email,
          phone: customer.phone ?? '',
          city: customer.city ?? '',
          ordersCount: customer.ordersCount ?? 0,
          totalSpent: customer.totalSpent ?? 0.0,
          status: customer.status ?? 'Active',
        );
      },
    );
  }

  // بطاقة الإحصائيات
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// صف العميل في الجدول
class CustomerRow extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final int ordersCount;
  final double totalSpent;
  final String status;

  const CustomerRow({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.ordersCount,
    required this.totalSpent,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // الصورة الرمزية
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5542F6).withOpacity(0.8),
                  const Color(0xFF5542F6),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // الاسم
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // البريد الإلكتروني
          Expanded(
            flex: 2,
            child: Text(
              email,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // الهاتف
          Expanded(
            child: Text(
              phone,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // المدينة
          Expanded(
            child: Text(
              city,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // عدد الطلبات
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  ordersCount.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // إجمالي المصروف
          Expanded(
            child: Text(
              '\$${totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // الحالة
          Expanded(
            child: _buildStatusBadge(status),
          ),

          // الأزرار
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final cubit = context.read<CustomerCubit>();
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: UpdateCustomerDialog(
                          id: id,
                          name: name,
                          email: email,
                          phone: phone,
                          city: city,
                          status: status,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF5542F6),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    final cubit = context.read<CustomerCubit>();
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: cubit,
                        child: DeleteCustomerDialog(
                          id: id,
                          email: email,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFEF4444),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء badge الحالة
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    // استخدام toLowerCase() للمقارنة بدون حساسية لحالة الأحرف
    if (status.toLowerCase() == 'active') {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF059669);
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
