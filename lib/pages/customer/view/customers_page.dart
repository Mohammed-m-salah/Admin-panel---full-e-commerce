import 'package:flutter/material.dart';
import 'widgets/add_customer.dart';
import 'widgets/update_customer.dart';
import 'widgets/delete_customer.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  // بيانات وهمية للعرض فقط
  final List<Map<String, dynamic>> _dummyCustomers = [
    {
      'id': '1',
      'name': 'Ahmed Mohammed',
      'email': 'ahmed@example.com',
      'phone': '+966 50 123 4567',
      'city': 'Riyadh',
      'orders_count': 15,
      'total_spent': 2500.00,
      'status': 'Active',
    },
    {
      'id': '2',
      'name': 'Sara Ali',
      'email': 'sara@example.com',
      'phone': '+966 55 987 6543',
      'city': 'Jeddah',
      'orders_count': 8,
      'total_spent': 1200.00,
      'status': 'Active',
    },
    {
      'id': '3',
      'name': 'Mohammed Hassan',
      'email': 'moh@example.com',
      'phone': '+966 54 456 7890',
      'city': 'Dammam',
      'orders_count': 3,
      'total_spent': 450.00,
      'status': 'Inactive',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                showDialog(
                  context: context,
                  builder: (context) => const AddCustomerDialog(),
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
            // حقل البحث والفلترة
            Row(
              children: [
                // حقل البحث
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search customers by name or email...',
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF6B7280)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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

            // إحصائيات سريعة
            Row(
              children: [
                _buildStatCard(
                  'Total Customers',
                  '1,234',
                  Icons.people_outline,
                  const Color(0xFF5542F6),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active Customers',
                  '1,180',
                  Icons.check_circle_outline,
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'New This Month',
                  '56',
                  Icons.person_add_outlined,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Total Revenue',
                  '\$45,230',
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

                    // محتوى الجدول
                    Expanded(
                      child: ListView.builder(
                        itemCount: _dummyCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _dummyCustomers[index];
                          return CustomerRow(
                            id: customer['id'],
                            name: customer['name'],
                            email: customer['email'],
                            phone: customer['phone'],
                            city: customer['city'],
                            ordersCount: customer['orders_count'],
                            totalSpent: customer['total_spent'],
                            status: customer['status'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                    showDialog(
                      context: context,
                      builder: (context) => UpdateCustomerDialog(
                        id: id,
                        name: name,
                        email: email,
                        phone: phone,
                        city: city,
                        status: status,
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF5542F6),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteCustomerDialog(
                        id: id,
                        name: name,
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

    if (status == 'Active') {
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
