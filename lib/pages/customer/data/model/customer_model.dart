class CustomerModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final int? ordersCount;
  final double? totalSpent;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.ordersCount,
    this.totalSpent,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // تحويل من Map (عند الجلب من Supabase)
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      address: map['address'],
      city: map['city'],
      ordersCount: map['orders_count'],
      totalSpent: map['total_spent']?.toDouble(),
      status: map['status'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // تحويل إلى Map (عند الإرسال إلى Supabase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'orders_count': ordersCount,
      'total_spent': totalSpent,
      'status': status,
    };
  }
}
